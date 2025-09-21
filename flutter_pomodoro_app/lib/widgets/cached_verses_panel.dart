import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';

/// Dialog/overlay showing cached scripture passages (termed 'Cached Verses' in UI).
class CachedVersesPanel extends ConsumerWidget {
  const CachedVersesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(scriptureRepositoryProvider).history;
    return AlertDialog(
      key: const Key('cached_verses_panel'),
      title: const Text('Cached Verses'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: history.isEmpty
            ? const Center(
                child: Text(
                  'No verses cached yet.',
                  key: Key('cached_verses_empty'),
                ),
              )
            : Scrollbar(
                child: ListView.separated(
                  key: const Key('cached_verses_list'),
                  primary: false,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final p = history[i];
                    return Semantics(
                      label:
                          '${p.reference} ${p.text.substring(0, p.text.length > 40 ? 40 : p.text.length)}',
                      child: ListTile(
                        key: Key('cached_verse_tile_$i'),
                        dense: true,
                        title: Text(p.reference, key: Key('cached_verse_ref_$i')),
                        subtitle: Text(
                          p.text,
                          key: Key('cached_verse_text_$i'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          key: const Key('cached_verses_close'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
