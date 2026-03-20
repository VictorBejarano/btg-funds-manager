// To parse this JSON data, do
//
//     final subscription = subscriptionFromJson(jsonString);

import 'dart:convert';

Subscription subscriptionFromJson(String str) => Subscription.fromJson(json.decode(str));

String subscriptionToJson(Subscription data) => json.encode(data.toJson());

class Subscription {
    
    ///Monto invertido por el usuario.
    int amount;
    
    ///Fecha de creación en formato ISO 8601 (convertida desde Firestore Timestamp).
    DateTime createdAt;
    
    ///ID único del documento del fondo.
    String fundId;
    
    ///Inversión mínima requerida capturada al momento de la suscripción.
    int fundMinInvestment;
    
    ///Nombre del fondo para trazabilidad histórica.
    String fundName;
    
    ///Identificador único de la subscripcion
    String id;
    
    ///UID del usuario obtenido de Firebase Auth.
    String userId;

    Subscription({
        required this.amount,
        required this.createdAt,
        required this.fundId,
        required this.fundMinInvestment,
        required this.fundName,
        required this.id,
        required this.userId,
    });

    factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        amount: json["amount"],
        createdAt: DateTime.parse(json["createdAt"]),
        fundId: json["fundId"],
        fundMinInvestment: json["fundMinInvestment"],
        fundName: json["fundName"],
        id: json["id"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "amount": amount,
        "createdAt": createdAt.toIso8601String(),
        "fundId": fundId,
        "fundMinInvestment": fundMinInvestment,
        "fundName": fundName,
        "id": id,
        "userId": userId,
    };
}
