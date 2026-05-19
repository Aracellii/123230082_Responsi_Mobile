import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:latres/pages/detail_page.dart';

import '../services/auth_service.dart';
import '../storage/hive_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
  
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    AuthService.syncActiveUser();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AuthService.activeUserListenable(),
      builder: (context, username, _) {
        if (username == null || username.isEmpty) {
          return const Center(child: Text('Login untuk melihat favorite'));
        }

        return ValueListenableBuilder<Box<Map>>(
          valueListenable: HiveService.favoritesListenable(),
          builder: (context, box, _) {
            final favorites = HiveService.getFavoritesFor(username);

            if (favorites.isEmpty) {
              return const Center(child: Text('Belum ada favorite'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final show = favorites[index];
                return Card(
                  child: ListTile(
                    leading:
                        show['imageUrl'] == null ||
                            show['imageUrl'].toString().isEmpty
                        ? const Icon(Icons.tv)
                        : Image.network(
                            show['imageUrl'].toString(),
                            width: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                    title: Text(show['name'].toString()),
                    subtitle: Text('Genre: ${show['genres']}'),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await HiveService.removeFavoriteFor(
                          username,
                          show['id'] as int,
                        );
                      },
                    ),
                    onTap: () {
                      // DetailPage(context);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
