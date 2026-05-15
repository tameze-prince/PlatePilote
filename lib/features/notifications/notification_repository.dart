import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/mvp_entities.dart';
import 'notifications_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref);
});

class NotificationRepository {
  const NotificationRepository(this._ref);

  final Ref _ref;

  List<AppNotification> read() => _ref.read(notificationsProvider);
  void markAllRead() => _ref.read(notificationsProvider.notifier).markAllRead();
}
