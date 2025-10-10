import 'package:fishcast/core/utils/constants.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: kForegroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Getting Started',
            icon: Icons.rocket_launch,
            items: [
              _HelpItem(
                question: 'How do I use Fishcast?',
                answer:
                    'Fishcast helps you monitor fish prices, weather conditions, and moon phases to optimize your fishing activities. Navigate through the app using the bottom navigation bar.',
              ),
              _HelpItem(
                question: 'How to create an account?',
                answer:
                    'Tap on "Sign Up" on the login screen, enter your details, and create your account. You can also sign up with Google for faster access.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            context,
            title: 'Features',
            icon: Icons.star,
            items: [
              _HelpItem(
                question: 'Dashboard',
                answer:
                    'View real-time weather conditions, current moon phase, and highest price fish at a glance.',
              ),
              _HelpItem(
                question: 'Weather',
                answer:
                    'Access detailed 7-day weather forecasts and moon phase calendar to plan your fishing trips.',
              ),
              _HelpItem(
                question: 'Forecast',
                answer:
                    'Analyze fish price trends and market data to make informed decisions about when to sell your catch.',
              ),
              _HelpItem(
                question: 'Notifications',
                answer:
                    'Receive alerts about price changes, weather warnings, and important market updates.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            context,
            title: 'Weather & Moon Phases',
            icon: Icons.wb_sunny,
            items: [
              _HelpItem(
                question: 'Why are moon phases important for fishing?',
                answer:
                    'Moon phases affect fish behavior and feeding patterns. Full and new moons often result in better catches.',
              ),
              _HelpItem(
                question: 'How accurate is the weather forecast?',
                answer:
                    'Weather data is sourced from reliable APIs and updates every 30 minutes for current conditions and hourly for forecasts.',
              ),
              _HelpItem(
                question: 'Can I see weather for different locations?',
                answer:
                    'The app automatically detects your location. If location services are disabled, it defaults to Zamboanga City.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            context,
            title: 'Account & Settings',
            icon: Icons.account_circle,
            items: [
              _HelpItem(
                question: 'How do I update my profile?',
                answer:
                    'Go to the Profile tab, tap on "Edit Profile", and update your information. Don\'t forget to save your changes.',
              ),
              _HelpItem(
                question: 'How do I change my password?',
                answer:
                    'Navigate to Profile > Settings > Change Password to update your login credentials.',
              ),
              _HelpItem(
                question: 'How do I delete my account?',
                answer:
                    'Go to Profile > Settings > Delete Account. Note: This action cannot be undone and all your data will be permanently deleted.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            context,
            title: 'Troubleshooting',
            icon: Icons.help_outline,
            items: [
              _HelpItem(
                question: 'App is not loading data',
                answer:
                    'Check your internet connection. If the issue persists, try clearing the app cache in your device settings.',
              ),
              _HelpItem(
                question: 'Location not detected',
                answer:
                    'Enable location services in your device settings and grant location permission to Fishcast.',
              ),
              _HelpItem(
                question: 'Notifications not working',
                answer:
                    'Ensure notifications are enabled for Fishcast in your device settings. Check if Do Not Disturb mode is off.',
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildContactCard(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_HelpItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kSecondaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kForegroundColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildHelpItem(context, item)),
      ],
    );
  }

  Widget _buildHelpItem(BuildContext context, _HelpItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kForegroundColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                item.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF03457F), Color(0xFF009BDD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.contact_support, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Need More Help?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact our support team for assistance',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact: eh202201029@wmsu.edu.ph'),
                    backgroundColor: kSecondaryColor,
                  ),
                );
              },
              icon: const Icon(Icons.email, color: kSecondaryColor),
              label: const Text(
                'Contact Support',
                style: TextStyle(color: kSecondaryColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem {
  final String question;
  final String answer;

  _HelpItem({required this.question, required this.answer});
}
