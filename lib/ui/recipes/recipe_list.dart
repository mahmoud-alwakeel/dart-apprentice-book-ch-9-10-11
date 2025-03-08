import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:recipes/network/recipe_model.dart';

import '../recipe_card.dart';
import 'recipe_details.dart';
// TODO: Add imports

import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_dropdown.dart';


class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';
  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;

  // TODO: Add searches array
  APIReccipeQuery? _currentRecipes1;

  List<String> previousSearches = [];
  // TODO: Add _currentRecipes1


  @override
  void initState() {
    super.initState();
    loadRecipes();

    getPreviousSearches();
    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

  Future loadRecipes() async {
    final jsonString = await rootBundle.loadString('assets/recipes1.json');
    setState(() {
      _currentRecipes1 = APIReccipeQuery.fromJson(jsonDecode(jsonString));
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void savePreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSearchKey)) {
      final searches = prefs.getStringList(prefSearchKey);
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                startSearch(searchTextController.text);
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              icon: Icon(Icons.search),
            ),
            const SizedBox(
              width: 6.0,
            ),
            // *** Start Replace
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                      autofocus: false,
                      controller: searchTextController,
                      onChanged: (query) => {
                        if (query.length >= 3)
                          {
                            // Rebuild list
                            setState(
                              () {
                                currentSearchList.clear();
                                currentCount = 0;
                                currentEndPosition = pageCount;
                                currentStartPosition = 0;
                              },
                            )
                          }

                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        startSearch(searchTextController.text);

                      },
                      controller: searchTextController,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.arrow_drop_down),
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      // ignore: lines_longer_than_80_chars
                      return previousSearches.map<CustomDropdownMenuItem<String>>((String value) {
                        // ignore: lines_longer_than_80_chars
                        return CustomDropdownMenuItem(value: value, text: value, 
                        callback: () {
                          setState(() {
                            previousSearches.remove(value);
                            savePreviousSearches();
                            Navigator.pop(context);
                          });
                        },
                        );
                      }).toList();
                    })
                ],
              ),
            ),
            // *** End Replace
          ],
        ),
      ),
    );
  }

  void startSearch(String value) {
    setState(() {
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();

      if (!previousSearches.contains(value)) {
        previousSearches.add(value);
        savePreviousSearches();
      }
    });
  }

  Widget _buildRecipeLoader(BuildContext context) {
    if (_currentRecipes1 == null || _currentRecipes1?.hits == null) {
      return Container();
    }
    return Flexible(child: ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Center(
          child: _buildRecipeCard(context, _currentRecipes1!.hits, 0),
        );
      },
    ));
  }

  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    final recipe = hits[index].reccipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext, MaterialPageRoute(
          builder: (context) {
            return const RecipeDetails();
          },
        ));
      },
      child: recipeStringCard(recipe.image, recipe.label),
    );
  }
}
