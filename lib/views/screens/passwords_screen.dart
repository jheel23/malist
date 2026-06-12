import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/data/models/password/password_model.dart';
import 'package:malist/providers/passwords/passwords_provider.dart';
import 'package:malist/providers/passwords/state/passwords_state.dart';
import 'package:malist/views/widgets/dialogs/add_password_dialog.dart';
import 'package:malist/views/widgets/no_data_widget.dart';

class PasswordsScreen extends ConsumerStatefulWidget {
  const PasswordsScreen({super.key});

  @override
  ConsumerState<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends ConsumerState<PasswordsScreen> {
  bool _isCompact = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(passwordsNotifierProvider.notifier).getPasswords();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Add Password",
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, anim1, anim2) => const AddPasswordDialog(),
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * anim1.value),
                child: FadeTransition(opacity: anim1, child: child),
              );
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        child: const Icon(Iconsax.add, size: 35),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 100,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vault', style: theme.textTheme.displayMedium),
                        Text(
                          'SECURE STORAGE',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isCompact = !_isCompact;
                        });
                      },
                      icon: Icon(
                        _isCompact
                            ? Icons.view_agenda_outlined
                            : Icons.grid_view_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              background: Container(color: theme.colorScheme.surface),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40)),
          Consumer(
            builder: (context, ref, child) {
              final passState = ref.watch(passwordsNotifierProvider);

              return passState.when(
                initial: () => SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: theme.primaryColor,
                    ),
                  ),
                ),
                loading: () => SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                loaded: (passwords) {
                  if (passwords.isEmpty) {
                    return SliverToBoxAdapter(
                      child: NoDataWidget(
                        icon: Iconsax.lock,
                        message: 'No Passwords Yet',
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final password = passwords[index];
                      return _PasswordCard(
                        password: password,
                        isCompact: _isCompact,
                        confirmDismiss: () =>
                            _showDeleteDialog(context, password.id),
                      );
                    },
                  );
                },
                error: (error) => SliverToBoxAdapter(
                  child: Center(
                    child: NoDataWidget(
                      message: error,
                      icon: Iconsax.info_circle,
                    ),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, String id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete"),
        content: Text("Are you sure you want to delete this password?"),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(passwordsNotifierProvider.notifier)
                  .deletePassword(id);
              if (!context.mounted) return;
              context.pop(true);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _PasswordCard extends StatefulWidget {
  final PasswordModel password;
  final bool isCompact;
  final Future<bool> Function() confirmDismiss;

  const _PasswordCard({
    required this.password,
    required this.isCompact,
    required this.confirmDismiss,
  });

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  bool _isVisible = false;

  void _copyToClipboard() {
    Clipboard.setData(
      ClipboardData(
        text: "${widget.password.username}\n${widget.password.password}",
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Username and Password copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maskedUsername = widget.password.username.replaceRange(
      (widget.password.username.length > 4)
          ? widget.password.username.length -
                (widget.password.username.length / 2).ceil()
          : 0,
      null,
      List.filled(
        widget.password.username.length -
            (widget.password.username.length / 2).ceil(),
        '*',
      ).join(),
    );

    final displayUsername = _isVisible
        ? widget.password.username
        : maskedUsername;
    final displayPassword = _isVisible
        ? widget.password.password
        : List.filled(widget.password.password.length, '*').join();

    final cardContent = widget.isCompact
        ? _buildCompactCard(theme, displayUsername, displayPassword)
        : _buildDetailedCard(theme, displayUsername, displayPassword);

    return Dismissible(
      key: Key(widget.password.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => widget.confirmDismiss(),
      background: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(
          vertical: widget.isCompact ? 5 : 10,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(1),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Swipe to\nDelete',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(width: 20),
            Icon(
              Iconsax.trash,
              color: theme.primaryColor.withValues(alpha: 0.5),
              size: 40,
            ),
          ],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: cardContent,
      ),
    );
  }

  Widget _buildDetailedCard(
    ThemeData theme,
    String displayUsername,
    String displayPassword,
  ) {
    return Container(
      key: const ValueKey('detailed'),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.key,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              Text(
                'ENCRYPTED',
                style: theme.textTheme.bodyMedium!.copyWith(
                  letterSpacing: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  _isVisible ? Icons.visibility_off : Icons.visibility,
                ),
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
              ),
              GestureDetector(
                onTap: _copyToClipboard,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('COPY'),
                    SizedBox(height: 10),
                    Container(height: 1, width: 40, color: Colors.white38),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.password.category),
                    SizedBox(height: 5),
                    Text(
                      displayUsername,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      displayPassword,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        letterSpacing: _isVisible ? 0 : 2,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.lock, color: Colors.white12, size: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(
    ThemeData theme,
    String displayUsername,
    String displayPassword,
  ) {
    return Container(
      key: const ValueKey('compact'),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.password.category,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  displayUsername,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  displayPassword,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    letterSpacing: _isVisible ? 0 : 2,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility),
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.copy, size: 20),
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}
