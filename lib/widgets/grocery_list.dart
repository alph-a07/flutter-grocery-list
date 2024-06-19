import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';

import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadItems() async {
    final url = Uri.https(
      'flutter-grocery-list-a6dc6-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Something went wrong! Please refresh the list.';
      });
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<GroceryItem> dataList = [];

    for (final item in data.entries) {
      final category = categories.entries
          .firstWhere((category) =>
              category.value.categoryName == item.value['category'])
          .value;

      dataList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }

    setState(() {
      _groceryItems = dataList;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) return;

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _groceryItems.isEmpty
                  ? const Center(
                      child: Text(
                          'You have no items in the list! Try adding some.'))
                  : ListView.builder(
                      itemCount: _groceryItems.length,
                      itemBuilder: (ctx, i) => Dismissible(
                        onDismissed: (_) {
                          setState(() {
                            _groceryItems.remove(_groceryItems[i]);
                          });
                        },
                        key: ValueKey(_groceryItems[i].id),
                        child: ListTile(
                          leading: Icon(
                            Icons.square_rounded,
                            color: _groceryItems[i].category.color,
                            size: 24,
                          ),
                          title: Text(_groceryItems[i].name),
                          trailing: Text(_groceryItems[i].quantity.toString()),
                        ),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
