import { setGlobalOptions } from 'firebase-functions';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { Fund, FundSubscriptionData } from '@btg-funds-manager/contracts';

setGlobalOptions({ maxInstances: 10 });

initializeApp();
const db = getFirestore();

export const getfunds = onCall(async (request) => {
  try {
    const snapshot = await db
      .collection('funds')
      .where('status', '==', 'ACTIVE')
      .orderBy('createdAt', 'desc')
      .get();
    const fundsList = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt
          ? data.createdAt.toDate().toISOString()
          : null,
      } as Fund;
    });
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
          'No tienes suficiente saldo (availableBalance) para esta suscripción.',
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
