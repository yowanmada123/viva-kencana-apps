import 'dart:convert';

import 'package:flutter/foundation.dart';

class Menu {
  final String entityId;
  final String applId;
  final String groupId;
  final String menuHeaderCaption;
  final String menuHeaderPath;
  final String menuHeaderId;
  final String icon;
  final List<SubMenu> submenus;
  Menu({
    required this.entityId,
    required this.applId,
    required this.groupId,
    required this.menuHeaderCaption,
    required this.menuHeaderPath,
    required this.menuHeaderId,
    required this.icon,
    required this.submenus,
  });

  Menu copyWith({
    String? entityId,
    String? applId,
    String? groupId,
    String? menuHeaderCaption,
    String? menuHeaderPath,
    String? menuHeaderId,
    String? icon,
    List<SubMenu>? submenus,
  }) {
    return Menu(
      entityId: entityId ?? this.entityId,
      applId: applId ?? this.applId,
      groupId: groupId ?? this.groupId,
      menuHeaderCaption: menuHeaderCaption ?? this.menuHeaderCaption,
      menuHeaderPath: menuHeaderPath ?? this.menuHeaderPath,
      menuHeaderId: menuHeaderId ?? this.menuHeaderId,
      icon: icon ?? this.icon,
      submenus: submenus ?? this.submenus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entity_id': entityId,
      'appl_id': applId,
      'group_id': groupId,
      'menu_header_caption': menuHeaderCaption,
      'menu_header_path': menuHeaderPath,
      'menu_header_id': menuHeaderId,
      'icon': icon,
      'submenus': submenus.map((x) => x.toMap()).toList(),
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      entityId: map['entity_id'] ?? '',
      applId: map['appl_id'] ?? '',
      groupId: map['group_id'] ?? '',
      menuHeaderCaption: map['menu_header_caption'] ?? '',
      menuHeaderPath: map['menu_header_path'] ?? '',
      menuHeaderId: map['menu_header_id'] ?? '',
      icon: map['icon'] ?? '',
      submenus: List<SubMenu>.from(map['submenus']?.map((x) => SubMenu.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Menu.fromJson(String source) => Menu.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Menu(entityId: $entityId, applId: $applId, groupId: $groupId, menuHeaderCaption: $menuHeaderCaption, menuHeaderPath: $menuHeaderPath, menuHeaderId: $menuHeaderId, icon: $icon, submenus: $submenus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Menu &&
      other.entityId == entityId &&
      other.applId == applId &&
      other.groupId == groupId &&
      other.menuHeaderCaption == menuHeaderCaption &&
      other.menuHeaderPath == menuHeaderPath &&
      other.menuHeaderId == menuHeaderId &&
      other.icon == icon &&
      listEquals(other.submenus, submenus);
  }

  @override
  int get hashCode {
    return entityId.hashCode ^
      applId.hashCode ^
      groupId.hashCode ^
      menuHeaderCaption.hashCode ^
      menuHeaderPath.hashCode ^
      menuHeaderId.hashCode ^
      icon.hashCode ^
      submenus.hashCode;
  }
}

class SubMenu {
  final String entityId;
  final String applId;
  final String menuId;
  final String seqId;
  final String menuCaption;
  final String routePath;
  final String icon;
  final Future<void> Function()? action;
  SubMenu({
    required this.entityId,
    required this.applId,
    required this.menuId,
    required this.seqId,
    required this.menuCaption,
    required this.routePath,
    required this.icon,
    this.action,
  });

  SubMenu copyWith({
    String? entityId,
    String? applId,
    String? menuId,
    String? seqId,
    String? menuCaption,
    String? routePath,
    String? icon,
    Future<void> Function()? action,
  }) {
    return SubMenu(
      entityId: entityId ?? this.entityId,
      applId: applId ?? this.applId,
      menuId: menuId ?? this.menuId,
      seqId: seqId ?? this.seqId,
      menuCaption: menuCaption ?? this.menuCaption,
      routePath: routePath ?? this.routePath,
      icon: icon ?? this.icon,
      action: action ?? this.action,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entity_id': entityId,
      'appl_id': applId,
      'menu_id': menuId,
      'seq_id': seqId,
      'menu_caption': menuCaption,
      'route_path': routePath,
      'icon': icon,
    };
  }

  factory SubMenu.fromMap(Map<String, dynamic> map) {
    return SubMenu(
      entityId: map['entity_id'] ?? '',
      applId: map['appl_id'] ?? '',
      menuId: map['menu_id'] ?? '',
      seqId: map['seq_id'] ?? '',
      menuCaption: map['menu_caption'] ?? '',
      routePath: map['route_path'] ?? '',
      icon: map['icon'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SubMenu.fromJson(String source) => SubMenu.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SubMenu(entityId: $entityId, applId: $applId, menuId: $menuId, seqId: $seqId, menuCaption: $menuCaption, routePath: $routePath, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SubMenu &&
      other.entityId == entityId &&
      other.applId == applId &&
      other.menuId == menuId &&
      other.seqId == seqId &&
      other.menuCaption == menuCaption &&
      other.routePath == routePath &&
      other.icon == icon;
  }

  @override
  int get hashCode {
    return entityId.hashCode ^
      applId.hashCode ^
      menuId.hashCode ^
      seqId.hashCode ^
      menuCaption.hashCode ^
      routePath.hashCode ^
      icon.hashCode;
  }
}