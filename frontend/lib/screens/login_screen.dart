import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final success = await AuthService().login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth >= 800;

        if (isWide) {
          // Side-by-side panels, no scroll needed
          return Row(
            children: [
              _buildLeftPanel(flex: 5),
              _buildRightPanel(flex: 3),
            ],
          );
        } else {
          // Stacked panels, whole page scrollable
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildLeftPanel(flex: 0), // flex is unused here
                _buildRightPanel(flex: 0),
              ],
            ),
          );
        }
      },
    ),
  );
}

Widget _buildLeftPanel({required int flex}) {
  final content = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/background.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      color: const Color.fromARGB(255, 106, 2, 6).withOpacity(0.8),
      width: double.infinity,
      height: flex > 0 ? double.infinity : null, // ✅ FIXED
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'Maintenance Portal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your maintenance history and insights, organized and accessible.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // Wrap in Expanded if needed
  return flex > 0 ? Expanded(flex: flex, child: content) : content;
}



Widget _buildRightPanel({required int flex}) {
  final content = Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              'User ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // If side-by-side: wrap with Expanded
  return flex > 0 ? Expanded(flex: flex, child: content) : content;
}
}
