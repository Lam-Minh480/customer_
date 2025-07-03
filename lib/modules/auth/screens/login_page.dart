import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/home/screens/home_screen.dart';
import 'register_page.dart';
import 'package:customer_app/shared/types/user_model.dart';

const String _baseUrl = "https://api-ndolv2.nongdanonline.vn";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<UserModel?> login(String email, String password) async {
    final url = Uri.parse("$_baseUrl/auth/login");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );
      print(
        'Login Response - Status: ${response.statusCode}, Body: ${response.body}',
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        print("Lỗi đăng nhập: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối khi đăng nhập: $e");
      return null;
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập email và mật khẩu.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await login(_emailController.text, _passwordController.text);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', user.token ?? '');
        await prefs.setString('refreshToken', user.refreshToken ?? '');
        await prefs.setString('fullName', user.fullName);
        await prefs.setString('email', user.email);
        print('Access Token: ${user.token}');
        print('Refresh Token: ${user.refreshToken}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng nhập thành công!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi không xác định: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('fullName');
    await prefs.remove('email');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        elevation: 0,
        actions: [
          if (_emailController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.black87),
              onPressed: _logout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/customer.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Chào mừng bạn đến Cutsomer App',
              style: TextStyle(fontSize: 24, color: Colors.amber[700]),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'mật khẩu',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Đăng nhập', style: TextStyle(fontSize: 18)),
                ),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: Image.asset('lib/assets/images/google.png', height: 24),
              label: Text(
                'Tiếp tục với Google',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                side: BorderSide(color: Colors.amber[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Chưa có tài khoản? '),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: Text('Đăng ký'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
