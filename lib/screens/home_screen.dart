import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> groceryItems = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'null.com',
        'flutter-shopping-list.json');
    try{
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = jsonDecode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        var category = categories.entries.firstWhere(
                (cateItem) => cateItem.value.title == item.value['category']);
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value));
      }
      setState(() {
        groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error){
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }

  }

  void _addItem() async {
    var newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
    });
  }

  void _removeItem(index) async {
    print(index);
    GroceryItem tempGroceryItem = groceryItems[index];
    setState(() {
      groceryItems.removeAt(index);
    });

    final url = Uri.https(
        'null.firebaseio.com',
        'flutter-shopping-list/${tempGroceryItem.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() {
        groceryItems.insert(index, tempGroceryItem);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "An error has occured while deleting. Undoing the operation"),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _listContent = const Center(
      child: Text("No items found"),
    );

    if (_isLoading) {
      _listContent = const Center(
        child: CircularProgressIndicator(
          semanticsLabel: "Loading",
        ),
      );
    }

    if (_isError) {
      _listContent = const Center(
        child: Card(
          color: Colors.red,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Something is not right here...",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (groceryItems.isNotEmpty) {
      _listContent = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: Key(groceryItems[index].name),
          onDismissed: (direction) {
            _removeItem(index);
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }

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
      body: _listContent,
    );
  }
}
