import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/home/screens/home_screen.dart';
import 'package:customer_app/shared/types/user_model.dart';

const String _baseUrl = "https://api-ndolv2.nongdanonline.vn";

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text.trim(),
              'fullName': _nameController.text.trim(),
            }),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Yêu cầu hết thời gian');
            },
          );

      print(
        'Phản hồi đăng ký - Mã: ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', user.token ?? '');
        await prefs.setString('refreshToken', user.refreshToken ?? '');
        await prefs.setString('fullName', user.fullName);
        await prefs.setString('email', user.email);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng ký thành công!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        String errorMessage = 'Đăng ký thất bại.';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
          if (response.statusCode == 400 || response.statusCode == 422) {
            errorMessage = errorData['message'] ?? 'Dữ liệu không hợp lệ.';
          } else if (response.statusCode == 500) {
            errorMessage = 'Lỗi server, vui lòng thử lại sau.';
          }
        } catch (e) {
          errorMessage =
              'Lỗi server: ${response.statusCode} - ${response.body}';
        }
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFFFFF7DC);
    final fillColor = Color(0xFFFFF7DC);
    final buttonColor = Color(0xFFFFD54F);
    final textColor = Colors.amber[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 40),
            Image.asset(
              'lib/assets/images/customer.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Tạo tài khoản mới',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Họ tên',
                    icon: Icons.person,
                    fillColor: fillColor,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Vui lòng nhập họ tên.'
                                : null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    fillColor: fillColor,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập email.';
                      if (!_isValidEmail(value)) return 'Email không hợp lệ.';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    icon: Icons.lock,
                    fillColor: fillColor,
                    isObscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập mật khẩu.';
                      if (value.length < 6)
                        return 'Mật khẩu phải ít nhất 6 ký tự.';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Nhập lại mật khẩu',
                    icon: Icons.lock,
                    fillColor: fillColor,
                    isObscure: true,
                    validator: (value) {
                      if (value != _passwordController.text)
                        return 'Mật khẩu không khớp.';
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Quay lại đăng nhập',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color fillColor,
    bool isObscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
