import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Widgets/RecipeTagWidget.dart';

class RecipeCardWidget extends StatelessWidget {
  final Widget recipeImage;
  final String recipeName;
  final int recipeDuration;
  final int recipeDifficulty;
  final int recipeServing;
  final String recipeCategory;
  final List<String> recipeTags;
  final void Function() onTap;

  const RecipeCardWidget({
    required this.recipeImage,
    required this.recipeName,
    required this.recipeDuration,
    required this.recipeDifficulty,
    required this.recipeServing,
    required this.recipeCategory,
    required this.recipeTags,
    required this.onTap,
    super.key,
  });

  RecipeTagWidget _generateRecipeTag(String tagName) {
    return RecipeTagWidget(
      text: tagName,
      isSelected: false,
      trailing: Recipe.getTagIcon(tagName),
      onSelectionFunction: (selection) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shadowColor: Colors.orange[200],
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: <Widget>[
            // IMAGE
            AspectRatio(
              aspectRatio: 16/9,
              child: Stack(
                // All the available space
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    "https://t3.gstatic.com/licensed-image?q=tbn:ANd9GcSVzpnv_EMpNYb9WrblxuxMR0zaeSA6M7uGtBU40PfQm32zlHBQys-3WO3xAtEX5bXDyxydNiq4lr7h9Kud",
                    fit: BoxFit.cover,
                  ),
                  
                  // TITLE
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: ColoredBox(
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipeName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                      )
                    )
                  )
                  
                ],
              ),
            ),
        
            //Divider(thickness: 2, indent: 8.0, endIndent: 8.0),
        
            // Duration
            ListTile(
              leading: Icon(Icons.timer_outlined),
              title: Row(
                children: [
                  const Text("Duration:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                  const SizedBox(width: 6,),
                  Text("$recipeDuration m")
                ],
              ),
            ),
        
            // DIFFICULTY
            ListTile(
              leading: Image.asset(
                "content/images/chefHat.png",
                color: Colors.amber[700],
                width: 30,
                height: 30,
              ),
              title: Row(
                children: <Widget>[
                  const Text(
                    "Difficulty:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(recipeDifficulty.toString()),
                ],
              ),
            ),
        
            // SERVINGS
            ListTile(
              leading: Icon(Icons.people_alt_rounded),
              title: Row(
                children: <Widget>[
                  const Text(
                    "Servings:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(recipeServing.toString()),
                ],
              ),
            ),
        
            // CATEGORY
            ListTile(
              leading: Recipe.getMealIcon(recipeCategory),
              title: Row(
                children: <Widget>[
                  const Text(
                    "Category:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(recipeCategory),
                ],
              ),
            ),
        
            // TAGS
            ListTile(
              leading: Icon(Icons.label_important_sharp),
              title: const Text(
                "Tags:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Wrap(
              spacing: 2.0,
              runSpacing: 2.0,
              children: List.generate(recipeTags.length, (index) {
                return _generateRecipeTag(recipeTags[index]);
              }),
            ),
          
          ],
        ),
      ),
    );
  }
}
