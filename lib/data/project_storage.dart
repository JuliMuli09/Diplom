import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProjectStorage {
  // Генерируем уникальный ключ для каждого пользователя
  static Future<String> _getProjectsKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? 'default';
    return 'saved_projects_$userEmail';
  }

  // Получить все проекты текущего пользователя
  static Future<List<Map<String, dynamic>>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getProjectsKey();
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Сохранить все проекты текущего пользователя
  static Future<void> saveProjects(List<Map<String, dynamic>> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getProjectsKey();
    final jsonString = jsonEncode(projects);
    await prefs.setString(key, jsonString);
  }

  // Получить проекты по типу
  static Future<List<Map<String, dynamic>>> getProjectsByType(String type) async {
    final allProjects = await getProjects();
    return allProjects.where((project) => project['type'] == type).toList();
  }

  // Очистить все проекты текущего пользователя
  static Future<void> clearAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getProjectsKey();
    await prefs.remove(key);
  }

  // Очистить проекты определенного типа у текущего пользователя
  static Future<void> clearProjectsByType(String type) async {
    final allProjects = await getProjects();
    final filteredProjects = allProjects.where((p) => p['type'] != type).toList();
    await saveProjects(filteredProjects);
  }
}