import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationPage.dart';
import 'WorkOrderPage.dart';
import 'login_screen.dart'; // ✅ import your LoginScreen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('jwt_expiry');
    await prefs.remove('username');

    // ✅ Use explicit pushReplacement to go back to LoginScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // Responsive content
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth >= 800;

              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: isWide
                    ? Row(
                        children: [
                          // Left panel
                          Expanded(
                            flex: 2,
                            child: _buildTextPanel(),
                          ),
                          // Right cards
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildCard(
                                  context: context,
                                  title: 'Notification',
                                  description: 'View all your recent notifications.',
                                  icon: Icons.notifications,
                                  pageBuilder: () => const NotificationPage(),
                                ),
                                const SizedBox(width: 30),
                                _buildCard(
                                  context: context,
                                  title: 'Work Order',
                                  description: 'Manage and track work orders.',
                                  icon: Icons.work,
                                  pageBuilder: () => const WorkOrderPage(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextPanel(),
                            const SizedBox(height: 40),
                            _buildCard(
                              context: context,
                              title: 'Notification',
                              description: 'View all your recent notifications.',
                              icon: Icons.notifications,
                              pageBuilder: () => const NotificationPage(),
                            ),
                            const SizedBox(height: 30),
                            _buildCard(
                              context: context,
                              title: 'Work Order',
                              description: 'Manage and track work orders.',
                              icon: Icons.work,
                              pageBuilder: () => const WorkOrderPage(),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Maintenance \nPortal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Check your notifications and work orders',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  static Widget _buildCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Widget Function() pageBuilder,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => pageBuilder(),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 50,
              color: const Color.fromARGB(255, 156, 0, 0),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 80),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

