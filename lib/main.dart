import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checklist/root.dart';
import 'package:checklist/section_type.dart';
import 'package:checklist/section.dart';
import 'package:checklist/checklist.dart';

import 'package:checklist/section_page.dart';
import 'package:checklist/checklist_page.dart';

class DataModel extends ChangeNotifier {
  DataModel(BuildContext context) {
    DefaultAssetBundle.of(context).loadString('assets/root.json').then((value) {
      Map rootMap = jsonDecode(value);
      _root = Root.fromJson(rootMap);

      _root.sections.forEach((section) {
        for (var i=0; i<section.checklists.length; i++) {
          section.checklists[i].prev = (i - 1 < 0) ? null : section.checklists[i-1];
          section.checklists[i].next = (i + 1 >= section.checklists.length) ? null : section.checklists[i+1];
        }
      });

      this.notifyListeners();
    });
  }

  Root _root;
  Root get root => _root;
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataModel(context),
      child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData.dark();
    return MaterialApp(
      title: 'Checklist',
      theme: themeData.copyWith(
        accentColor: Colors.lightGreenAccent,
        buttonTheme: ButtonThemeData().copyWith(
          buttonColor: Colors.grey,
        ),
      ),
      initialRoute: RootPage.routeName,
      onGenerateRoute: (settings) {
        final routeName = settings.name;
        switch (routeName) {
          case RootPage.routeName:
            return MaterialPageRoute(builder: (context) => RootPage(title: 'C172M Checklist'));
          case SectionPage.routeName:
            final Section section = settings.arguments;
            return MaterialPageRoute(builder: (context) => SectionPage(section: section));
          case ChecklistPage.routeName:
            final ChecklistPageArguments arguments = settings.arguments;
            return MaterialPageRoute(builder: (context) =>
              ChecklistPage(
                checklist: arguments.checklist,
                onChecklistItemChanged: arguments.onChecklistItemChanged,
                onGoToPreviousChecklist: arguments.onGoToPreviousChecklist,
                onGoToNextChecklist: arguments.onGoToNextChecklist,
              )
            );
        }
        throw Exception('Unknown route name.');
      },
    );
  }
}

class RootPage extends StatefulWidget {
  static const routeName = '/';
  
  RootPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () { },
          ),
//          IconButton(
//            icon: Icon(Icons.error_outline, color: Colors.amberAccent, size: 32,),
//            onPressed: () {},
//          ),
        ],
      ),
      body: Consumer<DataModel>(
        builder: (context, datamodel, child) {
          if (datamodel.root == null)
            return CircularProgressIndicator();
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: datamodel.root.sections.length,
            itemBuilder: (BuildContext context, int index) {
              final Section section = datamodel.root.sections[index];
              bool isEmergency = section.sectionType == SectionType.EMERGENCY;
              return Container(
                color: ((){
                  if (section.sectionType != SectionType.NORMAL)
                    return Theme.of(context).errorColor;
                  else
                    return null;
                }()),
                child: ListTile(
                  leading: (isEmergency)
                    ? Icon(Icons.error_outline, color: Colors.amber, size: 42,)
                    : (section.completed()) ? Icon(Icons.check_circle, size: 42,) : Icon(Icons.radio_button_unchecked, size: 42,),
                  title: Text(section.title, style: Theme
                    .of(context)
                    .textTheme
                    .headline6),
                  subtitle: (section.description != null) ? Text(section.description, style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1) : null,
                  trailing: Icon(Icons.navigate_next),
                  //selected: false,
                  onTap: () {
                    Navigator.pushNamed(context, SectionPage.routeName, arguments: section);
                  }
                )
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          );
        }
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {},
//        tooltip: 'Emergency',
//        backgroundColor: Theme.of(context).disabledColor,
//        child: Icon(Icons.help_outline, size: 42),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
