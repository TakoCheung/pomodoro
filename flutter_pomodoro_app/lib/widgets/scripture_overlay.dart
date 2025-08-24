import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';

class ScriptureOverlay extends ConsumerStatefulWidget {
  final String bibleId;
  final String passageId;
  /// How many seconds before the overlay auto-hides. Defaults to 60 seconds (one minute).
  final int autoHideSeconds;

  const ScriptureOverlay({super.key, required this.bibleId, required this.passageId, this.autoHideSeconds = 60});

  @override
  ConsumerState<ScriptureOverlay> createState() => _ScriptureOverlayState();
}

class _ScriptureOverlayState extends ConsumerState<ScriptureOverlay> {
  Timer? _hideTimer;

  void _startAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: widget.autoHideSeconds), () {
      ref.read(scriptureOverlayVisibleProvider.notifier).state = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Start auto-hide after the first frame so any animations/layout are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoHide());
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _hideTimer?.cancel();
    ref.read(scriptureOverlayVisibleProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    // If a Passage was set directly (e.g. in tests or debug), show it immediately
    final direct = ref.watch(shownScriptureProvider);
    if (direct != null) {
      final p = direct;
      debugPrint('ScriptureOverlay: showing direct Passage ${p.reference}');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          elevation: 6,
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(p.reference, key: const Key('scripture_reference'), style: const TextStyle(fontWeight: FontWeight.bold))),
                    IconButton(
                      key: const Key('scripture_close_button'),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _dismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(p.text, key: const Key('scripture_text'), maxLines: 6, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
    }

    final asyncPassage = ref.watch(scriptureProvider(ScriptureRequest(bibleId: widget.bibleId, passageId: widget.passageId)));
    return asyncPassage.when(
      data: (p) {
        debugPrint('ScriptureOverlay: showing fetched Passage ${p.reference}');
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            elevation: 6,
            color: Colors.white70,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(p.reference, key: const Key('scripture_reference'), style: const TextStyle(fontWeight: FontWeight.bold))),
                      IconButton(
                        key: const Key('scripture_close_button'),
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _dismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(p.text, key: const Key('scripture_text'), maxLines: 6, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
