import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/domain/entities/user.dart';

class UsageStatsCard extends StatelessWidget {
  final User user;

  const UsageStatsCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Usage Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Daily Usage Progress
            _buildUsageProgress(theme),
            
            const SizedBox(height: 20),
            
            // Usage Details
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Today',
                    '${user.dailyMessageCount}',
                    'messages',
                    Icons.today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'This Month',
                    _getMonthlyUsage().toString(),
                    'messages',
                    Icons.calendar_month,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Plan Limit',
                    _getPlanLimitText(),
                    'per day',
                    Icons.speed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Remaining',
                    _getRemainingMessages().toString(),
                    'today',
                    Icons.hourglass_empty,
                  ),
                ),
              ],
            ),
            
            if (_shouldShowUpgradePrompt()) ...[
              const SizedBox(height: 16),
              _buildUpgradePrompt(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageProgress(ThemeData theme) {
    final progress = _getUsageProgress();
    final color = _getProgressColor(theme, progress);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Usage',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.dailyMessageCount} of ${_getPlanLimitText()} messages used',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Upgrade to Premium for unlimited messages and premium features!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: theme.colorScheme.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  double _getUsageProgress() {
    if (user.subscriptionPlan.messageLimit == -1) {
      return 0.0; // Unlimited plan
    }
    
    return (user.dailyMessageCount / user.subscriptionPlan.messageLimit)
        .clamp(0.0, 1.0);
  }

  Color _getProgressColor(ThemeData theme, double progress) {
    if (progress < 0.7) {
      return theme.colorScheme.primary;
    } else if (progress < 0.9) {
      return Colors.orange;
    } else {
      return theme.colorScheme.error;
    }
  }

  String _getPlanLimitText() {
    return user.subscriptionPlan.messageLimit == -1 
        ? 'Unlimited' 
        : user.subscriptionPlan.messageLimit.toString();
  }

  int _getRemainingMessages() {
    if (user.subscriptionPlan.messageLimit == -1) {
      return -1; // Unlimited
    }
    
    return (user.subscriptionPlan.messageLimit - user.dailyMessageCount)
        .clamp(0, user.subscriptionPlan.messageLimit);
  }

  int _getMonthlyUsage() {
    // TODO: Implement actual monthly usage calculation
    // For now, simulate based on daily usage
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    
    // Simulate monthly usage (this would come from actual data)
    return (user.dailyMessageCount * currentDay * 0.8).round();
  }

  bool _shouldShowUpgradePrompt() {
    return user.subscriptionPlan == SubscriptionPlan.free && 
           _getUsageProgress() > 0.7;
  }
}