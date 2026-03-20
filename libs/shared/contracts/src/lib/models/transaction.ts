export interface Transaction {
    amount:             number;
    createdAt:          Date;
    finalBalance?:      number;
    fundId:             string;
    fundMinInvestment?: number;
    fundName:           string;
    previousBalance?:   number;
    status:             TransactionStatus;
    type:               TransactionType;
    userId:             string;
}

export enum TransactionStatus {
    Completed = "completed",
    Failed = "failed",
}

export enum TransactionType {
    Subscribe = "subscribe",
    Unsubscribe = "unsubscribe",
}
