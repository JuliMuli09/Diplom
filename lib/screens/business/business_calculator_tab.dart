import 'package:flutter/material.dart';

class BusinessCalculatorTab extends StatefulWidget {
  final String projectType;
  final Map<String, dynamic>? projectData;
  final Function(Map<String, dynamic>)? onProjectSaved;

  const BusinessCalculatorTab({
    Key? key,
    required this.projectType,
    this.projectData,
    this.onProjectSaved,
  }) : super(key: key);

  @override
  _BusinessCalculatorTabState createState() => _BusinessCalculatorTabState();
}

class _BusinessCalculatorTabState extends State<BusinessCalculatorTab> {
  final _formKey = GlobalKey<FormState>();

  // Основные контроллеры
  final _projectNameController = TextEditingController();
  final _projectDescController = TextEditingController();

  // Блок 1: Общие параметры
  final _initialInvestmentController = TextEditingController(); // Начальные инвестиции
  final _discountRateController = TextEditingController(text: '15'); // Ставка дисконтирования
  final _longTermGrowthRateController = TextEditingController(text: '3'); // Долгосрочный темп роста для модели Гордона

  // Блок 2: Параметры для расчета по годам
  final _forecastYearsController = TextEditingController(text: '5'); // Количество лет прогноза

  // Списки для динамического ввода данных по годам
  List<TextEditingController> _revenueControllers = [];
  List<TextEditingController> _fixedExpensesControllers = [];
  List<TextEditingController> _variableExpensesControllers = [];
  List<TextEditingController> _depreciationControllers = [];
  List<TextEditingController> _capexControllers = [];
  List<TextEditingController> _nwcChangeControllers = [];

  // Параметры для кредита
  bool _hasLoan = false;
  final _loanAmountController = TextEditingController(); // кредит
  final _loanRateController = TextEditingController(); // Процентная ставка
  final _loanTermController = TextEditingController(); // Срок кредита
  final _loanRepaymentController = TextEditingController(); // Погашение в год

  // Ставка налога на прибыль
  final _taxRateController = TextEditingController(text: '20');

