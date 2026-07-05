import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/posters/domain/entities/poster_entity.dart';
import 'package:solar_hub/src/features/posters/presentation/widgets/poster_status_badge.dart';

class PosterCard extends StatelessWidget {
  final PosterEntity poster;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PosterCard({
    super.key,
    required this.poster,
    this.onTap,
    this.onToggleActive,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: poster.imageUrl != null
                    ? Image.network(poster.imageUrl!, width: 80, height: 80, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160)
                    : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (poster.companyName != null)
                      Text(poster.companyName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    if (poster.text != null)
                      Text(poster.text!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        PosterStatusBadge(poster: poster),
                        Text(poster.actionType, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              if (poster.isApproved && onToggleActive != null)
                IconButton(
                  icon: Icon(poster.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 20),
                  onPressed: onToggleActive,
                  tooltip: poster.isActive ? 'Pause' : 'Activate',
                ),
              if (onEdit != null)
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit, tooltip: 'Edit'),
              if (onDelete != null)
                IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: onDelete, tooltip: 'Delete'),
            ],
          ),
        ),
      ),
    );
  }
}
