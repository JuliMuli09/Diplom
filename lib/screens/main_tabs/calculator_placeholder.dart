import 'package:flutter/material.dart';

class CalculatorPlaceholder extends StatelessWidget {
  const CalculatorPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Калькулятор',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Перейдите из раздела проектов',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}