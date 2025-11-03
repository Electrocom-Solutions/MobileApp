import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(showAll: true),
          _buildTaskList(showPending: true),
          _buildTaskList(showCompleted: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList({
    bool showAll = false,
    bool showPending = false,
    bool showCompleted = false,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showAll || showPending) ...[
          _TaskCard(
            title: 'Complete Project Documentation',
            description: 'Write comprehensive documentation for the new feature',
            priority: 'High',
            priorityColor: AppTheme.errorColor,
            dueDate: 'Today',
            isCompleted: false,
          ),
          _TaskCard(
            title: 'Review Code Changes',
            description: 'Review pull requests from team members',
            priority: 'Medium',
            priorityColor: AppTheme.warningColor,
            dueDate: 'Tomorrow',
            isCompleted: false,
          ),
          _TaskCard(
            title: 'Update Test Cases',
            description: 'Add unit tests for new API endpoints',
            priority: 'Low',
            priorityColor: AppTheme.successColor,
            dueDate: 'Nov 5, 2025',
            isCompleted: false,
          ),
        ],
        if (showAll || showCompleted) ...[
          _TaskCard(
            title: 'Setup Development Environment',
            description: 'Configure local environment for new project',
            priority: 'High',
            priorityColor: AppTheme.errorColor,
            dueDate: 'Nov 1, 2025',
            isCompleted: true,
          ),
          _TaskCard(
            title: 'Attend Team Meeting',
            description: 'Weekly sync-up with the development team',
            priority: 'Medium',
            priorityColor: AppTheme.warningColor,
            dueDate: 'Nov 2, 2025',
            isCompleted: true,
          ),
        ],
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final Color priorityColor;
  final String dueDate;
  final bool isCompleted;

  const _TaskCard({
    required this.title,
    required this.description,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted
                      ? AppTheme.successColor
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dueDate,
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
    );
  }
}
