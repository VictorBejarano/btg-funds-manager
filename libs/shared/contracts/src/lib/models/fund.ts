/**
 * Esquema para la validación de fondos de inversión de BTG Pactual
 */
export interface Fund {
    /**
     * Categoría o tipo de activo del fondo
     */
    category: Category;
    /**
     * Fecha de creación del registro en formato ISO 8601
     */
    createdAt: Date;
    /**
     * Identificador único del fondo (ej: fund_001 o ID de Firestore)
     */
    id: string;
    /**
     * Monto mínimo de inversión en COP
     */
    minInvestment: number;
    /**
     * Nombre comercial del fondo
     */
    name: string;
    /**
     * Estado actual de disponibilidad del fondo
     */
    status: Status;
    /**
     * Rendimiento anual esperado en porcentaje (%)
     */
    targetApy: number;
}

/**
 * Categoría o tipo de activo del fondo
 */
export enum Category {
    Fic = "FIC",
    Fpv = "FPV",
}

/**
 * Estado actual de disponibilidad del fondo
 */
export enum Status {
    Active = "ACTIVE",
    Closed = "CLOSED",
}
