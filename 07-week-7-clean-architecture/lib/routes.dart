import 'package:go_router/go_router.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: '/note/new',
      builder: (context, state) => const NoteDetailPage(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return NoteDetailPage(noteId: id);
      },
    ),
  ],
);

