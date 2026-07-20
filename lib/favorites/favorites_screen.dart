import 'package:flutter/material.dart';

import '../event_detail_screen.dart';
import '../networks_call/event.dart';

class FavoritesScreen extends StatelessWidget {
  // liste des événements ajoutés en favoris
  final List<Event> favorites;

  // fonction reçue du HomeScreen pour retirer un favori
  final void Function(Event) onFavoriteTap;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    // si la liste est videon affiche un message
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'Aucun événement dans les favoris',
        ),
      );
    }

    // sinon, on affiche tous les événements favoris
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        // on récupère le favori à la position actuelle
        final event = favorites[index];

        return ListTile(
          // Titre de l’événement
          title: Text(
            event.title ?? 'Événement sans titre',
          ),

          // Nom du lieu
          subtitle: Text(
            event.addressName ?? 'Lieu non renseigné',
          ),

          // coeur permettant de retirer l’événement des favoris
          trailing: IconButton(
            icon: const Icon(
              Icons.favorite,
            ),
            onPressed: () {
              onFavoriteTap(event);
            },
          ),

          // quand on clique sur l’événement,
          // on ouvre la page de détail
          onTap: () {
            // On vérifie que l’identifiant existe
            if (event.id == null) {
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(
                  id: event.id!,
                  favorites: favorites,
                  onFavoriteTap: onFavoriteTap,
                ),
              ),
            );
          },
        );
      },
    );
  }
}