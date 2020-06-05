import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:checklist/checklist.dart';
import 'package:checklist/item_type.dart';
import 'package:checklist/item.dart';

class ChecklistPageArguments {
  final Checklist checklist;
  final VoidCallback onChecklistItemChanged;
  final Function(Checklist) onGoToPreviousChecklist;
  final Function(Checklist) onGoToNextChecklist;

  ChecklistPageArguments(this.checklist, this.onChecklistItemChanged, this.onGoToPreviousChecklist,
    this.onGoToNextChecklist);
}

class ChecklistPage extends StatefulWidget {
  static const routeName = '/checklist_page';

  ChecklistPage({Key key, this.checklist,
    this.onChecklistItemChanged,
    this.onGoToPreviousChecklist,
    this.onGoToNextChecklist,
  })
    : super(key: key);

  final Checklist checklist;
  final VoidCallback onChecklistItemChanged;
  final Function(Checklist) onGoToPreviousChecklist;
  final Function(Checklist) onGoToNextChecklist;

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {

  AutoScrollController _controller;
  AutoScrollPosition _position = AutoScrollPosition.middle;

  static const SCROLL_DURATION_MS = 600;
  static const SCROLL_REVEAL_DURATION_MS = 300;
  static const SCROLL_REVEAL_AMOUNT = 32.0;

  double percentChecked = 0.0;

  @override
  void initState() {
    super.initState();

    percentChecked = widget.checklist.getPercentChecked();

    _controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToNextUncheckedIndex();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _scrollToNextUncheckedIndex() {
    if (widget.checklist.getNumberOfCheckedItems() == 0) {
      // Pull the list down a bit to show no items are above the top item
      _controller.animateTo(
        -SCROLL_REVEAL_AMOUNT,
        duration: Duration(milliseconds: SCROLL_REVEAL_DURATION_MS),
        curve: Curves.easeInOut
      );
    } else if (widget.checklist.getNumberOfCheckedItems() == widget.checklist.getNumberOfCheckableItems()) {
      // Pull the list up a bit to show no items are below the last item
      _controller.animateTo(
        _controller.position.maxScrollExtent + SCROLL_REVEAL_AMOUNT,
        duration: Duration(milliseconds: SCROLL_REVEAL_DURATION_MS),
        curve: Curves.easeInOut
      );
    } else {
      _controller.scrollToIndex(
        widget.checklist.getNextItemUncheckedIndex(),
        duration: Duration(milliseconds: SCROLL_DURATION_MS),
        preferPosition: _position,
      );
    }
  }

  void _checkItem() {
    widget.checklist.checkCurrentItem();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      _scrollToNextUncheckedIndex();
    });
  }

  void _uncheckLastItem() {
    widget.checklist.unCheckLastItem();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      _scrollToNextUncheckedIndex();
    });
  }

  void _uncheckAll() {
    widget.checklist.uncheckAll();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      _scrollToNextUncheckedIndex();
    });
  }

  void _checkAll() {
    widget.checklist.checkAll();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      _scrollToNextUncheckedIndex();
    });
  }

  @override
  void didUpdateWidget(ChecklistPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.checklist.title),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              color: Theme
                .of(context)
                .scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(4.0),
