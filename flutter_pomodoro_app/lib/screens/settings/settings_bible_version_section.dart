import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/state/settings_controller.dart';
import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/data/bible_versions.dart';

class SettingsBibleVersionSection extends ConsumerWidget {
  const SettingsBibleVersionSection({
    super.key,
    required this.settingsCtl,
    required this.settingsCtlNotifier,
  });

  final SettingsControllerState settingsCtl;
  final SettingsController settingsCtlNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BibleVersion>> versionsAsync = ref.watch(bibleVersionsProvider);
    return Row(
      children: [
        const Text('BIBLE VERSION', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        Expanded(
          child: versionsAsync.when(
            data: (list) {
              final Map<String, BibleVersion> byId = {for (final v in list) v.id: v};
              final uniqueList = byId.values.toList(growable: false);
              final items = uniqueList
                  .map((v) => DropdownMenuItem<String>(value: v.id, child: Text(v.label)))
                  .toList(growable: false);

              final currentName = settingsCtl.staged.bibleVersionName;
              final match = uniqueList.firstWhere(
                (v) =>
                    v.label == currentName ||
                    v.displayName == currentName ||
                    v.name == currentName ||
                    v.abbreviationLocal == currentName ||
                    v.abbreviation == currentName,
                orElse: () => uniqueList.first,
              );
              final selectedId = match.id;

              return DropdownButton<String>(
                key: const Key('bible_version_dropdown'),
                isExpanded: true,
                value: settingsCtl.staged.bibleVersionId ?? selectedId,
                items: items,
                onChanged: (id) {
                  if (id == null) return;
                  final sel = uniqueList.firstWhere((v) => v.id == id, orElse: () => match);
                  settingsCtlNotifier.updateStaged(
                    bibleVersionName: sel.label,
                    bibleVersionId: sel.id,
                  );
                },
              );
            },
            loading: () {
              final entries = kBibleVersions.entries.toList(growable: false);
              final items = entries
                  .map((e) => DropdownMenuItem<String>(value: e.value, child: Text(e.key)))
                  .toList(growable: false);
              final selectedId = settingsCtl.staged.bibleVersionId ??
                  kBibleVersions[settingsCtl.staged.bibleVersionName] ??
                  (entries.isNotEmpty ? entries.first.value : null);
              return DropdownButton<String>(
                key: const Key('bible_version_dropdown'),
                isExpanded: true,
                value: selectedId,
                items: items,
                onChanged: (id) {
                  if (id == null) return;
                  final e = entries.firstWhere((e) => e.value == id, orElse: () => entries.first);
                  settingsCtlNotifier.updateStaged(
                    bibleVersionName: e.key,
                    bibleVersionId: e.value,
                  );
                },
              );
            },
            error: (_, __) {
              final entries = kBibleVersions.entries.toList(growable: false);
              final items = entries
                  .map((e) => DropdownMenuItem<String>(value: e.value, child: Text(e.key)))
                  .toList(growable: false);
              final selectedId = settingsCtl.staged.bibleVersionId ??
                  kBibleVersions[settingsCtl.staged.bibleVersionName] ??
                  (entries.isNotEmpty ? entries.first.value : null);
              return DropdownButton<String>(
                key: const Key('bible_version_dropdown'),
                isExpanded: true,
                value: selectedId,
                items: items,
                onChanged: (id) {
                  if (id == null) return;
                  final e = entries.firstWhere((e) => e.value == id, orElse: () => entries.first);
                  settingsCtlNotifier.updateStaged(
                    bibleVersionName: e.key,
                    bibleVersionId: e.value,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
