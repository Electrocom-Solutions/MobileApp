import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../../config/theme.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import 'create_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final task = Provider.of<TaskProvider>(context).getTaskById(widget.taskId);

    if (task == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(
          child: Text(
            'Task not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    _selectedStatus ??= task.status;
    final bool canEdit = task.status != TaskStatus.completed;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                      projectId: task.projectId,
                      taskId: task.id,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(task, canEdit),
            const SizedBox(height: 24),
            _buildStatusSelector(task, canEdit),
            const SizedBox(height: 24),
            _buildTaskInformation(task),
            const SizedBox(height: 24),
            _buildAttachmentsSection(task),
            const SizedBox(height: 24),
            _buildResourcesSection(task),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Task task, bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(task.status), width: 2),
              ),
              child: Text(
                task.statusText,
                style: TextStyle(
                  color: _getStatusColor(task.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Created ${DateFormat('MMM dd, yyyy').format(task.createdAt)}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(Task task, bool canEdit) {
    if (!canEdit) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change Status',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(TaskStatus.draft),
              _buildStatusChip(TaskStatus.inProgress),
              _buildStatusChip(TaskStatus.completed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    final isSelected = _selectedStatus == status;
    
    return GestureDetector(
      onTap: () async {
        if (status == TaskStatus.completed) {
          final confirmed = await _showCompleteConfirmation();
          if (!confirmed) return;
        }
        setState(() => _selectedStatus = status);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _getStatusColor(status).withOpacity(0.2) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _getStatusColor(status) : AppTheme.textSecondary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Text(
          _getStatusText(status),
          style: TextStyle(
            color: isSelected ? _getStatusColor(status) : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInformation(Task task) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Information',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('EEEE, MMM d, y').format(task.date)),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.timer, 'Time Taken', task.timeTakenFormatted),
          const SizedBox(height: 16),
          if (task.location != null)
            _buildInfoRow(Icons.location_on, 'Location', task.location!, hasMap: true),
          if (task.location != null) const SizedBox(height: 16),
          _buildInfoRow(Icons.folder, 'Project', task.projectTitle),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool hasMap = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (hasMap)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Open Map',
                        style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (task.attachments.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.textHint.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.attach_file, size: 48, color: AppTheme.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'No attachments yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: task.attachments.length,
            itemBuilder: (context, index) {
              return _buildAttachmentThumbnail(task.attachments[index], index, task.attachments);
            },
          ),
      ],
    );
  }

  Widget _buildAttachmentThumbnail(TaskAttachment attachment, int index, List<TaskAttachment> allAttachments) {
    return GestureDetector(
      onTap: () {
        if (attachment.type == AttachmentType.image) {
          _showImageViewer(index, allAttachments);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: attachment.type == AttachmentType.image
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      File(attachment.filePath),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppTheme.errorColor, size: 40),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      attachment.fileName,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    attachment.fileSizeFormatted,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResourcesSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resources Used',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (task.resources.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.textHint.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inventory_2, size: 48, color: AppTheme.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'No resources recorded',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                ...task.resources.map((resource) => _buildResourceItem(resource, task.status)),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Resource Cost',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${task.totalResourceCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResourceItem(ResourceUsed resource, TaskStatus status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.textHint, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${resource.quantity} ${resource.unit}${resource.unitCost != null ? ' × \$${resource.unitCost!.toStringAsFixed(2)}' : ''}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (resource.unitCost != null)
            Text(
              '\$${resource.totalCost.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  void _showImageViewer(int initialIndex, List<TaskAttachment> attachments) {
    final imageAttachments = attachments.where((a) => a.type == AttachmentType.image).toList();
    int currentIndex = imageAttachments.indexWhere((a) => a.id == attachments[initialIndex].id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('${currentIndex + 1} of ${imageAttachments.length}'),
          ),
          body: PhotoView(
            imageProvider: FileImage(File(imageAttachments[currentIndex].filePath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  Future<bool> _showCompleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Mark as Completed?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Once marked as completed, you will not be able to edit this task or change its status back.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.draft:
        return AppTheme.textSecondary;
      case TaskStatus.toDo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return AppTheme.warningColor;
      case TaskStatus.completed:
        return AppTheme.successColor;
      case TaskStatus.pendingApproval:
        return AppTheme.primaryColor;
      case TaskStatus.approved:
        return AppTheme.successColor;
      case TaskStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.draft:
        return 'Draft';
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.pendingApproval:
        return 'Pending Approval';
      case TaskStatus.approved:
        return 'Approved';
      case TaskStatus.rejected:
        return 'Rejected';
    }
  }
}
