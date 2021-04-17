import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const OPENAI_KEY = String.fromEnvironment("OPENAI_KEY");

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Chef de PartAI - Cookie'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var userInput;
  String prompt = "";

  void sentToAI(String s) async {

    prompt = "Name five delicious meals I can cook containing " + s + ":" + "\n" + "1.";

    var result = await http.post(
      Uri.parse("https://api.openai.com/v1/engines/davinci/completions"),

      headers: {
        "Authorization": "Bearer $OPENAI_KEY",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": prompt,
        "max_tokens": 120,
        "temperature": 0.9,
        "top_p": 1,
        "stop": "Name",
      }),
    );

    var body = jsonDecode(result.body);
    var text = body["choices"][0]["text"];

    String string = text.toString();
    List<String> list = string.split("\n");
    // list.forEach((element) {print(element);});
    // list.forEach((element) {element.replaceFirst("\d\\.\s", "");});

    list.removeWhere((element) => element.isEmpty);

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Generator(suggestions: list)));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: TextFormField(
            onFieldSubmitted: (String s) {
              sentToAI(s);
            },
            decoration: InputDecoration(
              //filled: true,
              //fillColor: Colors.lightGreenAccent,
              helperText: 'Enter Ingredients (Eggs, Cheese, ...)',
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Generator extends StatefulWidget {

  List<String> suggestions;
  Generator({this.suggestions});

  @override
  _GeneratorState createState() => _GeneratorState(list: this.suggestions);
}

class _GeneratorState extends State<Generator> {
  final List<String> list;
  //final _suggestions = <WordPair>[];                 // NEW
  final _biggerFont = const TextStyle(fontSize: 18);

  _GeneratorState({this.list}); // NEW

  Widget buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),

        itemBuilder: (BuildContext _context, int i) {

          if (i < list.length) {
            return _buildRow(list[i]);
          } else {
            return null;
          }
        }
    );
  }

  Widget _buildRow(String string) {
    return ListTile(
      leading: Icon(Icons.kitchen),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDescription(name: string))),
      title: Text(
        string,
        style: _biggerFont,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chef de PartAI from Cookie"),
      ),
      body: buildList(),
    );
  }
}

class RecipeDescription extends StatefulWidget {
  String name;
  RecipeDescription({this.name});

  @override
  _RecipeDescriptionState createState() => _RecipeDescriptionState(name: name);
}

class _RecipeDescriptionState extends State<RecipeDescription> {
  String name;
  _RecipeDescriptionState({this.name});

  Future<List<String>> generateRecipe(String name) async {

    String prompt = "";

    var result = await http.post(
      Uri.parse("https://api.openai.com/v1/engines/davinci/completions"),

      headers: {
        "Authorization": "Bearer $OPENAI_KEY",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": prompt,
        "max_tokens": 120,
        "temperature": 0.9,
        "top_p": 1,
        "stop": "Name",
      }),
    );

    var body = jsonDecode(result.body);
    var text = body["choices"][0]["text"];

    String string = text.toString();
    List<String> list = string.split("\n");

    return list;
  }

  @override
  Widget build(BuildContext context) {
    //List<String> list = generateRecipe(this.name) as List<String>;

    return Scaffold(
        appBar: AppBar(
          title: Text('Chef de PartAI - Cookie'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(fontSize: 36, color: Colors.black),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apple Pi',
                        style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                    const Text(
                      'Ingredients:',
                      style: TextStyle(fontSize: 35, color: Colors.green),
                    ),
                    const Text(
                      'Instructions:',
                      style: TextStyle(fontSize: 35, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'The fourth text',
            ),
          ],
        )
    );
  }
}

