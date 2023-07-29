import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<GroceryItem> groceryItems = [];

  void _addItem() async {
    final _newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return NewItem();
        },
      ),
    );
    if (_newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(_newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: Key(groceryItems[index].name), // Unique key for each item
          onDismissed: (direction) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("${groceryItems[index].name} is deleted")),
            );
            setState(() {
              groceryItems.removeAt(index);
            });
          },
          background: Container(
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            child: ListTile(
              title: Text(groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: groceryItems[index].category.color,
              ),
              trailing: Text(
                groceryItems[index].quantity.toString(),
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
