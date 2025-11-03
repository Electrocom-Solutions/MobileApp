import 'dart:io';

enum PunchType { punchIn, punchOut }

enum AttendanceStatus { present, absent, halfDay, leave }

class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime timestamp;
  final PunchType punchType;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? address;
  final String? selfieFilePath;
  final String deviceId;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.punchType,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.address,
    this.selfieFilePath,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'punchType': punchType.toString(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'address': address,
      'selfieFilePath': selfieFilePath,
      'deviceId': deviceId,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      punchType: json['punchType'] == 'PunchType.punchIn'
          ? PunchType.punchIn
          : PunchType.punchOut,
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      address: json['address'],
      selfieFilePath: json['selfieFilePath'],
      deviceId: json['deviceId'],
    );
  }
}

class DailyAttendance {
  final DateTime date;
  final AttendanceRecord? punchIn;
  final AttendanceRecord? punchOut;
  final AttendanceStatus status;
  final Duration? totalHours;

  DailyAttendance({
    required this.date,
    this.punchIn,
    this.punchOut,
    required this.status,
    this.totalHours,
  });

  String get formattedTotalHours {
    if (totalHours == null) return '--';
    final hours = totalHours!.inHours;
    final minutes = totalHours!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String get punchInTime {
    if (punchIn == null) return '--';
    final hour = punchIn!.timestamp.hour;
    final minute = punchIn!.timestamp.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get punchOutTime {
    if (punchOut == null) return '--';
    final hour = punchOut!.timestamp.hour;
    final minute = punchOut!.timestamp.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
