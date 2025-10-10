import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
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
                    'Fishcast Terms of Use',
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

            // Simple terms
            _buildSection(
              'Welcome to Fishcast!',
              'By using our weather app, you agree to these simple terms:',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'What We Provide',
              'Fishcast gives you weather forecasts, current conditions, fish supply, and price alerts based on your location.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Your Responsibility',
              '• Use the app responsibly\n'
                  '• Keep your account secure\n'
                  '• Don\'t misuse the service\n'
                  '• Respect others\' privacy',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Weather Data',
              'Weather information comes from third-party services. We can\'t guarantee it\'s always 100% accurate, so please use it as a guide.',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Our Rights',
              '• We can update or change the app\n'
                  '• We can suspend accounts that break the rules\n'
                  '• All app content belongs to Fishcast',
            ),

            const SizedBox(height: 24),

            _buildSection(
              'No Guarantees',
              'We provide the app "as is" without warranties. We\'re not responsible for any issues that come from using weather information.',
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
