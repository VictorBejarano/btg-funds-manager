export interface User {
    /**
     * Saldo disponible
     */
    availableBalance: number;
    email:            string;
    /**
     * UID único del usuario
     */
    id:                   string;
    identificationNumber: string;
    identificationType:   UserIdentificationType;
    lastname:             string;
    name:                 string;
    notificationMethod?:  UserNotificationMethod;
    phone?:               string;
}

/**
 * Tipo de documento de identidad
 */
export enum UserIdentificationType {
    Cc = "CC",
    Ce = "CE",
    Nit = "NIT",
    Pp = "PP",
}

/**
 * Método preferido de notificación
 */
export enum UserNotificationMethod {
    Email = "EMAIL",
    SMS = "SMS",
}
