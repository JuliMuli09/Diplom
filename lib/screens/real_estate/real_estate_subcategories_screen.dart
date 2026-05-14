import 'package:flutter/material.dart';
import 'real_estate_projects_screen.dart';

class RealEstateSubcategoriesScreen extends StatelessWidget {
  final String projectType = 'Недвижимость';
  final Color projectColor = Colors.green;
  final IconData projectIcon = Icons.home;

  const RealEstateSubcategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Недвижимость'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Плитка "Продажи"
            _buildSubcategoryTile(
              context,
              title: 'Продажи',
              description: 'Инвестиции в покупку и продажу недвижимости',
              icon: Icons.sell,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealEstateProjectsScreen(
                      subcategory: 'Продажи',
                      projectColor: Colors.blue,
                      projectIcon: Icons.sell,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Плитка "Аренда"
            _buildSubcategoryTile(
              context,
              title: 'Аренда',
              description: 'Инвестиции в арендный бизнес',
              icon: Icons.key,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealEstateProjectsScreen(
                      subcategory: 'Аренда',
                      projectColor: Colors.orange,
                      projectIcon: Icons.key,
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