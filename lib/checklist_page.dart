import 'dart:ffi';

import 'package:flutter/material.dart';

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

  final _scrollController = ScrollController();

  static const SCROLL_DURATION = 300;

  int lastCheckedIndex = 0;
  double percentChecked = 0.0;

  @override
  void initState() {
    super.initState();

    percentChecked = widget.checklist.getNumberOfCheckedItems() / widget.checklist.getNumberOfCheckableItems();
    lastCheckedIndex = widget.checklist.getNextItemUncheckedIndex();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.checklist.getNumberOfCheckedItems() == 0) {
        _scrollController.animateTo(
          -64.0, duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut);
      } else {
        var totalRatio = (widget.checklist.getNumberOfCheckedItems()) / (widget.checklist.items.length);
        _scrollController.animateTo(
          totalRatio * _scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkItem() {
    widget.checklist.checkCurrentItem();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      lastCheckedIndex = widget.checklist.getNextItemUncheckedIndex();
      var totalRatio = (widget.checklist.getNumberOfCheckedItems() * 2) / (widget.checklist.items.length);
      _scrollController.animateTo(
        totalRatio * _scrollController.position.maxScrollExtent, duration: Duration(milliseconds: SCROLL_DURATION),
        curve: Curves.easeInOut);
    });
  }

  void _uncheckLastItem() {
    widget.checklist.unCheckLastItem();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      lastCheckedIndex = widget.checklist.getNextItemUncheckedIndex();
      print(lastCheckedIndex);
      var totalRatio = (widget.checklist.getNumberOfCheckedItems()) / (widget.checklist.items.length);
      _scrollController.animateTo(
        totalRatio * _scrollController.position.maxScrollExtent, duration: Duration(milliseconds: SCROLL_DURATION),
        curve: Curves.easeInOut);
    });
  }

  void _uncheckAll() {
    widget.checklist.uncheckAll();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getNumberOfCheckedItems() / widget.checklist.getNumberOfCheckableItems();
      lastCheckedIndex = widget.checklist.getNextItemUncheckedIndex();
      _scrollController.animateTo(-64.0, duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
    });
  }

  void _checkAll() {
    widget.checklist.checkAll();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getNumberOfCheckedItems() / widget.checklist.getNumberOfCheckableItems();
      lastCheckedIndex = widget.checklist.getNextItemUncheckedIndex();
      _scrollController.animateTo(_scrollController.position.maxScrollExtent + 64.0, duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
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
              child: ListView.separated(
                padding: EdgeInsets.all(0.0),
                controller: _scrollController,
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
                    return Container(
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
                    );
                  } else {
                    return Container(
                      child: ListTile(
                        title: Text(item.action, style: Theme
                          .of(context)
                          .textTheme
                          .headline6),
                        selected: false,
                        onTap: () {}
                      )
                    );
                  }
                },
                //separatorBuilder: (BuildContext context, int index) => const Divider(),
                separatorBuilder: (BuildContext context, int index) => Container(height: 0,),
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
                    child: (widget.checklist.canUncheckLastItem()) ? Icon(Icons.undo) : Icon(Icons.skip_previous),
                    onPressed: (widget.checklist.canUncheckLastItem()) ? () {
                      _uncheckLastItem();
                    } : null,
                  ),
                  FlatButton(
                    child: Icon(Icons.vertical_align_top),
                    onPressed: (widget.checklist.isAnyChecked()) ? () {
                      _uncheckAll();
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
                      ? Text('NEXT', style: TextStyle(color: Colors.black),)
                      : Icon(Icons.check, color: Colors.lightGreenAccent,),
                    color: (widget.checklist.isAllChecked()) ? Colors.lightGreenAccent : Colors.white10,
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
}

class ChecklistItemTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}
