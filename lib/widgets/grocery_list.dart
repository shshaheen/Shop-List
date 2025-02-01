import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_list/data/categories.dart';
import 'package:shop_list/models/category.dart';
import 'package:shop_list/models/grocery_item.dart';
import 'package:shop_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error = null;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _removeItem(GroceryItem item) {
    final url = Uri.https("flutter-prep-ccf49-default-rtdb.firebaseio.com",
        'shop-list/${item.id}.json');

    http.delete(url);
    setState(() {
      _groceryItems.remove(item);
    });
  }

  void _loadItems() async {
    final url = Uri.https(
        "flutter-prep-ccf49-default-rtdb.firebaseio.com", 'shop-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        _error = "Failed to fetch data. Please try again later";
        return;
      });
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    List<GroceryItem> _loadedItems = [];
    for (final item in listData.entries) {
      final cat = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      item.value['category'];
      _loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: cat));
    }
    setState(() {
      _groceryItems = _loadedItems;
      _isLoading = false;
    });
    print(_loadedItems[0].name);
    print(response);
    print(listData);
  }

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
    // _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_error != null) {
      // print("error");
      content = Center(
        child: Text(_error!),
      );
    } else if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_groceryItems.isEmpty) {
      content = Center(child: const Text('No groceries added yet..!'));
    } else {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                const Color.fromARGB(250, 17, 90, 208),
                Colors.teal,
                const Color.fromARGB(180, 233, 68, 189)
              ])),
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
          ),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
        ),
      );
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
