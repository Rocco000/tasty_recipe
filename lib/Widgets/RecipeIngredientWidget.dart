import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';

class RecipeIngredientWidget extends StatelessWidget {
  final RecipeIngredient ingredient;
  final String ingredientName;
  final void Function() onPressed;


  const RecipeIngredientWidget({required this.ingredient, required this.ingredientName, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.orange[100],
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: Row(
          spacing: 10,
          children: [
            Text(
              ingredientName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Text(
              ingredient.quantity.toString(),
              style: const TextStyle(fontSize: 16),
            ),

            Text(
              ingredient.unitMeasurement,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.shopping_cart_sharp),
        ),
      ),
    );
  }
}