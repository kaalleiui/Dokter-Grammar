import 'package:flutter/material.dart';
import '../../../core/constants/color_scheme.dart';

class ModernHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool showTitle;

  const ModernHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered title
          if (showTitle)
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          // Leading and trailing buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leading != null) leading!,
              if (leading == null) const SizedBox.shrink(),
              if (trailing != null) trailing!,
              if (trailing == null) const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

