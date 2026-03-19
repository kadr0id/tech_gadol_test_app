import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.withAlpha(2);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(1)),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.white,
        colorOpacity: 0.3,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: double.infinity, height: 16, color: baseColor),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 12, color: baseColor),
                    const SizedBox(height: 16),
                    Container(width: 80, height: 18, color: baseColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}