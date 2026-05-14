import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProjectStorage {
  static const String _projectsKey = 'saved_projects';

  // Получить все проекты
  static Future<List<Map<String, dynamic>>> getProjects() async {
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

  // Получить проекты по типу
  static Future<List<Map<String, dynamic>>> getProjectsByType(String type) async {
    final allProjects = await getProjects();
    return allProjects.where((project) => project['type'] == type).toList();
  }

  // Сохранить проект
  static Future<void> saveProject(Map<String, dynamic> project) async {
    final prefs = await SharedPreferences.getInstance();
    final existingProjects = await getProjects();
    existingProjects.add(project);
    final jsonString = jsonEncode(existingProjects);
    await prefs.setString(_projectsKey, jsonString);
  }

  // Обновить проект
  static Future<void> updateProject(int index, String type, Map<String, dynamic> updatedProject) async {
    final allProjects = await getProjects();
    final projectsByType = await getProjectsByType(type);

    if (index >= 0 && index < projectsByType.length) {
      final projectToUpdate = projectsByType[index];
      final projectIndex = allProjects.indexWhere((p) =>
      p['name'] == projectToUpdate['name'] &&
          p['type'] == projectToUpdate['type'] &&
          p['createdAt'] == projectToUpdate['createdAt']
      );

      if (projectIndex != -1) {
        allProjects[projectIndex] = updatedProject;
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(allProjects);
        await prefs.setString(_projectsKey, jsonString);
      }
    }
  }

  // Удалить проект
  static Future<void> deleteProject(int index, String type) async {
    final allProjects = await getProjects();
    final projectsByType = await getProjectsByType(type);

    if (index >= 0 && index < projectsByType.length) {
      final projectToDelete = projectsByType[index];
      allProjects.removeWhere((p) =>
      p['name'] == projectToDelete['name'] &&
          p['type'] == projectToDelete['type'] &&
          p['createdAt'] == projectToDelete['createdAt']
      );

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(allProjects);
      await prefs.setString(_projectsKey, jsonString);
    }
  }

  // Очистить все проекты
  static Future<void> clearAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_projectsKey);
  }

  // Очистить проекты определенного типа
  static Future<void> clearProjectsByType(String type) async {
    final allProjects = await getProjects();
    final filteredProjects = allProjects.where((p) => p['type'] != type).toList();

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(filteredProjects);
    await prefs.setString(_projectsKey, jsonString);
  }
}