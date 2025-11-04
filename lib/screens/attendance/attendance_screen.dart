import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import 'camera_capture_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sample attendance data
  Map<DateTime, AttendanceStatus> _getAttendanceData() {
    final now = DateTime.now();
    return {
      DateTime(now.year, now.month, now.day): AttendanceStatus.present,
      DateTime(now.year, now.month, now.day - 1): AttendanceStatus.present,
      DateTime(now.year, now.month, now.day - 2): AttendanceStatus.absent,
      DateTime(now.year, now.month, now.day - 3): AttendanceStatus.present,
      DateTime(now.year, now.month, now.day - 4): AttendanceStatus.present,
      DateTime(now.year, now.month, now.day - 7): AttendanceStatus.present,
    };
  }

  AttendanceStatus? _getStatusForDay(DateTime day) {
    final attendanceData = _getAttendanceData();
    return attendanceData[DateTime(day.year, day.month, day.day)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Attendance'),
        
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Calendar View'),
            Tab(text: 'List View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildListView(),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDayDetail(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
                selectedTextStyle: const TextStyle(color: Colors.white),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: const TextStyle(
                  
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                titleCentered: true,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final status = _getStatusForDay(day);
                  if (status != null) {
                    return _buildCalendarDay(day, status, false);
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  final status = _getStatusForDay(day);
                  return _buildCalendarDay(day, status ?? AttendanceStatus.none, true);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, AttendanceStatus status, bool isToday) {
    Color? backgroundColor;
    Color? borderColor;

    if (status == AttendanceStatus.present) {
      backgroundColor = AppTheme.successColor.withOpacity(0.2);
      borderColor = AppTheme.successColor;
    } else if (status == AttendanceStatus.absent) {
      backgroundColor = AppTheme.errorColor.withOpacity(0.2);
      borderColor = AppTheme.errorColor;
    } else if (isToday) {
      backgroundColor = AppTheme.primaryColor.withOpacity(0.2);
      borderColor = AppTheme.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            
            fontWeight: status != AttendanceStatus.none ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Present', AppTheme.successColor),
          _buildLegendItem('Absent', AppTheme.errorColor),
          _buildLegendItem('Today', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final attendanceRecords = [
      AttendanceRecord(
        date: DateTime.now(),
        checkIn: '9:04 AM',
        checkOut: null,
        totalHours: null,
        status: 'Present',
        statusColor: AppTheme.successColor,
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 1)),
        checkIn: '9:02 AM',
        checkOut: '6:15 PM',
        totalHours: '9h 13m',
        status: 'Present',
        statusColor: AppTheme.successColor,
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 2)),
        checkIn: null,
        checkOut: null,
        totalHours: null,
        status: 'Absent',
        statusColor: AppTheme.errorColor,
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 3)),
        checkIn: '9:15 AM',
        checkOut: '6:30 PM',
        totalHours: '9h 15m',
        status: 'Present',
        statusColor: AppTheme.successColor,
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 4)),
        checkIn: '9:00 AM',
        checkOut: '6:00 PM',
        totalHours: '9h 0m',
        status: 'Present',
        statusColor: AppTheme.successColor,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceRecords.length,
      itemBuilder: (context, index) {
        return _buildAttendanceCard(attendanceRecords[index]);
      },
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: record.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Date circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: record.statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(record.date),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: record.statusColor,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(record.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: record.statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('EEEE').format(record.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: record.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: record.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (record.checkIn != null || record.checkOut != null)
                  Row(
                    children: [
                      if (record.checkIn != null) ...[
                        const Icon(Icons.login, size: 14, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          record.checkIn!,
                          style: const TextStyle(
                            fontSize: 13,
                            
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (record.checkOut != null) ...[
                        const Icon(Icons.logout, size: 14, color: AppTheme.errorColor),
                        const SizedBox(width: 4),
                        Text(
                          record.checkOut!,
                          style: const TextStyle(
                            fontSize: 13,
                            
                          ),
                        ),
                      ],
                    ],
                  ),
                if (record.totalHours != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Total: ${record.totalHours}',
                        style: const TextStyle(
                          fontSize: 12,
                          
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Selfie preview (if present)
          if (record.status == 'Present')
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.2),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _showDayDetail(DateTime day) {
    final status = _getStatusForDay(day);
    if (status == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              DateFormat('EEEE, MMMM d, y').format(day),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            const SizedBox(height: 20),
            if (status == AttendanceStatus.present) ...[
              _buildDetailRow(Icons.login, 'Check In', '9:04 AM'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.logout, 'Check Out', '--:--'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.timer, 'Total Hours', '6h 30m'),
            ] else ...[
              const Text(
                'No attendance record for this day',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

enum AttendanceStatus { present, absent, none }

class AttendanceRecord {
  final DateTime date;
  final String? checkIn;
  final String? checkOut;
  final String? totalHours;
  final String status;
  final Color statusColor;

  AttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours,
    required this.status,
    required this.statusColor,
  });
}
