// To parse this JSON data, do
//
//     final transaction = transactionFromJson(jsonString);

import 'dart:convert';

Transaction transactionFromJson(String str) => Transaction.fromJson(json.decode(str));

String transactionToJson(Transaction data) => json.encode(data.toJson());

class Transaction {
    int amount;
    DateTime createdAt;
    int? finalBalance;
    String fundId;
    int? fundMinInvestment;
    String fundName;
    Metadata metadata;
    int? previousBalance;
    TransactionStatus status;
    TransactionType type;
    String userId;

    Transaction({
        required this.amount,
        required this.createdAt,
        this.finalBalance,
        required this.fundId,
        this.fundMinInvestment,
        required this.fundName,
        required this.metadata,
        this.previousBalance,
        required this.status,
        required this.type,
        required this.userId,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        amount: json["amount"],
        createdAt: DateTime.parse(json["createdAt"]),
        finalBalance: json["finalBalance"],
        fundId: json["fundId"],
        fundMinInvestment: json["fundMinInvestment"],
        fundName: json["fundName"],
        metadata: Metadata.fromJson(json["metadata"]),
        previousBalance: json["previousBalance"],
        status: transactionStatusValues.map[json["status"]]!,
        type: transactionTypeValues.map[json["type"]]!,
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "amount": amount,
        "createdAt": createdAt.toIso8601String(),
        "finalBalance": finalBalance,
        "fundId": fundId,
        "fundMinInvestment": fundMinInvestment,
        "fundName": fundName,
        "metadata": metadata.toJson(),
        "previousBalance": previousBalance,
        "status": transactionStatusValues.reverse[status],
        "type": transactionTypeValues.reverse[type],
        "userId": userId,
    };
}

class Metadata {
    String device;
    String ip;
    String userAgent;

    Metadata({
        required this.device,
        required this.ip,
        required this.userAgent,
    });

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        device: json["device"],
        ip: json["ip"],
        userAgent: json["userAgent"],
    );

    Map<String, dynamic> toJson() => {
        "device": device,
        "ip": ip,
        "userAgent": userAgent,
    };
}

enum TransactionStatus {
    COMPLETED,
    FAILED
}

final transactionStatusValues = EnumValues({
    "completed": TransactionStatus.COMPLETED,
    "failed": TransactionStatus.FAILED
});

enum TransactionType {
    SUBSCRIBE,
    UNSUBSCRIBE
}

final transactionTypeValues = EnumValues({
    "subscribe": TransactionType.SUBSCRIBE,
    "unsubscribe": TransactionType.UNSUBSCRIBE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
