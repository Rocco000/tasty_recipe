import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/MyUser.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Widgets/MyBottomNavigationBar.dart';

class ProfileScreen extends StatefulWidget {
  static const String route = "/profileScreen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MyUser _user = MyUser("foo.mail@.com", "Abcd3fg!00", "Jhon");
  final int _recipeCount = 50;
  final Map<String, int> _categoryCounts = {
    "Total recipes": 50,
    "Breakfast": 10,
    "First Course": 10,
    "Second Course": 10,
    "Snack": 10,
    "Dessert": 10,
  };

  Widget _generateProfileRecipeInfo(int index) {
    final String category = _categoryCounts.keys.elementAt(index);
    final int count = _categoryCounts.values.elementAt(index);
    return Chip(
      avatar: (index == 0)
          ? Image.asset(
              "content/images/chefUtensil.png",
              width: 150,
              height: 150,
            )
          : Recipe.getMealIcon(category),
      backgroundColor: Colors.black12,
      label: Text(
        "$category: $count",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );

    /*Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Recipe.getMealIcon("Breakfast"),
          Text(_categoryCounts.keys.elementAt(0), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          Text("${_categoryCounts.values.elementAt(0)}", style: TextStyle(fontSize: 12),),
        ],
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Tasty Recipe"),
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.white,
              shadowColor: Colors.orange[200],
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Stack(
                        // All the available space
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          // RECIPE IMG
                          Image.network(
                            "https://t3.gstatic.com/licensed-image?q=tbn:ANd9GcSVzpnv_EMpNYb9WrblxuxMR0zaeSA6M7uGtBU40PfQm32zlHBQys-3WO3xAtEX5bXDyxydNiq4lr7h9Kud",
                            fit: BoxFit.cover,
                          ),

                          // PROFILE IMAGE
                          Positioned(
                            bottom: -40,
                            child: CircleAvatar(
                              radius: 50,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundImage: AssetImage(
                                  "content/images/dessertBackground.jpg",
                                ),
                              ),
                            ),
                          ),

                          // EDIT ICON
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: IconButton(
                                color: Colors.black,
                                tooltip: "Edit profile",
                                onPressed: () {},
                                icon: const Icon(Icons.edit_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      "${_user.username}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: const Text(
                      "Statistics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Wrap(
                      spacing: 2.0,
                      runSpacing: 2.0,
                      children: List.generate(
                        5,
                        (index) => _generateProfileRecipeInfo(index),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2.0,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: const Text("Change Password"),
                          icon: const Icon(Icons.lock_outline_rounded),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: const Text("Donate a coffee"),
                          icon: const Icon(Icons.favorite_border),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        ElevatedButton.icon(
                          onPressed: () {},
                          label: const Text("Delete Profile"),
                          icon: const Icon(Icons.delete_outline),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        bottomNavigationBar: MyBottomNavigationBar(4),
      ),
    );
  }
}
