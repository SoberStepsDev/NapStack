import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/timer/alarm_service.dart';
import '../../features/timer/nap_preset.dart';
import '../../features/pro/user_prefs_service.dart';

/// Widget do wyboru dzwonka w ustawieniach.
class RingtoneSelector extends ConsumerStatefulWidget {
  const RingtoneSelector({super.key});

  @override
  ConsumerState<RingtoneSelector> createState() => _RingtoneSelectorState();
}

class _RingtoneSelectorState extends ConsumerState<RingtoneSelector> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final userPrefsService = ref.watch(userPrefsServiceProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: userPrefsService.getOrCreate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final selectedId = _selectedId ??
            (prefs['selected_ringtone'] as String? ??
                RingtoneType.defaultRingtone.resourceId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Dzwonka alarmu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...RingtoneType.values.map(
              (ringtone) => _buildRingtoneOption(
                ringtone,
                isSelected: ringtone.resourceId == selectedId,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRingtoneOption(RingtoneType ringtone, {required bool isSelected}) {
    return ListTile(
      leading: isSelected
          ? Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      title: Text(ringtone.label),
      subtitle: Text(ringtone.description),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      onTap: () {
        setState(() => _selectedId = ringtone.resourceId);
        _selectRingtone(ringtone);
      },
    );
  }

  Future<void> _selectRingtone(RingtoneType ringtone) async {
    AlarmService.setRingtone(ringtone);
    await ref.read(userPrefsServiceProvider).setSelectedRingtone(ringtone);
  }
}
