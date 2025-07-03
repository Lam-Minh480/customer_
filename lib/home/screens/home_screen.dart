import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/modules/auth/screens/login_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _fullName;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fullName = prefs.getString('fullName') ?? 'User';
      });
    } catch (e) {
      print("Lỗi tải dữ liệu user: $e");
      setState(() {
        _fullName = 'User';
      });
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('fullName');
      await prefs.remove('email');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        print("Home tapped");
        break;
      case 1:
        print("Profile tapped");
        break;
      case 2:
        print("Settings tapped");
        break;
      case 3:
        _logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        elevation: 0,
        title: Text(
          'Chào mừng, ${_fullName ?? 'User'}!',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _fullName ?? 'User',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.amber[300],
                child: Icon(Icons.person, size: 40, color: Colors.black87),
              ),
              decoration: BoxDecoration(color: Colors.amber[700]),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.amber[700]),
              title: Text('Đăng xuất', style: TextStyle(fontSize: 16)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.amber[100],
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Nội dung chính sẽ được thêm vào đây',
                  style: TextStyle(fontSize: 18, color: Colors.amber[800]),
                ),
              ),
            ),
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Logout',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[700],
              onTap: _onItemTapped,
              backgroundColor: Colors.amber[300],
            ),
          ],
        ),
      ),
    );
  }
}
