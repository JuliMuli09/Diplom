import 'package:flutter/material.dart';
import 'startup_projects_screen.dart';

class StartupSubcategoriesScreen extends StatelessWidget {
  final String projectType = 'Стартап';
  final Color projectColor = Colors.red;
  final IconData projectIcon = Icons.rocket_launch;

  const StartupSubcategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Стартап'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Плитка "Мой стартап"
            _buildSubcategoryTile(
              context,
              title: 'Мой стартап',
              description: 'Оценка собственного стартапа. Введите параметры и узнайте стоимость своей компании.',
              icon: Icons.business_center,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartupProjectsScreen(
                      subcategory: 'Мой стартап',
                      projectColor: Colors.purple,
                      projectIcon: Icons.business_center,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Плитка "Я-инвестор"
            _buildSubcategoryTile(
              context,
              title: 'Я-инвестор',
              description: 'Оценка стартапа для входа. Проверьте, справедливо ли основатели оценили компанию.',
              icon: Icons.trending_up,
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartupProjectsScreen(
                      subcategory: 'Я-инвестор',
                      projectColor: Colors.amber,
                      projectIcon: Icons.trending_up,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryTile(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка с иконкой и названием
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Описание
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка "Перейти"
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Перейти',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}