import 'package:flutter/material.dart';

import 'package:checklist/section_type.dart';
import 'package:checklist/section.dart';
import 'package:checklist/checklist.dart';
import 'package:checklist/item.dart';

import 'package:checklist/checklist_page.dart';

class SectionPage extends StatefulWidget {
  static const routeName = '/section_page';

  SectionPage({Key key, this.section}) : super(key: key);

  final Section section;

  @override
  _SectionPageState createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {

  void _goToPreviousChecklist(int currentIndex) {
    int newIndex = currentIndex - 1;
    if (newIndex >= 0) {
      Checklist checklist = widget.section.checklists[newIndex];
      Navigator.pushNamed(
        context,
        ChecklistPage.routeName,
        arguments: ChecklistPageArguments(
          checklist,
            () {
            setState(() {});
          },
            (Checklist checklist) {
            _goToPreviousChecklist(newIndex);
          },
            (Checklist checklist) {
            _goToNextChecklist(newIndex);
          },
        )
      );
    }
  }

  void _goToNextChecklist(int currentIndex) {

  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (_) {
        setState(() {});
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: (widget.section.sectionType == SectionType.EMERGENCY)
            ? Theme
            .of(context)
            .errorColor
            : Theme
            .of(context)
            .appBarTheme
            .color,
          title: Text(widget.section.title),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: widget.section.checklists.length,
                  itemBuilder: (BuildContext context, int index) {
                    Checklist checklist = widget.section.checklists[index];
                    Item currentItem = checklist.getNextUncheckedItem();
                    bool isEmergency = widget.section.sectionType == SectionType.EMERGENCY;
                    return Container(
                      color: (() {
                        if (isEmergency)
                          return Theme
                            .of(context)
                            .errorColor;
                        else
                          return null;
                      }()),
                      child: ListTile(
                        leading: Builder(
                          builder: (context) {
                            if (checklist.isAllChecked())
                              return Icon(Icons.check_circle, color: Colors.lightGreenAccent, size: 42,);
                            else {
                              var progress = checklist.getNumberOfCheckedItems() / checklist.getNumberOfCheckableItems();
                              return CircularProgressIndicator(value: progress, backgroundColor: Colors.white12,);
                            }
//                      return Icon(Icons.radio_button_unchecked, size: 42,);
//                      return ()
//                        ? Icon(Icons.error_outline, color: Colors.amber, size: 42,)
//                        : Icon(Icons.bookmark_border, size: 42,);
                          }
                        ),
                        title: Text(checklist.title, style: Theme
                          .of(context)
                          .textTheme
                          .headline6),
                        subtitle: (currentItem != null && checklist.isAnyChecked()) ? Text('Next: ' + currentItem.action) : null,
                        trailing: Icon(Icons.navigate_next),
                        selected: false,
                        onTap: () {
                          Navigator.pushNamed(context, ChecklistPage.routeName,
                            arguments: ChecklistPageArguments(
                              checklist,
                                () {
                                setState(() {});
                              },
                                (Checklist checklist) {
                                _goToPreviousChecklist(index);
                              },
                                (Checklist checklist) {
                                _goToNextChecklist(index);
                              },
                            )
                          );
                        },
                        onLongPress: () {
                          setState(() {
                            checklist.uncheckAll();
                          });
                        },
                      )
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                ),
              ),
              Container(
                color: Theme
                  .of(context)
                  .primaryColor,
                height: 72,
                //padding: EdgeInsets.all(2.0),
                child: ButtonBar(
                  buttonHeight: 52.0,
                  children: <Widget>[
//                    RaisedButton(
//                      child: Icon(Icons.undo),
//                      onPressed: () {},
//                    ),
                    RaisedButton(
                      child: Icon(Icons.vertical_align_top),
                      onPressed: () {
                        setState(() {
                          widget.section.checklists.forEach((checklist) { checklist.uncheckAll(); });
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text('EMERGENCY'),
                      color: Theme
                        .of(context)
                        .errorColor,
                      onPressed: () {},
                    ),
//                    RaisedButton(
//                      child: Icon(Icons.skip_next),
//                      onPressed: null,
//                    )
                  ],
                  alignment: MainAxisAlignment.center,
                ),
              ),
              Container(height: 24,),
            ]
          ),
        ),
//        floatingActionButton: FloatingActionButton(
//          onPressed: () {},
//          tooltip: 'Emergency',
//          backgroundColor: Theme
//            .of(context)
//            .errorColor,
//          child: Icon(Icons.error_outline, color: Colors.amber, size: 42),
//        ),
      ),
    );
  }
}