//                    color: Theme
//                      .of(context)
//                      .primaryColor,
                    child: (widget.checklist.prev != null)
                      ? Text('' + widget.checklist.prev.title, style: TextStyle(color: Theme
                      .of(context)
                      .disabledColor),) : null
                  ),
                  Container(
                    padding: EdgeInsets.all(4.0),
//                    color: Theme
//                      .of(context)
//                      .appBarTheme
//                      .color,
                    child: (widget.checklist.next != null)
                      ? Text('' + widget.checklist.next.title, style: TextStyle(color: Theme
                      .of(context)
                      .disabledColor),) : null
                  ),
                ],
              )
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(0.0),
                scrollDirection: Axis.vertical,
                controller: _controller,
                itemCount: widget.checklist.items.length,
                itemBuilder: (BuildContext context, int index) {
                  Item item = widget.checklist.items[index];
                  if (item.type == ItemType.ACTION) {
                    final TextStyle textStyle = TextStyle(
//                      decoration: (item.isChecked)
//                        ? TextDecoration.lineThrough
//                        : TextDecoration.none,
                      fontWeight: (index == widget.checklist.getNextItemUncheckedIndex()) ? FontWeight.bold : FontWeight.normal,
                      color: (item.isChecked)
                        ? Theme
                        .of(context)
                        .disabledColor
                        : null,);
                    return _wrapScrollTag(index: index, child: Container(
                      color: (item.isChecked) ? Colors.black26 : ((index == widget.checklist.getNextItemUncheckedIndex()) ? Colors.white12 : null),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        leading: (item.isChecked)
                          ? Icon(Icons.check, color: Colors.white30,)
                          : Icon(Icons.radio_button_unchecked, color: null),
                        title: Text(item.action, style: textStyle),
                        trailing: Text(item.expectedResult, style: textStyle),
                        selected: (index == widget.checklist.getNextItemUncheckedIndex()),
                        onTap: (index == widget.checklist.getNextItemUncheckedIndex()) ? () {
                          _checkItem();
                        } : null,
                      )
                    ));
                  } else {
                    return _wrapScrollTag(index: index, child: Container(
                      child: ListTile(
                        title: Text(item.action, style: Theme
                          .of(context)
                          .textTheme
                          .headline6),
                        selected: false,
                        onTap: () {}
                      )
                    ));
                  }
                },
                //separatorBuilder: (BuildContext context, int index) => const Divider(),
                //separatorBuilder: (BuildContext context, int index) => Container(height: 2,),
              ),
            ),
            Container(
              color: Theme
                .of(context)
                .primaryColor,
              height: 4,
              padding: EdgeInsets.all(0.0),
              child: LinearProgressIndicator(
                value: percentChecked,
                backgroundColor: Theme
                  .of(context)
                  .dialogBackgroundColor,
              )
            ),
            Container(
              color: Theme
                .of(context)
                .primaryColor,
              height: 72,
              //padding: EdgeInsets.all(8.0),
              child: ButtonBar(
                buttonHeight: 52.0,
                children: <Widget>[
                  FlatButton(
                    //color: Theme.of(context).buttonColor,
                    //child: (widget.checklist.canUncheckLastItem()) ? Icon(Icons.undo) : Icon(Icons.skip_previous),
                    child: Text('UNDO'),
                    onPressed: (widget.checklist.canUncheckLastItem()) ? () {
                      _uncheckLastItem();
                    } : null,
                  ),
                  FlatButton(
                    //child: Icon(Icons.vertical_align_top),
                    child: Text('RESET'),
                    onPressed: (widget.checklist.isAnyChecked()) ? () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Reset Checklist'),
                            content: Text('Are you sure you want to reset this checklist?'),
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
                                  _uncheckAll();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }
                      );
                    } : null,
                  ),
                  FlatButton(
                    child: Text('EMERG'),
                    color: Theme
                      .of(context)
                      .errorColor,
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: (widget.checklist.isAllChecked())
                      //? Icon(Icons.skip_next, color: Colors.black)
                      ? Text('CONT', style: TextStyle(color: Colors.black),)
                      : Icon(Icons.check, color: Colors.black, size: 32.0),
                    color: Colors.lightGreenAccent, //(widget.checklist.isAllChecked()) ? Colors.lightGreenAccent : Colors.white10,
                    onPressed: (!widget.checklist.isAllChecked())
                      ? () {
                      _checkItem();
                    } : () {
                      Navigator.pop(context);
                    },
                    onLongPress: () {
                      _checkAll();
                    },
                  )
                ],
                alignment: MainAxisAlignment.center,
              ),
            ),
            Container(height: 24,),
          ],
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () { _uncheckAll(); },
//        tooltip: 'Emergency',
//        //backgroundColor: Theme.of(context).errorColor,
//        child: Icon(Icons.undo, size: 42),
//      ),
    );
  }

  Widget _wrapScrollTag({int index, Widget child}) => AutoScrollTag(
    key: ValueKey(index),
    controller: _controller,
    index: index,
    child: child,
  );
}

class ChecklistItemTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}
