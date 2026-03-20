import { setGlobalOptions } from 'firebase-functions';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { Fund, FundSubscriptionData, Subscription, Transaction, User } from '@btg-funds-manager/contracts';

setGlobalOptions({ maxInstances: 10 });

initializeApp();
const db = getFirestore();

export const getfunds = onCall<{ userId?: string }>(async (request) => {
  try {
    const { userId } = request.data || {};

    const snapshot = await db
      .collection('funds')
      .where('status', '==', 'ACTIVE')
      .orderBy('createdAt', 'desc')
      .get();

    let fundsList = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt
          ? data.createdAt.toDate().toISOString()
          : null,
      } as Fund;
    });

    if (userId) {
      const subsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .get();

      const subscribedFundIds = subsSnapshot.docs.map(doc => doc.data().fundId);

      if (subscribedFundIds.length > 0) {
        fundsList = fundsList.filter(fund => !subscribedFundIds.includes(fund.id));
      }
    }

    return fundsList;
  } catch (error) {
    logger.error('Error fetching funds:', error);
    throw new HttpsError(
      'internal',
      'No se pudo obtener el listado de fondos.',
    );
  }
});


export const subscribefund = onCall<FundSubscriptionData>(async (request) => {
  const data = request.data;
  const userId = data.userId;
  const fundId = data.fundId;
  const amount = Number(data.amount);

  if (!userId || !fundId || isNaN(amount)) {
    throw new HttpsError(
      'invalid-argument',
      'Los campos userId, fundId y amount son obligatorios.',
    );
  }

  const userRef = db.collection('users').doc(userId);
  const fundRef = db.collection('funds').doc(fundId);
  const transactionRef = db.collection('transactions').doc();
  const subscriptionRef = userRef.collection('subscriptions').doc();

  // Parsing metadata request info
  const userAgent = (request.rawRequest?.headers['user-agent'] as string) || '';
  let device = 'web';
  if (userAgent.toLowerCase().includes('android')) device = 'android';
  else if (
    userAgent.toLowerCase().includes('iphone') ||
    userAgent.toLowerCase().includes('ipad')
  )
    device = 'ios';

  const ip =
    request.rawRequest?.ip ||
    request.rawRequest?.headers['x-forwarded-for'] ||
    'unknown';

  let txLogData: any = null;
  let validationError: string | null = null;

  try {
    await db.runTransaction(async (t) => {
      const userDoc = await t.get(userRef);
      const fundDoc = await t.get(fundRef);

      if (!userDoc.exists) {
        throw new Error('El usuario no existe.');
      }
      if (!fundDoc.exists) {
        throw new Error('El fondo especificado no existe.');
      }

      const userData = userDoc.data();
      const fundData = fundDoc.data();

      const availableBalance = userData?.availableBalance || 0;
      const minInvestment = fundData?.minInvestment || 0;
      const fundName = fundData?.name || 'Fondo Desconocido';

      // Estructuramos el payload de la transacción en histórico asumiendo fallo temporalmente
      txLogData = {
        fundId,
        userId,
        userRef,
        fundRef,
        subscriptionRef,
        fundName,
        fundMinInvestment: minInvestment,
        previousBalance: availableBalance,
        amount,
        type: 'subscribe',
        finalBalance: availableBalance, // Inicialmente el mismo saldo sin descontar
        status: 'failed',
        metadata: {
          device,
          ip,
          userAgent,
        },
        createdAt: FieldValue.serverTimestamp(),
      };

      // Reglas de negocio
      if (amount < minInvestment) {
        throw new Error(`El monto mínimo de inversión es de ${minInvestment}.`);
      }

      if (availableBalance < amount) {
        throw new Error(
          'No tienes suficiente saldo para esta suscripción.',
        );
      }

      // Proceso Exitoso
      const finalBalance = availableBalance - amount;
      txLogData.finalBalance = finalBalance;
      txLogData.status = 'completed';

      // Se aplican las mutaciones a la base de datos atómicamente
      t.update(userRef, { availableBalance: finalBalance });
      t.set(subscriptionRef, {
        fundId,
        userId,
        userRef,
        fundRef,
        amount,
        fundMinInvestment: minInvestment,
        fundName,
        createdAt: FieldValue.serverTimestamp(),
      });
      t.set(transactionRef, txLogData);
    });
  } catch (error: any) {
    validationError = error.message;
  }

  // Manejo de errores controlados
  if (validationError && txLogData && txLogData.status === 'failed') {
    // Si falló la validación del saldo/monto, guardamos el log fallido externamente del transaction() truncado.
    await transactionRef.set(txLogData);
    logger.error('Subscription logic validation failed:', validationError);
    throw new HttpsError('failed-precondition', validationError);
  } else if (!txLogData && validationError) {
    // Fallos por existencia de base de datos antes del armado del Log.
    throw new HttpsError('not-found', validationError);
  } else if (validationError) {
    // Fallas de red general
    logger.error('Unexpected Subscription Error:', validationError);
    throw new HttpsError('internal', 'Error inesperado interno.');
  }

  return { success: true, message: '¡Te has suscrito exitosamente al fondo!' };
});

