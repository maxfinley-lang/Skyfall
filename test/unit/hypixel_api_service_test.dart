import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:skyblock/services/hypixel_api_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late HypixelApiService service;
  late MockHttpClient client;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    client = MockHttpClient();
    service = HypixelApiService(client: client);
  });

  group('HypixelApiService Unit Tests', () {
    const uuid = 'user-uuid';
    const apiKey = 'api-key';

    test('getProfiles should return profiles for valid UUID', () async {
      final responseBody = jsonEncode({
        'success': true,
        'profiles': [
          {'profile_id': 'p1', 'cute_name': 'Apple', 'selected': true},
          {'profile_id': 'p2', 'cute_name': 'Banana', 'selected': false},
        ]
      });

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      final result = await service.getProfiles(uuid, apiKey);

      expect(result.length, 2);
      expect(result[0].profileId, 'p1');
      expect(result[0].isActive, true);
      expect(result[1].profileId, 'p2');
      expect(result[1].isActive, false);
    });

    test('getProfiles should throw exception on Hypixel error', () async {
      final responseBody = jsonEncode({
        'success': false,
        'cause': 'Invalid API Key',
      });

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      expect(() => service.getProfiles(uuid, apiKey), throwsException);
    });

    test('getProfiles should throw exception on non-200 response', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      expect(() => service.getProfiles(uuid, apiKey), throwsException);
    });

    test('getPlayer should return player data for valid UUID', () async {
      final responseBody = jsonEncode({
        'success': true,
        'player': {
          'uuid': uuid,
          'displayname': 'TestPlayer',
        }
      });

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      final result = await service.getPlayer(uuid, apiKey);

      expect(result?['displayname'], 'TestPlayer');
      expect(result?['uuid'], uuid);
    });

    test('getPlayer should throw exception on Hypixel error', () async {
      final responseBody = jsonEncode({
        'success': false,
        'cause': 'Invalid API Key',
      });

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(responseBody, 200),
      );

      expect(() => service.getPlayer(uuid, apiKey), throwsException);
    });
  });
}
