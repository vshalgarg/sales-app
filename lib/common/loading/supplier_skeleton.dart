
import 'package:flutter/material.dart';
import 'package:hisabio/common/loading/shimmer.dart';

class SupplierSkeleton extends StatelessWidget {
  const SupplierSkeleton({super.key});

  Widget _placeholder({
    required double width,
    required double height,
    double radius = 5,
  }) {
    return ShimmerEffect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE9EAF0),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _placeholder(width: 65, height: 23),
                  const SizedBox(height: 12),
                  _placeholder(width: 175, height: 16),
                  const SizedBox(height: 12),
                  _placeholder(width: 130, height: 13),
                  const SizedBox(height: 9),
                  _placeholder(width: 155, height: 13),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                _placeholder(width: 34, height: 34, radius: 9),
                const SizedBox(height: 10),
                _placeholder(width: 34, height: 34, radius: 9),
                const SizedBox(height: 10),
                _placeholder(width: 34, height: 34, radius: 9),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierSkeletonList extends StatelessWidget {
  final int itemCount;

  const SupplierSkeletonList({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SupplierSkeleton(
          key: ValueKey('supplier-skeleton-$index'),
        );
      },
    );
  }
}
