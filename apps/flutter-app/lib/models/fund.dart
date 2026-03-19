// To parse this JSON data, do
//
//     final fund = fundFromJson(jsonString);

import 'dart:convert';

Fund fundFromJson(String str) => Fund.fromJson(json.decode(str));

String fundToJson(Fund data) => json.encode(data.toJson());


///Esquema para la validación de fondos de inversión de BTG Pactual
class Fund {
    
    ///Categoría o tipo de activo del fondo
    Category category;
    
    ///Fecha de creación del registro en formato ISO 8601
    DateTime createdAt;
    
    ///Identificador único del fondo (ej: fund_001 o ID de Firestore)
    String id;
    
    ///Monto mínimo de inversión en COP
    double minInvestment;
    
    ///Nombre comercial del fondo
    String name;
    
    ///Estado actual de disponibilidad del fondo
    Status status;
    
    ///Rendimiento anual esperado en porcentaje (%)
    double targetApy;

    Fund({
        required this.category,
        required this.createdAt,
        required this.id,
        required this.minInvestment,
        required this.name,
        required this.status,
        required this.targetApy,
    });

    factory Fund.fromJson(Map<String, dynamic> json) => Fund(
        category: categoryValues.map[json["category"]]!,
        createdAt: DateTime.parse(json["createdAt"]),
        id: json["id"],
        minInvestment: json["minInvestment"]?.toDouble(),
        name: json["name"],
        status: statusValues.map[json["status"]]!,
        targetApy: json["targetApy"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "category": categoryValues.reverse[category],
        "createdAt": createdAt.toIso8601String(),
        "id": id,
        "minInvestment": minInvestment,
        "name": name,
        "status": statusValues.reverse[status],
        "targetApy": targetApy,
    };
}


///Categoría o tipo de activo del fondo
enum Category {
    ACCIONES,
    COMMODITIES,
    DEUDA,
    FONDO_INMOBILIARIO,
    INFRAESTRUCTURA,
    MULTIACTIVO,
    RENTA_FIJA,
    SOSTENIBLE
}

final categoryValues = EnumValues({
    "Acciones": Category.ACCIONES,
    "Commodities": Category.COMMODITIES,
    "Deuda": Category.DEUDA,
    "Fondo Inmobiliario": Category.FONDO_INMOBILIARIO,
    "Infraestructura": Category.INFRAESTRUCTURA,
    "Multiactivo": Category.MULTIACTIVO,
    "Renta Fija": Category.RENTA_FIJA,
    "Sostenible": Category.SOSTENIBLE
});


///Estado actual de disponibilidad del fondo
enum Status {
    ACTIVE,
    CLOSED
}

final statusValues = EnumValues({
    "ACTIVE": Status.ACTIVE,
    "CLOSED": Status.CLOSED
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
