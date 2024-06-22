import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ricky_and_morty/dao/character_dao.dart';
import 'package:ricky_and_morty/models/character.dart';
import 'package:ricky_and_morty/services/character_service.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Characters"),
      ),
      body: const CharacterList(),
    );
  }
}

class CharacterList extends StatefulWidget {
  const CharacterList({super.key});

  @override
  State<CharacterList> createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  final CharacterService _characterService = CharacterService();
  static const _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _fetchPage(pageKey);
      },
    );

    super.initState();
  }

  _fetchPage(int pageKey) async {
    try {
      final newItems = await _characterService.getAll(pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, dynamic>(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) => CharacterItem(
          character: item,
        ),
      ),
    );
  }
}

class CharacterItem extends StatefulWidget {
  final Character character;
  const CharacterItem({super.key, required this.character});

  @override
  State<CharacterItem> createState() => _CharacterItemState();
}

class _CharacterItemState extends State<CharacterItem> {
  final CharacterDao _characterDao = CharacterDao();
  bool _isFavorite = false;

  checkFavorite() {
    _characterDao.isFavorite(widget.character).then((value) {
      if (mounted) {
        setState(() {
          _isFavorite = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    checkFavorite();

    MaterialColor color;
    switch (widget.character.status) {
      case "Alive":
        color = Colors.green;
        break;
      case "Dead":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
        break;
    }

    return Card(
      child: Column(
        children: [
          Expanded(child: Image.network(widget.character.image)),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              widget.character.name,
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: color,
                ),
                Expanded(child: Text(widget.character.species, maxLines: 1)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });

                      _isFavorite
                          ? _characterDao.insert(widget.character)
                          : _characterDao.delete(widget.character);
                    },
                    icon: Icon(Icons.favorite,
                        color: _isFavorite
                            ? const Color.fromARGB(255, 249, 22, 6)
                            : const Color.fromARGB(255, 115, 115, 115),
                        size: 20)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
