import 'package:flutter/material.dart';
import 'dart:math';

class BusinessReportScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final VoidCallback? onEditProject;

  const BusinessReportScreen({
    Key? key,
    required this.projectData,
    this.onEditProject,
  }) : super(key: key);

  @override
  _BusinessReportScreenState createState() => _BusinessReportScreenState();
}

class _BusinessReportScreenState extends State<BusinessReportScreen> {
  late Map<String, dynamic> _calculatedResults;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculatedResults = {};
    _calculateResults();
  }

  // ШАГ 1: Расчет чистой прибыли для каждого года
  List<double> _calculateNetProfit(
      List<double> revenues,
      List<double> fixedExpenses,
      List<double> variableExpenses,
      List<double> depreciations,
      double taxRate,
      bool hasLoan,
      double loanAmount,
      double loanRate,
      double loanRepayment,
      int years) {

    List<double> netProfits = [];

    double remainingLoan = hasLoan ? loanAmount : 0;

    for (int i = 0; i < years; i++) {
      // Выручка - операционные расходы
      double operatingProfit = revenues[i] - fixedExpenses[i] - variableExpenses[i] - depreciations[i];

      // Расчет процентов по кредиту
      double interest = 0;
      if (hasLoan && remainingLoan > 0) {
        interest = remainingLoan * (loanRate / 100);
      }

      // Прибыль до налогообложения
      double profitBeforeTax = operatingProfit - interest;

      // Налог
      double tax = profitBeforeTax > 0 ? profitBeforeTax * (taxRate / 100) : 0;

      // Чистая прибыль
      double netProfit = profitBeforeTax - tax;
      netProfits.add(netProfit);

      // Уменьшаем остаток кредита
      if (hasLoan) {
        remainingLoan -= loanRepayment;
        if (remainingLoan < 0) remainingLoan = 0;
      }
    }

    return netProfits;
  }

  // ШАГ 2: Расчет денежного потока (FCF)
  List<double> _calculateFCF(
      List<double> netProfits,
      List<double> depreciations,
      List<double> capexes,
      List<double> nwcChanges) {

    List<double> fcfs = [];

    for (int i = 0; i < netProfits.length; i++) {
      // FCF = Чистая прибыль + Амортизация - CAPEX - ΔNWC
      double fcf = netProfits[i] + depreciations[i] - capexes[i] - nwcChanges[i];
      fcfs.add(fcf);
    }

    return fcfs;
  }

  // ШАГ 3: Расчет терминальной стоимости (модель Гордона)
  double _calculateTerminalValue(double lastFCF, double growthRate, double discountRate) {
    if (discountRate <= growthRate) return 0;
    return lastFCF * (1 + growthRate / 100) / ((discountRate - growthRate) / 100);
  }

  // ШАГ 4: Расчет NPV
  double _calculateNPV(
      List<double> fcfs,
      double terminalValue,
      double discountRate,
      double initialInvestment) {

    double npv = -initialInvestment;

    for (int i = 0; i < fcfs.length; i++) {
      npv += fcfs[i] / pow(1 + discountRate / 100, i + 1);
    }

    // Добавляем терминальную стоимость
    npv += terminalValue / pow(1 + discountRate / 100, fcfs.length);

    return npv;
  }

  // ШАГ 5: Расчет IRR
  double _calculateIRR(
      List<double> fcfs,
      double terminalValue,
      double initialInvestment) {

    if (fcfs.isEmpty) return 0.0;

    // Метод деления пополам
    double low = -0.99;
    double high = 10.0; // до 1000%

    for (int iter = 0; iter < 50; iter++) {
      double mid = (low + high) / 2;

      double npvMid = -initialInvestment;
      for (int i = 0; i < fcfs.length; i++) {
        npvMid += fcfs[i] / pow(1 + mid, i + 1);
      }
      npvMid += terminalValue / pow(1 + mid, fcfs.length);

      double npvLow = -initialInvestment;
      for (int i = 0; i < fcfs.length; i++) {
        npvLow += fcfs[i] / pow(1 + low, i + 1);
      }
      npvLow += terminalValue / pow(1 + low, fcfs.length);

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

  // ШАГ 6: Расчет дисконтированного срока окупаемости
  double _calculateDiscountedPayback(
      List<double> fcfs,
      double terminalValue,
      double discountRate,
      double initialInvestment) {

    double cumulativeDiscounted = 0;

    for (int i = 0; i < fcfs.length; i++) {
      double discountedFCF = fcfs[i] / pow(1 + discountRate / 100, i + 1);
      cumulativeDiscounted += discountedFCF;

      if (cumulativeDiscounted >= initialInvestment) {

        double previousCumulative = cumulativeDiscounted - discountedFCF;
        double fraction = (initialInvestment - previousCumulative) / discountedFCF;
        return i + fraction;
      }
    }

    // Если не окупился за прогнозный период, учитываем терминальную стоимость
    double discountedTV = terminalValue / pow(1 + discountRate / 100, fcfs.length);
    if (cumulativeDiscounted + discountedTV >= initialInvestment) {
      return fcfs.length.toDouble();
    }

    return double.infinity; // Не окупается никогда
  }


  void _calculateResults() {
    try {
      // Извлекаем данные из проекта
      double initialInvestment = widget.projectData['initialInvestment']?.toDouble() ?? 0;
      double discountRate = widget.projectData['discountRate']?.toDouble() ?? 15;
      double growthRate = widget.projectData['longTermGrowthRate']?.toDouble() ?? 3;
      double taxRate = widget.projectData['taxRate']?.toDouble() ?? 20;

      bool hasLoan = widget.projectData['hasLoan'] ?? false;
      double loanAmount = widget.projectData['loanAmount']?.toDouble() ?? 0;
      double loanRate = widget.projectData['loanRate']?.toDouble() ?? 0;
      double loanRepayment = widget.projectData['loanRepayment']?.toDouble() ?? 0;

      List<dynamic> revenuesDynamic = widget.projectData['revenues'] ?? [];
      List<dynamic> fixedExpensesDynamic = widget.projectData['fixedExpenses'] ?? [];
      List<dynamic> variableExpensesDynamic = widget.projectData['variableExpenses'] ?? [];
      List<dynamic> depreciationsDynamic = widget.projectData['depreciations'] ?? [];
      List<dynamic> capexesDynamic = widget.projectData['capexes'] ?? [];
      List<dynamic> nwcChangesDynamic = widget.projectData['nwcChanges'] ?? [];

      int years = revenuesDynamic.length;


      List<double> revenues = revenuesDynamic.map((e) => _toDouble(e)).toList();
      List<double> fixedExpenses = fixedExpensesDynamic.map((e) => _toDouble(e)).toList();
      List<double> variableExpenses = variableExpensesDynamic.map((e) => _toDouble(e)).toList();
      List<double> depreciations = depreciationsDynamic.map((e) => _toDouble(e)).toList();
      List<double> capexes = capexesDynamic.map((e) => _toDouble(e)).toList();
      List<double> nwcChanges = nwcChangesDynamic.map((e) => _toDouble(e)).toList();

      // ШАГ 1: Чистая прибыль
      List<double> netProfits = _calculateNetProfit(
          revenues, fixedExpenses, variableExpenses, depreciations,
          taxRate, hasLoan, loanAmount, loanRate, loanRepayment, years);

      // ШАГ 2: Денежные потоки
      List<double> fcfs = _calculateFCF(netProfits, depreciations, capexes, nwcChanges);

      // ШАГ 3: Терминальная стоимость
      double lastFCF = fcfs.isNotEmpty ? fcfs.last : 0;
      double terminalValue = _calculateTerminalValue(lastFCF, growthRate, discountRate);

      // ШАГ 4: NPV
      double npv = _calculateNPV(fcfs, terminalValue, discountRate, initialInvestment);

      // ШАГ 5: IRR
      double irr = _calculateIRR(fcfs, terminalValue, initialInvestment);

      // ШАГ 6: Дисконтированный срок окупаемости
      double dpp = _calculateDiscountedPayback(fcfs, terminalValue, discountRate, initialInvestment);

      // Дополнительные показатели
      double totalRevenue = revenues.isEmpty ? 0 : revenues.reduce((a, b) => a + b);
      double totalNetProfit = netProfits.isEmpty ? 0 : netProfits.reduce((a, b) => a + b);
      double totalFCF = fcfs.isEmpty ? 0 : fcfs.reduce((a, b) => a + b);

      bool isProfitable = npv > 0;
      bool irrGood = irr > discountRate;

      setState(() {
        _calculatedResults = {
          'npv': npv,
          'irr': irr,
          'dpp': dpp,
          'terminalValue': terminalValue,
          'isProfitable': isProfitable,
          'irrGood': irrGood,

          'netProfits': netProfits,
          'fcfs': fcfs,

          'totalRevenue': totalRevenue,
          'totalNetProfit': totalNetProfit,
          'totalFCF': totalFCF,

          'initialInvestment': initialInvestment,
          'discountRate': discountRate,
          'growthRate': growthRate,
          'years': years,

          'revenues': revenues,
          'fixedExpenses': fixedExpenses,
          'variableExpenses': variableExpenses,
          'depreciations': depreciations,
          'capexes': capexes,
          'nwcChanges': nwcChanges,
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


  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  void _editProject() {
    if (widget.onEditProject != null) {
      widget.onEditProject!();
    } else {
      Navigator.pop(context);
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(2)} млрд руб';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)} млн руб';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)} тыс руб';
    }
    return '${value.toStringAsFixed(0)} руб';
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

    double npv = _calculatedResults['npv'] ?? 0;
    double irr = _calculatedResults['irr'] ?? 0;
    double dpp = _calculatedResults['dpp'] ?? 0;
    double discountRate = _calculatedResults['discountRate'] ?? 15;

    bool isProfitable = npv > 0;
    bool irrGood = irr > discountRate;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectData['name'] ?? 'Отчет по бизнесу'),
        backgroundColor: isProfitable ? Colors.green : Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // КРАТКИЙ ИТОГ
            Card(
              color: isProfitable ? Colors.green[50] : Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isProfitable ? Icons.check_circle : Icons.warning,
                          color: isProfitable ? Colors.green : Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isProfitable ? 'ПРОЕКТ ПРИБЫЛЬНЫЙ' : 'ПРОЕКТ УБЫТОЧНЫЙ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isProfitable ? Colors.green : Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'NPV = ${_formatCurrency(npv)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ОСНОВНЫЕ ПОКАЗАТЕЛИ
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ОСНОВНЫЕ ПОКАЗАТЕЛИ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildResultRow('NPV (чистая приведенная стоимость):', _formatCurrency(npv),
                        valueColor: npv >= 0 ? Colors.green : Colors.red),
                    _buildResultRow('IRR (внутренняя норма доходности):', _formatPercent(irr),
                        valueColor: irr > discountRate ? Colors.green : Colors.red),
                    _buildResultRow('Ставка дисконтирования:', _formatPercent(discountRate)),
                    _buildResultRow(
                        'Дисконтированный срок окупаемости:',
                        dpp.isFinite ? '${dpp.toStringAsFixed(1)} лет' : 'Не окупается',
                        valueColor: dpp.isFinite && dpp <= 5 ? Colors.green : Colors.orange),
                    _buildResultRow('Терминальная стоимость (TV):', _formatCurrency(_calculatedResults['terminalValue'] ?? 0)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ОБЪЯСНЕНИЕ ПОКАЗАТЕЛЕЙ
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ЧТО ЭТО ЗНАЧИТ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    _buildExplanation(
                      'NPV > 0',
                      'Проект принесет БОЛЬШЕ, чем банковский вклад под $discountRate%',
                    ),
                    _buildExplanation(
                      'NPV < 0',
                      'Проект принесет МЕНЬШЕ, чем банковский вклад',
                    ),
                    _buildExplanation(
                      'IRR = ${irr.toStringAsFixed(1)}%',
                      irr > discountRate
                          ? 'Проект выгоднее, чем требуемая доходность'
                          : 'Проект не дотягивает до желаемой доходности',
                    ),
                    _buildExplanation(
                      'Срок окупаемости',
                      dpp.isFinite
                          ? 'Инвестиции вернутся через ${dpp.toStringAsFixed(1)} лет'
                          : 'Инвестиции не окупятся в прогнозном периоде',
                    ),
                    _buildExplanation(
                      'Терминальная стоимость (TV)',
                      'Стоимость бизнеса после прогнозируемых лет',
                    ),
                    _buildExplanation(
                      'Чистая прибыль',
                      'Это бумажный показатель (результат работы компании по документам)',
                    ),
                    _buildExplanation(
                      'Денежный поток (FCF)',
                      'Это реальные деньги, которые появились на счете компании',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ДЕНЕЖНЫЕ ПОТОКИ ПО ГОДАМ
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ДЕНЕЖНЫЕ ПОТОКИ ПО ГОДАМ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Заголовки
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text('Год', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text('Выручка', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                        ),
                        Expanded(
                          child: Text('Чистая прибыль', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                        ),
                        Expanded(
                          child: Text('FCF', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Данные по годам
                    for (int i = 0; i < (_calculatedResults['years'] ?? 0); i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text('${i + 1}'),
                            ),
                            Expanded(
                              child: Text(
                                _formatCurrency(_calculatedResults['revenues'][i]),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatCurrency(_calculatedResults['netProfits'][i]),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: _calculatedResults['netProfits'][i] >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatCurrency(_calculatedResults['fcfs'][i]),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: _calculatedResults['fcfs'][i] >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Divider(),
                    // Итоги
                    Row(
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: Text('ИТОГО:', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                        ),
                        Expanded(
                          child: Text(
                            _formatCurrency(_calculatedResults['totalNetProfit'] ?? 0),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatCurrency(_calculatedResults['totalFCF'] ?? 0),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Кнопка редактирования
            Center(
              child: ElevatedButton.icon(
                onPressed: _editProject,
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать проект'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation(String term, String explanation) {
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
}