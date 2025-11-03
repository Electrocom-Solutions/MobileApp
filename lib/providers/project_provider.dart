import 'package:flutter/foundation.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  String _searchQuery = '';
  ProjectStatus? _filterStatus;
  bool _showOnlyMyProjects = false;

  List<Project> get projects {
    var filtered = _projects;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.clientName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((p) => p.status == _filterStatus).toList();
    }

    if (_showOnlyMyProjects) {
      filtered = filtered.where((p) => p.isMyProject).toList();
    }

    return filtered;
  }

  String get searchQuery => _searchQuery;
  ProjectStatus? get filterStatus => _filterStatus;
  bool get showOnlyMyProjects => _showOnlyMyProjects;

  ProjectProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _projects = [
      Project(
        id: '1',
        title: 'Office Network Upgrade',
        clientName: 'TechCorp Solutions',
        description: 'Complete network infrastructure upgrade for corporate office',
        startDate: DateTime(now.year, now.month - 1, 1),
        endDate: DateTime(now.year, now.month + 1, 30),
        status: ProjectStatus.inProgress,
        isMyProject: true,
      ),
      Project(
        id: '2',
        title: 'Smart Home Installation',
        clientName: 'Residential Client',
        description: 'IoT devices and automation system installation',
        startDate: DateTime(now.year, now.month, 15),
        endDate: DateTime(now.year, now.month, 28),
        status: ProjectStatus.inProgress,
        isMyProject: true,
      ),
      Project(
        id: '3',
        title: 'Data Center Setup',
        clientName: 'CloudServe Inc',
        description: 'New data center electrical and cooling infrastructure',
        startDate: DateTime(now.year, now.month + 1, 1),
        status: ProjectStatus.planned,
        isMyProject: false,
      ),
      Project(
        id: '4',
        title: 'Solar Panel Installation',
        clientName: 'Green Energy Ltd',
        description: 'Commercial solar panel system installation',
        startDate: DateTime(now.year, now.month - 2, 1),
        endDate: DateTime(now.year, now.month - 1, 15),
        status: ProjectStatus.completed,
        isMyProject: true,
      ),
    ];
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(ProjectStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void toggleMyProjects() {
    _showOnlyMyProjects = !_showOnlyMyProjects;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _showOnlyMyProjects = false;
    notifyListeners();
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addProject(Project project) async {
    _projects.insert(0, project);
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }
}
