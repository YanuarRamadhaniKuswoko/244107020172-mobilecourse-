import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/detail_page.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/todo_page.dart';
import 'widgets/main_layout.dart';

void main() {
  runApp(
    // ProviderScope stores the state of all Riverpod providers across the widget tree
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// GoRouter configuration defining declarative routes and path parameters.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute wraps primary tab destinations with a persistent NavigationBar
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(
          currentLocation: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
    // Dynamic path parameter route for detail view
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '1';
        return DetailPage(id: id);
      },
    ),
    // Praktikum 1 demo route
    GoRoute(
      path: '/demo-router',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

/// Root application widget configuring MaterialApp.router.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Week 3 - Navigation & State Management',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
