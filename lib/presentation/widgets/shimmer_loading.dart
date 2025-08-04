import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weather Card Shimmer
        _buildShimmerContainer(
          height: 280,
          width: double.infinity,
          borderRadius: 24,
        ),
        const SizedBox(height: 24),
        
        // Hourly Forecast Title
        _buildShimmerContainer(
          height: 20,
          width: 150,
          borderRadius: 8,
        ),
        const SizedBox(height: 12),
        
        // Hourly Forecast
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: _buildShimmerContainer(
                  height: 120,
                  width: 80,
                  borderRadius: 16,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        
        // Weather Details Title
        _buildShimmerContainer(
          height: 20,
          width: 130,
          borderRadius: 8,
        ),
        const SizedBox(height: 12),
        
        // Weather Details Grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: List.generate(
            6,
            (index) => _buildShimmerContainer(
              height: 100,
              width: double.infinity,
              borderRadius: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Daily Forecast Title
        _buildShimmerContainer(
          height: 20,
          width: 140,
          borderRadius: 8,
        ),
        const SizedBox(height: 12),
        
        // Daily Forecast
        _buildShimmerContainer(
          height: 350,
          width: double.infinity,
          borderRadius: 16,
        ),
      ],
    );
  }

  Widget _buildShimmerContainer({
    required double height,
    required double width,
    required double borderRadius,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Shimmer.fromColors(
          baseColor: colorScheme.surface,
          highlightColor: colorScheme.onSurface.withOpacity(0.1),
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
    );
  }
}