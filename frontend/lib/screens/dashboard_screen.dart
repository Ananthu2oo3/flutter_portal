import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String protectedData = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchProtectedData();
  }

  Future<void> _fetchProtectedData() async {
    final response = await AuthService().getProtectedData('notification');
    if (response.statusCode == 200) {
      setState(() {
        protectedData = response.body;
      });
    } else {
      setState(() {
        protectedData = 'Failed to load protected data';
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text(protectedData),
      ),
    );
  }
}
