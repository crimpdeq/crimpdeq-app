import 'package:freezed_annotation/freezed_annotation.dart';

part 'grip_models.freezed.dart';
part 'grip_models.g.dart';

enum Finger { thumb, indexFinger, middle, ring, pinky }

enum GripType { halfCrimp, fullCrimp, openHand }

enum ContractionType { passive, active }

@freezed
sealed class Grip with _$Grip {
  const Grip._();

  const factory Grip({
    required String id,
    required String name,
    required double edgeDepthMm,
    required Set<Finger> fingers,
    required GripType gripType,
    required ContractionType contractionType,
    required DateTime createdAt,
  }) = _Grip;

  factory Grip.fromJson(Map<String, dynamic> json) => _$GripFromJson(json);

  String get gripTypeLabel => switch (gripType) {
        GripType.halfCrimp => 'Half Crimp',
        GripType.fullCrimp => 'Full Crimp',
        GripType.openHand => 'Open Hand',
      };

  String get displayLabel => '$gripTypeLabel - ${edgeDepthMm.toStringAsFixed(0)}mm';
}
