import 'package:flutter/material.dart';

class AnalysisTab extends StatelessWidget {
  const AnalysisTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            'Анализ проектов',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Отчеты по вашим проектам',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {

            },
            icon: const Icon(Icons.list),
            label: const Text('Все отчеты'),
          ),
        ],
      ),
    );
  }
}