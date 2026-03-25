import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/photo_group.dart';

class GroupGridTile extends StatelessWidget {
  final PhotoGroup group;
  final IconData? icon;
  final String? emoji;
  final VoidCallback onTap;

  const GroupGridTile({
    super.key,
    required this.group,
    this.icon,
    this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover image
            Expanded(
              child: FutureBuilder<Uint8List?>(
                future: group.getCoverThumbnail(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: emoji != null
                          ? Text(emoji!, style: const TextStyle(fontSize: 40))
                          : Icon(
                              icon ?? Icons.photo,
                              size: 40,
                              color: colorScheme.onSurfaceVariant,
                            ),
                    ),
                  );
                },
              ),
            ),

            // Info bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (emoji != null) ...[
                    Text(emoji!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      group.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${group.photoCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
