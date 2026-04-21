part of 'app_router.dart';

class RoutePathHelper {
  RoutePathHelper._();
  static String home = "/home";
  static String notes = "/home/notes";
  static String noteDetail = "/home/notes/noteDetail";
  static String todo = "/home/todo";
  static String passwords = "/home/passwords";
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return HomeScreen();
        },
        routes: [
          GoRoute(
            path: 'notes',
            builder: (context, state) {
              return NotesScreen();
            },
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
            builder: (context, state) {
              return TodoScreen();
            },
          ),
          GoRoute(
            path: 'passwords',
            builder: (context, state) {
              return PasswordsScreen();
            },
          ),
        ],
      ),
    ],
  );
});
