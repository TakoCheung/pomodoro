import 'package:flutter/material.dart';

class AlarmBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  final Color backgroundColor;
  final String fontFamily;
  final String? reference;
  final String? snippet;

  const AlarmBanner({
    super.key,
    required this.onDismiss,
    required this.backgroundColor,
    required this.fontFamily,
    this.reference,
    this.snippet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('alarm_banner'),
      width: double.infinity,
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reference ?? "Time's up! 🎯",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    if (snippet != null && snippet!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        snippet!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                key: const Key('alarm_dismiss'),
                onPressed: onDismiss,
                child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
