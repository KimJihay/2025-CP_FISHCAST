import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            Center(
              child: Column(
                children: [
                  SvgPicture.asset('assets/logo.svg', height: 60, width: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Fishcast Privacy Policy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Simple privacy policy
            _buildSection(
              'Your Privacy Matters',
              'At Fishcast, we respect your privacy and are committed to protecting your personal information.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Information We Collect',
              '• Location: To give you accurate weather forecasts\n'
                  '• Account Info: Name, email when you sign up\n'
                  '• App Usage: How you use the app to improve it\n'
                  '• Device Info: To make the app work better',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'How We Use Your Information',
              '• Weather Services: To provide forecasts and alerts\n'
                  '• App Improvement: To make Fishcast better\n'
                  '• Communication: To send important updates\n'
                  '• Security: To keep your account safe',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Information Sharing',
              'We don\'t sell your personal information. We only share data when required by law or with service providers who help us run the app.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Data Security',
              'We use industry-standard security measures to protect your information. However, no internet service is 100% secure.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Your Rights',
              '• Access: See what information we have about you\n'
                  '• Update: Change your account information\n'
                  '• Delete: Remove your account and data\n'
                  '• Opt-out: Stop receiving marketing messages',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Children\'s Privacy',
              'Fishcast is not intended for children under 13. We don\'t knowingly collect personal information from children.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Changes to This Policy',
              'We may update this privacy policy from time to time. We\'ll let you know about any important changes.',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
