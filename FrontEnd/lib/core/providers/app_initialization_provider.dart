import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/notification_service.dart';

final appInitializationProvider = FutureProvider<void>((ref) async {
  await NotificationService.instance.initialize();
});
