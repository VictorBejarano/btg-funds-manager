export interface User {
    /**
     * ISO String de la fecha de creación
     */
    createdAt?:   Date;
    displayName?: string;
    email:        string;
    /**
     * El UID proveniente de Firebase Auth
     */
    id:        string;
    photoURL?: null | string;
    role:      Role;
    [property: string]: any;
}

export enum Role {
    Admin = "ADMIN",
    Guest = "GUEST",
    User = "USER",
}
