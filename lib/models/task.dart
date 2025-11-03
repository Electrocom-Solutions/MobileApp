enum TaskStatus { draft, toDo, inProgress, completed, pendingApproval, approved, rejected }

enum AttachmentType { image, pdf, other }

class TaskAttachment {
  final String id;
  final String fileName;
  final String filePath;
  final AttachmentType type;
  final int fileSize;
  final String? thumbnailPath;
  final bool isUploaded;
  final bool isUploading;
  final double uploadProgress;

  TaskAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.fileSize,
    this.thumbnailPath,
    this.isUploaded = false,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  TaskAttachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    AttachmentType? type,
    int? fileSize,
    String? thumbnailPath,
    bool? isUploaded,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return TaskAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isUploaded: isUploaded ?? this.isUploaded,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class ResourceUsed {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double? unitCost;

  ResourceUsed({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.unitCost,
  });

  double get totalCost => (unitCost ?? 0) * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitCost': unitCost,
    };
  }

  factory ResourceUsed.fromJson(Map<String, dynamic> json) {
    return ResourceUsed(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitCost: json['unitCost'],
    );
  }
}

class Task {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int timeTakenMinutes;
  final String projectId;
  final String projectTitle;
  final TaskStatus status;
  final List<TaskAttachment> attachments;
  final List<ResourceUsed> resources;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.createdAt,
    this.location,
    this.latitude,
    this.longitude,
    required this.timeTakenMinutes,
    required this.projectId,
    required this.projectTitle,
    required this.status,
    required this.attachments,
    required this.resources,
  });

  String get statusText {
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

  String get timeTakenFormatted {
    final hours = timeTakenMinutes / 60;
    return '$timeTakenMinutes min (${hours.toStringAsFixed(1)} hrs)';
  }

  double get totalResourceCost {
    return resources.fold(0, (sum, resource) => sum + resource.totalCost);
  }

  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    String? location,
    double? latitude,
    double? longitude,
    int? timeTakenMinutes,
    String? projectId,
    String? projectTitle,
    TaskStatus? status,
    List<TaskAttachment>? attachments,
    List<ResourceUsed>? resources,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timeTakenMinutes: timeTakenMinutes ?? this.timeTakenMinutes,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      resources: resources ?? this.resources,
    );
  }
}
