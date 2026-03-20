// To parse this JSON data, do
//
//     final fundSubscriptionData = fundSubscriptionDataFromJson(jsonString);

import 'dart:convert';

FundSubscriptionData fundSubscriptionDataFromJson(String str) => FundSubscriptionData.fromJson(json.decode(str));

String fundSubscriptionDataToJson(FundSubscriptionData data) => json.encode(data.toJson());

class FundSubscriptionData {
    
    ///El monto de la transacción
    double amount;
    
    ///El identificador único del fondo
    String fundId;
    
    ///El identificador único del usuario (UID)
    String userId;

    FundSubscriptionData({
        required this.amount,
        required this.fundId,
        required this.userId,
    });

    factory FundSubscriptionData.fromJson(Map<String, dynamic> json) => FundSubscriptionData(
        amount: json["amount"]?.toDouble(),
        fundId: json["fundId"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "amount": amount,
        "fundId": fundId,
        "userId": userId,
    };
}
