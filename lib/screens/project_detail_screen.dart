import 'package:flutter/material.dart';
import 'package:diplom/screens/main_tabs/calculator_tab.dart';
import 'package:diplom/screens/report_screen.dart';
import 'package:diplom/data/project_storage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectType;
  final Color projectColor;
  final IconData projectIcon;

  const ProjectDetailScreen({
    Key? key,
    required this.projectType,
    required this.projectColor,
    required this.projectIcon,
  }) : super(key: key);

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  List<Map<String, dynamic>> _savedProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await ProjectStorage.getProjectsByType(widget.projectType);
      setState(() {
        _savedProjects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCalculator({Map<String, dynamic>? projectToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorTab(
          projectType: widget.projectType,
          projectData: projectToEdit,
          onProjectSaved: (projectData) async {
            await _saveOrUpdateProject(projectData, isEdit: projectToEdit != null);
            return projectData;
          },
        ),
      ),
    );

    if (result != null) {
      await _loadProjects();
    }
  }

  Future<void> _saveOrUpdateProject(Map<String, dynamic> projectData, {bool isEdit = false}) async {
    try {
      projectData['type'] = widget.projectType;

      if (isEdit) {
        projectData['createdAt'] = projectData['createdAt'] ?? DateTime.now().toIso8601String();
      } else {
        projectData['createdAt'] = DateTime.now().toIso8601String();
      }

      projectData['updatedAt'] = DateTime.now().toIso8601String();

      final allProjects = await ProjectStorage.getProjects();

      if (isEdit) {
        final projectName = projectData['name'];
        final projectType = projectData['type'];
        final index = allProjects.indexWhere((p) =>
        p['name'] == projectName && p['type'] == projectType);

        if (index != -1) {
          allProjects[index] = projectData;
        } else {
          allProjects.add(projectData);
        }
      } else {
        allProjects.add(projectData);
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(allProjects);
      await prefs.setString('saved_projects', jsonString);

      await _loadProjects();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Проект "${projectData['name']}" ${isEdit ? 'обновлен' : 'сохранен'}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка ${isEdit ? 'обновления' : 'сохранения'}: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // МЕТОД ДЛЯ ПОКАЗА ОТЧЕТА
  void _showReport(Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(
          projectData: project,
          onEditProject: () {
            Navigator.pop(context);
            _navigateToCalculator(projectToEdit: project);
          },
        ),
      ),
    );
  }

  // МЕТОД ДЛЯ УДАЛЕНИЯ ПРОЕКТА
  Future<void> _deleteProject(int index) async {
    if (index >= 0 && index < _savedProjects.length) {
      final projectName = _savedProjects[index]['name'];

      try {
        await ProjectStorage.deleteProject(index, widget.projectType);
        await _loadProjects();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Проект "$projectName" удален'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllProjects() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Text(
          'Удалить все проекты типа "${widget.projectType}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final allProjects = await ProjectStorage.getProjects();
        final filteredProjects = allProjects
            .where((p) => p['type'] != widget.projectType)
            .toList();

        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(filteredProjects);
        await prefs.setString('saved_projects', jsonString);

        await _loadProjects();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Все проекты "${widget.projectType}" удалены'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Проекты: ${widget.projectType}'),
        centerTitle: true,
        backgroundColor: widget.projectColor,
        actions: [
          if (_savedProjects.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllProjects,
              tooltip: 'Удалить все проекты',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedProjects.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.projectIcon,
              size: 80,
              color: widget.projectColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Нет созданных проектов',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Нажмите + чтобы создать первый проект',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadProjects,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _savedProjects.length,
          itemBuilder: (context, index) {
            final project = _savedProjects[index];
            final createdAt = project['createdAt'] != null
                ? DateTime.parse(project['createdAt'])
                : DateTime.now();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.projectColor,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  project['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project['description'] != null &&
                        project['description'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(project['description']),
                      ),
                    Text(
                      'Создан: ${_formatDate(createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (project['investment'] != null)
                      Text(
                        'Инвестиции: ${project['investment']} руб.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.analytics, color: Colors.blue),
                      onPressed: () {
                        _showReport(project);
                      },
                      tooltip: 'Смотреть отчет',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProject(index);
                      },
                    ),
                  ],
                ),
                onTap: () {},
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.projectColor,
        onPressed: () {
          _navigateToCalculator();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
