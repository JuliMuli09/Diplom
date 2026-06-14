import 'package:flutter/material.dart';
import 'dart:math';

class ReportScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final VoidCallback? onEditProject;

  const ReportScreen({
    Key? key,
    required this.projectData,
    this.onEditProject,
  }) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Map<String, dynamic> _calculatedResults;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculatedResults = {};
    _calculateResults();
  }

  // РАСЧЕТ ДЕНЕЖНЫХ ПОТОКОВ
  Map<String, dynamic> _calculateCashFlows() {

    final investment = widget.projectData['investment']?.toDouble() ?? 0.0;
    final monthlyFixedCosts = widget.projectData['fixedCosts']?.toDouble() ?? 0.0;
    final variableCostPerUnit = widget.projectData['variableCosts']?.toDouble() ?? 0.0;
    final months = widget.projectData['period']?.toInt() ?? 1;
    final pricePerUnit = widget.projectData['price']?.toDouble() ?? 0.0;

    // Простые предположения для бизнес-расчетов
    double monthlyUnits = investment / 1000; // 1 единица на 1000 руб инвестиций
    if (monthlyUnits < 5) monthlyUnits = 5.0; // минимум 5 единиц

    List<double> monthlyCashFlows = [];
    List<double> monthlyRevenues = [];
    List<double> monthlyCosts = [];

    for (int month = 1; month <= months; month++) {
      // Объем продаж (растет на 2% в месяц)
      double units = monthlyUnits * pow(1.02, month - 1);

      // Выручка
      double revenue = units * pricePerUnit;

      // Затраты
      double variableCost = variableCostPerUnit * units;
      double totalCost = monthlyFixedCosts + variableCost;

      // Денежный поток
      double cashFlow = revenue - totalCost;

      monthlyRevenues.add(revenue);
      monthlyCosts.add(totalCost);
      monthlyCashFlows.add(cashFlow);
    }

    // Годовые потоки
    List<double> annualCashFlows = [];
    int years = (months / 12).ceil();

    for (int year = 0; year < years; year++) {
      double annualFlow = 0;
      int startMonth = year * 12;
      int endMonth = min(startMonth + 12, months);

      for (int month = startMonth; month < endMonth; month++) {
        if (month < monthlyCashFlows.length) {
          annualFlow += monthlyCashFlows[month];
        }
      }
      annualCashFlows.add(annualFlow);
    }

    return {
      'monthlyCashFlows': monthlyCashFlows,
      'annualCashFlows': annualCashFlows,
      'monthlyRevenues': monthlyRevenues,
      'monthlyCosts': monthlyCosts,
      'initialUnits': monthlyUnits,
      'months': months,
    };
  }

  // ФОРМУЛА NPV
  double _calculateNPV(List<double> annualCashFlows, double discountRate, double investment) {
    double npv = -investment;

    for (int year = 0; year < annualCashFlows.length; year++) {
      npv += annualCashFlows[year] / pow(1 + discountRate / 100, year + 1);
    }

    return npv;
  }

  // ФОРМУЛА IRR
  double _calculateIRR(List<double> annualCashFlows, double investment) {
    if (annualCashFlows.isEmpty) return 0.0;

    // Метод деления пополам
    double low = -0.99;
    double high = 10.0; // до 1000%

    for (int i = 0; i < 50; i++) {
      double mid = (low + high) / 2;

      double npvMid = -investment;
      for (int year = 0; year < annualCashFlows.length; year++) {
        npvMid += annualCashFlows[year] / pow(1 + mid, year + 1);
      }

      double npvLow = -investment;
      for (int year = 0; year < annualCashFlows.length; year++) {
        npvLow += annualCashFlows[year] / pow(1 + low, year + 1);
      }

      if (npvMid.abs() < 0.001) {
        return mid * 100;
      }

      if (npvLow * npvMid < 0) {
        high = mid;
      } else {
        low = mid;
      }
    }

    return ((low + high) / 2) * 100;
  }

  // ФОРМУЛА PI (Индекс рентабельности)
  double _calculatePI(double npv, double investment) {
    if (investment == 0) return 0.0;
    return (npv + investment) / investment;
  }

  // Точка безубыточности
  double _calculateBreakEven(double fixedCosts, double price, double variableCost) {
    if (price <= variableCost) return double.infinity;
    return fixedCosts / (price - variableCost);
  }

  // Срок окупаемости (месяцы)
  double _calculatePayback(double investment, List<double> monthlyCashFlows) {
    double sum = 0;

    for (int month = 0; month < monthlyCashFlows.length; month++) {
      sum += monthlyCashFlows[month];
      if (sum >= investment) {
        return month + 1;
      }
    }

    return monthlyCashFlows.length.toDouble(); // не окупился
  }

  void _calculateResults() {
    try {
      // Исходные данные
      final investment = widget.projectData['investment']?.toDouble() ?? 0.0;
      final monthlyFixedCosts = widget.projectData['fixedCosts']?.toDouble() ?? 0.0;
      final variableCosts = widget.projectData['variableCosts']?.toDouble() ?? 0.0;
      final months = widget.projectData['period']?.toInt() ?? 1;
      final price = widget.projectData['price']?.toDouble() ?? 0.0;
      final discountRate = widget.projectData['discountRate']?.toDouble() ?? 10.0;

      // Денежные потоки
      Map<String, dynamic> flows = _calculateCashFlows();
      List<double> monthlyCashFlows = flows['monthlyCashFlows'] as List<double>;
      List<double> annualCashFlows = flows['annualCashFlows'] as List<double>;
      List<double> monthlyRevenues = flows['monthlyRevenues'] as List<double>;
      List<double> monthlyCosts = flows['monthlyCosts'] as List<double>;

      // Основные показатели
      double npv = _calculateNPV(annualCashFlows, discountRate, investment);
      double irr = _calculateIRR(annualCashFlows, investment);
      double pi = _calculatePI(npv, investment);
      double breakEven = _calculateBreakEven(monthlyFixedCosts, price, variableCosts);
      double payback = _calculatePayback(investment, monthlyCashFlows);

      // Итоговые суммы
      double totalRevenue = monthlyRevenues.isEmpty ? 0 : monthlyRevenues.reduce((a, b) => a + b);
      double totalCost = monthlyCosts.isEmpty ? 0 : monthlyCosts.reduce((a, b) => a + b);
      double totalProfit = totalRevenue - totalCost;
      double profitability = totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0;

      setState(() {
        _calculatedResults = {
          // Основные финансовые показатели
          'npv': npv,
          'irr': irr,
          'pi': pi,
          'breakEven': breakEven,
          'payback': payback,

          // Итоги
          'totalRevenue': totalRevenue,
          'totalCost': totalCost,
          'totalProfit': totalProfit,
          'profitability': profitability,
          'avgMonthlyProfit': months > 0 ? totalProfit / months : 0,

          // Параметры
          'investment': investment,
          'months': months,
          'years': months / 12.0,
          'discountRate': discountRate,
          'fixedCosts': monthlyFixedCosts,
          'variableCosts': variableCosts,
          'price': price,

          // Для отображения
          'monthlyCashFlows': monthlyCashFlows,
        };
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _calculatedResults = {'error': 'Ошибка: $e'};
      });
    }
  }

  void _editProject() {
    if (widget.onEditProject != null) {
      widget.onEditProject!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_calculatedResults.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text('${_calculatedResults['error']}'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      );
    }

    double npv = _calculatedResults['npv'] ?? 0;
    double irr = _calculatedResults['irr'] ?? 0;
    double pi = _calculatedResults['pi'] ?? 0;
    double discountRate = _calculatedResults['discountRate'] ?? 10;

    bool npvOk = npv >= 0;
    bool irrOk = irr >= discountRate;
    bool piOk = pi >= 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectData['name'] ?? 'Отчет'),
        backgroundColor: npvOk ? Colors.green : Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ИТОГОВОЕ РЕШЕНИЕ
            _buildDecisionCard(npvOk, irrOk, piOk),
            const SizedBox(height: 20),

            // ОСНОВНЫЕ ПОКАЗАТЕЛИ
            _buildMainMetricsCard(npv, irr, pi, discountRate),
            const SizedBox(height: 20),

            // ПАРАМЕТРЫ
            _buildParamsCard(),
            const SizedBox(height: 20),

            // РЕЗУЛЬТАТЫ
            _buildResultsCard(),
            const SizedBox(height: 20),

            // ФОРМУЛЫ
            _buildFormulasCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionCard(bool npvOk, bool irrOk, bool piOk) {
    int okCount = (npvOk ? 1 : 0) + (irrOk ? 1 : 0) + (piOk ? 1 : 0);
    String text = '';
    Color color = Colors.grey;

    if (okCount == 3) {
      text = '✓ ПРОЕКТ ПРИНИМАЕТСЯ';
      color = Colors.green;
    } else if (okCount >= 2) {
      text = '⚠ ПРОЕКТ НА ГРАНИ';
      color = Colors.orange;
    } else {
      text = '✗ ПРОЕКТ ОТКЛОНЯЕТСЯ';
      color = Colors.red;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assessment, color: color),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('${_calculatedResults['months']} мес · ${_calculatedResults['investment'].toStringAsFixed(0)} руб'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetricChip('NPV', npvOk),
                const SizedBox(width: 10),
                _buildMetricChip('IRR', irrOk),
                const SizedBox(width: 10),
                _buildMetricChip('PI', piOk),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, bool ok) {
    return Chip(
      label: Text(label),
      backgroundColor: ok ? Colors.green : Colors.red,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildMainMetricsCard(double npv, double irr, double pi, double discountRate) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'ОСНОВНЫЕ ПОКАЗАТЕЛИ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),

            _buildMetricRow('NPV', '${npv.toStringAsFixed(2)} руб', npv >= 0),
            _buildMetricRow('IRR', '${irr.toStringAsFixed(1)}%', irr >= discountRate),
            _buildMetricRow('PI', pi.toStringAsFixed(2), pi >= 1.0),
            _buildMetricRow('Срок окупаемости', '${_calculatedResults['payback'].toStringAsFixed(0)} мес', true),
            _buildMetricRow('Точка безубыточности', '${_calculatedResults['breakEven'].toStringAsFixed(0)} ед/мес', true),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool good) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: good ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ПАРАМЕТРЫ ПРОЕКТА',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildParamRow('Инвестиции:', '${_calculatedResults['investment'].toStringAsFixed(0)} руб'),
            _buildParamRow('Срок:', '${_calculatedResults['months']} месяцев'),
            _buildParamRow('Ставка дисконтирования:', '${_calculatedResults['discountRate']}%'),
            _buildParamRow('Постоянные затраты:', '${_calculatedResults['fixedCosts'].toStringAsFixed(0)} руб/мес'),
            _buildParamRow('Переменные затраты:', '${_calculatedResults['variableCosts'].toStringAsFixed(0)} руб/ед'),
            _buildParamRow('Цена:', '${_calculatedResults['price'].toStringAsFixed(0)} руб/ед'),
          ],
        ),
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ИТОГИ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildResultRow('Общая выручка:', '${_calculatedResults['totalRevenue'].toStringAsFixed(0)} руб'),
            _buildResultRow('Общие затраты:', '${_calculatedResults['totalCost'].toStringAsFixed(0)} руб'),
            _buildResultRow('Чистая прибыль:', '${_calculatedResults['totalProfit'].toStringAsFixed(0)} руб'),
            _buildResultRow('Рентабельность:', '${_calculatedResults['profitability'].toStringAsFixed(1)}%'),
            _buildResultRow('Средняя прибыль в месяц:', '${_calculatedResults['avgMonthlyProfit'].toStringAsFixed(0)} руб'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFormulasCard() {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ФОРМУЛЫ РАСЧЕТА',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('NPV = Σ[CFₜ / (1 + r)ᵗ] - I'),
            const Text('IRR: NPV = 0 при r = IRR'),
            const Text('PI = (NPV + I) / I'),
            const SizedBox(height: 10),
            const Text(
              'CFₜ - денежный поток в году t\n'
                  'r - ставка дисконтирования\n'
                  'I - инвестиции',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _editProject,
              child: const Text('Изменить проект'),
            ),
          ],
        ),
      ),
    );
  }
}