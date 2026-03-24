import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:skyblock/services/mojang_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MojangService mojangService;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mojangService = MojangService(client: mockHttpClient);
  });

  group('MojangService Unit Tests', () {
    test('getUuid should return UUID for valid username', () async {
      final username = 'test_user';
      final uuid = '1234567890';
      final responseBody = '{"id": "$uuid", "name": "$username"}';

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      final result = await mojangService.getUuid(username);

      expect(result, uuid);
    });

    test('getUuid should return null for 204 response', () async {
      final username = 'invalid_user';

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('', 204),
      );

      final result = await mojangService.getUuid(username);

      expect(result, isNull);
    });

    test('getUuid should throw exception on non-200/404 response', () async {
      final username = 'test_user';

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Internal Server Error', 500),
      );

      expect(() => mojangService.getUuid(username), throwsException);
    });
  });
}
