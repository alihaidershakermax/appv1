import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialSignInButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialSignInButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        side: BorderSide(
          color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? theme.colorScheme.onSurface,
                ),
              ),
            )
          else
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: icon.endsWith('.svg')
                    ? SvgPicture.asset(
                        icon,
                        width: 16,
                        height: 16,
                      )
                    : Icon(
                        Icons.g_mobiledata, // Fallback icon
                        size: 16,
                        color: Colors.blue,
                      ),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}