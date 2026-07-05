import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/posters/presentation/controllers/active_posters_provider.dart';
import 'package:solar_hub/src/shared/presntations/providers/is_enabled_providers.dart';

class PosterCarousel extends ConsumerWidget {
  const PosterCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(isPosterEnabled);
    if (!enabled) return const SizedBox.shrink();

    final async = ref.watch(activePostersProvider);
    final l10n = AppLocalizations.of(context);
    return async.when(
      loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, _) => const SizedBox.shrink(),
      data: (posters) {
        if (posters.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                l10n?.posters ?? 'Company Posters',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posters.length,
                itemBuilder: (_, i) {
                  final poster = posters[i];
                  return GestureDetector(
                    onTap: () => _handlePosterTap(context, poster),
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: poster.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(poster.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: poster.imageUrl == null ? Colors.teal.shade800 : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Gradient Overlay for readability
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 100,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (poster.text != null && poster.text!.isNotEmpty)
                                    Text(
                                      poster.text!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (poster.text != null && poster.text!.isNotEmpty)
                                    const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.business, color: Colors.white, size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              poster.companyName ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePosterTap(BuildContext context, dynamic poster) {
    if (poster.actionType == 'company_profile' || poster.actionType == 'post') {
      // post: fallback to company profile until community is active
      Navigator.pushNamed(context, '/services/company/${poster.companyId}');
    } else if (poster.actionType == 'work') {
      if (poster.actionId != null) {
        Navigator.pushNamed(context, '/company-work/${poster.actionId}');
      } else {
        Navigator.pushNamed(context, '/company-work');
      }
    } else if (poster.actionType == 'product') {
      if (poster.actionId != null) {
        Navigator.pushNamed(context, '/storefront/product/${poster.actionId}');
      } else {
        Navigator.pushNamed(context, '/storefront/products', arguments: {'audience': 'b2c'});
      }
    }
  }
}
