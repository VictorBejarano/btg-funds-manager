export interface Subscription {
    /**
     * Monto invertido por el usuario.
     */
    amount: number;
    /**
     * Fecha de creación en formato ISO 8601 (convertida desde Firestore Timestamp).
     */
    createdAt: Date;
    /**
     * ID único del documento del fondo.
     */
    fundId: string;
    /**
     * Inversión mínima requerida capturada al momento de la suscripción.
     */
    fundMinInvestment: number;
    /**
     * Nombre del fondo para trazabilidad histórica.
     */
    fundName: string;
    /**
     * UID del usuario obtenido de Firebase Auth.
     */
    userId: string;
}