export const unsubscribefund = onCall<{ userId: string; subscriptionId: string }>(
  async (request) => {
    const { userId, subscriptionId } = request.data;

    if (!userId || !subscriptionId) {
      throw new HttpsError(
        'invalid-argument',
        'Los campos userId y subscriptionId son obligatorios.',
      );
    }

    const userRef = db.collection('users').doc(userId);
    const subscriptionRef = userRef.collection('subscriptions').doc(subscriptionId);
    const transactionRef = db.collection('transactions').doc();

    const userAgent = (request.rawRequest?.headers['user-agent'] as string) || '';
    let device = 'web';
    if (userAgent.toLowerCase().includes('android')) device = 'android';
    else if (
      userAgent.toLowerCase().includes('iphone') ||
      userAgent.toLowerCase().includes('ipad')
    )
      device = 'ios';

    const ip =
      request.rawRequest?.ip ||
      request.rawRequest?.headers['x-forwarded-for'] ||
      'unknown';

    let txLogData: any = null;
    let validationError: string | null = null;

    try {
      await db.runTransaction(async (t) => {
        const userDoc = await t.get(userRef);
        const subDoc = await t.get(subscriptionRef);

        if (!userDoc.exists) {
          throw new Error('El usuario no existe.');
        }
        if (!subDoc.exists) {
          throw new Error('La suscripción especificada no existe.');
        }

        const userData = userDoc.data();
        const subData = subDoc.data();

        const amount = subData?.amount || 0;
        const currentBalance = userData?.availableBalance || 0;
        const finalBalance = currentBalance + amount;

        txLogData = {
          fundId: subData?.fundId,
          userId,
          userRef,
          fundRef: subData?.fundRef,
          subscriptionRef,
          fundName: subData?.fundName,
          fundMinInvestment: subData?.fundMinInvestment,
          previousBalance: currentBalance,
          amount,
          type: 'unsubscribe',
          finalBalance,
          status: 'completed',
          metadata: {
            device,
            ip,
            userAgent,
          },
          createdAt: FieldValue.serverTimestamp(),
        };

        // Mutaciones
        t.update(userRef, { availableBalance: finalBalance });
        t.delete(subscriptionRef);
        t.set(transactionRef, txLogData);
      });
    } catch (error: any) {
      validationError = error.message;
    }

    if (validationError) {
      logger.error('Unsubscribe error:', validationError);
      throw new HttpsError('internal', validationError);
    }

    return {
      success: true,
      message: 'Suscripción cancelada y saldo devuelto con éxito.',
    };
  },
);


export const getusersubscriptions = onCall<{ userId: string }>(async (request) => {
  const { userId } = request.data;

  if (!userId) {
    throw new HttpsError(
      'invalid-argument',
      'El campo userId es obligatorio para obtener las suscripciones.',
    );
  }

  try {
    const snapshot = await db
      .collection('users')
      .doc(userId)
      .collection('subscriptions')
      .orderBy('createdAt', 'desc')
      .get();

    const subscriptions = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        amount: data.amount,
        createdAt: data.createdAt ? data.createdAt.toDate().toISOString() : null,
        fundId: data.fundId,
        fundMinInvestment: data.fundMinInvestment,
        fundName: data.fundName,
        userId: data.userId,
      } as Subscription;
    });

    return subscriptions;
  } catch (error) {
    logger.error('Error fetching user subscriptions:', error);
    throw new HttpsError(
      'internal',
      'No se pudo obtener el listado de suscripciones del usuario.',
    );
  }
});

export const getusertransactions = onCall<{ userId: string }>(async (request) => {
  const { userId } = request.data;

  if (!userId) {
    throw new HttpsError(
      'invalid-argument',
      'El campo userId es obligatorio para obtener las transacciones.',
    );
  }

  try {
    const snapshot = await db
      .collection('transactions')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => {
      const data = doc.data();
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { userRef, fundRef, subscriptionRef, ...rest } = data;
      return {
        id: doc.id,
        ...rest,
        createdAt: data.createdAt ? data.createdAt.toDate().toISOString() : null,
      } as unknown as Transaction;
    });


  } catch (error) {
    logger.error('Error fetching user transactions:', error);
    throw new HttpsError(
      'internal',
      'No se pudo obtener el historial de transacciones.',
    );
  }
});

export const getuserdata = onCall<{ userId: string }>(async (request) => {
  const { userId } = request.data;
  if (!userId) {
    throw new HttpsError('invalid-argument', 'El ID del usuario es requerido.');
  }

  try {
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new HttpsError('not-found', 'El usuario no existe.');
    }

    const data = userDoc.data();
    return {
      id: userDoc.id,
      ...data,
    } as unknown as User;
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    logger.error('Error al obtener usuario:', error);
    throw new HttpsError('internal', 'Error al obtener los datos del usuario.');
  }
});

export const updateuserdata = onCall<{ userId: string; userData: Partial<User> }>(
  async (request) => {
    const { userId, userData } = request.data;
    if (!userId || !userData) {
      throw new HttpsError('invalid-argument', 'El ID y los datos son requeridos.');
    }

    try {
      const userRef = db.collection('users').doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw new HttpsError('not-found', 'El usuario no existe.');
      }

      // No permitimos actualizar el ID por esta vía, pero para propósitos de prueba el saldo sí se puede editar
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { id, ...cleanData } = userData as any;

      await userRef.update({
        ...cleanData,
        updatedAt: FieldValue.serverTimestamp(),
      });

      return { success: true, message: 'Usuario actualizado correctamente.' };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      logger.error('Error al actualizar usuario:', error);
      throw new HttpsError('internal', 'Error al actualizar los datos del usuario.');
    }
  }
);



