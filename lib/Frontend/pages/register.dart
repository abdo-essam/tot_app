import 'package:flutter/material.dart';
import 'package:dio/dio.dart';  // Dio for HTTP requests

//const baseUrl = 'http://192.168.1.5:8080';
const baseUrl = 'http://192.168.1.5:8080';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedNationality;
  bool _isLoading = false;

  final Dio _dio = Dio();  // Initialize Dio

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Prepare the registration data
      Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'mobile': phone,
        'password': password,
        'user_type': 'tourist',  // Assuming a fixed user type for now
        'country': _selectedNationality ?? 'Other',
      };

      // Send POST request to the backend
      Response response = await _dio.post(
        '$baseUrl/api/register',  // Replace with your actual API URL
        data: data,
      );

      // Handle response
      if (response.statusCode == 201) {
        print('Registration successful: ${response.data}');
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        _showErrorDialog('Registration failed: ${response.data}');
      }
    } on DioError catch (error) {
      // Handle DioError, which includes network errors and HTTP errors
      _showErrorDialog('Error: ${error.response?.data ?? error.message}');
    }

    setState(() {
      _isLoading = false;
    });
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
              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Join Us Now'),
            const Spacer(),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Name',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
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
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'Phone Number',
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
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedNationality,
              decoration: InputDecoration(
                hintText: 'Select Nationality',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              items: ['American', 'Canadian', 'British', 'Australian', 'Indian', 'Other']
                  .map((String nationality) {
                return DropdownMenuItem<String>(
                  value: nationality,
                  child: Text(nationality),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedNationality = newValue;
                });
              },
            ),
            const SizedBox(width: 250),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
