import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/config/router/app_router.dart';
import 'package:malist/core/constants/asssets.dart';
import 'package:malist/providers/todo/state/todo_state.dart';
import 'package:malist/providers/todo/todo_provider.dart';
import 'package:malist/views/widgets/no_data_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  bool isRepeatTextForever = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoProvider.notifier).getTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.appLogo,
              height: 28,
              width: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 5),
            const Text("A L I S T"),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Iconsax.setting_4),
            splashRadius: 18,
            elevation: 10,
            shadowColor: Colors.white24,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Iconsax.import),
                      const SizedBox(width: 10),
                      Text("Import"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'nuke',
                  child: Row(
                    children: [
                      Icon(Iconsax.danger),
                      const SizedBox(width: 10),
                      Text("Nuke"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Iconsax.export),
                      const SizedBox(width: 10),
                      Text("Export"),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) {
              // ToDo : Implement each method
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Container(
            height: 0.3,
            color: theme.primaryColor.withValues(alpha: 0.11),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SYSTEM STATUS",
                style: theme.textTheme.bodySmall!.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 5),
              AnimatedTextKit(
                repeatForever: isRepeatTextForever,
                totalRepeatCount: 1,
                onTap: () => setState(() {
                  isRepeatTextForever = !isRepeatTextForever;
                }),
                animatedTexts: [
                  TypewriterAnimatedText(
                    "FOCUSED.",
                    speed: Duration(milliseconds: 200),
                    textStyle: theme.textTheme.displayLarge,
                  ),
                  TypewriterAnimatedText(
                    "DECISIVE.",
                    speed: Duration(milliseconds: 200),
                    textStyle: theme.textTheme.displayLarge,
                  ),
                  TypewriterAnimatedText(
                    "SECURE.",
                    speed: Duration(milliseconds: 200),
                    textStyle: theme.textTheme.displayLarge,
                  ),
                  TypewriterAnimatedText(
                    "PRODUCTIVE.",
                    speed: Duration(milliseconds: 200),
                    textStyle: theme.textTheme.displayLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Menu Options
              GridView.count(
                shrinkWrap: true,
                mainAxisExtent: 180,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push(RoutePathHelper.notes);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.edit_note),
                          const Spacer(),
                          Text("Notes", style: theme.textTheme.titleMedium),
                          const SizedBox(height: 5),
                          Text(
                            "Personal Journal",
                            style: theme.textTheme.titleSmall!.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePathHelper.todo),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.task_alt),
                          const Spacer(),
                          Text("ToDo", style: theme.textTheme.titleMedium),
                          const SizedBox(height: 5),
                          Text(
                            "Daily Tasks",
                            style: theme.textTheme.titleSmall!.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePathHelper.passwords),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(1),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          const Icon(Icons.lock),
                          const Spacer(),
                          Text("Passwords", style: theme.textTheme.titleMedium),
                          const SizedBox(height: 5),
                          Text(
                            "ENCRYPTED",
                            style: theme.textTheme.titleSmall!.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        const Icon(Icons.archive_outlined),
                        const Spacer(),
                        Text("Archive", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 5),
                        Text(
                          "Coming Soon...",
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: theme.primaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Quick View
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    "Priority Tasks",
                    style: theme.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePathHelper.todo),
                    child: Text("VIEW ALL", style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Consumer(
                builder: (context, ref, _) {
                  final tasksState = ref.watch(todoProvider);
                  return tasksState.when(
                    loaded: (data) {
                      if (data.isEmpty) {
                        return Center(
                          child: NoDataWidget(
                            icon: Icons.task_alt,
                            message: "No tasks yet",
                            widgetSize: null,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: data.length > 3 ? 3 : data.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final task = data[index];
                          return ListTile(
                            leading: GestureDetector(
                              onLongPress: () async {
                                if (task.status == null) {
                                  final updatedTodo = task.copyWith(
                                    status: false,
                                  );
                                  await ref
                                      .read(todoProvider.notifier)
                                      .updateTodo(updatedTodo);
                                }
                              },
                              child: Checkbox.adaptive(
                                value: task.status,
                                onChanged: (value) async {
                                  switch (task.status) {
                                    case true:
                                      final updatedTodo = task.copyWith(
                                        status: null,
                                      );
                                      await ref
                                          .read(todoProvider.notifier)
                                          .updateTodo(updatedTodo);

                                      break;
                                    case false:
                                      final updatedTodo = task.copyWith(
                                        status: true,
                                      );
                                      await ref
                                          .read(todoProvider.notifier)
                                          .updateTodo(updatedTodo);
                                      break;
                                    case null:
                                      await ref
                                          .read(todoProvider.notifier)
                                          .deleteTodo(task.id);
                                      break;
                                  }
                                },
                                tristate: true,
                              ),
                            ),
                            title: Text(
                              task.description,
                              style: theme.textTheme.titleMedium,
                            ),
                          );
                        },
                      );
                    },
                    initial: () {
                      return Center(child: CircularProgressIndicator());
                    },
                    error: (e) {
                      return Center(
                        child: NoDataWidget(
                          icon: Iconsax.warning_2,
                          message: e,
                          widgetSize: null,
                        ),
                      );
                    },
                    loading: () {
                      return Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
