import 'package:flutter/material.dart';
import 'package:shop_list/data/dummy_items.dart';
// import 'package:shop_list/data/dummy_items.dart';
import 'package:shop_list/models/grocery_item.dart';
import 'package:shop_list/widgets/new_item.dart';

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
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color.fromARGB(250, 17, 90, 208),  const Color.fromARGB(190, 244, 54, 193)])
            ),
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _groceryItems
                  .removeWhere((elem) => elem.id == _groceryItems[index].id);
            });
          },
        ),
      );
    } else {
      content = Center(child: const Text('No groceries added yet..!'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addItem();
            },
          ),
        ],
      ),
      body: content,
    );
  }
}
