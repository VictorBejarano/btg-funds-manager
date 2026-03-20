// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    
    ///Saldo disponible
    double availableBalance;
    String email;
    
    ///UID único del usuario
    String id;
    String identificationNumber;
    UserIdentificationType identificationType;
    String lastname;
    String name;
    UserNotificationMethod? notificationMethod;
    String? phone;

    User({
        required this.availableBalance,
        required this.email,
        required this.id,
        required this.identificationNumber,
        required this.identificationType,
        required this.lastname,
        required this.name,
        this.notificationMethod,
        this.phone,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        availableBalance: json["availableBalance"]?.toDouble(),
        email: json["email"],
        id: json["id"],
        identificationNumber: json["identificationNumber"],
        identificationType: userIdentificationTypeValues.map[json["identificationType"]]!,
        lastname: json["lastname"],
        name: json["name"],
        notificationMethod: userNotificationMethodValues.map[json["notificationMethod"]]!,
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "availableBalance": availableBalance,
        "email": email,
        "id": id,
        "identificationNumber": identificationNumber,
        "identificationType": userIdentificationTypeValues.reverse[identificationType],
        "lastname": lastname,
        "name": name,
        "notificationMethod": userNotificationMethodValues.reverse[notificationMethod],
        "phone": phone,
    };
}


///Tipo de documento de identidad
enum UserIdentificationType {
    CC,
    CE,
    NIT,
    PP
}

final userIdentificationTypeValues = EnumValues({
    "CC": UserIdentificationType.CC,
    "CE": UserIdentificationType.CE,
    "NIT": UserIdentificationType.NIT,
    "PP": UserIdentificationType.PP
});


///Método preferido de notificación
enum UserNotificationMethod {
    EMAIL,
    SMS
}

final userNotificationMethodValues = EnumValues({
    "EMAIL": UserNotificationMethod.EMAIL,
    "SMS": UserNotificationMethod.SMS
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
