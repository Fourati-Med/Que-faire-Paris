import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites/favorites_screen.dart';
import 'networks_call/event.dart';
import 'networks_call/events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 correspond aux événements et 1 aux favoris
  int _index = 0;

  // liste globale des événements favoris
  final List<Event> _favorites = [];

  // permet d'enregistrer les favoris en local
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  // nom utilisé pour retrouver les favoris
  static const String _favoritesKey = 'favorites';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Que faire à Paris' : 'Mes favoris'),
      ),
      body: _index == 0
          ? EventsScreen(
        favorites: _favorites,
        onFavoriteTap: _toggleFavorite,
      )
          : FavoritesScreen(
        favorites: _favorites,
        onFavoriteTap: _toggleFavorite,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Événements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
        ],
      ),
    );
  }

  // change la page affichée
  void _onTap(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }

  // vérifie si l'événement est déjà favori
  bool _isFavorite(Event event) {
    return _favorites.any((favorite) => favorite.id == event.id);
  }

  // ajoute ou retire un événement des favoris
  void _toggleFavorite(Event event) {
    setState(() {
      if (_isFavorite(event)) {
        _favorites.removeWhere((favorite) => favorite.id == event.id);
      } else {
        _favorites.add(event);
      }
    });
    _saveFavorites();
  }

  // enregistre les favoris en local
  Future<void> _saveFavorites() async {
    final savedFavorites = _favorites.map((event) {
      return jsonEncode({
        'id': event.id,
        'title': event.title,
        'lead_text': event.leadText,
        'description': event.description,
        'cover_url': event.coverUrl,
        'date_start': event.dateStart,
        'date_end': event.dateEnd,
        'address_name': event.addressName,
        'price_detail': event.priceDetail,
        'qfap_tags': event.tags,
      });
    }).toList();

    await _preferences.setStringList(_favoritesKey, savedFavorites);
  }

  // récupère les favoris au lancement
  Future<void> _loadFavorites() async {
    final savedFavorites = await _preferences.getStringList(_favoritesKey) ?? [];

    final events = savedFavorites.map((savedEvent) {
      final json = jsonDecode(savedEvent) as Map<String, dynamic>;
      return Event.fromJson(json);
    }).toList();

    if (!mounted) return;

    setState(() {
      _favorites.clear();
      _favorites.addAll(events);
    });
  }
}