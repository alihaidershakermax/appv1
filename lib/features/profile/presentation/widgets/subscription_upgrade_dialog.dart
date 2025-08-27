import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../subscription/presentation/providers/subscription_controller.dart';

class SubscriptionUpgradeDialog extends ConsumerStatefulWidget {
  final SubscriptionPlan currentPlan;

  const SubscriptionUpgradeDialog({
    super.key,
    required this.currentPlan,
  });

  @override
  ConsumerState<SubscriptionUpgradeDialog> createState() => _SubscriptionUpgradeDialogState();
}

class _SubscriptionUpgradeDialogState extends ConsumerState<SubscriptionUpgradeDialog> {
  SubscriptionPlan? selectedPlan;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select the next tier up
    if (widget.currentPlan == SubscriptionPlan.free) {
      selectedPlan = SubscriptionPlan.premium;
    } else if (widget.currentPlan == SubscriptionPlan.premium) {
      selectedPlan = SubscriptionPlan.premiumPlus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Upgrade Your Plan'),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Choose a plan that fits your needs',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Plan Options
            if (widget.currentPlan != SubscriptionPlan.premium)
              _buildPlanOption(
                theme,
                SubscriptionPlan.premium,
                'Most Popular',
              ),
            
            if (widget.currentPlan != SubscriptionPlan.premiumPlus)
              _buildPlanOption(
                theme,
                SubscriptionPlan.premiumPlus,
                'Best Value',
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedPlan == null || isLoading ? null : _upgradePlan,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upgrade Now'),
        ),
      ],
    );
  }

  Widget _buildPlanOption(
    ThemeData theme,
    SubscriptionPlan plan,
    String badge,
  ) {
    final isSelected = selectedPlan == plan;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPlan = plan;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.05)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? theme.colorScheme.primary 
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${plan.monthlyPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: '/month',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<SubscriptionPlan>(
                    value: plan,
                    groupValue: selectedPlan,
                    onChanged: (value) {
                      setState(() {
                        selectedPlan = value;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Features
              ..._getPlanFeatures(plan).map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getPlanFeatures(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.premium:
        return [
          'Unlimited daily messages',
          'Premium AI models (GPT-4, Gemini Pro)',
          'Unlimited file uploads',
          'Priority support',
          'Advanced chat features',
          'Export chat history',
        ];
      case SubscriptionPlan.premiumPlus:
        return [
          'Everything in Premium',
          'Latest AI models (GPT-4 Turbo)',
          'Custom AI personalities',
          'Voice conversations',
          'Team collaboration features',
          'API access',
          'White-label option',
        ];
      case SubscriptionPlan.free:
        return [];
    }
  }

  void _upgradePlan() async {
    if (selectedPlan == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Implement actual subscription upgrade
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully upgraded to ${selectedPlan!.displayName}!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error upgrading subscription: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}