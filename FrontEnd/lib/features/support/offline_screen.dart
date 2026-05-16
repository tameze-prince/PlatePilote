import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';
import '../../shared/widgets/plate_scaffold.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlateScaffold(
      title: 'Offline',
      showBack: true,
      child: EmptyState(
        icon: Icons.wifi_off,
        title: 'You are offline',
        message:
            'PlatePilot will keep local data available and sync when the connection returns.',
      ),
    );
  }
}
