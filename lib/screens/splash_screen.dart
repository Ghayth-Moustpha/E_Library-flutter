import 'package:book_management_app/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loadToken();
    
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => authService.isAuthenticated 
            ? HomeScreen() 
            : LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Book Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
