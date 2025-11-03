enum ProjectStatus { planned, inProgress, completed }

class Project {
  final String id;
  final String title;
  final String clientName;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final bool isMyProject;

  Project({
    required this.id,
    required this.title,
    required this.clientName,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.status,
    this.isMyProject = false,
  });

  String get statusText {
    switch (status) {
      case ProjectStatus.planned:
        return 'Planned';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'clientName': clientName,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.toString(),
      'isMyProject': isMyProject,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      clientName: json['clientName'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProjectStatus.planned,
      ),
      isMyProject: json['isMyProject'] ?? false,
    );
  }
}
