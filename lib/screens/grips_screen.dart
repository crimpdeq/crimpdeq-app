import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/grip_models.dart';
import '../providers/grip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class GripsScreen extends ConsumerWidget {
  const GripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gripsAsync = ref.watch(gripListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackgroundGradient(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'Grips',
                    style: tsInterW800S24.copyWith(
                      color: isDark ? webText : lightText,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/grips/create'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: brandAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 16)),
          gripsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Failed to load grips',
                  style: tsInterS14.copyWith(color: webMuted),
                ),
              ),
            ),
            data: (grips) {
              if (grips.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(isDark: isDark),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: grips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _GripCard(
                    grip: grips[index],
                    isDark: isDark,
                    onDelete: () async {
                      final dao = await ref.read(gripDaoProvider.future);
                      await dao.deleteGrip(grips[index].id);
                      ref.invalidate(gripListProvider);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.back_hand_outlined,
            size: 48,
            color: webMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No grips yet',
            style: tsInterW600S16.copyWith(
              color: isDark ? webText : lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to create your first grip',
            style: tsInterS14.copyWith(color: webMuted),
          ),
        ],
      ),
    );
  }
}

class _GripCard extends StatelessWidget {
  const _GripCard({
    required this.grip,
    required this.isDark,
    required this.onDelete,
  });

  final Grip grip;
  final bool isDark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? webPanel : lightPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? webBorder.withValues(alpha: 0.6)
              : lightBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          // Grip type icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: brandAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.back_hand, size: 20, color: brandAccent),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: grip.gripTypeLabel,
                      style: tsInterW600S14.copyWith(
                        color: isDark ? webText : lightText,
                      ),
                    ),
                    TextSpan(
                      text: '  ${grip.edgeDepthMm.toStringAsFixed(0)}mm',
                      style: tsInterW600S14.copyWith(color: webMuted),
                    ),
                  ]),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle,
                  style: tsInterS12.copyWith(color: webMuted),
                ),
              ],
            ),
          ),
          // Delete
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              size: 18,
              color: webMuted.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final type = _gripTypeLabel(grip.gripType);
    final fingers = grip.fingers.map(_fingerLabel).join(', ');
    final contraction =
        grip.contractionType == ContractionType.passive ? 'Passive' : 'Active';
    return '$type \u2022 $contraction \u2022 $fingers';
  }
}

String _gripTypeLabel(GripType type) {
  switch (type) {
    case GripType.halfCrimp:
      return 'Half Crimp';
    case GripType.fullCrimp:
      return 'Full Crimp';
    case GripType.openHand:
      return 'Open Hand';
  }
}

String _fingerLabel(Finger finger) {
  switch (finger) {
    case Finger.thumb:
      return 'Thumb';
    case Finger.indexFinger:
      return 'Index';
    case Finger.middle:
      return 'Middle';
    case Finger.ring:
      return 'Ring';
    case Finger.pinky:
      return 'Pinky';
  }
}
