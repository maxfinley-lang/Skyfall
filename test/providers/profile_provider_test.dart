import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skyblock/providers/profile_provider.dart';

void main() {
  group('ProfileProvider Provider Tests', () {
    test('apiKeyProvider should return value from dotenv', () async {
      // Setup mock dotenv
      dotenv.testLoad(fileInput: 'HYPIXEL_API_KEY=test-api-key');
      
      final container = ProviderContainer();
      
      final apiKey = container.read(apiKeyProvider);
      
      expect(apiKey, 'test-api-key');
    });

    test('apiKeyProvider should return empty string if key is missing', () async {
      // Setup mock dotenv with missing key
      dotenv.testLoad(fileInput: 'OTHER_KEY=something');
      
      final container = ProviderContainer();
      
      final apiKey = container.read(apiKeyProvider);
      
      expect(apiKey, '');
    });
  });
}
