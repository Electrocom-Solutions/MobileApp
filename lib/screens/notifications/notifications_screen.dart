import 'package:flutter/material.dart';
import '../../config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {},
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationCard(
            icon: Icons.task_alt,
            iconColor: AppTheme.primaryColor,
            title: 'Task Assigned',
            message: 'You have been assigned a new task: "Complete Project Documentation"',
            time: '5 minutes ago',
            isRead: false,
          ),
          _NotificationCard(
            icon: Icons.message,
            iconColor: AppTheme.secondaryColor,
            title: 'New Message',
            message: 'You have a new message from your manager',
            time: '1 hour ago',
            isRead: false,
          ),
          _NotificationCard(
            icon: Icons.check_circle,
            iconColor: AppTheme.successColor,
            title: 'Task Approved',
            message: 'Your task "Setup Development Environment" has been approved',
            time: '2 hours ago',
            isRead: false,
          ),
          _NotificationCard(
            icon: Icons.event,
            iconColor: AppTheme.warningColor,
            title: 'Meeting Reminder',
            message: 'Team meeting starts in 30 minutes',
            time: '3 hours ago',
            isRead: true,
          ),
          _NotificationCard(
            icon: Icons.calendar_today,
            iconColor: AppTheme.primaryColor,
            title: 'Leave Request Approved',
            message: 'Your leave request for Nov 10-12 has been approved',
            time: 'Yesterday',
            isRead: true,
          ),
          _NotificationCard(
            icon: Icons.announcement,
            iconColor: AppTheme.errorColor,
            title: 'System Maintenance',
            message: 'System will be under maintenance tonight from 12 AM to 2 AM',
            time: 'Yesterday',
            isRead: true,
          ),
          _NotificationCard(
            icon: Icons.celebration,
            iconColor: AppTheme.successColor,
            title: 'Achievement Unlocked',
            message: 'Congratulations! You completed 100 tasks this month',
            time: '2 days ago',
            isRead: true,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? cardColor : cardColor.withOpacity(0.95),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight:
                                          isRead ? FontWeight.w500 : FontWeight.w700,
                                    ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
