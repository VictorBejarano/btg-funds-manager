export interface Transaction {
    amount:             number;
    createdAt:          Date;
    finalBalance?:      number;
    fundId:             string;
    fundMinInvestment?: number;
    fundName:           string;
    metadata:           Metadata;
    previousBalance?:   number;
    status:             TransactionStatus;
    type:               TransactionType;
    userId:             string;
}

export interface Metadata {
    device:    string;
    ip:        string;
    userAgent: string;
}

export enum TransactionStatus {
    Completed = "completed",
    Failed = "failed",
}

export enum TransactionType {
    Subscribe = "subscribe",
    Unsubscribe = "unsubscribe",
}
