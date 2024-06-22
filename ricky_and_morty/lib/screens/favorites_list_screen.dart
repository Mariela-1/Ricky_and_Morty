import 'package:flutter/material.dart';
import 'package:ricky_and_morty/dao/character_dao.dart';
import 'package:ricky_and_morty/models/character.dart';

class FavoritesListScreen extends StatelessWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const FavoriteList(),
    );
  }
}

class FavoriteList extends StatefulWidget {
  const FavoriteList({super.key});

  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  List<Character> _favorites = [];
  final CharacterDao _characterDao = CharacterDao();

  fetchFavorites() {
    _characterDao.fetchFavorites().then((value) {
      if (mounted) {
        setState(() {
          _favorites = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchFavorites();
    return ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) => FavoriteItem(
              favorite: _favorites[index],
              callback: () {
                _characterDao.delete(_favorites[index]);
              },
            ));
  }
}

class FavoriteItem extends StatelessWidget {
  const FavoriteItem({
    super.key,
    required this.favorite,
    required this.callback,
  });

  final Character favorite;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 5;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(
              favorite.image,
              width: width,
              height: width,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(favorite.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(favorite.species),
                    IconButton(
                        onPressed: () {
                          callback();
                        },
                        icon: const Icon(Icons.delete))
                  ],
                )),
          ),
        ]),
      ),
    );
  }
}
