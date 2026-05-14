import 'package:flutter/material.dart';
import 'business_projects_screen.dart';

class BusinessSubcategoriesScreen extends StatelessWidget {
  final String projectType = 'Бизнес';
  final Color projectColor = Colors.amber;
  final IconData projectIcon = Icons.store;

  const BusinessSubcategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бизнес'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Плитка "Денежные потоки"
            _buildSubcategoryTile(
              context,
              title: 'Денежные потоки',
              description: 'Оценка бизнеса на основе прогноза денежных потоков. Расчет NPV, IRR, срока окупаемости.',
              icon: Icons.analytics,
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessProjectsScreen(
                      subcategory: 'Денежные потоки',
                      projectColor: Colors.amber,
                      projectIcon: Icons.analytics,
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