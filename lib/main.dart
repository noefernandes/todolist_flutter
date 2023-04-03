import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: "Lista de Tarefas",
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _todoController = TextEditingController();
  List lista = [];

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        lista = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
        ),
        body: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: Text("Adicionar"),
                    onPressed: addItem,
                  )
                ],
              )),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: lista.length,
                  itemBuilder: buildItem),
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: ElevatedButton(
                  child: Text("Apagar marcados"), onPressed: deleteItem))
        ]));
  }

  void addItem() {
    setState(() {
      Map<String, dynamic> item = Map();
      item["title"] = _todoController.text;
      _todoController.text = "";
      item["ok"] = false;
      lista.add(item);
      _saveData();
    });
  }

  void deleteItem() {
    setState(() {
      lista.removeWhere((element) => element["ok"] == true);
    });
  }

  Widget buildItem(context, index) {
    return Container(
      padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
      child: CheckboxListTile(
          title: Text(lista[index]["title"]),
          value: lista[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(
              lista[index]["ok"] ? Icons.check : Icons.error,
              color: lista[index]["ok"] ? Colors.green : Colors.white,
            ),
          ),
          onChanged: (c) {
            checkItem(index, c);
          }),
    );
  }

  void checkItem(index, c) {
    setState(() {
      lista[index]["ok"] = c;
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(lista);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    final file = await _getFile();
    return file.readAsString();
  }
}
