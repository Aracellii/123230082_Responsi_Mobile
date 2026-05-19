import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../storage/hive_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.showId, this.initialShow});

  final int showId;
  final Map<String, dynamic>? initialShow;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> _detailFuture;
  String? _username;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final loggedIn = await AuthService.isLoggedIn();
    final username = await AuthService.getUsername();
    if (!mounted) return;
    setState(() {
      _username = loggedIn ? username : null;
    });
  }

  Future<Map<String, dynamic>> _loadDetail() async {
    if (widget.initialShow != null) {
      return widget.initialShow!;
    }
    return {};
  }

  String? _extractImageUrl(Map<String, dynamic> show) {
    final imageUrl = show['imageUrl'];
    if (imageUrl is String && imageUrl.isNotEmpty) {
      return imageUrl;
    }
    return null;
  }

  String _extractRating(Map<String, dynamic> show) {
    final rating = show['rating'];
    return rating;
  }

  String _extractPublisher(Map<String, dynamic> show) {
    final publisher = show['publisher'];
    return publisher;
  }
  String _extractDeveloper(Map<String, dynamic> show) {
    final developer = show['developer'];
    return developer;
  }
  List<String> _extractGenres(Map<String, dynamic> show) {
    final genres = show['genres'];
    if (genres is List) {
      return genres.map((g) => g.toString()).toList();
    }
    final category = show['strCategory'];
    if (category is String && category.isNotEmpty) {
      return [category];
    }
    return const [];
  }

  String _extractSummary(Map<String, dynamic> show) {
    final summary =
        show['summary']?.toString() ??
        show['short_description']?.toString() ??
        '';
    return summary;
  }

  Future<void> _toggleFavorite(Map<String, dynamic> show) async {
    if (_username == null || _username!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login untuk menambah favorite')),
      );
      return;
    }

    final showId = int.tryParse(show['id']?.toString() ?? '0') ?? 0;
    final normalizedShow = {
      'id': showId,
      'name': show['name'] ?? 'Unknown Title',
      'imageUrl': _extractImageUrl(show) ?? '',
      'rating': _extractRating(show),
      'genres': _extractGenres(show),
      'summary': _extractSummary(show),
      'publisher': _extractPublisher(show),
    };

    if (HiveService.isFavoriteFor(_username!, showId)) {
      await HiveService.removeFavoriteFor(_username!, showId);
    } else {
      await HiveService.addFavoriteFor(_username!, normalizedShow);
    }

    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          HiveService.isFavoriteFor(_username!, showId)
              ? 'Get'
              : 'In Library',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat detail: ${snapshot.error}'),
            );
          }

          final show = snapshot.data!;
          final imageUrl = _extractImageUrl(show);
          final rating = _extractRating(show).toString();
          final genres = _extractGenres(show);
          final developer = _extractDeveloper(show);
          final publisher = _extractPublisher(show);
          final mealId = int.tryParse(show['id']?.toString() ?? '0') ?? 0;
          final isFavorite = _username == null
              ? false
              : HiveService.isFavoriteFor(_username!, mealId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: imageUrl == null
                    ? Container(
                        height: 360,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.tv, size: 72),
                      )
                    : Image.network(
                        imageUrl,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 360,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 72),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                show['name'] ?? 'Unknown Title',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
               const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text('Release Date'),
                  Text("     "),
                  Text('publisher   '),
                  Text("     "),
                  Text('developer   '),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text(rating),
                  Text("     "),
                  Text(publisher),
                  Text("     "),
                  Text(developer),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres
                    .map((genre) => Chip(label: Text(genre)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                _extractSummary(show),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _username == null
                    ? null
                    : () => _toggleFavorite(show),
                icon: Icon(isFavorite ? Icons.add : Icons.check),
                label: Text(isFavorite ? 'Get' : 'In Library'),
              ),
            ],
          );
        },
      ),
    );
  }
}
