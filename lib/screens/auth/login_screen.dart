import 'package:book_management_app/api_service.dart';
import 'package:book_management_app/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final token = await apiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      await authService.saveToken(token);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الدخول: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/SVU-LOGO.jpg/800px-SVU-LOGO.jpg',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'برنامج الماجستير في أمن الويب',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'تسجيل الدخول إلى حسابك',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "ليس لديك حساب؟ قم بإنشاء حساب جديد",
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