  bool _isSaving = false;
  bool _isEditMode = false;
  int _years = 5;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    if (widget.projectData != null) {
      _loadProjectData(widget.projectData!);
      _isEditMode = true;
    }
  }

  void _initializeControllers() {
    _years = int.tryParse(_forecastYearsController.text) ?? 5;

    // Очищаем существующие списки
    _revenueControllers = List.generate(_years, (_) => TextEditingController());
    _fixedExpensesControllers = List.generate(_years, (_) => TextEditingController());
    _variableExpensesControllers = List.generate(_years, (_) => TextEditingController());
    _depreciationControllers = List.generate(_years, (_) => TextEditingController());
    _capexControllers = List.generate(_years, (_) => TextEditingController());
    _nwcChangeControllers = List.generate(_years, (_) => TextEditingController());
  }

  void _loadProjectData(Map<String, dynamic> projectData) {
    setState(() {
      _projectNameController.text = projectData['name'] ?? '';
      _projectDescController.text = projectData['description'] ?? '';

      _initialInvestmentController.text = (projectData['initialInvestment'] ?? '').toString();
      _discountRateController.text = (projectData['discountRate'] ?? '15').toString();
      _longTermGrowthRateController.text = (projectData['longTermGrowthRate'] ?? '3').toString();
      _forecastYearsController.text = (projectData['forecastYears'] ?? '5').toString();
      _taxRateController.text = (projectData['taxRate'] ?? '20').toString();

      _hasLoan = projectData['hasLoan'] ?? false;
      _loanAmountController.text = (projectData['loanAmount'] ?? '').toString();
      _loanRateController.text = (projectData['loanRate'] ?? '').toString();
      _loanTermController.text = (projectData['loanTerm'] ?? '').toString();
      _loanRepaymentController.text = (projectData['loanRepayment'] ?? '').toString();

      // Загружаем данные по годам
      _years = projectData['forecastYears'] ?? 5;
      _initializeControllers();

      List<dynamic> revenues = projectData['revenues'] ?? [];
      List<dynamic> fixedExpenses = projectData['fixedExpenses'] ?? [];
      List<dynamic> variableExpenses = projectData['variableExpenses'] ?? [];
      List<dynamic> depreciations = projectData['depreciations'] ?? [];
      List<dynamic> capexes = projectData['capexes'] ?? [];
      List<dynamic> nwcChanges = projectData['nwcChanges'] ?? [];

      for (int i = 0; i < _years && i < revenues.length; i++) {
        _revenueControllers[i].text = revenues[i].toString();
      }
      for (int i = 0; i < _years && i < fixedExpenses.length; i++) {
        _fixedExpensesControllers[i].text = fixedExpenses[i].toString();
      }
      for (int i = 0; i < _years && i < variableExpenses.length; i++) {
        _variableExpensesControllers[i].text = variableExpenses[i].toString();
      }
      for (int i = 0; i < _years && i < depreciations.length; i++) {
        _depreciationControllers[i].text = depreciations[i].toString();
      }
      for (int i = 0; i < _years && i < capexes.length; i++) {
        _capexControllers[i].text = capexes[i].toString();
      }
      for (int i = 0; i < _years && i < nwcChanges.length; i++) {
        _nwcChangeControllers[i].text = nwcChanges[i].toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'Редактирование: ${widget.projectData?['name'] ?? 'Бизнес'}'
            : 'Оценка бизнеса'),
        centerTitle: true,
        backgroundColor: _isEditMode ? Colors.amber : Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditMode)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Режим редактирования проекта',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text(
                'Оценка бизнеса по денежным потокам',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Заполните данные для расчета NPV, IRR и срока окупаемости',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Блок 1: Общая информация
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Основная информация',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Название проекта
                      TextFormField(
                        controller: _projectNameController,
                        decoration: const InputDecoration(
                          labelText: 'Название проекта *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите название проекта';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Описание
                      TextFormField(
                        controller: _projectDescController,
                        decoration: const InputDecoration(
                          labelText: 'Описание (необязательно)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Количество лет прогноза
                      TextFormField(
                        controller: _forecastYearsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Количество лет прогноза *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите количество лет';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Введите целое число';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          int? newYears = int.tryParse(value);
                          if (newYears != null && newYears > 0 && newYears != _years) {
                            setState(() {
                              _years = newYears;
                              _initializeControllers();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Блок 2: Общие параметры
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Общие параметры',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Начальные инвестиции
                      TextFormField(
                        controller: _initialInvestmentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Начальные инвестиции (I₀) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите начальные инвестиции';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Ставка дисконтирования
                      TextFormField(
                        controller: _discountRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ставка дисконтирования (r, %) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.percent),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите ставку';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Долгосрочный темп роста
                      TextFormField(
                        controller: _longTermGrowthRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Долгосрочный темп роста (g, %)',
                          helperText: 'Для модели Гордона (обычно 2-5%)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ставка налога
                      TextFormField(
                        controller: _taxRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ставка налога на прибыль (%) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите ставку налога';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Блок 3: Данные по годам
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Данные по годам',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Годовые значения',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Заголовки
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text('Год', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text('Выручка', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Text('Пост.расх', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Text('Перем.расх', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Строки для ввода
                      for (int i = 0; i < _years; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _revenueControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Выручка',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextFormField(
                                  controller: _fixedExpensesControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Пост.расх',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextFormField(
                                  controller: _variableExpensesControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Перем.расх',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Дополнительные параметры
                      const Text(
                        'Амортизация, CAPEX и изменение оборотного капитала',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Заголовки для доп параметров
                      Row(
                        children: [
                          SizedBox(width: 40),
                          Expanded(
                            child: Text('Амортизация', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Text('Инвестиции в основной капитал (CAPEX)', style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Text('Изменение оборотного капитала (ΔNWC)', style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      for (int i = 0; i < _years; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text('${i + 1}'),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _depreciationControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Аморт',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextFormField(
                                  controller: _capexControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'CAPEX',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextFormField(
                                  controller: _nwcChangeControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'ΔNWC',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Блок 4: Кредит
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Кредитное финансир-е',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _hasLoan,
                            onChanged: (value) {
                              setState(() {
                                _hasLoan = value;
                              });
                            },
                            activeColor: Colors.amber,
                          ),
                        ],
                      ),

                      if (_hasLoan) ...[
                        const SizedBox(height: 16),

                        // Сумма кредита
                        TextFormField(
                          controller: _loanAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Сумма кредита (руб)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Процентная ставка
                        TextFormField(
                          controller: _loanRateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Процентная ставка (% годовых)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.percent),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Срок кредита
                        TextFormField(
                          controller: _loanTermController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Срок кредита (лет)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timeline),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Ежегодное погашение
                        TextFormField(
                          controller: _loanRepaymentController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Ежегодное погашение (руб)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payment),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _isEditMode ? Colors.amber : Colors.amber,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isEditMode ? 'Обновить проект' : 'Сохранить проект',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              if (_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Сбор данных для сохранения
  Map<String, dynamic> _collectProjectData() {
    List<double> revenues = [];
    List<double> fixedExpenses = [];
    List<double> variableExpenses = [];
    List<double> depreciations = [];
    List<double> capexes = [];
    List<double> nwcChanges = [];

    for (int i = 0; i < _years; i++) {
      revenues.add(double.tryParse(_revenueControllers[i].text) ?? 0);
      fixedExpenses.add(double.tryParse(_fixedExpensesControllers[i].text) ?? 0);
      variableExpenses.add(double.tryParse(_variableExpensesControllers[i].text) ?? 0);
      depreciations.add(double.tryParse(_depreciationControllers[i].text) ?? 0);
      capexes.add(double.tryParse(_capexControllers[i].text) ?? 0);
      nwcChanges.add(double.tryParse(_nwcChangeControllers[i].text) ?? 0);
    }

    return {
      'name': _projectNameController.text,
      'description': _projectDescController.text,
      'type': widget.projectType,
      'subcategory': 'Денежные потоки',

      // Общие параметры
      'initialInvestment': double.tryParse(_initialInvestmentController.text) ?? 0,
      'discountRate': double.tryParse(_discountRateController.text) ?? 15,
      'longTermGrowthRate': double.tryParse(_longTermGrowthRateController.text) ?? 3,
      'forecastYears': _years,
      'taxRate': double.tryParse(_taxRateController.text) ?? 20,

      // Кредит
      'hasLoan': _hasLoan,
      'loanAmount': double.tryParse(_loanAmountController.text) ?? 0,
      'loanRate': double.tryParse(_loanRateController.text) ?? 0,
      'loanTerm': double.tryParse(_loanTermController.text) ?? 0,
      'loanRepayment': double.tryParse(_loanRepaymentController.text) ?? 0,

      // Данные по годам
      'revenues': revenues,
      'fixedExpenses': fixedExpenses,
      'variableExpenses': variableExpenses,
      'depreciations': depreciations,
      'capexes': capexes,
      'nwcChanges': nwcChanges,

      'createdAt': _isEditMode
          ? (widget.projectData?['createdAt'] ?? DateTime.now().toIso8601String())
          : DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final projectData = _collectProjectData();


      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isSaving = false;
        });

        _showSuccessDialog(projectData);
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> projectData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditMode ? 'Проект обновлен' : 'Проект сохранен'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Название проекта:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(projectData['name']),
            const SizedBox(height: 12),
            Text('Инвестиции: ${projectData['initialInvestment']} руб'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onProjectSaved != null) {
                widget.onProjectSaved!(projectData);
              }
              Navigator.pop(context, projectData);
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescController.dispose();
    _initialInvestmentController.dispose();
    _discountRateController.dispose();
    _longTermGrowthRateController.dispose();
    _forecastYearsController.dispose();
    _taxRateController.dispose();
    _loanAmountController.dispose();
    _loanRateController.dispose();
    _loanTermController.dispose();
    _loanRepaymentController.dispose();

    for (var controller in _revenueControllers) {
      controller.dispose();
    }
    for (var controller in _fixedExpensesControllers) {
      controller.dispose();
    }
    for (var controller in _variableExpensesControllers) {
      controller.dispose();
    }
    for (var controller in _depreciationControllers) {
      controller.dispose();
    }
    for (var controller in _capexControllers) {
      controller.dispose();
    }
    for (var controller in _nwcChangeControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}