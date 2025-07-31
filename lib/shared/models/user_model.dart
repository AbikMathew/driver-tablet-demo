// Example data models that will be implemented with proper serialization

/*
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
@HiveType(typeId: 0)
class User with _$User {
  const factory User({
    @HiveField(0) required String id,
    @HiveField(1) required String phone,
    @HiveField(2) required String name,
    @HiveField(3) String? email,
    @HiveField(4) String? avatar,
    @HiveField(5) @Default(false) bool isActive,
    @HiveField(6) DateTime? lastLogin,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class RouteData with _$RouteData {
  const factory RouteData({
    required String id,
    required String name,
    required DateTime date,
    required List<RouteStop> stops,
    @Default(RouteStatus.pending) RouteStatus status,
    String? notes,
  }) = _RouteData;

  factory RouteData.fromJson(Map<String, dynamic> json) => 
      _$RouteDataFromJson(json);
}

@freezed
class RouteStop with _$RouteStop {
  const factory RouteStop({
    required String id,
    required String address,
    required double latitude,
    required double longitude,
    required int sequence,
    @Default(StopStatus.pending) StopStatus status,
    String? notes,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
  }) = _RouteStop;

  factory RouteStop.fromJson(Map<String, dynamic> json) => 
      _$RouteStopFromJson(json);
}

enum RouteStatus {
  pending,
  active,
  completed,
  cancelled,
}

enum StopStatus {
  pending,
  enRoute,
  arrived,
  completed,
  skipped,
}

@freezed
class ScheduleDay with _$ScheduleDay {
  const factory ScheduleDay({
    required DateTime date,
    required bool isAvailable,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? notes,
  }) = _ScheduleDay;

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => 
      _$ScheduleDayFromJson(json);
}
*/

// Placeholder models - will be replaced with above when packages are installed
class User {
  final String id;
  final String phone;
  final String name;

  User({required this.id, required this.phone, required this.name});
}

class RouteData {
  final String id;
  final String name;
  final DateTime date;

  RouteData({required this.id, required this.name, required this.date});
}
