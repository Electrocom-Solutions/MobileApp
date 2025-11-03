import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.login,
                                color: AppTheme.successColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '9:00 AM',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check In',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: AppTheme.textHint,
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.logout,
                                color: AppTheme.textHint,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '--:--',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check Out',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.logout),
                          label: const Text('Check Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance History',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('This Month'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              _AttendanceCard(
                date: 'Today',
                checkIn: '9:00 AM',
                checkOut: '--:--',
                status: 'Present',
                statusColor: AppTheme.successColor,
              ),
              _AttendanceCard(
                date: 'Yesterday',
                checkIn: '9:05 AM',
                checkOut: '6:00 PM',
                status: 'Present',
                statusColor: AppTheme.successColor,
              ),
              _AttendanceCard(
                date: 'Nov 01, 2025',
                checkIn: '9:30 AM',
                checkOut: '6:15 PM',
                status: 'Present',
                statusColor: AppTheme.successColor,
              ),
              _AttendanceCard(
                date: 'Oct 31, 2025',
                checkIn: '--:--',
                checkOut: '--:--',
                status: 'Absent',
                statusColor: AppTheme.errorColor,
              ),
              _AttendanceCard(
                date: 'Oct 30, 2025',
                checkIn: '10:30 AM',
                checkOut: '6:00 PM',
                status: 'Late',
                statusColor: AppTheme.warningColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
  final Color statusColor;

  const _AttendanceCard({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.login,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        checkIn,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        checkOut,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
