import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/providers/loading_provider.dart';

/// A full-screen loading overlay driven by [loadingProvider].
///
/// When [loadingProvider] is `true`, renders a semi-transparent black scrim
/// with a centred gold [CircularProgressIndicator] on top of the current
/// screen. When `false`, renders nothing.
///
/// Intended to be placed at the top of a [Stack] inside [AuthenticatedShell]
/// or on any screen that needs a global loading indicator.
///
/// Requirements: 10.7
class LoadingOverlay extends ConsumerWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    if (!isLoading) return const SizedBox.shrink();

    return ColoredBox(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      ),
    );
  }
}
