import 'package:flutter/material.dart';

class InvestorCalculatorTab extends StatefulWidget {
  final String projectType;
  final Map<String, dynamic>? projectData;
  final Function(Map<String, dynamic>)? onProjectSaved;

  const InvestorCalculatorTab({
    Key? key,
    required this.projectType,
    this.projectData,
    this.onProjectSaved,
  }) : super(key: key);

  @override
  _InvestorCalculatorTabState createState() => _InvestorCalculatorTabState();
}

class _InvestorCalculatorTabState extends State<InvestorCalculatorTab> {
  final _formKey = GlobalKey<FormState>();



  // Блок 1. Данные о стартапе
  final _nameController = TextEditingController();
  final _industryController = TextEditingController(text: 'IT');
  final _revenueController = TextEditingController(); // Выручка за год
  final _expensesController = TextEditingController(); // Расходы за год
  final _debtController = TextEditingController(); // Долги
  final _cashController = TextEditingController(); // Денежные средства
  final _monthlyGrowthController = TextEditingController(); // Рост выручки за месяц

  // Блок 2. Условия сделки
  final _investmentAmountController = TextEditingController(); // Запрашиваемая сумма инвестиций
  final _equityOfferController = TextEditingController(); // Предлагаемая доля

  // Блок 3. Ожидания инвестора
  final _exitTermController = TextEditingController(text: '5'); // Желаемый срок выхода
  final _desiredReturnController = TextEditingController(text: '10'); // Желаемая доходность

  // Список отраслей
  final List<String> _industries = [
    'IT',
    'Электронная коммерция',
    'Финансовые технологии',
    'Пищевая индустрия',
    'Медицина',
    'Образование'
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
      _revenueController.text = (projectData['revenue'] ?? '').toString();
      _expensesController.text = (projectData['expenses'] ?? '').toString();
      _debtController.text = (projectData['debt'] ?? '').toString();
      _cashController.text = (projectData['cash'] ?? '').toString();
      _monthlyGrowthController.text = (projectData['monthlyGrowth'] ?? '').toString();

      _investmentAmountController.text = (projectData['investmentAmount'] ?? '').toString();
      _equityOfferController.text = (projectData['equityOffer'] ?? '').toString();

      _exitTermController.text = (projectData['exitTerm'] ?? '5').toString();
      _desiredReturnController.text = (projectData['desiredReturn'] ?? '10').toString();
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
            ? 'Редактирование: ${widget.projectData?['name'] ?? 'Я-инвестор'}'
            : 'Я-инвестор'),
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
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.amber),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Режим редактирования проекта',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text('Оценка стартапа для инвестора', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Введите данные стартапа и условия сделки', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              // БЛОК 1: Данные о стартапе
              _buildSectionCard('Данные о стартапе', [
                _buildTextField(_nameController, 'Название стартапа *', Icons.title, validator: true),
                _buildDropdownField('Отрасль *', _industryController, _industries),
                _buildTextField(_revenueController, 'Выручка за год (₽) *', Icons.trending_up, isNumber: true, validator: true),
                _buildTextField(_expensesController, 'Расходы за год (₽) *', Icons.money_off, isNumber: true, validator: true),
                _buildTextField(_debtController, 'Долги (₽)', Icons.credit_card, isNumber: true),
                _buildTextField(_cashController, 'Денежные средства (₽)', Icons.account_balance, isNumber: true),
                _buildTextField(_monthlyGrowthController, 'Рост выручки за месяц (%)', Icons.show_chart, isNumber: true),
              ]),

              const SizedBox(height: 16),

              // БЛОК 2: Условия сделки
              _buildSectionCard('Условия сделки', [
                _buildTextField(_investmentAmountController, 'Запрашиваемая сумма инвестиций (₽) *', Icons.money, isNumber: true, validator: true),
                _buildTextField(_equityOfferController, 'Предлагаемая доля (%) *', Icons.percent, isNumber: true, validator: true),
              ]),

              const SizedBox(height: 16),

              // БЛОК 3: Ожидания инвестора
              _buildSectionCard('Ожидания инвестора', [
                _buildTextField(_exitTermController, 'Желаемый срок выхода (лет) *', Icons.timeline, isNumber: true, validator: true),
                _buildTextField(_desiredReturnController, 'Желаемая доходность (X раз) *', Icons.trending_up, isNumber: true, validator: true),
              ]),

              const SizedBox(height: 30),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.amber,
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
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
        'revenue': _parseDouble(_revenueController),
        'expenses': _parseDouble(_expensesController),
        'debt': _parseDouble(_debtController),
        'cash': _parseDouble(_cashController),
        'monthlyGrowth': _parseDouble(_monthlyGrowthController),
        'investmentAmount': _parseDouble(_investmentAmountController),
        'equityOffer': _parseDouble(_equityOfferController),
        'exitTerm': _parseInt(_exitTermController),
        'desiredReturn': _parseDouble(_desiredReturnController),
        'type': widget.projectType,
        'subcategory': 'Я-инвестор',
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
    _nameController.dispose();
    _industryController.dispose();
    _revenueController.dispose();
    _expensesController.dispose();
    _debtController.dispose();
    _cashController.dispose();
    _monthlyGrowthController.dispose();
    _investmentAmountController.dispose();
    _equityOfferController.dispose();
    _exitTermController.dispose();
    _desiredReturnController.dispose();
    super.dispose();
  }
}