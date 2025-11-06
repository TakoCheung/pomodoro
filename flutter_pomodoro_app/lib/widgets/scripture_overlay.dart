import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';
import 'package:flutter_pomodoro_app/state/encouragement_provider.dart';

class ScriptureOverlay extends ConsumerStatefulWidget {
  final String bibleId;
  final String passageId;

  /// How many seconds before the overlay auto-hides. Defaults to 60 seconds (one minute).
  final int autoHideSeconds;

  const ScriptureOverlay(
      {super.key, required this.bibleId, required this.passageId, this.autoHideSeconds = 60});

  @override
  ConsumerState<ScriptureOverlay> createState() => _ScriptureOverlayState();
}

class _ScriptureOverlayState extends ConsumerState<ScriptureOverlay> {
  Timer? _hideTimer;

  Widget _buildOverlayContent({
    required BuildContext context,
    required String font,
    required String reference,
    required String text,
    String? encouragement,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Material(
          key: const Key('scripture_overlay_material'),
          elevation: 6,
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              key: const Key('scripture_overlay_scroll'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      key: const Key('scripture_close_button'),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _dismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Text(reference,
                      key: const Key('scripture_reference'),
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: font)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(text, key: const Key('scripture_text'), style: TextStyle(fontFamily: font)),
                  if (encouragement != null && encouragement.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(encouragement,
                        key: const Key('scripture_encouragement'),
                        style: TextStyle(fontFamily: font, color: Colors.black87)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
    // Apply font from settings across the overlay
    final settings = ref.watch(localSettingsProvider);
    final font = settings.fontFamily;
    // If a Passage was set directly (e.g. in tests or debug), show it immediately
    final direct = ref.watch(shownScriptureProvider);
    if (direct != null) {
      final p = direct;
      debugPrint('ScriptureOverlay: showing Passage from state ${p.reference}');
      final maybeEnc = ref
          .watch(encouragementForCurrentPassageProvider)
          .maybeWhen(data: (v) => v, orElse: () => null);
      return _buildOverlayContent(
        context: context,
        font: font,
        reference: p.reference,
        text: p.text,
        encouragement: maybeEnc,
      );
    }

    final asyncPassage = ref.watch(
        scriptureProvider(ScriptureRequest(bibleId: widget.bibleId, passageId: widget.passageId)));
    return asyncPassage.when(
      data: (p) {
        debugPrint('ScriptureOverlay: showing fetched Passage ${p.reference}');
        final maybeEnc = ref
            .watch(encouragementForCurrentPassageProvider)
            .maybeWhen(data: (v) => v, orElse: () => null);
        return _buildOverlayContent(
          context: context,
          font: font,
          reference: p.reference,
          text: p.text,
          encouragement: maybeEnc,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
