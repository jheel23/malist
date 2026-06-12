part of 'app_router.dart';

class RoutePathHelper {
  RoutePathHelper._();

  static String launch = "/";
  static String onboarding = "/onboarding";
  static String home = "/home";
  static String notes = "/home/notes";
  static String noteDetail = "/home/notes/noteDetail";
  static String todo = "/home/todo";
  static String passwords = "/home/passwords";
  static String files = "/home/files";
  static String fileView = "/home/files/view";
  static String settings = "/home/settings";
  static String backup = "/home/settings/backup";
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePathHelper.launch,
    routes: [
      GoRoute(
        path: RoutePathHelper.launch,
        builder: (context, state) => const _OnboardingGateScreen(),
      ),
      GoRoute(
        path: RoutePathHelper.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePathHelper.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'notes',
            builder: (context, state) => const NotesScreen(),
            routes: [
              GoRoute(
                path: 'noteDetail',
                builder: (context, state) {
                  final note = state.extra as NotesModel?;
                  return NoteDetailScreen(note: note);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'todo',
            builder: (context, state) => const TodoScreen(),
          ),
          GoRoute(
            path: 'passwords',
            builder: (context, state) => const PasswordsScreen(),
          ),
          GoRoute(
            path: 'files',
            builder: (context, state) => const FilesScreen(),
            routes: [
              GoRoute(
                path: 'view',
                builder: (context, state) {
                  final file = state.extra as UserFile;
                  return FileViewScreen(file: file);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'backup',
                builder: (context, state) => const BackupSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _OnboardingGateScreen extends StatefulWidget {
  const _OnboardingGateScreen();

  @override
  State<_OnboardingGateScreen> createState() => _OnboardingGateScreenState();
}

class _OnboardingGateScreenState extends State<_OnboardingGateScreen> {
  late final Future<bool> _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _hasCompletedOnboarding = sl<SecureStorageService>()
        .getBool(StorageKeys.hasCompletedOnboarding)
        .then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedOnboarding,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          context.go(
            snapshot.data! ? RoutePathHelper.home : RoutePathHelper.onboarding,
          );
        });

        return const Scaffold(backgroundColor: Colors.black);
      },
    );
  }
}
