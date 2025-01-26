import 'package:flutter/material.dart';
import 'package:tot_app/Frontend/styles/globals.dart' as globals;
import 'package:dio/dio.dart';

const baseUrl = 'http://192.168.1.5:8080';
var token = '';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Dio _dio = Dio();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    // Validate input fields
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email and password are required.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Response response = await _dio.post(
        '$baseUrl/api/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("response : $response");
        globals.authToken = response.data['token'];
        String userType = response.data['user_type']; // Get user_type from response
        globals.userId = response.data['user_id'];

        if (userType == 'Tourist') {
          Navigator.of(context).pushReplacementNamed('/addtrip');
        } else if (userType == 'Tour Guide') {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else if(userType=='Admin'){
          Navigator.of(context).pushReplacementNamed('/admin');

        }
        else {
          _showErrorDialog('Unsupported user type.');
        }
      } else {
        debugPrint("response : $response");
        // Handle login failure (wrong credentials)
        String errorMessage = 'Login failed';
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.statusMessage != null) {
          errorMessage = response.statusMessage!;
        }
        _showErrorDialog('Error: $errorMessage');
      }
    } on DioError catch (e) {
      String errorMessage = 'Unknown error occurred';
      if (e.response != null) {
        if (e.response?.data is Map<String, dynamic> &&
            e.response?.data.containsKey('message')) {
          errorMessage = e.response?.data['message'];
        } else if (e.response?.statusMessage != null) {
          var errorMessage = e.response?.statusMessage!;
        }
      } else {
        errorMessage = e.message ?? 'Unknown error occurred';
      }
      _showErrorDialog('Error: $errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Hello, Welcome back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Login to continue'),
            const Spacer(),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              obscureText: true,
            ),
            TextButton(
              onPressed: () {
                print('Forgot Password clicked');
              },
              child: const Text('Forgot Password?'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(width: 250),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
            const Spacer(),
            const Text(
              'Or login with:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('Login with Google pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 16),
                  const Text('Sign in with Google'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('Login with Facebook pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/facebook.png',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 12),
                  const Text('Sign in with Facebook'),
                ],
              ),
            ),
            Row(
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/register');
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
