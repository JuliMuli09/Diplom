import 'package:flutter/material.dart';

class MyStartupReportScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final VoidCallback? onEditProject;

  const MyStartupReportScreen({Key? key, required this.projectData, this.onEditProject}) : super(key: key);

  @override
  _MyStartupReportScreenState createState() => _MyStartupReportScreenState();
}

class _MyStartupReportScreenState extends State<MyStartupReportScreen> {
  late Map<String, dynamic> _results;
  bool _isLoading = true;

  // Вспомогательные функции для безопасного парсинга
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  void _calculateResults() {
    try {
      // 1. Извлечение данных из проекта
      double revenue = _toDouble(widget.projectData['revenue']); // Выручка
      double operatingExpenses = _toDouble(widget.projectData['operatingExpenses']); // Расходы
      double cash = _toDouble(widget.projectData['cash']);
      double loans = _toDouble(widget.projectData['loans']);
      String taxSystem = widget.projectData['taxSystem'] ?? 'УСН 6%';
      int monthsSinceLaunch = _toInt(widget.projectData['monthsSinceLaunch']);
      int activeUsers = _toInt(widget.projectData['activeUsers']);
      double avgCheck = _toDouble(widget.projectData['avgCheck']);
      double revenueGrowth = _toDouble(widget.projectData['revenueGrowth']);
      double desiredInvestment = _toDouble(widget.projectData['desiredInvestment']);
      double equityForInvestor = _toDouble(widget.projectData['equityForInvestor']);
      String industry = widget.projectData['industry'] ?? 'IT';

      // 2. Расчет чистой прибыли с учетом налогов
      double netProfit = 0;
      double taxableBase = revenue - operatingExpenses;

      switch (taxSystem) {
        case 'УСН 6%': // Налог 6% от выручки
          double tax = revenue * 0.06;
          netProfit = revenue - operatingExpenses - tax;
          break;

        case 'УСН 15%': // Налог 15% от прибыли (доходы - расходы)
          double profit = revenue - operatingExpenses;
          double tax = profit > 0 ? profit * 0.15 : 0;
          netProfit = profit - tax;
          break;

        case 'ОСНО': // Налог на прибыль 20%
          double profit = revenue - operatingExpenses;
          double tax = profit > 0 ? profit * 0.20 : 0;
          netProfit = profit - tax;
          break;

        case 'Самозанятость': // Налог 4-6% от дохода (в среднем 5%)
          double tax = revenue * 0.05;
          netProfit = revenue - operatingExpenses - tax;
          break;

        default:
          netProfit = revenue - operatingExpenses;
      }

      // 3. Текущая оценка компании по мультипликаторам
      double revenueMultiplier = _getRevenueMultiplier(industry);
      double profitMultiplier = _getProfitMultiplier(industry);
      double valuationByRevenue = revenue * revenueMultiplier;
      double valuationByProfit = netProfit * profitMultiplier;

      // 4. Оценка по инвестиционному раунду
      double postMoneyValuation = 0.0;
      double preMoneyValuation = 0.0;

      if (equityForInvestor > 0) {
        postMoneyValuation = desiredInvestment / (equityForInvestor / 100);
        preMoneyValuation = postMoneyValuation - desiredInvestment;
      }

      // 5. Runway
      double monthlyExpenses = operatingExpenses / 12;
      double runwayMonths = monthlyExpenses > 0 ? cash / monthlyExpenses : 0;

      // 6. Дополнительные метрики
      double revenuePerUser = activeUsers > 0 ? revenue / activeUsers : 0;

      setState(() {
        _results = {
          // Исходные данные
          'name': widget.projectData['name'],
          'industry': industry,
          'monthsSinceLaunch': monthsSinceLaunch,
          'taxSystem': taxSystem,
          'activeUsers': activeUsers,
          'avgCheck': avgCheck,
          'revenueGrowth': revenueGrowth,
          'desiredInvestment': desiredInvestment,
          'equityForInvestor': equityForInvestor,
          'revenue': revenue,
          'operatingExpenses': operatingExpenses,
          'cash': cash,

          // Рассчитанные показатели
          'netProfit': netProfit,
          'taxableBase': taxableBase,
          'revenueMultiplier': revenueMultiplier,
          'profitMultiplier': profitMultiplier,
          'valuationByRevenue': valuationByRevenue,
          'valuationByProfit': valuationByProfit,
          'preMoneyValuation': preMoneyValuation,
          'postMoneyValuation': postMoneyValuation,
          'runwayMonths': runwayMonths,
          'revenuePerUser': revenuePerUser,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _results = {'error': 'Ошибка расчета: $e'};
      });
    }
  }

  // Мультипликаторы по выручке
  double _getRevenueMultiplier(String industry) {
    switch (industry) {
      case 'IT': return 5.25; // среднее 4.5-6.0
      case 'Электронная коммерция': return 1.6; // среднее 1.2-2.0
      case 'Финансовые технологии': return 4.0; // среднее 3.0-5.0
      case 'Пищевая индустрия': return 2.25; // среднее 1.5-3.0
      case 'Медицина': return 3.25; // среднее 2.5-4.0
      case 'Образование': return 3.0;
      default: return 3.0;
    }
  }

  // Мультипликаторы по прибыли
  double _getProfitMultiplier(String industry) {
    switch (industry) {
      case 'IT': return 20.0; // среднее 15-25
      case 'Электронная коммерция': return 11.5; // среднее 8-15
      case 'Финансовые технологии': return 16.0; // среднее 12-20
      case 'Пищевая индустрия': return 14.0; // среднее 10-18
      case 'Медицина': return 17.0; // среднее 12-22
      case 'Образование': return 15.0;
      default: return 12.0;
    }
  }

  // Форматирование валюты
  String _formatCurrency(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)} млрд ₽';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)} млн ₽';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)} тыс ₽';
    return '${value.toStringAsFixed(0)} ₽';
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_results.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 20),
          Text('${_results['error']}'),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Назад')),
        ])),
      );
    }

    double preMoney = _results['preMoneyValuation'] ?? 0;
    double runway = _results['runwayMonths'] ?? 0;
    double netProfit = _results['netProfit'] ?? 0;
    double valuationByRevenue = _results['valuationByRevenue'] ?? 0;
    double valuationByProfit = _results['valuationByProfit'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_results['name'] ?? 'Отчет по стартапу'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Ключевая оценка (Pre-money)
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.business_center, color: Colors.purple, size: 32),
                      const SizedBox(width: 10),
                      Text('Оценка компании', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[800])),
                    ]),
                    const SizedBox(height: 10),
                    Text('Pre-money: ${_formatCurrency(preMoney)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Post-money: ${_formatCurrency(_results['postMoneyValuation'] ?? 0)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(' Запрашивают: ${_formatCurrency(_results['desiredInvestment'] ?? 0)} за ${(_results['equityForInvestor'] ?? 0).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ПЛАШКА "Что это означает"
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(' ЧТО ЭТО ОЗНАЧАЕТ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 10),
                    _buildExplanation('Runway', 'Сколько месяцев компания проработает без новых инвестиций. Норма: > 6-12 месяцев.'),
                    _buildExplanation('Pre-money оценка', 'Стоимость компании ДО получения инвестиций. = Post-money минус сумма инвестиций.'),
                    _buildExplanation('Post-money оценка', 'Стоимость компании ПОСЛЕ получения инвестиций. = Инвестиции / (% доли инвестора).'),
                    _buildExplanation('Мультипликаторы P/S и P/E', 'Во сколько раз оценка компании превышает выручку (P/S) или прибыль (P/E). Чем выше, тем дороже компания.'),
                    _buildExplanation('Чистая прибыль', 'Выручка минус расходы минус налоги. Реальный заработок компании.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Карточка: Оценка по рынку
            _buildInfoCard('Мультипликаторные оценки', Icons.trending_up, [
              _buildInfoRow(' По выручке (P/S = ${_results['revenueMultiplier'].toStringAsFixed(1)}):', _formatCurrency(valuationByRevenue)),
              _buildInfoRow(' По прибыли (P/E = ${_results['profitMultiplier'].toStringAsFixed(1)}):', _formatCurrency(valuationByProfit)),
              const Divider(height: 16),
            ]),
            const SizedBox(height: 16),

            // Карточка: Финансовые показатели
            _buildInfoCard('Финансовые показатели', Icons.assessment, [
              _buildInfoRow(' Выручка (12 мес):', _formatCurrency(_results['revenue'] ?? 0)),
              _buildInfoRow(' Расходы (12 мес):', _formatCurrency(_results['operatingExpenses'] ?? 0)),
              _buildInfoRow(' Чистая прибыль:', _formatCurrency(netProfit),
                  valueColor: netProfit >= 0 ? Colors.green : Colors.red),
              _buildInfoRow(' Runway (мес):', '${runway.toStringAsFixed(1)} мес',
                  valueColor: runway >= 12 ? Colors.green : (runway >= 6 ? Colors.orange : Colors.red)),
            ]),
            const SizedBox(height: 16),

            // Карточка: Детали расчета чистой прибыли
            _buildInfoCard('Детали расчета налога', Icons.calculate, [
              _buildInfoRow(' Выручка:', _formatCurrency(_results['revenue'] ?? 0)),
              _buildInfoRow(' Расходы:', _formatCurrency(_results['operatingExpenses'] ?? 0)),
              _buildInfoRow(' Система:', _results['taxSystem'] ?? ''),
              _buildInfoRow(' Чистая прибыль:', _formatCurrency(netProfit)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getTaxExplanation(_results['taxSystem'] ?? '', _results['revenue'] ?? 0, _results['operatingExpenses'] ?? 0),
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Кнопка редактирования
            Center(
              child: ElevatedButton.icon(
                onPressed: _editProject,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Редактировать проект',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTaxExplanation(String taxSystem, double revenue, double expenses) {
    double profit = revenue - expenses;
    switch (taxSystem) {
      case 'УСН 6%':
        double tax = revenue * 0.06;
        return 'УСН 6%: налог ${_formatCurrency(tax)} (6% от выручки)';
      case 'УСН 15%':
        double tax = profit > 0 ? profit * 0.15 : 0;
        return 'УСН 15%: налог ${_formatCurrency(tax)} (15% от прибыли)';
      case 'ОСНО':
        double tax = profit > 0 ? profit * 0.20 : 0;
        return 'ОСНО: налог ${_formatCurrency(tax)} (20% от прибыли)';
      case 'Самозанятость':
        double tax = revenue * 0.05;
        return 'Самозанятость: налог ${_formatCurrency(tax)} (≈5% от выручки)';
      default:
        return '';
    }
  }

  Widget _buildExplanation(String term, String explanation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: RichText(text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 14), children: [
          TextSpan(text: '$term: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: explanation),
        ]))),
      ]),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> rows) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: Colors.purple), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          ...rows,
        ]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
      ]),
    );
  }
}