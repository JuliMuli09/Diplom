import 'package:flutter/material.dart';

class MyStartupCalculatorTab extends StatefulWidget {
  final String projectType;
  final Map<String, dynamic>? projectData;
  final Function(Map<String, dynamic>)? onProjectSaved;

  const MyStartupCalculatorTab({
    Key? key,
    required this.projectType,
    this.projectData,
    this.onProjectSaved,
  }) : super(key: key);

  @override
  _MyStartupCalculatorTabState createState() => _MyStartupCalculatorTabState();
}

class _MyStartupCalculatorTabState extends State<MyStartupCalculatorTab> {
  final _formKey = GlobalKey<FormState>();



  // Блок 1. Общая информация
  final _nameController = TextEditingController();
  final _industryController = TextEditingController(text: 'IT'); // Отрасль
  final _monthsSinceLaunchController = TextEditingController(); // Месяцев с запуска

  // Блок 2. Финансовые показатели (за последние 12 месяцев)
  final _revenueController = TextEditingController(); // Выручка
  final _operatingExpensesController = TextEditingController(); // Операционные расходы
  final _cashController = TextEditingController(); // Денежные средства на счетах
  final _loansController = TextEditingController(); // Кредиты и займы
  final _taxSystemController = TextEditingController(text: 'УСН 6%'); // Налоговая система

  // Блок 3. Метрики роста
  final _activeUsersController = TextEditingController(); // Количество активных пользователей
  final _avgCheckController = TextEditingController(); // Средний чек в месяц
  final _revenueGrowthController = TextEditingController(); // Рост выручки за последний месяц (%)

  // Блок 4. Инвестиционный раунд
  final _desiredInvestmentController = TextEditingController(); // Желаемая сумма инвестиций
  final _equityForInvestorController = TextEditingController(); // Готовая доля для инвестора

  // Списки для выпадающих списков
  final List<String> _industries = [
    'IT',
    'Электронная коммерция',
    'Финансовые технологии',
    'Пищевая индустрия',
    'Медицина',
    'Образование'
  ];
  final List<String> _taxSystems = [
    'УСН 6%',
    'УСН 15%',
    'ОСНО',
    'Самозанятость'
  ];

