import 'package:flutter/material.dart';
import 'package:shopping_list/widgets/new_item.dart';

import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
      ),
      body: _groceryItems.isEmpty
          ? const Center(
              child: Text('You have no items in the list! Try adding some.'))
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
