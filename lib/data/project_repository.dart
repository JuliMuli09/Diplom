import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProjectRepository {
  static const String _projectsKey = 'saved_projects';

  // Получить все проекты
  static Future<List<Map<String, dynamic>>> getAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_projectsKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Сохранить проект
  static Future<void> saveProject(Map<String, dynamic> project, {bool isUpdate = false}) async {
    final allProjects = await getAllProjects();

    if (isUpdate) {
      // Обновляем существующий проект
      final projectName = project['name'];
      final projectType = project['type'];
      final index = allProjects.indexWhere((p) =>
      p['name'] == projectName && p['type'] == projectType);

      if (index != -1) {
        allProjects[index] = project;
      } else {
        allProjects.add(project);
      }
    } else {
      // Добавляем новый проект
      allProjects.add(project);
    }

    await _saveAllProjects(allProjects);
  }

  // Обновить проект по индексу
  static Future<void> updateProject(int index, Map<String, dynamic> project) async {
    final allProjects = await getAllProjects();

    if (index >= 0 && index < allProjects.length) {
      // Сохраняем оригинальную дату создания
      project['createdAt'] = allProjects[index]['createdAt'];
      project['updatedAt'] = DateTime.now().toIso8601String();

      allProjects[index] = project;
      await _saveAllProjects(allProjects);
    }
  }

  // Сохранить все проекты
  static Future<void> _saveAllProjects(List<Map<String, dynamic>> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(projects);
    await prefs.setString(_projectsKey, jsonString);
  }

  // Найти проект по имени и типу
  static Future<int> findProjectIndex(String name, String type) async {
    final projects = await getAllProjects();
    return projects.indexWhere((p) => p['name'] == name && p['type'] == type);
  }
}