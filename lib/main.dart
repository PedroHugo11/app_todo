import 'dart:convert';
import 'dart:io';

import 'package:app_to_do/models/item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
      title: "Lista de Tarefas",
      theme: ThemeData(primarySwatch: Colors.green),
      home: Home()));
}

class Home extends StatefulWidget {
  var items = new List<Item>();

  Home() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var newTaskController = TextEditingController();

  void add() {
    if (newTaskController.text.isEmpty) return;

    setState(() {
      widget.items.add(
        Item(
          title: newTaskController.text,
          done: false,
        ),
      );
      newTaskController.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString("data");

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString("data", jsonEncode(widget.items));
  }

  _HomeState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    Scaffold screen = Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext txt, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.5),
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );

    return screen;
  }
}
