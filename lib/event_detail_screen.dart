import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'networks_call/event.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.id,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final String id;
  final List<Event> favorites;
  final void Function(Event) onFavoriteTap;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _loading = true;
  Event? _event;
  Exception? _error;

  @override
  void initState() {
    super.initState();
    _getEventDetail();
  }

  void _getEventDetail() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://opendata.paris.fr',
      ),
    );

    try {
      final response = await dio.get(
        '/api/explore/v2.1/catalog/datasets/que-faire-a-paris-/records',
        queryParameters: {
          'where': 'id="${widget.id}"',
        },
      );

      final results = response.data['results'] as List;

      setState(() {
        _loading = false;
        _event = Event.fromJson(results.first);
      });
    } catch (error) {
      setState(() {
        _loading = false;
        _error = Exception();
      });
    }
  }

  // Vérifie si l'événement est dans les favoris
  bool _isFavorite(Event event) {
    return widget.favorites.any((favorite) => favorite.id == event.id);
  }
  // Enlève les balises HTML d'un texte
  String _stripHtml(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          if (_event != null)
            IconButton(
              icon: Icon(
                _isFavorite(_event!) ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                widget.onFavoriteTap(_event!);
                setState(() {});
              },
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null || _event == null) {
      return const Center(
        child: Text('Oups, une erreur est survenue'),
      );
    }

    final event = _event!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.coverUrl != null) Image.network(event.coverUrl!),
          Text(
            event.title ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(event.addressName ?? ''),
          const SizedBox(height: 8),
          Text(_stripHtml(event.priceDetail)),
          const SizedBox(height: 16),
          Text(_stripHtml(event.leadText)),
        ],
      ),
    );
  }
}