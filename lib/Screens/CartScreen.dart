import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/CartItem.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Widgets/MyBottomNavigationBar.dart';

class CartScreen extends StatefulWidget {
  static const String route = "/cartScreen";

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Ingredient> _ingredients = [
    Ingredient("0", "Chocolate"),
    Ingredient("1", "Cacao"),
    Ingredient("2", "Milk"),
  ];

  List<CartItem> _uncheckedItems = [
    CartItem("abc", 0, 250, "gr", false),
    CartItem("abc", 1, 100, "gr", false),
    CartItem("abc", 2, 2, "cup", false),
  ];

  List<CartItem> _checkedItems = [];

  Widget _generateUncheckedItem(int index) {
    // Get the corresponding ingredient name
    final String ingredientName = _ingredients[index].name;
    final CartItem cartItem = _uncheckedItems[index];

    return Dismissible(
      key: ValueKey<int>(cartItem.ingredientId),
      // Bin icon
      background: DecoratedBox(
        decoration: BoxDecoration(color: Colors.red),
        child: Align(
          alignment: Alignment(-0.9, 00),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          print(_uncheckedItems[index]);
          _uncheckedItems.removeAt(
            index,
          ); // removeWhere((item) => item.ingredientId == cartItem.ingredientId)
          print(_uncheckedItems.length);
        });
      },
      child: CheckboxListTile(
        value: cartItem.isChecked,
        onChanged: (newValue) {
          setState(() {
            // Set the checked state to checked
            cartItem.checkStatus = !cartItem.isChecked;
            // Add the item in the checked list
            _checkedItems.add(cartItem);
            // Remove the item from the unchecked list
            _uncheckedItems.removeAt(
              index,
            ); // removeWhere((item) => item.ingredientId == cartItem.ingredientId)
          });
        },
        title: Text(ingredientName, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _generateCheckedItem(int index) {
    // Get the corresponding ingredient name
    String ingredientName = _ingredients[index].name;

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
              onPressed: () {
                setState(() {
                  _checkedItems.clear();
                });
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Tasty Recipe"),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            // UNCHECKED
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Text(
                  'Shopping List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // CHECKED
            if (_checkedItems.isNotEmpty) ..._generateCompletedScreen(),
          ],
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
