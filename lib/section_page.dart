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

class _SectionPageState extends State<SectionPage> with TickerProviderStateMixin {

  AnimationController _animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _colorTween = ColorTween(
      begin: Colors.lightGreenAccent,
      end: Colors.green[1000]
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      TickerFuture tickerFuture = _animationController.repeat(reverse: true);
      tickerFuture.timeout(Duration(milliseconds: 200 * 8), onTimeout: () {
        _animationController.forward(from: 0);
        _animationController.stop(canceled: true);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  void _navigateToChecklist(Checklist checklist) {
    Navigator.pushNamed(context, ChecklistPage.routeName,
      arguments: ChecklistPageArguments(
        checklist, () { setState(() {}); },
        (Checklist checklist) {},
        (Checklist checklist) {},
      )
    );
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
                  padding: const EdgeInsets.all(0),
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
                        else if (widget.section.getFirstIncompleteChecklist() == checklist) {
                          return Colors.white12;
                        } else
                          return null;
                      }()),
                      child: ListTile(
                        leading: Builder(
                          builder: (context) {
                            if (checklist.isAllChecked())
                              return Icon(Icons.check, color: Colors.white30, size: 42,);
                            else {
                              var progress = checklist.getNumberOfCheckedItems() / checklist.getNumberOfCheckableItems();
                              return CircularProgressIndicator(value: progress, backgroundColor: Colors.white24,);
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
                  layoutBehavior: ButtonBarLayoutBehavior.constrained,
                  buttonHeight: 52.0,
                  children: <Widget>[
                    FlatButton(
                      child: Icon(Icons.undo),
                      //onPressed: () { _animationController.repeat(reverse: true); },
                    ),
                    FlatButton(
                      child: Text('RESET'), //Icon(Icons.vertical_align_top),
                      //color: Colors.white10,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Reset Section'),
                              content: Text('Are you sure you want to reset this section?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text('Reset'),
                                  color: Theme.of(context).errorColor,
                                  onPressed: () {
                                    setState(() {
                                      widget.section.checklists.forEach((checklist) { checklist.uncheckAll(); });
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                    ),
                    FlatButton(
                      child: Text('EMERG'),
                      color: Theme
                        .of(context)
                        .errorColor,
                      onPressed: () {},
                    ),
                    AnimatedBuilder(
                      animation: _colorTween,
                      builder: (context, child) => FlatButton(
                        child: Icon(Icons.play_arrow, color: Colors.black,),
                        color: _colorTween.value,
                        //color: Colors.lightGreenAccent, //(widget.section.completed()) ? Colors.lightGreenAccent : Colors.white10,
                        onPressed: () { _navigateToChecklist(widget.section.getFirstIncompleteChecklist()); },
                      )
                    ),
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
