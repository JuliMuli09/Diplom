import 'package:flutter/material.dart';
import 'package:diplom/screens/project_detail_screen.dart';

class CalculatorTab extends StatefulWidget {
  final String projectType;
  final Map<String, dynamic>? projectData; // Новый параметр для редактирования
  final Function(Map<String, dynamic>)? onProjectSaved;

  const CalculatorTab({
    Key? key,
    required this.projectType,
    this.projectData,
    this.onProjectSaved,
  }) : super(key: key);

  @override
  _CalculatorTabState createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();
  final _projectDescController = TextEditingController();
  final _investmentController = TextEditingController();
  final _fixedCostsController = TextEditingController();
  final _variableCostsController = TextEditingController();
  final _implementationPeriodController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _discountRateController = TextEditingController(text: '10');

  bool _isSaving = false;
  bool _isEditMode = false; // Флаг режима редактирования

  @override
  void initState() {
    super.initState();

    // Если переданы данные для редактирования - загружаем их
    if (widget.projectData != null) {
      _loadProjectData(widget.projectData!);
      _isEditMode = true;
    }
  }

  void _loadProjectData(Map<String, dynamic> projectData) {
    setState(() {
      _projectNameController.text = projectData['name'] ?? '';
      _projectDescController.text = projectData['description'] ?? '';
      _investmentController.text = (projectData['investment'] ?? 0).toString();
      _fixedCostsController.text = (projectData['fixedCosts'] ?? 0).toString();
      _variableCostsController.text = (projectData['variableCosts'] ?? 0).toString();
      _implementationPeriodController.text = (projectData['period'] ?? 0).toString();
      _pricePerUnitController.text = (projectData['price'] ?? 0).toString();
      _discountRateController.text = (projectData['discountRate'] ?? 10).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'Редактирование: ${widget.projectData?['name'] ?? widget.projectType}'
            : 'Калькулятор: ${widget.projectType}'),
        centerTitle: true,
        backgroundColor: _isEditMode ? Colors.orange : Colors.blue,
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
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Режим редактирования проекта',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text(
                'Расчет инвестиционного проекта',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Заполните данные для расчета эффективности',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Поле для названия проекта
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

              // Поле для описания
              TextFormField(
                controller: _projectDescController,
                decoration: const InputDecoration(
                  labelText: 'Описание проекта (необязательно)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Плашка с финансовыми данными
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Финансовые параметры',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Сумма инвестиций
                      TextFormField(
                        controller: _investmentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Сумма инвестиций (рубли) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.savings),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите сумму инвестиций';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Постоянные затраты
                      TextFormField(
                        controller: _fixedCostsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Постоянные затраты (рубли/мес) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите постоянные затраты';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Переменные затраты
                      TextFormField(
                        controller: _variableCostsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Переменные затраты (рубли/ед) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите переменные затраты';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Срок реализации
                      TextFormField(
                        controller: _implementationPeriodController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Срок реализации (месяцы) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите срок реализации';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Цена за единицу
                      TextFormField(
                        controller: _pricePerUnitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Цена за единицу (рубли) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sell),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите цену за единицу';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Ставка дисконтирования
                  TextFormField(
                    controller: _discountRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Ставка дисконтирования (% ГОДОВЫХ) *',
                        helperText: 'Рекомендуется 8-15% годовых',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.percent),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите ставку дисконтирования';
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

              const SizedBox(height: 30),

              // Кнопка сохранения/обновления
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _isEditMode ? Colors.orange : Colors.green,
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

              // Кнопка отмены в режиме редактирования
              if (_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Вернуться назад
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

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Собираем данные проекта
      final projectData = {
        'name': _projectNameController.text,
        'description': _projectDescController.text,
        'type': widget.projectType,
        'investment': double.parse(_investmentController.text),
        'fixedCosts': double.parse(_fixedCostsController.text),
        'variableCosts': double.parse(_variableCostsController.text),
        'period': int.parse(_implementationPeriodController.text),
        'price': double.parse(_pricePerUnitController.text),
        'discountRate': double.parse(_discountRateController.text),
        'createdAt': _isEditMode
            ? (widget.projectData?['createdAt'] ?? DateTime.now().toIso8601String())
            : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(), // Добавляем время обновления
      };

      // Имитация сохранения
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isSaving = false;
        });

        // Показываем диалог подтверждения
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
            if (projectData['description'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Описание проекта:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(projectData['description']),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Закрываем диалог
              Navigator.pop(context);


              if (widget.onProjectSaved != null) {
                widget.onProjectSaved!(projectData);
              }

              // Закрываем калькулятор и возвращаемся в детали проекта
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
    _investmentController.dispose();
    _fixedCostsController.dispose();
    _variableCostsController.dispose();
    _implementationPeriodController.dispose();
    _pricePerUnitController.dispose();
    _discountRateController.dispose();
    super.dispose();
  }
}