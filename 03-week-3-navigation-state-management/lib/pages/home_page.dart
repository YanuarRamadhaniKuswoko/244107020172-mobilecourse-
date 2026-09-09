import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// HomePage demonstrating Praktikum 1 multi-page routing with GoRouter.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 1 - GoRouter Demo'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          final itemId = index + 1;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text('$itemId'),
              ),
              title: Text('Item $itemId'),
              subtitle: Text('Navigasi ke /detail/$itemId'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/detail/$itemId'),
            ),
          );
        },
      ),
    );
  }
}
