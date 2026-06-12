import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/config/router/app_router.dart';
import 'package:malist/providers/backup/backup_provider.dart';

class BackupAlertBanner extends ConsumerStatefulWidget {
  const BackupAlertBanner({super.key});

  @override
  ConsumerState<BackupAlertBanner> createState() => _BackupAlertBannerState();
}

class _BackupAlertBannerState extends ConsumerState<BackupAlertBanner>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backupInfoAsync = ref.watch(backupInfoProvider);

    return backupInfoAsync.when(
      data: (info) {
        if (info.frequency == 'never') {
          return _buildBanner(
            isWarning: true,
            title: 'BACKUP NOT CONFIGURED',
            message:
                'Your notes, passwords, and files are stored only on this device. Setup a Auto Backup interval to prevent data loss.',
            btnText: 'SETUP NOW',
            icon: Iconsax.warning_2,
            color: Colors.amber,
          );
        }

        if (info.lastBackupTimestamp == null) {
          return _buildBanner(
            isWarning: true,
            title: 'NO BACKUP CREATED YET',
            message:
                'You have scheduled backups, but no backup file has been created yet. Run a backup now to secure your local data.',
            btnText: 'BACKUP NOW',
            icon: Iconsax.warning_2,
            color: Colors.amber,
          );
        }

        final lastBackup = DateTime.tryParse(info.lastBackupTimestamp!);
        if (lastBackup == null) {
          return const SizedBox.shrink();
        }

        final diff = DateTime.now().difference(lastBackup);
        if (diff.inDays >= 7) {
          return _buildBanner(
            isWarning: false,
            title: 'WEEKLY BACKUP REMINDER',
            message:
                'Export and download your backup file off-device before changing phones to avoid any data loss.',
            btnText: 'EXPORT NOW',
            icon: Iconsax.export_1,
            color: Colors.blueAccent,
          );
        }

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner({
    required bool isWarning,
    required String title,
    required String message,
    required String btnText,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pulseController]),
      builder: (context, child) {
        final glowOpacity = 0.02 + (_pulseAnimation.value * 0.03);
        final borderOpacity = 0.15 + (_pulseAnimation.value * 0.15);

        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: glowOpacity),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: color.withValues(alpha: borderOpacity),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                          alpha: 0.02 * _pulseAnimation.value,
                        ),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: color,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                context.push(RoutePathHelper.backup);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  btnText,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
