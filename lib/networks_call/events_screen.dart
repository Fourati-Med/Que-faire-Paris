import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../event_detail_screen.dart';
import 'event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({
    super.key,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final List<Event> favorites;
  final void Function(Event) onFavoriteTap;

  @override
  State<EventsScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventsScreen> {
  bool _loading = true;
  final List<Event> _events = [];
  Exception? _error;

  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  void _getEvents() async {
    final dio = Dio(BaseOptions(baseUrl:'https://opendata.paris.fr'));
try {
final response = await dio.get(
'/api/explore/v2.1/catalog/datasets/que-faire-a-paris-/records',
queryParameters: {'limit': 20},
);

final results = response.data['results'] as List;
final events = results.map((json) => Event.fromJson(json)).toList();

setState(() {
  _loading = false;
  _events.clear();
  _events.addAll(events);
});

}catch (error) {
  setState(() {
    _loading = false;
    _error = Exception();
  });
 }
}
@override
Widget build(BuildContext context) {
  return _buildContent();
}

Widget _buildContent() {
  if (_loading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (_error != null) {
    return const Center(child: Text('Oups, une erreur est survenue'));
  }
  if (_events.isEmpty) {
    return const Center(child: Text('Aucun événement'));
  }
  return ListView.builder(
    itemCount: _events.length,
    itemBuilder: (context, index) {
      final event = _events[index];

      return ListTile(
        leading: event.coverUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            event.coverUrl!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const Icon(Icons.event),
          ),
        )
            : const Icon(Icons.event),
        title: Text(event.title ?? ''),
        subtitle: Text(event.addressName ?? ''),
        trailing: IconButton(
          icon: Icon(_isFavorite(event) ? Icons.favorite : Icons.favorite_border),
          onPressed: () {
            widget.onFavoriteTap(event);
          },
        ),
        onTap: () => _openDetail(event.id),
      );
    },
  );

}

  bool _isFavorite(Event event) {
    return widget.favorites.any((favorite) => favorite.id == event.id);
  }

  void _openDetail(String? id) {
    if (id == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          id: id,
          favorites: widget.favorites,
          onFavoriteTap: widget.onFavoriteTap,
        ),
      ),
    );
  }

}