import 'dart:convert';

import 'package:latlong2/latlong.dart';

class House {
  final String idHouse;
  final String name;
  final String description;
  final String clusterName;
  final String commonName;
  final String buildingArea;
  final String landArea;
  final String statName;
  final String dateBuild;
  final String dateFinish;
  final String soldStatName;
  final String dateSold;
  final List<LatLng>? coordinates;
  final String color;
  final String colorName;
  final double ratio = 1000.0;

  House({
    required this.idHouse,
    required this.name,
    required this.description,
    required this.clusterName,
    required this.commonName,
    required this.buildingArea,
    required this.landArea,
    required this.statName,
    required this.dateBuild,
    required this.dateFinish,
    required this.soldStatName,
    required this.dateSold,
    required this.coordinates,
    required this.color,
    required this.colorName,
  });

  House copyWith({
    String? idHouse,
    String? name,
    String? description,
    String? clusterName,
    String? commonName,
    String? buildingArea,
    String? landArea,
    String? statName,
    String? dateBuild,
    String? dateFinish,
    String? soldStatName,
    String? dateSold,
    List<LatLng>? coordinates,
    String? color,
    String? colorName,
  }) {
    return House(
      idHouse: idHouse ?? this.idHouse,
      name: name ?? this.name,
      description: description ?? this.description,
      clusterName: clusterName ?? this.clusterName,
      commonName: commonName ?? this.commonName,
      buildingArea: buildingArea ?? this.buildingArea,
      landArea: landArea ?? this.landArea,
      statName: statName ?? this.statName,
      dateBuild: dateBuild ?? this.dateBuild,
      dateFinish: dateFinish ?? this.dateFinish,
      soldStatName: soldStatName ?? this.soldStatName,
      dateSold: dateSold ?? this.dateSold,
      coordinates: coordinates ?? this.coordinates,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
    );
  }

  static List<LatLng>? _parseCoordinates(String? coordString) {
    if (coordString == null || coordString.isEmpty || coordString == '""') {
      return null;
    }
    
    try {
      final double ratio = 1000.0;
      final List<dynamic> coords = jsonDecode(coordString);
      return coords.map((e) => LatLng(e[0].toDouble() / ratio, e[1].toDouble() / ratio)).toList();
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_house': idHouse,
      'name': name,
      'description': description,
      'cluster_name': clusterName,
      'common_name': commonName,
      'building_area': buildingArea,
      'land_area': landArea,
      'stat_name': statName,
      'date_build': dateBuild,
      'date_finish': dateFinish,
      'sold_stat_name': soldStatName,
      'date_sold': dateSold,
      'coordinates': coordinates,
      'color': color,
      'color_name': colorName,
    };
  }

  factory House.fromMap(Map<String, dynamic> map) {
    return House(
      idHouse: map['id_house'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      clusterName: map['cluster_name'] as String,
      commonName: map['common_name'] as String,
      buildingArea: map['building_area'] as String,
      landArea: map['land_area'] as String,
      statName: map['stat_name'] as String,
      dateBuild: map['date_build'] as String,
      dateFinish: map['date_finish'] as String,
      soldStatName: map['sold_stat_name'] as String,
      dateSold: map['date_sold'] as String,
      coordinates: _parseCoordinates(map['coordinates'] as String),
      color: map['color'] as String,
      colorName: map['color_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory House.fromJson(String source) => House.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'House(idHouse: $idHouse, name: $name, description: $description, clusterName: $clusterName, commonName: $commonName, buildingArea: $buildingArea, landArea: $landArea, statName: $statName, dateBuild: $dateBuild, dateFinish: $dateFinish, soldStatName: $soldStatName, dateSold: $dateSold, coordinates: $coordinates, color: $color, colorName: $colorName)';
  }

  @override
  bool operator ==(covariant House other) {
    if (identical(this, other)) return true;
  
    return 
      other.idHouse == idHouse &&
      other.name == name &&
      other.description == description &&
      other.clusterName == clusterName &&
      other.commonName == commonName &&
      other.buildingArea == buildingArea &&
      other.landArea == landArea &&
      other.statName == statName &&
      other.dateBuild == dateBuild &&
      other.dateFinish == dateFinish &&
      other.soldStatName == soldStatName &&
      other.dateSold == dateSold &&
      other.coordinates == coordinates &&
      other.color == color &&
      other.colorName == colorName;
  }

  @override
  int get hashCode {
    return idHouse.hashCode ^
      name.hashCode ^
      description.hashCode ^
      clusterName.hashCode ^
      commonName.hashCode ^
      buildingArea.hashCode ^
      landArea.hashCode ^
      statName.hashCode ^
      dateBuild.hashCode ^
      dateFinish.hashCode ^
      soldStatName.hashCode ^
      dateSold.hashCode ^
      coordinates.hashCode ^
      color.hashCode ^
      colorName.hashCode;
  }
}
