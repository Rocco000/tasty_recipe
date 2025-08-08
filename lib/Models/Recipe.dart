import 'dart:io';
import 'package:flutter/material.dart';

class Recipe {
  String _id;
  File? _image;
  String _name;
  int _difficulty;
  int _duration;
  int _servings;
  String _category;
  List<String> _tags;
  bool _favorite = false;
  String _userId;

  static final List<String> categoryList = [
    "First Course",
    "Second Course",
    "Breakfast",
    "Snack",
    "Dessert",
  ];

  static final List<Widget> mealIcons = [
    Icon(Icons.dinner_dining_outlined),
    Image.asset("content/images/secondCourse.png", width: 25, height: 25),
    Icon(Icons.bakery_dining_outlined),
    Image.asset("content/images/snack.png", width: 25, height: 25),
    Icon(Icons.cake_outlined),
  ];

  static final List<String> recipeTags = [
    "Vegan",
    "Gluten Free",
    "Lactose Free",
    "Fit",
  ];

  static final List<Widget> recipeTagIcons = [
    Icon(Icons.eco, color: Colors.lightGreen),
    SizedBox(
      width: 25,
      height: 25,
      child: Image.asset(
        "content/images/glutenFree.png",
        // 0xFFFFE0B2
        color: Colors.orange[200],
        fit: BoxFit.contain,
      ),
    ),
    SizedBox(
      width: 25,
      height: 25,
      child: Image.asset(
        "content/images/lactoseFree.png",
        color: Colors.lightBlue[700],
        fit: BoxFit.contain,
      ),
    ),
    Icon(Icons.fitness_center_outlined, color: Colors.grey[600]),
  ];

  Recipe(
    this._image,
    this._id,
    this._name,
    this._difficulty,
    this._duration,
    this._servings,
    this._category,
    this._tags,
    this._favorite,
    this._userId,
  );

  static Widget getMealIcon(String mealName) {
    if (!categoryList.contains(mealName))
      throw Exception("The input meal category doesn't exist!");

    return mealIcons[categoryList.indexOf(mealName)];
  }

  static Widget getTagIcon(String tagName) {
    if (!recipeTags.contains(tagName))
      throw Exception("The input tag doesn't exist!");

    int index = recipeTags.indexOf(tagName);
    return recipeTagIcons[index];
  }

  String get id => _id;

  File? get image => _image;

  set image(File? newImage) => _image = newImage;

  String get name => _name;

  set name(String newName) => _name = newName;

  int get difficulty => _difficulty;

  set difficulty(int newDifficulty) => _difficulty = newDifficulty;

  int get duration => _duration;

  set duration(int newDuration) => _duration = newDuration;

  int get servings => _servings;

  set servings(int newServings) => _servings = newServings;

  String get category => _category;

  set category(String newCategory) => _category = newCategory;

  List<String> get tags => _tags;

  void addTag(String tag) => _tags.add(tag);

  bool get isFavorite => _favorite;

  void changeFavoriteState() => _favorite = !_favorite;

  String get userId => _userId;
}
