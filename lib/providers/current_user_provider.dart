import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mojang_service.dart';

final mojangServiceProvider = Provider<MojangService>((ref) => MojangService());

class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setUuid(String? uuid) {
    state = uuid;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(CurrentUserNotifier.new);
