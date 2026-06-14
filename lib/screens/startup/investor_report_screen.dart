import 'package:flutter/material.dart';
import 'dart:math';

class InvestorReportScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final VoidCallback? onEditProject;

  const InvestorReportScreen({Key? key, required this.projectData, this.onEditProject}) : super(key: key);

  @override
  _InvestorReportScreenState createState() => _InvestorReportScreenState();
}

class _InvestorReportScreenState extends State<InvestorReportScreen> {
  late Map<String, dynamic> _results;
  bool _isLoading = true;

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
      // 1. Извлечение данных
      double revenue = _toDouble(widget.projectData['revenue']);
      double expenses = _toDouble(widget.projectData['expenses']);
      double debt = _toDouble(widget.projectData['debt']);
      double cash = _toDouble(widget.projectData['cash']);
      double monthlyGrowth = _toDouble(widget.projectData['monthlyGrowth']) / 100;

      double investmentAmount = _toDouble(widget.projectData['investmentAmount']);
      double equityOffer = _toDouble(widget.projectData['equityOffer']);

      int exitTerm = _toInt(widget.projectData['exitTerm']);
      double desiredReturn = _toDouble(widget.projectData['desiredReturn']);

      String industry = widget.projectData['industry'] ?? 'IT';

      // Прибыль/Убыток
      double profitBeforeTax = revenue - expenses;
      bool isProfitable = profitBeforeTax > 0;

      // Pre-money из предложения
      double preMoneyFromOffer = 0;
      if (equityOffer > 0) {
        preMoneyFromOffer = (investmentAmount / (equityOffer / 100)) - investmentAmount;
      }

      // Справедливая оценка
      double fairPreMoney = 0;
      String valuationMethod = "Недостаточно данных";

      if (isProfitable) {
        // Если прибыльная - считаем по прибыли
        double profitMultiplier = _getProfitMultiplier(industry);
        double enterpriseValue = profitBeforeTax * profitMultiplier;
        fairPreMoney = enterpriseValue - debt + cash;
        valuationMethod = "По прибыли (P/E = ${profitMultiplier.toStringAsFixed(1)})";
      } else if (revenue > 0) {
        // Если убыточная, но есть выручка - считаем по выручке
        double revenueMultiplier = _getRevenueMultiplier(industry) * 0.5; // Уменьшаем множитель для убыточных
        fairPreMoney = revenue * revenueMultiplier;
        valuationMethod = "По выручке (P/S = ${revenueMultiplier.toStringAsFixed(1)}) - понижающий коэффициент для убыточных";
      } else {
        // Если нет ни прибыли, ни выручки - оценка минимальная
        fairPreMoney = investmentAmount * 0.5; // 50% от запрашиваемых инвестиций
        valuationMethod = "Минимальная оценка (нет финансовых показателей)";
      }

      // Переплата
      double overpaymentPercent = 0;
      if (fairPreMoney > 0) {
        overpaymentPercent = ((preMoneyFromOffer - fairPreMoney) / fairPreMoney) * 100;
      } else if (preMoneyFromOffer > 0) {
        overpaymentPercent = 100;
      }

      // Прогноз на выход, если компания прибыльная или есть рост
      double forecastRevenue = revenue;
      double exitValuation = 0;
      double investorReturn = 0;
      double roi = 0;
      double irr = -100;

      if (isProfitable && revenue > 0) {
        // Прогноз только для прибыльных компаний
        if (monthlyGrowth > 0) {
          forecastRevenue = revenue * pow(1 + monthlyGrowth, exitTerm * 12);
        }

        double terminalMultiplier = _getTerminalMultiplier(industry);
        exitValuation = forecastRevenue * terminalMultiplier;

        double finalEquity = equityOffer * 0.8;
        investorReturn = exitValuation * (finalEquity / 100);

        if (investmentAmount > 0 && investorReturn > 0) {
          roi = investorReturn / investmentAmount;
          if (exitTerm > 0) {
            irr = (pow(roi, 1 / exitTerm) - 1) * 100;
          }
        }
      }

      //Логика выгодности
      bool isOverpaymentGood = overpaymentPercent <= 20; // Переплата не более 20%
      bool isRoiGood = roi >= desiredReturn && roi > 1.0; // ROI > желаемого и > 1
      bool isIrrGood = irr >= 25; // IRR не менее 25% годовых
      bool isCompanyProfitable = isProfitable; // Компания должна быть прибыльной

