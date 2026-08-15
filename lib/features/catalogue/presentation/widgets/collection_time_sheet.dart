import 'package:flutter/material.dart';

class CollectionTimeSheet extends StatefulWidget {
  const CollectionTimeSheet({super.key});

  @override
  State<CollectionTimeSheet> createState() => _CollectionTimeSheetState();
}

class _CollectionTimeSheetState extends State<CollectionTimeSheet> {
  int selectedDay = 0;
  int? selectedHour;

  final availableHours = [9, 10, 11, 12, 13, 14, 15, 16];

  DateTime get selectedDate {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day + selectedDay);
  }

  DateTime? get collectionAt {
    if (selectedHour == null) {
      return null;
    }

    final date = selectedDate;

    return DateTime(date.year, date.month, date.day, selectedHour!);
  }

  bool _isHourAvailable(int hour) {
    if (selectedDay == 1) {
      return true;
    }

    final now = DateTime.now();

    final slot = DateTime(now.year, now.month, now.day, hour);

    // Require the slot to still be in the future.
    return slot.isAfter(now);
  }

  bool get _hasAvailableToday {
    return availableHours.any(_isHourAvailable);
  }

  @override
  Widget build(BuildContext context) {
    final selected = collectionAt;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Collection Time',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Your product will be held for '
              '30 minutes from the selected time.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Text(
              'Collection day',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            SegmentedButton<int>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFB42318);
                  }
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFFF1F5F9);
                  }
                  return Colors.white;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFF64748B);
                  }
                  return const Color(0xFF111827);
                }),
                side: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const BorderSide(color: Color(0xFFB42318));
                  }
                  return const BorderSide(color: Color(0xFFE9E2DF));
                }),
              ),
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  label: Text(
                    _hasAvailableToday ? 'Today' : 'Today (Unavailable)',
                  ),
                  enabled: _hasAvailableToday,
                ),
                const ButtonSegment<int>(value: 1, label: Text('Tomorrow')),
              ],
              selected: {selectedDay},
              onSelectionChanged: (value) {
                setState(() {
                  selectedDay = value.first;
                  selectedHour = null;
                });
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Collection time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableHours.map((hour) {
                final available = _isHourAvailable(hour);

                final isSelected = selectedHour == hour;

                return ChoiceChip(
                  label: Text('${hour.toString().padLeft(2, '0')}:00'),
                  selected: isSelected,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFB42318),
                  disabledColor: const Color(0xFFF1F5F9),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFB42318)
                        : const Color(0xFFE9E2DF),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : available
                        ? const Color(0xFF111827)
                        : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: available
                      ? (_) {
                          setState(() {
                            selectedHour = hour;
                          });
                        }
                      : null,
                );
              }).toList(),
            ),

            if (selected != null) ...[
              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      color: Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Collection: '
                        '${_formatTime(selected)}\n'
                        'Held until: '
                        '${_formatTime(selected.add(const Duration(minutes: 30)))}',
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selected == null
                    ? null
                    : () {
                        Navigator.pop(context, selected);
                      },
                child: const Text('Confirm Collection Time'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');

    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
