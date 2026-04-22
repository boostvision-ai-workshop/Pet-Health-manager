import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../app/providers.dart';
import '../../app/router_refresh.dart';
import '../../models/models.dart';

/// PRD §7.5：创建 / 编辑单宠物档案。
class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({
    super.key,
    required this.isEditing,
  });

  final bool isEditing;

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _breed;
  late TextEditingController _initialWeight;
  PetGender _gender = PetGender.unknown;
  DateTime _birthday = DateTime(DateTime.now().year - 1);
  DateTime _adoptionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final repo = ref.read(petRepositoryProvider);
    final existing = repo.getPet();
    _name = TextEditingController(text: existing?.name ?? '');
    _breed = TextEditingController(text: existing?.breed ?? '');
    _initialWeight = TextEditingController(
      text: existing?.initialWeight?.toString() ?? '',
    );
    if (existing != null) {
      _gender = existing.gender;
      _birthday = existing.birthday;
      _adoptionDate = existing.adoptionDate;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _initialWeight.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPick,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) onPick(picked);
  }

  Future<void> _submit() async {
    final repo = ref.read(petRepositoryProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double? parseInitial() {
      final t = _initialWeight.text.trim();
      if (t.isEmpty) return null;
      return double.tryParse(t.replaceAll(',', '.'));
    }

    final errors = PetProfileRules.validate(
      name: _name.text,
      birthday: _birthday,
      adoptionDate: _adoptionDate,
      today: today,
    );

    final initial = parseInitial();
    if (initial != null && initial <= 0) {
      errors.add('初始体重必须大于 0');
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first)),
      );
      return;
    }

    final existing = repo.getPet();
    final id = existing?.id ?? 'pet_001';
    final pet = Pet(
      id: id,
      name: _name.text.trim(),
      birthday: _birthday,
      gender: _gender,
      breed: _breed.text.trim(),
      adoptionDate: _adoptionDate,
      avatar: existing?.avatar ?? '',
      latestWeight: initial ?? existing?.latestWeight,
      initialWeight: initial ?? existing?.initialWeight,
    );

    await repo.savePet(pet);
    routerRefreshNotifier.notify();
    ref.bumpAppData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? '编辑宠物档案' : '创建宠物档案';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(ChongbanTokens.spacePage),
          children: [
            Text(
              '头像暂用占位；后续可接相册。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: '姓名 *'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('出生日期 *'),
              subtitle: Text(_formatDate(_birthday)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(
                initial: _birthday,
                onPick: (d) => setState(() => _birthday = d),
              ),
            ),
            const SizedBox(height: 8),
            Text('性别', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<PetGender>(
              segments: const [
                ButtonSegment(value: PetGender.male, label: Text('弟弟')),
                ButtonSegment(value: PetGender.female, label: Text('妹妹')),
                ButtonSegment(value: PetGender.unknown, label: Text('未知')),
              ],
              selected: {_gender},
              onSelectionChanged: (s) =>
                  setState(() => _gender = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: '品种'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('到家日期 *'),
              subtitle: Text(_formatDate(_adoptionDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(
                initial: _adoptionDate,
                onPick: (d) => setState(() => _adoptionDate = d),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _initialWeight,
              decoration: const InputDecoration(
                labelText: '初始体重 (kg)',
                hintText: '可选',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _submit,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