      // Главные условия: компания прибыльна И (переплата мала ИЛИ доходность высока)
      bool isGood = isCompanyProfitable && (isOverpaymentGood || (isRoiGood && isIrrGood));

      String verdict = isGood ? 'ВЫГОДНО' : 'НЕ ВЫГОДНО';
      Color verdictColor = isGood ? Colors.green : Colors.red;

      double profitMargin = revenue > 0 ? (profitBeforeTax / revenue) * 100 : 0;
      double annualGrowth = monthlyGrowth * 12 * 100;

      setState(() {
        _results = {
          // Исходные данные
          'name': widget.projectData['name'],
          'industry': industry,
          'revenue': revenue,
          'expenses': expenses,
          'debt': debt,
          'cash': cash,
          'monthlyGrowth': monthlyGrowth * 100,
          'investmentAmount': investmentAmount,
          'equityOffer': equityOffer,
          'exitTerm': exitTerm,
          'desiredReturn': desiredReturn,

          // Ключевые показатели
          'profitBeforeTax': profitBeforeTax,
          'isProfitable': isProfitable,
          'profitMargin': profitMargin,
          'annualGrowth': annualGrowth,
          'preMoneyFromOffer': preMoneyFromOffer,
          'fairPreMoney': fairPreMoney,
          'valuationMethod': valuationMethod,
          'overpaymentPercent': overpaymentPercent,
          'forecastRevenue': forecastRevenue,
          'exitValuation': exitValuation,
          'finalEquity': equityOffer * 0.8,
          'investorReturn': investorReturn,
          'roi': roi,
          'irr': irr,

          // Вердикт
          'verdict': verdict,
          'verdictColor': verdictColor,

          // Флаги для подсветки
          'isOverpaymentGood': isOverpaymentGood,
          'isRoiGood': isRoiGood && roi > 0,
          'isIrrGood': isIrrGood && irr > 0,
          'isCompanyProfitable': isCompanyProfitable,
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

  double _getProfitMultiplier(String industry) {
    switch (industry) {
      case 'IT': return 12.0;
      case 'Электронная коммерция': return 8.0;
      case 'Финансовые технологии': return 10.0;
      case 'Пищевая индустрия': return 9.0;
      case 'Медицина': return 10.0;
      case 'Образование': return 9.0;
      default: return 9.0;
    }
  }

  double _getRevenueMultiplier(String industry) {
    switch (industry) {
      case 'IT': return 5.25;
      case 'Электронная коммерция': return 1.6;
      case 'Финансовые технологии': return 4.0;
      case 'Пищевая индустрия': return 2.25;
      case 'Медицина': return 3.25;
      case 'Образование': return 3.0;
      default: return 3.0;
    }
  }

  double _getTerminalMultiplier(String industry) {
    switch (industry) {
      case 'IT': return 3.0;
      case 'Электронная коммерция': return 2.0;
      case 'Финансовые технологии': return 2.5;
      case 'Пищевая индустрия': return 2.0;
      case 'Медицина': return 2.5;
      case 'Образование': return 2.0;
      default: return 2.0;
    }
  }

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

    String verdict = _results['verdict'] ?? '';
    Color verdictColor = _results['verdictColor'] ?? Colors.grey;
    double overpayment = _results['overpaymentPercent'] ?? 0;
    double preMoneyOffer = _results['preMoneyFromOffer'] ?? 0;
    double fairPreMoney = _results['fairPreMoney'] ?? 0;
    double roi = _results['roi'] ?? 0;
    double irr = _results['irr'] ?? 0;
    bool isProfitable = _results['isProfitable'] ?? false;

    bool isOverpaymentGood = _results['isOverpaymentGood'] ?? false;
    bool isRoiGood = _results['isRoiGood'] ?? false;
    bool isIrrGood = _results['isIrrGood'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_results['name'] ?? 'Отчет инвестора'),
        backgroundColor: verdictColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ГЛАВНЫЙ ВЕРДИКТ
            Card(
              color: verdict == 'ВЫГОДНО' ? Colors.green[50] : Colors.red[50], // Светло-зелёный или светло-красный фон
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        verdict == 'ВЫГОДНО' ? Icons.check_circle : Icons.cancel,
                        color: verdictColor,
                        size: 48,
                      ),
                      const SizedBox(width: 10),
                      Text(verdict, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                    ]),
                    if (!isProfitable)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Компания убыточная - высокий риск',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ЧТО ЭТО ОЗНАЧАЕТ
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ЧТО ЭТО ОЗНАЧАЕТ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 10),
                    _buildExplanation('Pre-money оценка', 'Стоимость компании до инвестиций.'),
                    _buildExplanation('Переплата', 'Если значение отрицательное — вы покупаете дешевле рынка (выгодно). Если положительное — переплачиваете.'),
                    _buildExplanation('ROI', 'Во сколько раз вырастут деньги. Для убыточных компаний не рассчитывается.'),
                    _buildExplanation('IRR', 'Доходность в % годовых. Для убыточных компаний не рассчитывается.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // СРАВНЕНИЕ ОЦЕНОК
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [Icon(Icons.compare_arrows, color: Colors.amber), SizedBox(width: 8), Text('Сравнение оценок', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  _buildInfoRow('Просят основатели (Pre-money):', _formatCurrency(preMoneyOffer)),
                  _buildInfoRow('Справедливая цена:', _formatCurrency(fairPreMoney)),
                  const Divider(height: 16),
                  _buildInfoRow('Переплата:', '${overpayment.toStringAsFixed(1)}%',
                      valueColor: isOverpaymentGood ? Colors.green : Colors.red),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // ПРОГНОЗ ДОХОДНОСТИ (только для прибыльных)
            if (isProfitable) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.trending_up, color: Colors.amber), SizedBox(width: 8), Text('Прогноз доходности', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 16),
                    _buildInfoRow('Сумма инвестиций:', _formatCurrency(_results['investmentAmount'] ?? 0)),
                    _buildInfoRow(
                      'Доля:',
                      '${(_results['equityOffer'] ?? 0).toStringAsFixed(1)}% → ${(_results['finalEquity'] ?? 0).toStringAsFixed(1)}%',
                    ),
                    _buildInfoRow('Выручка через ${_results['exitTerm']} лет:', _formatCurrency(_results['forecastRevenue'] ?? 0)),
                    _buildInfoRow('Стоимость на выходе:', _formatCurrency(_results['exitValuation'] ?? 0)),
                    const Divider(height: 16),
                    _buildInfoRow('Возврат инвестору:', _formatCurrency(_results['investorReturn'] ?? 0)),
                    _buildInfoRow('ROI:', '${roi.toStringAsFixed(1)}x',
                        valueColor: isRoiGood ? Colors.green : Colors.red),
                    _buildInfoRow('IRR:', '${irr.toStringAsFixed(1)}% годовых',
                        valueColor: isIrrGood ? Colors.green : Colors.red),
                  ]),
                ),
              ),
            ] else ...[
              Card(
                elevation: 2,
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Прогноз доходности не рассчитывается',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text('Компания убыточная - слишком высокий риск для прогнозирования'),
                  ]),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // ФИНАНСОВЫЕ ПОКАЗАТЕЛИ
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [Icon(Icons.assessment, color: Colors.amber), SizedBox(width: 8), Text('Показатели стартапа', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  _buildInfoRow('Выручка за год:', _formatCurrency(_results['revenue'] ?? 0)),
                  _buildInfoRow('Расходы за год:', _formatCurrency(_results['expenses'] ?? 0)),
                  _buildInfoRow('Прибыль до налогов:', _formatCurrency(_results['profitBeforeTax'] ?? 0)),
                  _buildInfoRow('Рентабельность:', '${(_results['profitMargin'] ?? 0).toStringAsFixed(1)}%',
                      valueColor: (_results['profitMargin'] ?? 0) > 0 ? Colors.green : Colors.red),
                  _buildInfoRow('Рост в месяц:', '${(_results['monthlyGrowth'] ?? 0).toStringAsFixed(1)}%'),
                  _buildInfoRow('Рост в год:', '${(_results['annualGrowth'] ?? 0).toStringAsFixed(1)}%'),
                  _buildInfoRow('Денежные средства:', _formatCurrency(_results['cash'] ?? 0)),
                  _buildInfoRow('Долги:', _formatCurrency(_results['debt'] ?? 0)),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Кнопка редактирования
            Center(
              child: ElevatedButton.icon(
                onPressed: _editProject,
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать проект'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
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