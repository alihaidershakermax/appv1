import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/domain/entities/user.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(
              theme,
              'Email',
              user.email,
              Icons.email_outlined,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoRow(
              theme,
              'Display Name',
              user.displayName ?? 'Not set',
              Icons.person_outline,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoRow(
              theme,
              'Member Since',
              DateFormat('MMM dd, yyyy').format(user.createdAt),
              Icons.calendar_today_outlined,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoRow(
              theme,
              'Last Sign In',
              _formatLastSignIn(user.lastSignIn),
              Icons.access_time_outlined,
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoRow(
              theme,
              'Email Status',
              user.isEmailVerified ? 'Verified' : 'Not Verified',
              user.isEmailVerified 
                  ? Icons.verified_outlined 
                  : Icons.warning_outlined,
              valueColor: user.isEmailVerified 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLastSignIn(DateTime lastSignIn) {
    final now = DateTime.now();
    final difference = now.difference(lastSignIn);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}