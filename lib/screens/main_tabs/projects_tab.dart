import 'package:flutter/material.dart';
import 'package:diplom/screens/project_detail_screen.dart';
import 'package:diplom/screens/real_estate/real_estate_subcategories_screen.dart';
import 'package:diplom/screens/startup/startup_subcategories_screen.dart';
import 'package:diplom/screens/business/business_subcategories_screen.dart';
import 'package:diplom/screens/startup/startup_subcategories_screen.dart';

class ProjectsTab extends StatefulWidget {
  final VoidCallback onProjectCreated;

  const ProjectsTab({
    Key? key,
    required this.onProjectCreated,
  }) : super(key: key);

  @override
  _ProjectsTabState createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _projects = [
        {
          'id': 1,
          'name': 'Недвижимость',
          'description': 'Материальный актив для дохода от аренды или роста цены',
          'risk': 'Низкий',
          'color': Colors.green,
          'icon': Icons.home,
        },
        {
          'id': 2,
          'name': 'Бизнес',
          'description': 'Система для получения стабильной прибыли от продаж товаров/услуг',
          'risk': 'Средний',
          'color': Colors.amber,
          'icon': Icons.store,
        },
        {
          'id': 3,
          'name': 'Стартап',
          'description': 'Высокорисковый проект для быстрого роста стоимости и продажи',
          'risk': 'Высокий',
          'color': Colors.red,
          'icon': Icons.rocket_launch,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _projects.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Нет проектов',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          _buildProjectTile(_projects[0]),
          const SizedBox(height: 16),
          _buildProjectTile(_projects[1]),
          const SizedBox(height: 16),
          _buildProjectTile(_projects[2]),
        ],
      ),
    );
  }

  Widget _buildProjectTile(Map<String, dynamic> project) {
    Color riskColor;
    IconData riskIcon;

    switch (project['risk']) {
      case 'Низкий':
        riskColor = Colors.green;
        riskIcon = Icons.shield;
        break;
      case 'Средний':
        riskColor = Colors.amber;
        riskIcon = Icons.warning;
        break;
      case 'Высокий':
        riskColor = Colors.red;
        riskIcon = Icons.dangerous;
        break;
      default:
        riskColor = Colors.grey;
        riskIcon = Icons.help;
    }

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
                // Кружок с иконкой
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: project['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    project['icon'],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Название проекта
                Expanded(
                  child: Text(
                    project['name'],
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
              project['description'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 12),
            // Риск
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: riskColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    riskIcon,
                    size: 14,
                    color: riskColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Риск: ${project['risk']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка "Перейти" в нижнем правом углу
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  _navigateToProject(project['id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: project['color'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Перейти',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProject(int projectId) {
    // Определяем тип проекта по ID
    String projectType = '';
    Color projectColor = Colors.grey;
    IconData projectIcon = Icons.help;

    switch (projectId) {
      case 1: // Недвижимость
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RealEstateSubcategoriesScreen(),
          ),
        );
        return;
      case 2: // Бизнес
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BusinessSubcategoriesScreen(),
          ),
        );
        return;
      case 3: // Стартап
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StartupSubcategoriesScreen(),
          ),
        );
        return;
    }
  }
}