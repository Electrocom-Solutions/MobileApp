import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  final String? projectId;
  final String? taskId;
  
  const CreateTaskScreen({super.key, this.projectId, this.taskId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeTakenController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TaskStatus _selectedStatus = TaskStatus.draft;
  String? _selectedProjectId;
  List<TaskAttachment> _attachments = [];
  List<ResourceUsed> _resources = [ResourceUsed(id: const Uuid().v4(), name: '', quantity: 0, unit: 'pcs')];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = 'Auto-detected location';
    _selectedProjectId = widget.projectId;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.taskId != null) {
        _loadTaskData();
      }
    });
  }
  
  void _loadTaskData() {
    final task = Provider.of<TaskProvider>(context, listen: false).getTaskById(widget.taskId!);
    if (task != null) {
      setState(() {
        _nameController.text = task.name;
        _descriptionController.text = task.description;
        _selectedDate = task.date;
        _locationController.text = task.location ?? 'Auto-detected location';
        _timeTakenController.text = task.timeTakenMinutes.toString();
        _selectedStatus = task.status;
        _selectedProjectId = task.projectId;
        _attachments = List.from(task.attachments);
        _resources = task.resources.isNotEmpty ? List.from(task.resources) : [ResourceUsed(id: const Uuid().v4(), name: '', quantity: 0, unit: 'pcs')];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeTakenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(widget.taskId != null ? 'Edit Task' : 'Create Task'),
        
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Task Information'),
              const SizedBox(height: 16),
              _buildTaskNameField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildTimeTakenField(),
              const SizedBox(height: 16),
              _buildProjectField(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Attachments'),
              const SizedBox(height: 16),
              _buildAttachmentsSection(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Resources Used'),
              const SizedBox(height: 16),
              _buildResourcesSection(),
              const SizedBox(height: 32),
              
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTaskNameField() {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(),
      decoration: InputDecoration(
        labelText: 'Task Name *',
        labelStyle: TextStyle(),
        filled: true,
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter task name';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      style: TextStyle(),
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: TextStyle(),
        filled: true,
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.primaryColor,
                  
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle( fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  style: const TextStyle( fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      style: TextStyle(),
      decoration: InputDecoration(
        labelText: 'Location',
        labelStyle: TextStyle(),
        filled: true,
        
        prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildTimeTakenField() {
    return TextFormField(
      controller: _timeTakenController,
      style: TextStyle(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Time Taken (minutes)',
        labelStyle: TextStyle(),
        filled: true,
        
        prefixIcon: const Icon(Icons.timer, color: AppTheme.primaryColor),
        suffixText: _timeTakenController.text.isNotEmpty 
            ? '(${(int.tryParse(_timeTakenController.text) ?? 0) / 60} hrs)'
            : '',
        suffixStyle: const TextStyle( fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildProjectField() {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;
    
    // If projectId was provided (from project detail), show read-only field
    if (widget.projectId != null) {
      final project = projectProvider.getProjectById(widget.projectId!);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.folder, color: Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project (Read-only)',
                  style: TextStyle( fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  project?.title ?? 'No Project',
                  style: const TextStyle( fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    // Otherwise show dropdown selector
    return DropdownButtonFormField<String>(
      value: _selectedProjectId,
      decoration: InputDecoration(
        labelText: 'Select Project *',
        labelStyle: TextStyle(),
        filled: true,
        
        prefixIcon: const Icon(Icons.folder, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      
      style: TextStyle(),
      items: projects.map((project) {
        return DropdownMenuItem<String>(
          value: project.id,
          child: Text(
            project.title,
            style: TextStyle(),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedProjectId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a project';
        }
        return null;
      },
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      children: [
        if (_attachments.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _attachments.removeAt(oldIndex);
                  _attachments.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                return _buildAttachmentCard(_attachments[index], index);
              },
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.attach_file,
                label: 'Files',
                onTap: _pickFile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle( fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(TaskAttachment attachment, int index) {
    return Container(
      key: ValueKey(attachment.id),
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: attachment.type == AttachmentType.image
                ? Image.file(
                    File(attachment.filePath),
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppTheme.errorColor, size: 40),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            attachment.fileName,
                            style: const TextStyle( fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          attachment.fileSizeFormatted,
                          style: const TextStyle( fontSize: 9),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() => _attachments.removeAt(index));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection() {
    double totalCost = _resources.fold(0, (sum, r) => sum + (r.unitCost ?? 0) * r.quantity);
    
    return Column(
      children: [
        // Column Headers
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Resource Name',
                  style: TextStyle(
                    
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  'Qty',
                  style: TextStyle(
                    
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        ..._resources.asMap().entries.map((entry) {
          int index = entry.key;
          return _buildResourceRow(index);
        }).toList(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _resources.add(ResourceUsed(
                id: const Uuid().v4(),
                name: '',
                quantity: 0,
                unit: 'pcs',
              ));
            });
          },
          icon: const Icon(Icons.add, color: AppTheme.primaryColor),
          label: const Text('Add Resource', style: TextStyle(color: AppTheme.primaryColor)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Resource Cost',
                style: TextStyle(
                  
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${totalCost.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildResourceRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: _resources[index].name,
              style: const TextStyle( fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Resource name',
                hintStyle: TextStyle( fontSize: 14),
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _resources[index] = ResourceUsed(
                  id: _resources[index].id,
                  name: value,
                  quantity: _resources[index].quantity,
                  unit: _resources[index].unit,
                  unitCost: _resources[index].unitCost,
                );
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: TextFormField(
              initialValue: _resources[index].quantity > 0 ? _resources[index].quantity.toString() : '',
              style: const TextStyle( fontSize: 14),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Qty',
                hintStyle: TextStyle( fontSize: 14),
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _resources[index] = ResourceUsed(
                  id: _resources[index].id,
                  name: _resources[index].name,
                  quantity: double.tryParse(value) ?? 0,
                  unit: _resources[index].unit,
                  unitCost: _resources[index].unitCost,
                );
                setState(() {});
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
            onPressed: () {
              if (_resources.length > 1) {
                setState(() => _resources.removeAt(index));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Save Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      
      setState(() {
        _attachments.add(TaskAttachment(
          id: const Uuid().v4(),
          fileName: image.name,
          filePath: image.path,
          type: AttachmentType.image,
          fileSize: fileSize,
          isUploaded: true,
        ));
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    
    if (result != null) {
      final file = result.files.first;
      setState(() {
        _attachments.add(TaskAttachment(
          id: const Uuid().v4(),
          fileName: file.name,
          filePath: file.path!,
          type: file.extension == 'pdf' ? AttachmentType.pdf : AttachmentType.other,
          fileSize: file.size,
          isUploaded: true,
        ));
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        final effectiveProjectId = _selectedProjectId ?? widget.projectId ?? '';
        final project = projectProvider.getProjectById(effectiveProjectId);
        
        final task = Task(
          id: widget.taskId ?? const Uuid().v4(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          createdAt: widget.taskId != null 
              ? (taskProvider.getTaskById(widget.taskId!)?.createdAt ?? DateTime.now())
              : DateTime.now(),
          location: _locationController.text.trim(),
          timeTakenMinutes: int.tryParse(_timeTakenController.text) ?? 0,
          projectId: effectiveProjectId,
          projectTitle: project?.title ?? 'No Project',
          status: _selectedStatus,
          attachments: _attachments,
          resources: _resources.where((r) => r.name.isNotEmpty && r.quantity > 0).toList(),
        );
        
        if (widget.taskId != null) {
          taskProvider.updateTask(task);
        } else {
          taskProvider.addTask(task);
        }
        
        if (mounted) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.taskId != null ? 'Task updated successfully ✅' : 'Task created successfully ✅'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving task: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }
}
