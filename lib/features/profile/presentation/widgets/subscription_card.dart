import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user.dart';

class SubscriptionCard extends StatelessWidget {
  final User user;
  final VoidCallback onUpgrade;
  final VoidCallback onManage;

  const SubscriptionCard({
    super.key,
    required this.user,
    required this.onUpgrade,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscription = user.subscriptionPlan;
    
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getSubscriptionGradient(theme, subscription),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSubscriptionIcon(subscription),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Plan',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          subscription.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subscription != SubscriptionPlan.premiumPlus)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Upgrade',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      theme,
                      'Daily Messages',
                      _getMessageLimitText(subscription),
                      Icons.chat_bubble_outline,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureRow(
                      theme,
                      'File Uploads',
                      subscription == SubscriptionPlan.free ? 'Limited' : 'Unlimited',
                      Icons.attach_file,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureRow(
                      theme,
                      'AI Models',
                      subscription == SubscriptionPlan.free ? 'Basic' : 'Premium',
                      Icons.psychology,
                    ),
                    if (subscription != SubscriptionPlan.free) ...[
                      const SizedBox(height: 8),
                      _buildFeatureRow(
                        theme,
                        'Priority Support',
                        'Included',
                        Icons.support_agent,
                      ),
                    ],
                    if (subscription == SubscriptionPlan.premiumPlus) ...[
                      const SizedBox(height: 8),
                      _buildFeatureRow(
                        theme,
                        'Advanced Features',
                        'All Access',
                        Icons.stars,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  if (subscription != SubscriptionPlan.premiumPlus)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onUpgrade,
                        icon: const Icon(Icons.upgrade),
                        label: const Text('Upgrade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _getSubscriptionColor(subscription),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (subscription != SubscriptionPlan.premiumPlus && 
                      subscription != SubscriptionPlan.free)
                    const SizedBox(width: 12),
                  if (subscription != SubscriptionPlan.free)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onManage,
                        icon: const Icon(Icons.settings),
                        label: const Text('Manage'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    ThemeData theme,
    String feature,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            feature,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  LinearGradient _getSubscriptionGradient(ThemeData theme, SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return LinearGradient(
          colors: [
            theme.colorScheme.outline,
            theme.colorScheme.outline.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SubscriptionPlan.premium:
        return LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SubscriptionPlan.premiumPlus:
        return LinearGradient(
          colors: [
            theme.colorScheme.tertiary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getSubscriptionColor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return Colors.grey;
      case SubscriptionPlan.premium:
        return Colors.blue;
      case SubscriptionPlan.premiumPlus:
        return Colors.purple;
    }
  }

  IconData _getSubscriptionIcon(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return Icons.account_circle_outlined;
      case SubscriptionPlan.premium:
        return Icons.workspace_premium_outlined;
      case SubscriptionPlan.premiumPlus:
        return Icons.diamond_outlined;
    }
  }

  String _getMessageLimitText(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return '${plan.messageLimit} per day';
      case SubscriptionPlan.premium:
      case SubscriptionPlan.premiumPlus:
        return 'Unlimited';
    }
  }
}