import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class UsernameEntryScreen extends ConsumerStatefulWidget {
  const UsernameEntryScreen({super.key});

  @override
  ConsumerState<UsernameEntryScreen> createState() => _UsernameEntryScreenState();
}

class _UsernameEntryScreenState extends ConsumerState<UsernameEntryScreen> {
  final _usernameController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to SkyFall')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'Enter your Minecraft details to see your Skyblock data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Minecraft Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Hypixel API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
                helperText: 'Type /api new in Minecraft to get your key.',
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => _submit(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('View Profiles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (username.isNotEmpty && apiKey.isNotEmpty) {
      ref.read(credentialsProvider.notifier).setCredentials(username, apiKey);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and API key.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}