  bool _isSaving = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectData != null) {
      _loadProjectData(widget.projectData!);
      _isEditMode = true;
    }
  }

  void _loadProjectData(Map<String, dynamic> projectData) {
    setState(() {
      _nameController.text = projectData['name'] ?? '';
      _industryController.text = projectData['industry'] ?? 'IT';
      _monthsSinceLaunchController.text = (projectData['monthsSinceLaunch'] ?? '').toString();

      _revenueController.text = (projectData['revenue'] ?? '').toString();
      _operatingExpensesController.text = (projectData['operatingExpenses'] ?? '').toString();
      _cashController.text = (projectData['cash'] ?? '').toString();
      _loansController.text = (projectData['loans'] ?? '').toString();
      _taxSystemController.text = projectData['taxSystem'] ?? 'УСН 6%';

      _activeUsersController.text = (projectData['activeUsers'] ?? '').toString();
      _avgCheckController.text = (projectData['avgCheck'] ?? '').toString();
      _revenueGrowthController.text = (projectData['revenueGrowth'] ?? '').toString();

      _desiredInvestmentController.text = (projectData['desiredInvestment'] ?? '').toString();
      _equityForInvestorController.text = (projectData['equityForInvestor'] ?? '').toString();
    });
  }

  // Вспомогательные методы для парсинга
  double _parseDouble(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
  }

  int _parseInt(TextEditingController controller) {
    return int.tryParse(controller.text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'Редактирование: ${widget.projectData?['name'] ?? 'Мой стартап'}'            : 'Мой стартап'),
        centerTitle: true,
        backgroundColor: _isEditMode ? Colors.purple : Colors.purple,
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
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.purple),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Режим редактирования проекта',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text('Оценка стартапа', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Введите данные вашего стартапа для расчета стоимости', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              // --- БЛОК 1: Общая информация ---
              _buildSectionCard('Общая информация', [
                _buildTextField(_nameController, 'Название стартапа *', Icons.title, validator: true),
                _buildDropdownField('Отрасль *', _industryController, _industries),
                _buildTextField(_monthsSinceLaunchController, 'Месяцев с момента запуска *', Icons.timer, isNumber: true, validator: true),
              ]),

              const SizedBox(height: 16),

              // --- БЛОК 2: Финансовые показатели ---
              _buildSectionCard('Финансовые показатели (за 12 мес)', [
                _buildTextField(_revenueController, 'Выручка (₽) *', Icons.trending_up, isNumber: true, validator: true),
                _buildTextField(_operatingExpensesController, 'Операционные расходы (₽) *', Icons.money_off, isNumber: true, validator: true),
                _buildTextField(_cashController, 'Денежные средства на счетах (₽) *', Icons.account_balance, isNumber: true, validator: true),
                _buildTextField(_loansController, 'Кредиты и займы (₽) *', Icons.credit_card, isNumber: true, validator: true),
                _buildDropdownField('Налоговая система *', _taxSystemController, _taxSystems),
              ]),

              const SizedBox(height: 16),

              // --- БЛОК 3: Метрики роста ---
              _buildSectionCard('Метрики роста', [
                _buildTextField(_activeUsersController, 'Количество активных пользователей', Icons.people, isNumber: true),
                _buildTextField(_avgCheckController, 'Средний чек в месяц (₽)', Icons.receipt, isNumber: true),
                _buildTextField(_revenueGrowthController, 'Рост выручки за последний месяц (%)', Icons.show_chart, isNumber: true),
              ]),

              const SizedBox(height: 16),

              // --- БЛОК 4: Инвестиционный раунд ---
              _buildSectionCard('Инвестиционный раунд', [
                _buildTextField(_desiredInvestmentController, 'Желаемая сумма инвестиций (₽) *', Icons.money, isNumber: true, validator: true),
                _buildTextField(_equityForInvestorController, 'Готовая доля для инвестора (%) *', Icons.percent, isNumber: true, validator: true),
              ]),

              const SizedBox(height: 30),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEditMode ? 'Обновить проект' : 'Сохранить проект', style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              if (_isEditMode) const SizedBox(height: 16),
              if (_isEditMode)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Отмена', style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для создания карточки раздела
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для создания текстового поля
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool validator = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'Поле обязательно для заполнения';
          }
          if (isNumber && double.tryParse(value.replaceAll(',', '.')) == null) {
            return 'Введите число';
          }
          return null;
        }
            : null,
      ),
    );
  }

  // Вспомогательный метод для создания выпадающего списка
  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: controller.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              controller.text = newValue;
            });
          }
        },
        validator: (value) => value == null || value.isEmpty ? 'Выберите значение' : null,
      ),
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final projectData = {
        'name': _nameController.text,
        'industry': _industryController.text,
        'monthsSinceLaunch': _parseInt(_monthsSinceLaunchController),
        'revenue': _parseDouble(_revenueController),
        'operatingExpenses': _parseDouble(_operatingExpensesController),
        'cash': _parseDouble(_cashController),
        'loans': _parseDouble(_loansController),
        'taxSystem': _taxSystemController.text,
        'activeUsers': _parseInt(_activeUsersController),
        'avgCheck': _parseDouble(_avgCheckController),
        'revenueGrowth': _parseDouble(_revenueGrowthController),
        'desiredInvestment': _parseDouble(_desiredInvestmentController),
        'equityForInvestor': _parseDouble(_equityForInvestorController),
        'type': widget.projectType,
        'subcategory': 'Мой стартап',
        'createdAt': _isEditMode ? (widget.projectData?['createdAt'] ?? DateTime.now().toIso8601String()) : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };


      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isSaving = false);
        _showSuccessDialog(projectData);
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> projectData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditMode ? 'Проект обновлен' : 'Проект сохранен'),
        content: Text('Название: ${projectData['name']}\nОтрасль: ${projectData['industry']}'),
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
    // Освобождаем все контроллеры
    _nameController.dispose();
    _industryController.dispose();
    _monthsSinceLaunchController.dispose();
    _revenueController.dispose();
    _operatingExpensesController.dispose();
    _cashController.dispose();
    _loansController.dispose();
    _taxSystemController.dispose();
    _activeUsersController.dispose();
    _avgCheckController.dispose();
    _revenueGrowthController.dispose();
    _desiredInvestmentController.dispose();
    _equityForInvestorController.dispose();
    super.dispose();
  }
}