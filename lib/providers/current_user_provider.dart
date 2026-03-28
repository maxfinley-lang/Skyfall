import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setUuid(String? uuid) {
    state = uuid;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(CurrentUserNotifier.new);
