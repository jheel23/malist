import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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
                  crossAxisAlignment: .center,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Text('Vault', style: theme.textTheme.displayMedium),
                        Text(
                          'SECURE STORAGE',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
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
                      return Dismissible(
                        key: Key(password.id),
                        direction: DismissDirection.endToStart,
                        // onUpdate: (details) async {
                        //   if (details.progress > 0.5) {
                        //     final dismissResult = await _showDeleteDialog(
                        //       context,
                        //       password.id,
                        //     );
                        //     if (dismissResult == false) {
                        //       ref
                        //           .read(passwordsNotifierProvider.notifier)
                        //           .getPasswords();
                        //     }
                        //   }
                        // },
                        confirmDismiss: (direction) async {
                          final dismissResult = await _showDeleteDialog(
                            context,
                            password.id,
                          );
                          return dismissResult;
                        },
                        background: Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          alignment: .center,
                          child: Row(
                            mainAxisAlignment: .end,
                            children: [
                              Icon(
                                Iconsax.trash,
                                color: theme.primaryColor.withValues(
                                  alpha: 0.5,
                                ),
                                size: 40,
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Swipe to\nDelete',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
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
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'ENCRYPTED',
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      letterSpacing: 2,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              "${passwords[index].username}\n${passwords[index].password}",
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Username and Password copied to clipboard',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisSize: .min,
                                      children: [
                                        Text('COPY'),
                                        SizedBox(height: 10),
                                        Container(
                                          height: 1,
                                          width: 40,
                                          color: Colors.white38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: .start,
                                    mainAxisSize: .min,
                                    children: [
                                      Text(passwords[index].category),
                                      SizedBox(height: 5),
                                      Text(
                                        passwords[index].username.replaceRange(
                                          (passwords[index].username.length > 4)
                                              ? passwords[index]
                                                        .username
                                                        .length -
                                                    (passwords[index]
                                                                .username
                                                                .length /
                                                            2)
                                                        .ceil()
                                              : 0,
                                          null,
                                          List.filled(
                                            passwords[index].username.length -
                                                (passwords[index]
                                                            .username
                                                            .length /
                                                        2)
                                                    .ceil(),
                                            '*',
                                          ).join(),
                                        ),
                                        style: theme.textTheme.titleLarge,
                                        maxLines: 1,
                                        overflow: .ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        List.filled(
                                          passwords[index].password.length,
                                          '*',
                                        ).join(),
                                        style: theme.textTheme.bodyLarge!
                                            .copyWith(
                                              letterSpacing: 2,
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.lock,
                                    color: Colors.white12,
                                    size: 100,
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
