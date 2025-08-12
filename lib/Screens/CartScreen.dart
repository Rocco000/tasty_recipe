import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Services/CartController.dart';
import 'package:tasty_recipe/Widgets/MyBottomNavigationBar.dart';

class CartScreen extends StatefulWidget {
  static const String route = "/cartScreen";
  final CartController _controller;

  const CartScreen(this._controller, {super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _uncheckedItems;
  late List<Ingredient> _ingredientList;
  late Future<(List<CartItem>, List<Ingredient>)> _cartFuture;

  List<Ingredient> _checkedIngredients = [];
  List<CartItem> _checkedItems = [];

  @override
  void initState() {
    super.initState();
    _cartFuture = widget._controller.getAllCartItems();
  }

  Widget _generateUncheckedItem(int index) {
    // Get the corresponding ingredient name
    final String ingredientName = _ingredientList[index].name;
    final CartItem cartItem = _uncheckedItems[index];

    return Dismissible(
      key: ValueKey<String>(cartItem.ingredientId),
      // Bin icon
      background: DecoratedBox(
        decoration: BoxDecoration(color: Colors.red),
        child: Align(
          alignment: Alignment(-0.9, 00),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      confirmDismiss: (direction) async {
        final bool result = await widget._controller.removeItemFromCart(
          cartItem,
        );

        if (!result) {
          //Something went wrong in the delete procedure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Something went wrong. Try again"),
              backgroundColor: const Color(0xFFE63946),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Makes it float over the UI
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          return false; // Prevent dismiss
        }

        // Remove item from list
        setState(() {
          _uncheckedItems.removeAt(index);
          _ingredientList.removeAt(index);
        });

        return true;
      },
      child: CheckboxListTile(
        value: cartItem.isChecked,
        onChanged: (newValue) {
          setState(() {
            // Set the checked state to checked
            cartItem.checkStatus = !cartItem.isChecked;
            // Remove the item from the unchecked list
            _uncheckedItems.removeAt(
              index,
            ); // removeWhere((item) => item.ingredientId == cartItem.ingredientId)

            // Add ingredient in the checked ingredient list
            _checkedIngredients.add(_ingredientList[index]);

            // Remove the ingredient from the list
            _ingredientList.removeAt(index);

            // Add item in the checked list
            _checkedItems.add(cartItem);
          });
        },
        title: Text(ingredientName, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _generateCheckedItem(int index) {
    // Get the ingredient name
    String ingredientName = _checkedIngredients[index].name;

    return CheckboxListTile(
      value: _checkedItems[index].isChecked,
      onChanged: (newValue) {
        setState(() {
          // Set the checked state to uncheck
          _checkedItems[index].checkStatus = !_checkedItems[index].isChecked;

          // Add the item in the unchecked list
          _uncheckedItems.add(_checkedItems[index]);

          // Remove the item from the checked list
          _checkedItems.removeAt(index);

          // Add ingredient in the unchecked ingredient list
          _ingredientList.add(_checkedIngredients[index]);

          // Remove ingredient from the checked ingredient list
          _checkedIngredients.removeAt(index);
        });
      },
      title: Text(
        ingredientName,
        style: const TextStyle(
          fontSize: 18,
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
        ),
      ),
    );
  }

  List<Widget> _generateCompletedScreen() {
    return [
      // TEXT + CLEAR ALL BUTTON
      SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(color: Colors.black38),
          child: ListTile(
            title: const Text(
              "Completed",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              onPressed: () async {
                final bool result = await widget._controller
                    .removeItemsFromCart(_checkedItems);

                if (result) {
                  // All items have been removed
                  setState(() {
                    _checkedItems.clear();
                    _checkedIngredients.clear();
                  });
                } else {
                  // Something went wrong in the delete procedure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Something went wrong. Try again"),
                      backgroundColor: const Color(0xFFE63946),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior
                          .floating, // Makes it float over the UI
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete),
              tooltip: "Clear all",
            ),
          ),
        ),
      ),

      // CHECKED ITEMS
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _generateCheckedItem(index),
          childCount: _checkedItems.length,
        ),
      ),
    ];
  }

  Widget _generateErrorMessage(Object error) {
    String msg = error.toString();
    final index = msg.indexOf(":");
    if (index != -1 && index < msg.length - 1) {
      msg = msg.substring(index + 1).trim();
    } else {
      msg = "Something went wrong. Try again";
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Card(
          color: const Color(
            0xFFFFF9F4,
          ), // const Color.fromRGBO(230, 57, 70, 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Color(0xFFE63946),
              ),
              Text(
                msg,
                style: const TextStyle(
                  color: Color(0xFFE63946),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        body: FutureBuilder<(List<CartItem>, List<Ingredient>)>(
          future: _cartFuture,
          builder: (context, snapshot) {
            // Show loading spinner while waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(color: Colors.orange),
                ),
              );
            }

            // Show error message if something went wrong
            if (snapshot.hasError) {
              print(snapshot.error);
              return _generateErrorMessage(snapshot.error!);
            }

            final (List<CartItem> items, List<Ingredient> ingredients) =
                snapshot.data!;
            _uncheckedItems = items;
            _ingredientList = ingredients;

            return CustomScrollView(
              slivers: <Widget>[
                // UNCHECKED
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Shopping List',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _generateUncheckedItem(index),
                    childCount: _uncheckedItems.length,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text(
                        "Add item",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // CHECKED
                if (_checkedItems.isNotEmpty) ..._generateCompletedScreen(),
              ],
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: "Add item",
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),

        bottomNavigationBar: MyBottomNavigationBar(1),
      ),
    );
  }
}
