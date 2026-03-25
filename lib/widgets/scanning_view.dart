import 'package:flutter/material.dart';
import '../providers/gallery_provider.dart';

class ScanningView extends StatelessWidget {
  final ScanStatus status;
  final String statusMessage;
  final double progress;
  final String? errorMessage;
  final VoidCallback onStart;

  const ScanningView({
    super.key,
    required this.status,
    required this.statusMessage,
    required this.progress,
    this.errorMessage,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon / status icon
            _buildStatusIcon(colorScheme),
            const SizedBox(height: 32),

            // Title
            Text(
              status == ScanStatus.idle
                  ? 'Smart Gallery'
                  : status == ScanStatus.error
                      ? 'Oops!'
                      : 'Analyzing Photos',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Status message
            Text(
              status == ScanStatus.idle
                  ? 'Scan your photos to automatically group them by people and categories'
                  : status == ScanStatus.error
                      ? errorMessage ?? 'An error occurred'
                      : statusMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: status == ScanStatus.error
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Progress bar (when scanning)
            if (status != ScanStatus.idle && status != ScanStatus.error) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Start / Retry button
            if (status == ScanStatus.idle || status == ScanStatus.error)
              FilledButton.icon(
                onPressed: onStart,
                icon: Icon(status == ScanStatus.error
                    ? Icons.refresh
                    : Icons.photo_library),
                label: Text(
                  status == ScanStatus.error ? 'Retry' : 'Start Scanning',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    if (status == ScanStatus.idle) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.auto_awesome,
          size: 48,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    if (status == ScanStatus.error) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.error_outline,
          size: 48,
          color: colorScheme.onErrorContainer,
        ),
      );
    }

    // Scanning animation
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: colorScheme.primary,
            ),
          ),
          Icon(
            _getStatusIcon(),
            size: 36,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ScanStatus.scanning:
        return Icons.photo_library;
      case ScanStatus.detectingFaces:
        return Icons.face;
      case ScanStatus.classifying:
        return Icons.category;
      default:
        return Icons.hourglass_top;
    }
  }
}
