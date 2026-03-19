import { setGlobalOptions } from 'firebase-functions';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

setGlobalOptions({ maxInstances: 10 });

initializeApp();
const db = getFirestore();

export const getfunds = onCall(async (request) => {
  try {
    const snapshot = await db.collection('funds').get();
    const fundsList = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt ? data.createdAt.toDate().toISOString() : null,
      };
    });
    return fundsList;
  } catch (error) {
    logger.error('Error fetching funds:', error);
    throw new HttpsError('internal', 'No se pudo obtener el listado de fondos.');
  }
});
