import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../event_detail_screen.dart';
import 'event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Que faire à Paris'),
      ),
      body: _buildContent(),
    );
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
          title: Text(event.title ?? ''),
          subtitle: Text(event.addressName ?? ''),
          onTap: () => _openDetail(event.id),
        );
      },
  );
}
  void _openDetail(String? id) {
    if (id == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(id: id),
      ),
    );
  }

}