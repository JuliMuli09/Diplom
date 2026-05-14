import 'package:flutter/material.dart';

class RentCalculatorTab extends StatefulWidget {
  final String projectType;
  final Map<String, dynamic>? projectData;
  final Function(Map<String, dynamic>)? onProjectSaved;

  const RentCalculatorTab({
    Key? key,
    required this.projectType,
    this.projectData,
    this.onProjectSaved,
  }) : super(key: key);

  @override
  _RentCalculatorTabState createState() => _RentCalculatorTabState();
}

class _RentCalculatorTabState extends State<RentCalculatorTab> {
  final _formKey = GlobalKey<FormState>();

  // Основные контроллеры
  final _projectNameController = TextEditingController();
  final _projectDescController = TextEditingController();

  // Параметры для аренды
  final _areaController = TextEditingController(); // Площадь объекта
  final _rentRateController = TextEditingController(); // Арендная ставка
  final _tenantChangePeriodController = TextEditingController(); // Период смены арендатора
  final _downtimeController = TextEditingController(); // Простой
  final _utilitiesController = TextEditingController(); // Коммунальные платежи
  final _majorRepairsController = TextEditingController(); // Сумма на капремонт
  final _cadastralValueController = TextEditingController(); // Кадастровая стоимость

  // Фиксированные значения
  final double _marketRisk = 1.5; // Среднестатистический риск по рынку
  final double _taxRate = 2.0; // Ставка налога 2%
  final double _insuranceRate = 0.1; // Страхование 0.1%

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
      _projectNameController.text = projectData['name'] ?? '';
      _projectDescController.text = projectData['description'] ?? '';

      // Загружаем параметры аренды
      _areaController.text = (projectData['area'] ?? '').toString();
      _rentRateController.text = (projectData['rentRate'] ?? '').toString();
      _tenantChangePeriodController.text = (projectData['tenantChangePeriod'] ?? '').toString();
      _downtimeController.text = (projectData['downtime'] ?? '').toString();
      _utilitiesController.text = (projectData['utilities'] ?? '').toString();
      _majorRepairsController.text = (projectData['majorRepairs'] ?? '').toString();
      _cadastralValueController.text = (projectData['cadastralValue'] ?? '').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'Редактирование: ${widget.projectData?['name'] ?? 'Аренда'}'
            : 'Калькулятор аренды'),
        centerTitle: true,
        backgroundColor: _isEditMode ? Colors.orange : Colors.orange,
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
                'Расчет инвестиций в аренду недвижимости',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Заполните данные для расчета доходности аренды',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Основная информация о проекте
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
                          color: Colors.orange,
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
                          labelText: 'Описание проекта (необязательно)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Параметры объекта
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Параметры объекта',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Площадь объекта
                      TextFormField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Площадь объекта (кв.м) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.square_foot),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите площадь объекта';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Арендная ставка
                      TextFormField(
                        controller: _rentRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Арендная ставка (руб/м² в месяц) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите арендную ставку';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Кадастровая стоимость
                      TextFormField(
                        controller: _cadastralValueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Кадастровая стоимость (руб) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите кадастровую стоимость';
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

              // Финансовые параметры
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
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Период смены арендатора
                      TextFormField(
                        controller: _tenantChangePeriodController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Период смены арендатора (месяцев) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.swap_horiz),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите период смены';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Введите целое число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Простой
                      TextFormField(
                        controller: _downtimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Простой между арендаторами (месяцев) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer_off),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите период простоя';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Введите целое число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Коммунальные платежи
                      TextFormField(
                        controller: _utilitiesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Коммунальные платежи (руб/год) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.electric_bolt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите коммунальные платежи';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Капитальный ремонт
                      TextFormField(
                        controller: _majorRepairsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Сумма на капремонт (руб/год) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.build),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите сумму на капремонт';
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

              // Фиксированные параметры
              Card(
                elevation: 3,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Фиксированные параметры',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFixedParamRow(
                        'Среднестат-й риск по рынку:',
                        '$_marketRisk%',
                      ),
                      const Divider(),
                      _buildFixedParamRow(
                        'Ставка налога:',
                        '$_taxRate%',
                      ),
                      const Divider(),
                      _buildFixedParamRow(
                        'Страхование объекта:',
                        '$_insuranceRate%',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '* Эти параметры фиксированы и не могут быть изменены',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
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
                    backgroundColor: _isEditMode ? Colors.orange : Colors.orange,
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

  Widget _buildFixedParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
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
        'subcategory': 'Аренда',

        // Параметры аренды
        'area': double.parse(_areaController.text),
        'rentRate': double.parse(_rentRateController.text),
        'tenantChangePeriod': int.parse(_tenantChangePeriodController.text),
        'downtime': int.parse(_downtimeController.text),
        'utilities': double.parse(_utilitiesController.text),
        'majorRepairs': double.parse(_majorRepairsController.text),
        'cadastralValue': double.parse(_cadastralValueController.text),

        // Фиксированные параметры
        'marketRisk': _marketRisk,
        'taxRate': _taxRate,
        'insuranceRate': _insuranceRate,

        'createdAt': _isEditMode
            ? (widget.projectData?['createdAt'] ?? DateTime.now().toIso8601String())
            : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };


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
            Text('Площадь: ${projectData['area']} кв.м'),
            Text('Ставка аренды: ${projectData['rentRate']} руб/м²'),
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
    _areaController.dispose();
    _rentRateController.dispose();
    _tenantChangePeriodController.dispose();
    _downtimeController.dispose();
    _utilitiesController.dispose();
    _majorRepairsController.dispose();
    _cadastralValueController.dispose();
    super.dispose();
  }
}