import 'package:flutter/material.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_tabs/projects_tab.dart';
import 'screens/main_tabs/settings_tab.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Инвест-Оценка',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RegisterScreen(), // начинаем с регистрации/входа
    );
  }
}

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({Key? key}) : super(key: key);

  @override
  _MainTabsScreenState createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Инвест-Оценка'),
        centerTitle: true,
      ),
      body: _getCurrentTab(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _getCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return ProjectsTab(
          onProjectCreated: () {},
        );
      case 1:
        return const SettingsTab();
      default:
        return ProjectsTab(onProjectCreated: () {});
    }
  }
}