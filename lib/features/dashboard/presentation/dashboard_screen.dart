import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar replacement as a Container
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
              ],
            ),
          ),
        ),
        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  'Today\'s Route',
                  Icons.route,
                  Colors.blue,
                  onTap: () {
                    // TODO: Navigate to route details
                  },
                ),
                _buildDashboardCard(
                  context,
                  'Schedule',
                  Icons.calendar_today,
                  Colors.green,
                  onTap: () {
                    // TODO: Navigate to calendar
                  },
                ),
                _buildDashboardCard(
                  context,
                  'Active Jobs',
                  Icons.work,
                  Colors.orange,
                  onTap: () {
                    // TODO: Navigate to jobs
                  },
                ),
                _buildDashboardCard(
                  context,
                  'Maps',
                  Icons.map,
                  Colors.red,
                  onTap: () {
                    // TODO: Navigate to maps
                  },
                ),
                _buildDashboardCard(
                  context,
                  'Earnings',
                  Icons.attach_money,
                  Colors.purple,
                  onTap: () {
                    // TODO: Show earnings
                  },
                ),
                _buildDashboardCard(
                  context,
                  'Profile',
                  Icons.person,
                  Colors.teal,
                  onTap: () {
                    // TODO: Navigate to profile
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1024) return 4; // Large iPad
    if (width > 768) return 3; // Standard iPad
    return 2; // Smaller screens
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
