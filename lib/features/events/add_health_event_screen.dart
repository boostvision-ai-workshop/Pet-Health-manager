import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../app/providers.dart';
import '../../models/models.dart';
import '../../services/local_notification_service.dart';
import '../../shared/event_type_labels.dart';

/// PRD §7.4：新增健康事件。
class AddHealthEventScreen extends ConsumerStatefulWidget {
  const AddHealthEventScreen({super.key});

  @override
  ConsumerState<AddHealthEventScreen> createState() =>
      _AddHealthEventScreenState();
}

class _AddHealthEventScreenState extends ConsumerState<AddHealthEventScreen> {
  HealthEventType _type = HealthEventType.weight;
  DateTime _when = DateTime.now();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _reminderDueDate;

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (time == null || !mounted) return;
    setState(() {
      _when = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickReminderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date != null) {
      setState(() {
        _reminderDueDate = DateTime(date.year, date.month, date.day, 9, 0);
      });
    }
  }

  Future<void> _save() async {
    final repo = ref.read(petRepositoryProvider);
    double? value;
    if (_type == HealthEventType.weight) {
      final raw = _valueController.text.trim().replaceAll(',', '.');
      value = double.tryParse(raw);
    }

    final ts = DateTime.now().millisecondsSinceEpoch;
    final event = HealthEvent(
      id: 'evt_$ts',
      type: _type,
      dateTime: _when,
      value: _type == HealthEventType.weight ? value : null,
      unit: _type == HealthEventType.weight ? 'kg' : null,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    final errors = HealthEventRules.validate(event);
    if (errors.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first)),
      );
      return;
    }

    await repo.saveEvent(event);

    if (_reminderDueDate != null) {
      final rem = Reminder(
        id: 'rem_$ts',
        eventId: event.id,
        title: '${healthEventTypeLabel(_type)}提醒',
        dueDate: _reminderDueDate!,
        status: ReminderStatus.todo,
      );
      await repo.saveReminder(rem);
    }

    await LocalNotificationService.syncWithRepository(repo);
    ref.bumpAppData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增健康记录')),
      body: ListView(
        padding: const EdgeInsets.all(ChongbanTokens.spacePage),
        children: [
          DropdownButtonFormField<HealthEventType>(
            value: _type,
            decoration: const InputDecoration(labelText: '类型'),
            items: HealthEventType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(healthEventTypeLabel(t)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('日期与时间'),
            subtitle: Text(_when.toString().substring(0, 16)),
            trailing: const Icon(Icons.schedule),
            onTap: _pickDateTime,
          ),
          if (_type == HealthEventType.weight) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: '体重 (kg) *',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '备注',
              hintText: '最多 ${HealthEventRules.maxNoteLength} 字',
            ),
            maxLines: 3,
            maxLength: HealthEventRules.maxNoteLength,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('下次提醒'),
            subtitle: Text(
              _reminderDueDate == null
                  ? '未设置（可选）'
                  : _reminderDueDate!.toString().substring(0, 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_reminderDueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () =>
                        setState(() => _reminderDueDate = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: _pickReminderDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
