import 'dart:convert';

class Entity {
  final String entityId;
  final String userId2;
  final String routeWeb;
  final String description;
  final String urlImage;
  final String color;
  final String class_;
  Entity({
    required this.entityId,
    required this.userId2,
    required this.routeWeb,
    required this.description,
    required this.urlImage,
    required this.color,
    required this.class_,
  });

  Entity copyWith({
    String? entityId,
    String? userId2,
    String? routeWeb,
    String? description,
    String? urlImage,
    String? color,
    String? class_,
  }) {
    return Entity(
      entityId: entityId ?? this.entityId,
      userId2: userId2 ?? this.userId2,
      routeWeb: routeWeb ?? this.routeWeb,
      description: description ?? this.description,
      urlImage: urlImage ?? this.urlImage,
      color: color ?? this.color,
      class_: class_ ?? this.class_,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entity_id': entityId,
      'user_id2': userId2,
      'route_web': routeWeb,
      'description': description,
      'url_image': urlImage,
      'color': color,
      'class': class_,
    };
  }

  factory Entity.fromMap(Map<String, dynamic> map) {
    return Entity(
      entityId: map['entity_id'] ?? '',
      userId2: map['user_id2'] ?? '',
      routeWeb: map['route_web'] ?? '',
      description: map['description'] ?? '',
      urlImage: map['url_image'] ?? '',
      color: map['color'] ?? '',
      class_: map['class'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Entity.fromJson(String source) => Entity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Entity(entityId: $entityId, userId2: $userId2, routeWeb: $routeWeb, description: $description, urlImage: $urlImage, color: $color, class_: $class_)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Entity &&
      other.entityId == entityId &&
      other.userId2 == userId2 &&
      other.routeWeb == routeWeb &&
      other.description == description &&
      other.urlImage == urlImage &&
      other.color == color &&
      other.class_ == class_;
  }

  @override
  int get hashCode {
    return entityId.hashCode ^
      userId2.hashCode ^
      routeWeb.hashCode ^
      description.hashCode ^
      urlImage.hashCode ^
      color.hashCode ^
      class_.hashCode;
  }
}