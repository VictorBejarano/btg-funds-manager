// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    
    ///ISO String de la fecha de creación
    DateTime? createdAt;
    String? displayName;
    String email;
    
    ///El UID proveniente de Firebase Auth
    String id;
    String? photoUrl;
    Role role;

    User({
        this.createdAt,
        this.displayName,
        required this.email,
        required this.id,
        this.photoUrl,
        required this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        displayName: json["displayName"],
        email: json["email"],
        id: json["id"],
        photoUrl: json["photoURL"],
        role: roleValues.map[json["role"]]!,
    );

    Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toIso8601String(),
        "displayName": displayName,
        "email": email,
        "id": id,
        "photoURL": photoUrl,
        "role": roleValues.reverse[role],
    };
}

enum Role {
    ADMIN,
    GUEST,
    USER
}

final roleValues = EnumValues({
    "ADMIN": Role.ADMIN,
    "GUEST": Role.GUEST,
    "USER": Role.USER
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
