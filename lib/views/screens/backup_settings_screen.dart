import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/providers/backup/backup_provider.dart';
import 'package:malist/providers/backup/state/backup_state.dart';
import 'package:share_plus/share_plus.dart';

class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() =>
      _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen>
    with SingleTickerProviderStateMixin {
  String _frequency = 'weekly';
  String? _lastBackupTime;
  String? _lastBackupSize;
  String? _savedPassword;
  bool _obscurePassword = true;
  List<File> _backupHistory = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadSettings();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final notifier = ref.read(backupNotifierProvider.notifier);
    final freq = await notifier.getBackupFrequency();
    final lastTime = await notifier.getLastBackupTimestamp();
    final lastSize = await notifier.getLastBackupSize();
    final history = await notifier.getBackupHistory();
    final pwd = await notifier.getBackupPassword();
    if (!mounted) return;
    setState(() {
      _frequency = freq;
      _lastBackupTime = lastTime;
      _lastBackupSize = lastSize;
      _backupHistory = history;
      _savedPassword = pwd;
    });
  }

  String _formatBytes(String? bytesStr) {
    if (bytesStr == null) return '—';
    final bytes = int.tryParse(bytesStr) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Never';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    bool obscure = true;
    final isChanging = _savedPassword != null && _savedPassword!.isNotEmpty;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Password',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final theme = Theme.of(ctx);
            return Dialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChanging ? 'CHANGE PASSWORD' : 'SET PASSWORD',
                      style: theme.textTheme.headlineSmall!.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isChanging)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Iconsax.warning_2,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Warning: Changing your password means older backups will only decrypt with the old password. A new backup will be created immediately with the new password.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Set a password to secure your backups. You will need this password to restore data.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Iconsax.eye_slash : Iconsax.eye),
                          onPressed: () =>
                              setDialogState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmController,
                      obscureText: obscure,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(letterSpacing: 1, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final pwd = controller.text;
                            if (pwd.isEmpty || pwd != confirmController.text) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Passwords do not match or are empty',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (pwd.length < 4) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password must be at least 4 characters',
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(ctx).pop();
                            await ref
                                .read(backupNotifierProvider.notifier)
                                .setBackupPassword(pwd);
                            await _loadSettings();
                            await _runExport(pwd);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            isChanging ? 'CHANGE & BACKUP' : 'SET & BACKUP',
                            style: const TextStyle(
                              letterSpacing: 1,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  void _showRestorePasswordDialog(String zipPath) {
    final controller = TextEditingController(text: _savedPassword);
    bool obscure = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Import',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final theme = Theme.of(ctx);
            return Dialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DECRYPT BACKUP',
                      style: theme.textTheme.headlineSmall!.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the password used when creating this backup.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Iconsax.eye_slash : Iconsax.eye),
                          onPressed: () =>
                              setDialogState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final pwd = controller.text;
                            if (pwd.isEmpty) return;
                            Navigator.of(ctx).pop();

                            final notifier = ref.read(
                              backupNotifierProvider.notifier,
                            );
                            await notifier.validateBackup(zipPath, pwd);

                            final state = ref.read(backupNotifierProvider);
                            if (!mounted) return;

                            state.whenOrNull(
                              validated: (summary) {
                                _showRestoreSummaryDialog(
                                  summary,
                                  zipPath,
                                  pwd,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          child: const Text(
                            'RESTORE',
                            style: TextStyle(letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Future<void> _runExport(String password) async {
    await ref.read(backupNotifierProvider.notifier).exportBackup(password);
    await _loadSettings();
  }

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      return;
    }
    final zipPath = result.files.first.path!;
    _showRestorePasswordDialog(zipPath);
  }

  void _showRestoreSummaryDialog(
    Map<String, dynamic> summary,
    String zipPath,
    String password,
  ) {
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Restore Summary',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESTORE SUMMARY',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                _summaryRow(
                  theme,
                  'Backup Date',
                  _formatDate(summary['backupDate']),
                ),
                _summaryRow(
                  theme,
                  'Backup Size',
                  _formatBytes(summary['backupSize']?.toString()),
                ),
                _summaryRow(theme, 'New Files', '${summary['newFiles'] ?? 0}'),
                _summaryRow(
                  theme,
                  'Existing (Skip)',
                  '${summary['existingFiles'] ?? 0}',
                ),
                _summaryRow(
                  theme,
                  'New Records',
                  '${summary['newRecords'] ?? 0}',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This will merge backup data into your current data. Existing data will not be overwritten.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(backupNotifierProvider.notifier).reset();
                      },
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await ref
                            .read(backupNotifierProvider.notifier)
                            .importBackup(zipPath, password);
                        await _loadSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      child: const Text(
                        'RESTORE',
                        style: TextStyle(letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backupState = ref.watch(backupNotifierProvider);

    ref.listen<BackupState>(backupNotifierProvider, (prev, next) {
      next.whenOrNull(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green.shade800,
            ),
          );
          ref.read(backupNotifierProvider.notifier).reset();
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
          ref.read(backupNotifierProvider.notifier).reset();
        },
      );
    });

    final isLoading =
        backupState is AsyncLoading ||
        backupState.whenOrNull(loading: (_, __, ___) => true) == true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'BACKUP & RESTORE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup',
                  style: theme.textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'SECURE DATA VAULT',
                  style: theme.textTheme.labelMedium!.copyWith(
                    letterSpacing: 1.5,
                    color: theme.primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 30),

                _buildStatusCard(theme),
                const SizedBox(height: 20),

                _buildActionButtons(theme, isLoading),
                const SizedBox(height: 30),

                _buildPasswordSection(theme),
                const SizedBox(height: 30),

                _buildFrequencySection(theme),
                const SizedBox(height: 30),

                if (_backupHistory.isNotEmpty) ...[
                  _buildHistorySection(theme),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),

          if (isLoading) _buildProgressOverlay(theme, backupState),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glowOpacity = 0.03 + (_pulseController.value * 0.04);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: glowOpacity),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.primaryColor.withValues(
                    alpha: 0.1 + (_pulseController.value * 0.05),
                  ),
                ),
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _lastBackupTime != null
                          ? Colors.greenAccent
                          : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _lastBackupTime != null ? 'PROTECTED' : 'NO BACKUP',
                    style: theme.textTheme.labelMedium!.copyWith(
                      letterSpacing: 2,
                      color: _lastBackupTime != null
                          ? Colors.greenAccent
                          : Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _statRow(theme, 'Last Backup', _formatDate(_lastBackupTime)),
              _statRow(theme, 'Backup Size', _formatBytes(_lastBackupSize)),
              _statRow(theme, 'Frequency', _frequency.toUpperCase()),
              _statRow(theme, 'Local Backups', '${_backupHistory.length}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isLoading) {
    final hasPassword = _savedPassword != null && _savedPassword!.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: _glassButton(
            theme,
            icon: Iconsax.export_1,
            label: 'BACKUP NOW',
            onTap: isLoading
                ? null
                : () {
                    if (hasPassword) {
                      _runExport(_savedPassword!);
                    } else {
                      _showChangePasswordDialog();
                    }
                  },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _glassButton(
            theme,
            icon: Iconsax.import_1,
            label: 'RESTORE',
            onTap: isLoading ? null : () => _pickAndImport(),
          ),
        ),
      ],
    );
  }

  Widget _glassButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(
                alpha: onTap == null ? 0.02 : 0.06,
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.primaryColor.withValues(
                  alpha: onTap == null ? 0.05 : 0.15,
                ),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: onTap == null
                      ? theme.primaryColor.withValues(alpha: 0.3)
                      : theme.primaryColor.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelSmall!.copyWith(
                    letterSpacing: 1.5,
                    color: onTap == null
                        ? theme.primaryColor.withValues(alpha: 0.3)
                        : theme.primaryColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection(ThemeData theme) {
    final hasPassword = _savedPassword != null && _savedPassword!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Iconsax.lock, size: 20),
              const SizedBox(width: 12),
              Text(
                'Encryption Key',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!hasPassword)
            GestureDetector(
              onTap: () => _showChangePasswordDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.key, size: 14, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'SETUP',
                      style: theme.textTheme.labelSmall!.copyWith(
                        letterSpacing: 1.5,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _obscurePassword ? '••••••••' : _savedPassword!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            letterSpacing: _obscurePassword ? 2 : 1,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor.withValues(alpha: 0.8),
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          size: 14,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showChangePasswordDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      Iconsax.edit_2,
                      size: 16,
                      color: theme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Iconsax.timer_1, size: 20),
              const SizedBox(width: 12),
              Text(
                'Auto Backup',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.15),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _frequency,
                dropdownColor: theme.colorScheme.surface,
                icon: Icon(
                  Iconsax.arrow_down_1,
                  size: 16,
                  color: theme.primaryColor.withValues(alpha: 0.6),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
                onChanged: (String? freq) async {
                  if (freq != null) {
                    await ref
                        .read(backupNotifierProvider.notifier)
                        .setBackupFrequency(freq);
                    setState(() => _frequency = freq);
                  }
                },
                items: ['never', 'daily', 'weekly', 'monthly']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toUpperCase(),
                            style: const TextStyle(
                              letterSpacing: 1,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Iconsax.clock, size: 20),
            const SizedBox(width: 10),
            Text(
              'Backup History',
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Material(
          color: theme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: _backupHistory.take(5).map((file) {
                final name = file.uri.pathSegments.last;
                final stat = file.statSync();
                return ListTile(
                  leading: Icon(
                    Iconsax.document,
                    color: theme.primaryColor.withValues(alpha: 0.5),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${_formatBytes(stat.size.toString())} · ${_formatDate(stat.modified.toIso8601String())}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Iconsax.export_1,
                      size: 18,
                      color: theme.primaryColor.withValues(alpha: 0.6),
                    ),
                    onPressed: () => Share.shareXFiles([XFile(file.path)]),
                  ),
                  onTap: () => Share.shareXFiles([XFile(file.path)]),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverlay(ThemeData theme, BackupState state) {
    String message = '';
    double? progress;
    state.whenOrNull(
      loading: (msg, current, total) {
        message = msg;
        if (total > 0) progress = current / total;
      },
    );

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    color: theme.primaryColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (progress != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      color: Colors.greenAccent.withValues(alpha: 0.7),
                      minHeight: 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
