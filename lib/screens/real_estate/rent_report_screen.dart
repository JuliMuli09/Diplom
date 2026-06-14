import 'package:flutter/material.dart';
import 'dart:math';

class RentReportScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final VoidCallback? onEditProject;

  const RentReportScreen({
    Key? key,
    required this.projectData,
    this.onEditProject,
  }) : super(key: key);

  @override
  _RentReportScreenState createState() => _RentReportScreenState();
}

class _RentReportScreenState extends State<RentReportScreen> {
  late Map<String, dynamic> _calculatedResults;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculatedResults = {};
    _calculateResults();
  }

  void _calculateResults() {
    try {
      // Исходные данные из проекта
      final area = widget.projectData['area']?.toDouble() ?? 0.0; // Площадь
      final rentRate = widget.projectData['rentRate']?.toDouble() ?? 0.0; // Арендная ставка
      final tenantChangePeriod = widget.projectData['tenantChangePeriod']?.toInt() ?? 36; // Период смены арендатора
      final downtime = widget.projectData['downtime']?.toInt() ?? 2; // Простой
      final utilities = widget.projectData['utilities']?.toDouble() ?? 0.0; // Коммунальные платежи
      final majorRepairs = widget.projectData['majorRepairs']?.toDouble() ?? 0.0; // Капремонт
      final cadastralValue = widget.projectData['cadastralValue']?.toDouble() ?? 0.0; // Кадастровая стоимость

      // Фиксированные параметры
      final marketRisk = widget.projectData['marketRisk']?.toDouble() ?? 1.5; // Риск по рынку
      final taxRate = widget.projectData['taxRate']?.toDouble() ?? 2.0; // Ставка налога
      final insuranceRate = widget.projectData['insuranceRate']?.toDouble() ?? 0.1; // Страхование

      // Шаг 1: Расчет ПВД (Потенциальный валовой доход)
      // ПВД = Арендная ставка × Площадь × 12
      double pvd = rentRate * area * 12;

      // Шаг 2: Расчет коэффициента недозагрузки
      // Коэффициент недозагрузки = Простой / Период смены арендаторов
      double downtimeCoeff = downtime / tenantChangePeriod;

      // Шаг 3: Расчет общего коэффициента потерь
      // Kпот = Коэффициент недозагрузки + (Риск по рынку / 100)
      double lossCoeff = downtimeCoeff + (marketRisk / 100);

      // Шаг 4: Расчет ДВД (Действительный валовой доход)
      // ДВД = ПВД - (ПВД × Kпот)
      double dvd = pvd - (pvd * lossCoeff);

      // Шаг 5: Расчет операционных расходов (OPEX)

      // 5.1 Налог на имущество: Кадастровая стоимость × Ставка налога / 100
      double propertyTax = cadastralValue * (taxRate / 100);

      // 5.2 Коммунальные услуги (уже введены пользователем)
      double utilitiesCost = utilities;

      // 5.3 Страхование: Кадастровая стоимость × Ставка страхования / 100
      double insurance = cadastralValue * (insuranceRate / 100);

      // 5.4 Управление (5% от ДВД)
      double managementCost = dvd * 0.05;

      // 5.5 Резерв на капремонт (уже введен пользователем)
      double repairsReserve = majorRepairs;

      // Общий OPEX
      double opex = propertyTax + utilitiesCost + insurance + managementCost + repairsReserve;

      // Шаг 6: Расчет NOI (Чистый операционный доход)
      // NOI = ДВД - OPEX
      double noi = dvd - opex;

      // Дополнительные показатели
      double monthlyNOI = noi / 12;
      double profitability = (noi / (cadastralValue > 0 ? cadastralValue : 1)) * 100; // Рентабельность к кадастровой стоимости
      double paybackYears = cadastralValue > 0 ? cadastralValue / (noi > 0 ? noi : 1) : 0; // Срок окупаемости (лет)

      setState(() {
        _calculatedResults = {
          // Основные показатели
          'pvd': pvd,
          'downtimeCoeff': downtimeCoeff,
          'lossCoeff': lossCoeff,
          'dvd': dvd,
          'opex': opex,
          'noi': noi,

          // Детали OPEX
          'propertyTax': propertyTax,
          'utilitiesCost': utilitiesCost,
          'insurance': insurance,
          'managementCost': managementCost,
          'repairsReserve': repairsReserve,

          // Дополнительные показатели
          'monthlyNOI': monthlyNOI,
          'profitability': profitability,
          'paybackYears': paybackYears,

          // Исходные данные для отображения
          'area': area,
          'rentRate': rentRate,
          'tenantChangePeriod': tenantChangePeriod,
          'downtime': downtime,
          'cadastralValue': cadastralValue,
          'marketRisk': marketRisk,
          'taxRate': taxRate,
          'insuranceRate': insuranceRate,
        };
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _calculatedResults = {'error': 'Ошибка расчета: $e'};
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

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} руб';
  }

  String _formatPercent(double value) {
    return '${value.toStringAsFixed(2)}%';
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

    double noi = _calculatedResults['noi'] ?? 0;
    bool isProfitable = noi > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectData['name'] ?? 'Отчет по аренде'),
        backgroundColor: isProfitable ? Colors.green : Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Краткий итог
            Card(
              color: isProfitable ? Colors.green[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isProfitable ? Icons.check_circle : Icons.info,
                          color: isProfitable ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isProfitable ? 'Проект прибыльный' : 'Проект требует анализа',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isProfitable ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Чистый операционный доход (NOI): ${_formatCurrency(noi)}/год',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Пояснения к терминам
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Что означают эти показатели:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    _buildTermExplanation(
                      'ПВД (Потенциальный валовой доход)',
                      'Доход, который можно получить при 100% заполнении объекта в течение года',
                    ),
                    _buildTermExplanation(
                      'Коэффициент потерь',
                      'Учитывает простои между арендаторами и рыночные риски',
                    ),
                    _buildTermExplanation(
                      'ДВД (Действительный валовой доход)',
                      'Реальный доход с учетом потерь от недозагрузки',
                    ),
                    _buildTermExplanation(
                      'OPEX (Операционные расходы)',
                      'Все расходы на содержание объекта: налоги, коммуналка, страхование, управление, ремонт',
                    ),
                    _buildTermExplanation(
                      'NOI (Чистый операционный доход)',
                      'Доход после вычета всех операционных расходов (но до налогов и кредитов)',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Детальный расчет ПВД
            _buildCalculationCard(
              'ШАГ 1: ПВД (Потенциальный валовой доход)',
              [
                'Арендная ставка: ${_formatCurrency(_calculatedResults['rentRate'])}/м² в месяц',
                'Площадь: ${_calculatedResults['area']} м²',
                'ПВД = Арендная ставка × Площадь × 12',
                'ПВД = ${_formatCurrency(_calculatedResults['pvd'])}',
              ],
              Icons.calculate,
            ),

            const SizedBox(height: 16),

            // Расчет потерь
            _buildCalculationCard(
              'ШАГ 2: Расчет потерь',
              [
                'Период смены арендатора: ${_calculatedResults['tenantChangePeriod']} мес',
                'Простой: ${_calculatedResults['downtime']} мес',
                'Коэффициент недозагрузки = Простой / Период смены = ${(_calculatedResults['downtimeCoeff'] * 100).toStringAsFixed(2)}%',
                'Риск по рынку: ${_calculatedResults['marketRisk']}%',
                'Общий коэффициент потерь = ${(_calculatedResults['lossCoeff'] * 100).toStringAsFixed(2)}%',
                'Потери в рублях = ПВД × Коэф.потерь = ${_formatCurrency(_calculatedResults['pvd'] * _calculatedResults['lossCoeff'])}',
              ],
              Icons.trending_down,
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            // Расчет ДВД
            _buildCalculationCard(
              'ШАГ 3: ДВД (Действительный валовой доход)',
              [
                'ДВД = ПВД - Потери',
                'ДВД = ${_formatCurrency(_calculatedResults['pvd'])} - ${_formatCurrency(_calculatedResults['pvd'] * _calculatedResults['lossCoeff'])}',
                'ДВД = ${_formatCurrency(_calculatedResults['dvd'])}',
              ],
              Icons.trending_up,
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            // Расчет OPEX
            _buildCalculationCard(
              'ШАГ 4: OPEX (Операционные расходы)',
              [
                '1. Налог на имущество (${_calculatedResults['taxRate']}% от кадастровой стоимости):',
                '   ${_formatCurrency(_calculatedResults['propertyTax'])}',
                '2. Коммунальные платежи:',
                '   ${_formatCurrency(_calculatedResults['utilitiesCost'])}',
                '3. Страхование (${_calculatedResults['insuranceRate']}%):',
                '   ${_formatCurrency(_calculatedResults['insurance'])}',
                '4. Управление (5% от ДВД):',
                '   ${_formatCurrency(_calculatedResults['managementCost'])}',
                '5. Резерв на капремонт:',
                '   ${_formatCurrency(_calculatedResults['repairsReserve'])}',
                'ИТОГО OPEX = ${_formatCurrency(_calculatedResults['opex'])}',
              ],
              Icons.receipt,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            // Расчет NOI
            _buildCalculationCard(
              'ШАГ 5: NOI (Чистый операционный доход)',
              [
                'NOI = ДВД - OPEX',
                'NOI = ${_formatCurrency(_calculatedResults['dvd'])} - ${_formatCurrency(_calculatedResults['opex'])}',
                'NOI = ${_formatCurrency(_calculatedResults['noi'])}/год',
                '',
                'Ежемесячный чистый доход: ${_formatCurrency(_calculatedResults['monthlyNOI'])}',
              ],
              Icons.account_balance,
              color: Colors.purple,
            ),

            const SizedBox(height: 16),

            // Итоговые показатели
            Card(
              elevation: 4,
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ИТОГОВЫЕ ПОКАЗАТЕЛИ ЭФФЕКТИВНОСТИ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow(
                      'Рентабельность к кадастру:',
                      '${_calculatedResults['profitability'].toStringAsFixed(2)}%',
                    ),
                    _buildResultRow(
                      'Срок окупаемости (лет):',
                      '${_calculatedResults['paybackYears'].toStringAsFixed(1)} лет',
                    ),
                    _buildResultRow(
                      'Кадастровая стоимость:',
                      _formatCurrency(_calculatedResults['cadastralValue']),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка редактирования
            Center(
              child: ElevatedButton.icon(
                onPressed: _editProject,
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать проект'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermExplanation(String term, String explanation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$term: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: explanation),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard(String title, List<String> lines, IconData icon, {Color color = Colors.blue}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...lines.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}