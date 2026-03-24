import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/current_user_provider.dart';

class UsernameEntryScreen extends ConsumerStatefulWidget {
  const UsernameEntryScreen({super.key});

  @override
  ConsumerState<UsernameEntryScreen> createState() => _UsernameEntryScreenState();
}

class _UsernameEntryScreenState extends ConsumerState<UsernameEntryScreen> {
  final _usernameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;

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
              enabled: !_isLoading,
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
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('View Profiles'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (username.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and API key.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final mojangService = ref.read(mojangServiceProvider);
      final uuid = await mojangService.getUuid(username);

      if (uuid != null) {
        // Step 2.1.1: Validate API Key by fetching player data
        final hypixelService = ref.read(hypixelApiServiceProvider);
        final player = await hypixelService.getPlayer(uuid, apiKey);

        if (player != null) {
          // First set the UUID
          ref.read(currentUserProvider.notifier).setUuid(uuid);
          // Then set credentials (this will trigger the home screen switch in MyApp)
          await ref.read(credentialsProvider.notifier).setCredentials(username, apiKey);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not fetch player data. Is your API key correct?')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Minecraft user not found.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}
