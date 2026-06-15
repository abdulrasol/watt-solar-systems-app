import 'package:flutter/material.dart';

enum ObstacleType {
  tree,
  wall,
  chimney,
  vent,
  other,
}

@immutable
class Obstacle {
  const Obstacle({
    required this.id,
    required this.type,
    required this.position,
    this.size = const Size(1.0, 1.0),
    this.heightM = 2.0,
    this.label,
  });

  final String id;
  final ObstacleType type;
  final Offset position;
  final Size size;
  final double heightM;
  final String? label;

  Obstacle copyWith({
    String? id,
    ObstacleType? type,
    Offset? position,
    Size? size,
    double? heightM,
    String? label,
  }) {
    return Obstacle(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      heightM: heightM ?? this.heightM,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'heightM': heightM,
      'label': label,
    };
  }

  factory Obstacle.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>? ?? {};
    final sz = json['size'] as Map<String, dynamic>? ?? {};
    return Obstacle(
      id: json['id'] as String? ?? '',
      type: ObstacleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ObstacleType.other,
      ),
      position: Offset(
        (pos['dx'] as num? ?? 0.0).toDouble(),
        (pos['dy'] as num? ?? 0.0).toDouble(),
      ),
      size: Size(
        (sz['width'] as num? ?? 1.0).toDouble(),
        (sz['height'] as num? ?? 1.0).toDouble(),
      ),
      heightM: (json['heightM'] as num? ?? 2.0).toDouble(),
      label: json['label'] as String?,
    );
  }
}

extension ObstacleTypeUi on ObstacleType {
  Color get color {
    return switch (this) {
      ObstacleType.tree => Colors.green,
      ObstacleType.wall => Colors.brown,
      ObstacleType.chimney => Colors.red,
      ObstacleType.vent => Colors.orange,
      ObstacleType.other => Colors.grey,
    };
  }

  String get label {
    return switch (this) {
      ObstacleType.tree => 'Tree',
      ObstacleType.wall => 'Wall',
      ObstacleType.chimney => 'Chimney',
      ObstacleType.vent => 'Vent',
      ObstacleType.other => 'Other',
    };
  }
}
