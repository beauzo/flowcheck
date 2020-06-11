import 'package:flutter/material.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

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

  AutoScrollController _controller;
  AutoScrollPosition _position = AutoScrollPosition.middle;

  static const SCROLL_DURATION_MS = 600;
  static const SCROLL_REVEAL_DURATION_MS = 300;
  static const SCROLL_REVEAL_AMOUNT = 32.0;

  AnimationController _animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();

    _controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _colorTween = ColorTween(begin: Colors.lightGreenAccent, end: Colors.green[1000]).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _flashNextButton();
      _scrollToNextUncheckedIndex();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToNextUncheckedIndex() {
    if (widget.section.getFirstIncompleteChecklistIndex() == 0) {
      // Pull the list down a bit to show no items are above the top item
      _controller.animateTo(-SCROLL_REVEAL_AMOUNT,
        duration: Duration(milliseconds: SCROLL_REVEAL_DURATION_MS), curve: Curves.easeInOut);
    } else if (widget.section.getFirstIncompleteChecklistIndex() == widget.section.checklists.length) {
      // Pull the list up a bit to show no items are below the last item
      _controller.animateTo(_controller.position.maxScrollExtent + SCROLL_REVEAL_AMOUNT,
        duration: Duration(milliseconds: SCROLL_REVEAL_DURATION_MS), curve: Curves.easeInOut);
    } else {
      _controller.scrollToIndex(
        widget.section.getFirstIncompleteChecklistIndex(),
        duration: Duration(milliseconds: SCROLL_DURATION_MS),
        preferPosition: _position,
      );
    }
  }

  void _flashNextButton() {
    TickerFuture tickerFuture = _animationController.repeat(reverse: true);
    tickerFuture.timeout(Duration(milliseconds: 200 * 8), onTimeout: () {
      _animationController.forward(from: 0);
      _animationController.stop(canceled: true);
    });
  }

  void _goToPreviousChecklist(int currentIndex) {
    int newIndex = currentIndex - 1;
    if (newIndex >= 0) {
      Checklist checklist = widget.section.checklists[newIndex];
      Navigator.pushNamed(context, ChecklistPage.routeName,
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
          ));
    }
  }

  void _goToNextChecklist(int currentIndex) {}

  void _navigateToChecklist(Checklist checklist) {
    Navigator.pushNamed(context, ChecklistPage.routeName,
        arguments: ChecklistPageArguments(
          checklist,
          () {
            _scrollToNextUncheckedIndex();
            setState(() {});
          },
          (Checklist checklist) {},
          (Checklist checklist) {},
        ));
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (_) {
        setState(() {});
        return true;
      },
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress)
            return false;
          else
            return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: (widget.section.sectionType == SectionType.EMERGENCY)
                ? Theme.of(context).errorColor
                : Theme.of(context).appBarTheme.color,
            title: Text(widget.section.title),
          ),
          body: Center(
            child: Column(children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  scrollDirection: Axis.vertical,
                  controller: _controller,
                  itemCount: widget.section.checklists.length,
                  itemBuilder: (BuildContext context, int index) {
                    Checklist checklist = widget.section.checklists[index];
                    Item currentItem = checklist.getNextUncheckedItem();
                    bool isEmergency = widget.section.sectionType == SectionType.EMERGENCY;

                    TextStyle textStyle = Theme.of(context).textTheme.headline6;
                    if (checklist.isAllChecked())
                      textStyle = textStyle.copyWith(color: Theme.of(context).disabledColor,);

                    return _wrapScrollTag(
                      index: index,
                      child: Container(
                        color: (() {
                          if (isEmergency)
                            return Theme.of(context).errorColor;
                          else if (widget.section.getFirstIncompleteChecklist() == checklist) {
                            return Colors.white12;
                          } else
                            return null;
                        }()),
                        child: ListTile(
                          leading: Builder(builder: (context) {
                            if (checklist.isAllChecked())
                              return Icon(
                                Icons.check,
                                color: Colors.white30,
                                size: 42,
                              );
                            else {
                              var progress = checklist.getPercentChecked();
                              return CircularProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white24,
                              );
                            }
//                      return Icon(Icons.radio_button_unchecked, size: 42,);
//                      return ()
//                        ? Icon(Icons.error_outline, color: Colors.amber, size: 42,)
//                        : Icon(Icons.bookmark_border, size: 42,);
                          }),
                          //title: Text(checklist.title, style: Theme.of(context).textTheme.headline6),
                          title: Text(checklist.title, style: textStyle),
                          subtitle: (currentItem != null && checklist.isAnyChecked())
                              ? Text('Next: ' + currentItem.action)
                              : null,
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
                                ));
                          },
                          onLongPress: () {
                            setState(() {
                              checklist.uncheckAll();
                            });
                          },
                        )
                      ),
                    );
                  },
                  //separatorBuilder: (BuildContext context, int index) => const Divider(),
                  separatorBuilder: (BuildContext context, int index) => Container(height: 12.0, color: Colors.transparent,),
                ),
              ),
              Container(
                color: Theme.of(context).primaryColor,
                height: 72,
                //padding: EdgeInsets.all(2.0),
                child: ButtonBar(
                  layoutBehavior: ButtonBarLayoutBehavior.constrained,
                  buttonHeight: 52.0,
                  children: <Widget>[
                    FlatButton(
                      //child: Icon(Icons.undo),
                      child: Text('UNDO'),
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
                                        widget.section.checklists.forEach((checklist) {
                                          checklist.uncheckAll();
                                        });
                                        _scrollToNextUncheckedIndex();
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                    FlatButton(
                      child: Text('EMERG'),
                      color: Theme.of(context).errorColor,
                      onPressed: () {},
                    ),
                    AnimatedBuilder(
                        animation: _colorTween,
                        builder: (context, child) => FlatButton(
                              child: Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                                size: 32.0,
                              ),
                              color: _colorTween.value,
                              //color: Colors.lightGreenAccent, //(widget.section.completed()) ? Colors.lightGreenAccent : Colors.white10,
                              onPressed: () {
                                _navigateToChecklist(widget.section.getFirstIncompleteChecklist());
                              },
                            )),
                  ],
                  alignment: MainAxisAlignment.center,
                ),
              ),
              Container(
                height: 24,
              ),
            ]),
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
      ),
    );
  }

  Widget _wrapScrollTag({int index, Widget child}) => AutoScrollTag(
    key: ValueKey(index),
    controller: _controller,
    index: index,
    child: child,
  );
}
