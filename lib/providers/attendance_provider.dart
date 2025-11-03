import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/attendance.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceRecord> _records = [];
  bool _isPunchedIn = false;
  AttendanceRecord? _todaysPunchIn;

  List<AttendanceRecord> get records => _records;
  bool get isPunchedIn => _isPunchedIn;
  AttendanceRecord? get todaysPunchIn => _todaysPunchIn;

  AttendanceProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _records = [
      AttendanceRecord(
        id: '1',
        userId: 'user1',
        timestamp: DateTime(now.year, now.month, now.day - 1, 9, 15),
        punchType: PunchType.punchIn,
        latitude: 28.6139,
        longitude: 77.2090,
        accuracy: 10.0,
        address: 'Connaught Place, New Delhi',
        selfieFilePath: null,
        deviceId: 'device1',
      ),
      AttendanceRecord(
        id: '2',
        userId: 'user1',
        timestamp: DateTime(now.year, now.month, now.day - 1, 18, 30),
        punchType: PunchType.punchOut,
        latitude: 28.6139,
        longitude: 77.2090,
        accuracy: 10.0,
        address: 'Connaught Place, New Delhi',
        selfieFilePath: null,
        deviceId: 'device1',
      ),
      AttendanceRecord(
        id: '3',
        userId: 'user1',
        timestamp: DateTime(now.year, now.month, now.day - 2, 9, 5),
        punchType: PunchType.punchIn,
        latitude: 28.6139,
        longitude: 77.2090,
        accuracy: 10.0,
        address: 'Connaught Place, New Delhi',
        selfieFilePath: null,
        deviceId: 'device1',
      ),
      AttendanceRecord(
        id: '4',
        userId: 'user1',
        timestamp: DateTime(now.year, now.month, now.day - 2, 17, 45),
        punchType: PunchType.punchOut,
        latitude: 28.6139,
        longitude: 77.2090,
        accuracy: 10.0,
        address: 'Connaught Place, New Delhi',
        selfieFilePath: null,
        deviceId: 'device1',
      ),
    ];
    _checkTodaysPunchStatus();
    notifyListeners();
  }

  void _checkTodaysPunchStatus() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todaysRecords = _records.where((record) {
      final recordDate = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      return recordDate.isAtSameMomentAs(today);
    }).toList();

    _todaysPunchIn = todaysRecords
        .where((r) => r.punchType == PunchType.punchIn)
        .isNotEmpty
        ? todaysRecords.firstWhere((r) => r.punchType == PunchType.punchIn)
        : null;

    final hasPunchOut = todaysRecords
        .where((r) => r.punchType == PunchType.punchOut)
        .isNotEmpty;

    _isPunchedIn = _todaysPunchIn != null && !hasPunchOut;
  }

  Future<void> addRecord(AttendanceRecord record) async {
    _records.insert(0, record);
    _checkTodaysPunchStatus();
    notifyListeners();
  }

  List<DailyAttendance> getDailyAttendanceForMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final List<DailyAttendance> dailyList = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final dayRecords = _records.where((record) {
        final recordDate = DateTime(
          record.timestamp.year,
          record.timestamp.month,
          record.timestamp.day,
        );
        return recordDate.isAtSameMomentAs(date);
      }).toList();

      AttendanceRecord? punchIn;
      AttendanceRecord? punchOut;
      AttendanceStatus status = AttendanceStatus.absent;
      Duration? totalHours;

      for (var record in dayRecords) {
        if (record.punchType == PunchType.punchIn) {
          punchIn = record;
        } else if (record.punchType == PunchType.punchOut) {
          punchOut = record;
        }
      }

      if (punchIn != null && punchOut != null) {
        totalHours = punchOut.timestamp.difference(punchIn.timestamp);
        if (totalHours.inHours >= 8) {
          status = AttendanceStatus.present;
        } else if (totalHours.inHours >= 4) {
          status = AttendanceStatus.halfDay;
        }
      } else if (punchIn != null) {
        status = AttendanceStatus.present;
      }

      if (date.isAfter(DateTime.now())) {
        status = AttendanceStatus.absent;
        punchIn = null;
        punchOut = null;
      }

      dailyList.add(DailyAttendance(
        date: date,
        punchIn: punchIn,
        punchOut: punchOut,
        status: status,
        totalHours: totalHours,
      ));
    }

    return dailyList;
  }

  DailyAttendance? getDailyAttendance(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayRecords = _records.where((record) {
      final recordDate = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      return recordDate.isAtSameMomentAs(normalizedDate);
    }).toList();

    if (dayRecords.isEmpty && normalizedDate.isAfter(DateTime.now())) {
      return null;
    }

    AttendanceRecord? punchIn;
    AttendanceRecord? punchOut;

    for (var record in dayRecords) {
      if (record.punchType == PunchType.punchIn) {
        punchIn = record;
      } else if (record.punchType == PunchType.punchOut) {
        punchOut = record;
      }
    }

    AttendanceStatus status = AttendanceStatus.absent;
    Duration? totalHours;

    if (punchIn != null && punchOut != null) {
      totalHours = punchOut.timestamp.difference(punchIn.timestamp);
      if (totalHours.inHours >= 8) {
        status = AttendanceStatus.present;
      } else if (totalHours.inHours >= 4) {
        status = AttendanceStatus.halfDay;
      }
    } else if (punchIn != null) {
      status = AttendanceStatus.present;
    }

    return DailyAttendance(
      date: normalizedDate,
      punchIn: punchIn,
      punchOut: punchOut,
      status: status,
      totalHours: totalHours,
    );
  }
}
