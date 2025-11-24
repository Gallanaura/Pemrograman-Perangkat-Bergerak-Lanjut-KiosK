import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onNext,
    this.onPrevious,
  });

  final String title;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_rounded, size: 20, color: AppColors.brandBrown),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const Spacer(),
        _RoundIconButton(icon: Icons.chevron_left, onPressed: onPrevious),
        const SizedBox(width: 8),
        _RoundIconButton(icon: Icons.chevron_right, onPressed: onNext),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.black12),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 18, color: AppColors.brandBrown),
      ),
    );
  }
}

