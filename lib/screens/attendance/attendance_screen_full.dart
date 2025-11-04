import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import 'camera_capture_screen.dart';
import 'location_confirmation_screen.dart';

class AttendanceScreenFull extends StatefulWidget {
  const AttendanceScreenFull({super.key});

  @override
  State<AttendanceScreenFull> createState() => _AttendanceScreenFullState();
}

class _AttendanceScreenFullState extends State<AttendanceScreenFull> {
  bool _isCalendarView = true;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppTheme.darkSurface,
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            tooltip: _isCalendarView ? 'List View' : 'Calendar View',
          ),
        ],
      ),
      body: _isCalendarView ? _buildCalendarView() : _buildListView(),
      floatingActionButton: Consumer<AttendanceProvider>(
        builder: (context, attendance, _) {
          return FloatingActionButton.extended(
            onPressed: () => _startAttendance(context, attendance.isPunchedIn),
            backgroundColor: attendance.isPunchedIn
                ? Colors.red
                : AppTheme.primaryPurple,
            icon: Icon(
              attendance.isPunchedIn ? Icons.logout : Icons.login,
              color: Colors.white,
            ),
            label: Text(
              attendance.isPunchedIn ? 'Punch Out' : 'Punch In',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarView() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendance, _) {
        final dailyAttendance = attendance.getDailyAttendanceForMonth(_focusedDay);
        
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showDayDetail(selectedDay, attendance);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppTheme.textSecondary),
                  weekendStyle: TextStyle(color: Colors.red.shade300),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final dayData = dailyAttendance.firstWhere(
                      (d) => isSameDay(d.date, day),
                      orElse: () => DailyAttendance(
                        date: day,
                        status: AttendanceStatus.absent,
                      ),
                    );
                    return _buildCalendarDay(day, dayData.status);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final dayData = dailyAttendance.firstWhere(
                      (d) => isSameDay(d.date, day),
                      orElse: () => DailyAttendance(
                        date: day,
                        status: AttendanceStatus.absent,
                      ),
                    );
                    return _buildCalendarDay(day, dayData.status, isToday: true);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLegend(),
            ),
            const SizedBox(height: 16),
            if (dailyAttendance.any((d) => d.status != AttendanceStatus.absent))
              Expanded(
                child: _buildMonthSummary(dailyAttendance),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarDay(DateTime day, AttendanceStatus status, {bool isToday = false}) {
    Color? backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = Colors.green.withOpacity(0.3);
        break;
      case AttendanceStatus.halfDay:
        backgroundColor = Colors.orange.withOpacity(0.3);
        break;
      case AttendanceStatus.leave:
        backgroundColor = Colors.blue.withOpacity(0.3);
        break;
      case AttendanceStatus.absent:
        if (day.isBefore(DateTime.now())) {
          backgroundColor = Colors.red.withOpacity(0.2);
        }
        break;
    }

    if (isToday) {
      backgroundColor = AppTheme.primaryPurple.withOpacity(0.5);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _buildLegendItem('Present', Colors.green),
          _buildLegendItem('Half Day', Colors.orange),
          _buildLegendItem('Absent', Colors.red),
          _buildLegendItem('Leave', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSummary(List<DailyAttendance> dailyAttendance) {
    final present = dailyAttendance.where((d) => d.status == AttendanceStatus.present).length;
    final halfDay = dailyAttendance.where((d) => d.status == AttendanceStatus.halfDay).length;
    final absent = dailyAttendance.where((d) => d.status == AttendanceStatus.absent && d.date.isBefore(DateTime.now())).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Month Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('Present', present.toString(), Colors.green),
              _buildSummaryCard('Half Day', halfDay.toString(), Colors.orange),
              _buildSummaryCard('Absent', absent.toString(), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendance, _) {
        final dailyAttendance = attendance.getDailyAttendanceForMonth(_focusedDay);
        final validAttendance = dailyAttendance
            .where((d) =>
                d.punchIn != null && d.date.isBefore(DateTime.now().add(const Duration(days: 1))))
            .toList()
            .reversed
            .toList();

        if (validAttendance.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  
                ),
                const SizedBox(height: 16),
                Text(
                  'No attendance records found',
                  style: TextStyle(
                    
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy').format(_focusedDay),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: validAttendance.length,
                itemBuilder: (context, index) {
                  return _buildAttendanceCard(validAttendance[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceCard(DailyAttendance attendance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: attendance.punchIn?.selfieFilePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(attendance.punchIn!.selfieFilePath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryPurple,
                      ),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryPurple,
                ),
              ),
        title: Text(
          DateFormat('EEEE, dd MMM yyyy').format(attendance.date),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.login,
                  size: 16,
                  
                ),
                const SizedBox(width: 4),
                Text(
                  'In: ${attendance.punchInTime}',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.logout,
                  size: 16,
                  
                ),
                const SizedBox(width: 4),
                Text(
                  'Out: ${attendance.punchOutTime}',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  
                ),
                const SizedBox(width: 4),
                Text(
                  'Total: ${attendance.formattedTotalHours}',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildStatusBadge(attendance.status),
        onTap: () => _showDayDetail(attendance.date, Provider.of<AttendanceProvider>(context, listen: false)),
      ),
    );
  }

  Widget _buildStatusBadge(AttendanceStatus status) {
    Color color;
    String label;

    switch (status) {
      case AttendanceStatus.present:
        color = Colors.green;
        label = 'P';
        break;
      case AttendanceStatus.halfDay:
        color = Colors.orange;
        label = 'HD';
        break;
      case AttendanceStatus.leave:
        color = Colors.blue;
        label = 'L';
        break;
      case AttendanceStatus.absent:
        color = Colors.red;
        label = 'A';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDayDetail(DateTime day, AttendanceProvider attendance) {
    final dayAttendance = attendance.getDailyAttendance(day);
    
    if (dayAttendance == null || dayAttendance.punchIn == null) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                DateFormat('EEEE, dd MMMM yyyy').format(day),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (dayAttendance.punchIn != null) ...[
                _buildDetailRow('Punch In', dayAttendance.punchInTime),
                if (dayAttendance.punchIn!.address != null)
                  _buildDetailRow('Location', dayAttendance.punchIn!.address!),
              ],
              if (dayAttendance.punchOut != null) ...[
                const Divider(color: Colors.grey, height: 24),
                _buildDetailRow('Punch Out', dayAttendance.punchOutTime),
                if (dayAttendance.punchOut!.address != null)
                  _buildDetailRow('Location', dayAttendance.punchOut!.address!),
              ],
              if (dayAttendance.totalHours != null) ...[
                const Divider(color: Colors.grey, height: 24),
                _buildDetailRow('Total Hours', dayAttendance.formattedTotalHours),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (dayAttendance.punchIn?.selfieFilePath != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Punch In Selfie',
                            style: TextStyle(
                              
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(dayAttendance.punchIn!.selfieFilePath!),
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 100,
                                  color: AppTheme.primaryPurple.withOpacity(0.2),
                                  child: const Icon(Icons.person),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (dayAttendance.punchOut?.selfieFilePath != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Punch Out Selfie',
                            style: TextStyle(
                              
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(dayAttendance.punchOut!.selfieFilePath!),
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 100,
                                  color: AppTheme.primaryPurple.withOpacity(0.2),
                                  child: const Icon(Icons.person),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startAttendance(BuildContext context, bool isPunchIn) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraCaptureScreen(
          isPunchIn: !isPunchIn,
        ),
      ),
    );

    if (result != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationConfirmationScreen(
            selfieFilePath: result,
            isPunchIn: !isPunchIn,
          ),
        ),
      );
    }
  }
}
