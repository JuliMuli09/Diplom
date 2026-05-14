import 'package:flutter/material.dart';
import 'package:diplom/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoginMode = false; // true = вход, false = регистрация

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  // Если пользователь уже заходил — сразу на главную
  Future<void> _checkIfAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainTabsScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');

      if (_isLoginMode) {
        // ВХОД
        if (_emailController.text == savedEmail &&
            _passwordController.text == savedPassword) {
          // Успешный вход
          await prefs.setBool('is_logged_in', true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainTabsScreen()),
                (route) => false,
          );
        } else {
          setState(() {
            _errorMessage = 'Такого аккаунта не существует или неверный пароль';
            _isLoading = false;
          });
        }
      } else {
        // РЕГИСТРАЦИЯ
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = 'Пароли не совпадают';
            _isLoading = false;
          });
          return;
        }

        // Проверяем, есть ли уже такой email
        if (savedEmail == _emailController.text) {
          setState(() {
            _errorMessage = 'Такой аккаунт уже существует. Нажмите "Войти".';
            _isLoading = false;
          });
          return;
        }

        // Сохраняем нового пользователя
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_email', _emailController.text);
        await prefs.setString('user_password', _passwordController.text);
        await prefs.setBool('is_logged_in', true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainTabsScreen()),
              (route) => false,
        );
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = '';
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Вход' : 'Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(
                  _isLoginMode ? Icons.login : Icons.app_registration,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  _isLoginMode ? 'Войдите в аккаунт' : 'Создайте аккаунт',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Поле Имя — только при регистрации
                if (!_isLoginMode)
                  Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_isLoginMode && (value == null || value.isEmpty)) {
                            return 'Введите имя';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите email';
                    }
                    if (!value.contains('@')) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Пароль
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пароль';
                    }
                    if (!_isLoginMode && value.length < 6) {
                      return 'Пароль должен быть не менее 6 символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Подтверждение пароля — только при регистрации
                if (!_isLoginMode)
                  Column(
                    children: [
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Подтвердите пароль',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_isLoginMode && (value == null || value.isEmpty)) {
                            return 'Подтвердите пароль';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Сообщение об ошибке
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Кнопка действия (Войти / Зарегистрироваться)
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isLoginMode ? 'Войти' : 'Зарегистрироваться',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Переключение между режимами
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLoginMode
                        ? 'Нет аккаунта? Зарегистрироваться'
                        : 'Уже есть аккаунт? Войти',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}