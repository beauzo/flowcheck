import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:checklist/checklist.dart';
import 'package:checklist/item_type.dart';
import 'package:checklist/item.dart';
import 'package:tuple/tuple.dart';

import 'list_bottom_bar.dart';

class ChecklistPageArguments {
  final Checklist checklist;
  final VoidCallback onChecklistItemChanged;
  final Function(Checklist) onGoToPreviousChecklist;
  final Function(Checklist) onGoToNextChecklist;

  ChecklistPageArguments(this.checklist, this.onChecklistItemChanged,
      this.onGoToPreviousChecklist, this.onGoToNextChecklist);
}

class ChecklistPage extends StatefulWidget {
  static const routeName = '/checklist_page';

  ChecklistPage({
    Key key,
    this.checklist,
    this.onChecklistItemChanged,
    this.onGoToPreviousChecklist,
    this.onGoToNextChecklist,
  }) : super(key: key);

  final Checklist checklist;
  final VoidCallback onChecklistItemChanged;
  final Function(Checklist) onGoToPreviousChecklist;
  final Function(Checklist) onGoToNextChecklist;

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

typedef String SayGeneratorFunction();

class _ChecklistPageState extends State<ChecklistPage>
    with SingleTickerProviderStateMixin {
  AutoScrollController _controller;
  AutoScrollPosition _position = AutoScrollPosition.middle;

  static const SCROLL_DURATION_MS = 600;
  static const SCROLL_REVEAL_DURATION_MS = 300;
  static const SCROLL_REVEAL_AMOUNT = 32.0;

  double percentChecked = 0.0;

  AnimationController _speechAnimationController;
  Animation<double> _speechAnimation;
  double _speechProgress = 0.0;

  FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();

    _setupTts();

    percentChecked = widget.checklist.getPercentChecked();

    _controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    _speechAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    //_speechAnimationController.forward();
    _speechAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_speechAnimationController)
      ..addListener(() {
        setState(() {
          // Changing...
        });
        //_speechAnimationController.repeat();
      });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToNextUncheckedIndex();
    });
  }

  @override
  void dispose() {
    _speechAnimationController.stop();
    _speechAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setupTts() async {
    await _tts.setSharedInstance(true);
//    await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
//      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
//      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
//      IosTextToSpeechAudioCategoryOptions.mixWithOthers
//    ]);
    await _tts.setSpeechRate(0.53);

//    _tts.setProgressHandler((text, start, end, word) {
//      //print(text + ', start: ' + start.toString() + ', end: ' + end.toString() + ', word: ' + word);
//      setState(() {
//        var s = start / text.length;
//        var e = end / text.length;
//        _speechAnimationController.animateTo(s);
//        _speechAnimationController.animateTo(e);
//      });
//    });
  }

  final Map<String, Function> _sayGenerators = {
    "{{time}}": () => DateFormat('kk:mm').format(DateTime.now()),
  };

  Future<dynamic> _say(String something) async {
    final String somethingExpanded = _sayGenerators.entries
        .fold(something, (prev, e) => prev.replaceAll(e.key, e.value()));
//    print(somethingExpanded);
    await _tts.speak(somethingExpanded);
  }

  void _scrollToNextUncheckedIndex() {
    if (widget.checklist.getNumberOfCheckedItems() == 0) {
      // Pull the list down a bit to show no items are above the top item
      _controller.animateTo(-SCROLL_REVEAL_AMOUNT,
          duration: Duration(milliseconds: SCROLL_REVEAL_DURATION_MS),
          curve: Curves.easeInOut);
      _say(widget.checklist.title +
          ' checklist. First item: ' +
          widget.checklist.getNextUncheckedItem().speakAction() +
          '. ' +
          widget.checklist.getNextUncheckedItem().expandSpeakExpectedResult());
    } else if (widget.checklist.getNumberOfCheckedItems() ==
        widget.checklist.getNumberOfCheckableItems()) {
      // Pull the list up a bit to show no items are below the last item
      _controller.animateTo(
          _controller.position.maxScrollExtent + SCROLL_REVEAL_AMOUNT,
          duration: Duration(milliseconds: SCROLL_REVEAL_DURATION_MS),
          curve: Curves.easeInOut);
      _say(widget.checklist.title + ' checklist complete.');
    } else {
      _controller.scrollToIndex(
        widget.checklist.getNextItemUncheckedIndex(),
        duration: Duration(milliseconds: SCROLL_DURATION_MS),
        preferPosition: _position,
      );
      if (widget.checklist.getNextUncheckedItem() != null)
        _say(widget.checklist.getNextUncheckedItem().speakAction() +
            '. ' +
            widget.checklist
                .getNextUncheckedItem()
                .expandSpeakExpectedResult());
    }
  }

  void _checkItem() {
    _speechAnimationController.value = 0.0;
    widget.checklist.checkCurrentItem();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      _tts.stop();
      _say('Check.');
      _scrollToNextUncheckedIndex();
    });
  }

  void _uncheckLastItem() {
    widget.checklist.unCheckLastItem();
    widget.onChecklistItemChanged();
    setState(() {
      percentChecked = widget.checklist.getPercentChecked();
      _tts.stop();
      _say('Going back one.');
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

  void _repeatCurrentItem() {
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
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.checklist.title),
        ),
        body: Center(
          child: Column(
            children: [
//              Container(
//                color: Theme.of(context).primaryColor,
//                height: 4,
//                padding: EdgeInsets.all(0.0),
//                child: LinearProgressIndicator(
//                  value: _speechAnimation.value,
//                  //value: _speechProgress,
//                  backgroundColor: Theme.of(context).dialogBackgroundColor,
//                )),
              Container(
                  color: Theme.of(context).primaryColor,
                  height: 4,
                  padding: EdgeInsets.all(0.0),
                  child: LinearProgressIndicator(
                    value: percentChecked,
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                  )),
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
                        fontWeight: (index ==
                                widget.checklist.getNextItemUncheckedIndex())
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (item.isChecked)
                            ? Theme.of(context).disabledColor
                            : null,
                        fontSize: (index ==
                                widget.checklist.getNextItemUncheckedIndex())
                            ? 20.0
                            : null,
                      );
                      return _wrapScrollTag(
                          index: index,
                          child: Container(
                              height: (index ==
                                      widget.checklist
                                          .getNextItemUncheckedIndex())
                                  ? 100.0
                                  : null,
                              color: (item.isChecked)
                                  ? Colors.black26
                                  : ((index ==
                                          widget.checklist
                                              .getNextItemUncheckedIndex())
                                      ? Colors.white12
                                      : null),
                              child: ChecklistItemTile(
                                action: item.action,
                                expectedResult: item.expandExpectedResult(),
                                checked: item.isChecked,
                                selected: (index == widget.checklist.getNextItemUncheckedIndex()),
                              )
                          )
//                              child: Center(
//                                child: ListTile(
//                                  contentPadding: EdgeInsets.symmetric(
//                                    horizontal: 12.0, vertical: 6.0),
//                                  leading: (item.isChecked)
//                                    ? Icon(
//                                        Icons.check,
//                                        color: Colors.white30,
//                                      )
//                                    : Icon(Icons.radio_button_unchecked,
//                                        color: null),
//                                  title: Text(item.action, style: textStyle),
//                                  trailing: Text(
//                                    item.expandExpectedResult(),
//                                    style: textStyle,
//                                    textAlign: TextAlign.right,
//                                  ),
//                                  selected: (index ==
//                                      widget.checklist
//                                          .getNextItemUncheckedIndex()),
//                                  onTap: (index ==
//                                          widget.checklist
//                                              .getNextItemUncheckedIndex())
//                                      ? () {
//                                          _checkItem();
//                                        }
//                                      : null,
//                              )))
                      );
                    } else {
                      return _wrapScrollTag(
                          index: index,
                          child: Container(
                              child: ListTile(
                                  title: Text(item.action,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                  selected: false,
                                  onTap: () {})));
                    }
                  },
                  //separatorBuilder: (BuildContext context, int index) => const Divider(),
                  //separatorBuilder: (BuildContext context, int index) => Container(height: 2,),
                ),
              ),
              Container(
                  padding: EdgeInsets.all(4.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  //color: Theme.of(context).primaryColor,
                  child: (widget.checklist.next != null)
                      ? Text(
                          'Next checklist: ' + widget.checklist.next.title,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        )
                      : null),
              Container(
                color: Theme.of(context).primaryColor,
                height: 84,
                child: ListBottomButtonBar(
                  actionState: (widget.checklist.isAllChecked())
                      ? ListBottomButtonBarActionState.back
                      : ListBottomButtonBarActionState.check,
                  onUndoPressed: (widget.checklist.canUncheckLastItem())
                      ? () {
                          _uncheckLastItem();
                        }
                      : null,
                  onResetPressed: (widget.checklist.isAnyChecked())
                      ? () {
                          _say('Are you sure you want to reset the ' +
                              widget.checklist.title +
                              ' checklist?');
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Reset Checklist'),
                                  content: Text(
                                      'Are you sure you want to reset this checklist?'),
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
                                        _say('Checklist reset.');
                                        _uncheckAll();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      : null,
                  onEmergencyPressed: () {
                    _say('Emergency!');
                  },
                  onCheckPressed: (!widget.checklist.isAllChecked())
                      ? () {
                          _checkItem();
                        }
                      : () {
                          Navigator.pop(context);
                        },
                ),
              ),
              Container(
                height: 28,
              ),
            ],
          ),
        ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () { _uncheckAll(); },
//        tooltip: 'Emergency',
//        //backgroundColor: Theme.of(context).errorColor,
//        child: Icon(Icons.undo, size: 42),
//      ),
      ),
    );
  }

  Widget _wrapScrollTag({int index, Widget child}) => AutoScrollTag(
        key: ValueKey(index),
        controller: _controller,
        index: index,
        child: child,
      );

  Widget _listViewBuilder(BuildContext context, int index) {}
}

String getMinimumRaggedness(String text, {maxLines = 3}) {
  var words = text.split(RegExp("\\s+"));

  if (words.length == 1)
    return words[0];

  var cumWordWidth = List<int>();
  cumWordWidth.add(0);

  words.forEach((word) => cumWordWidth.add(cumWordWidth.last + word.length));

  var totalWidth = cumWordWidth.last + words.length - 1;
  var lineWidth = (totalWidth - (maxLines - 1)).toDouble() ~/ maxLines;

  var cost = (int i, int j) {
    var actualLineWidth = math.max(j - i - 1, 0) + (cumWordWidth[j] - cumWordWidth[i]);
    return (lineWidth - actualLineWidth.toDouble()) * (lineWidth - actualLineWidth.toDouble());
  };

  var best = List<List<Tuple2<double, int>>>();
  var tmp = List<Tuple2<double, int>>();
  best.add(tmp);
  tmp.add(Tuple2<double, int>(0.0, null));
  words.forEach((word) => tmp.add(Tuple2<double, int>(double.maxFinite, -1)));

  for (int l = 1; l < maxLines + 1; ++l) {
    tmp = List<Tuple2<double, int>>();
    best.add(tmp);
    for (int j = 0; j < words.length + 1; ++j) {
      var min = Tuple2<double, int>(best[l - 1][0].item1 + cost(0, j), 0);
      for (int k = 0; k < j + 1; ++k) {
        var loc = best[l - 1][k].item1 + cost(k, j);
        if (loc < min.item1 || (loc == min.item1 && k < min.item2))
          min = Tuple2<double, int>(loc, k);
      }
      tmp.add(min);
    }
  }

  var lines = List<String>();
  var b = words.length;

  for (int l = maxLines; l > 0; --l) {
    var a = best[l][b].item2;
    if (a == b) continue;
    lines.add(words.sublist(a, b).join(" "));
    b = a;
  }

  return lines.reversed.join("\n");
}

class ChecklistItemTile extends StatefulWidget {
  const ChecklistItemTile({Key key, this.onTap, this.selected, this.action, this.expectedResult, this.checked}) : super(key: key);

  final bool selected;
  final bool checked;
  final String action;
  final String expectedResult;
  final VoidCallback onTap;
  
  @override
  State<StatefulWidget> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  @override
  Widget build(BuildContext context) {

    final Color textColor = (widget.selected)
      ? Colors.white
      : (widget.checked) ? Theme.of(context).disabledColor : Colors.white70;

    final TextStyle textStyle = TextStyle(
//                      decoration: (item.isChecked)
//                        ? TextDecoration.lineThrough
//                        : TextDecoration.none,
      fontWeight: (widget.selected)
        ? FontWeight.bold
        : FontWeight.normal,
      color: textColor,
      fontSize: (widget.selected)
        ? 20.0
        : 16.0,
      letterSpacing: 1.0,
    );

    return Container(
      //padding: EdgeInsets.all(16.0),
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.,
        children: <Widget>[
          Container(
            width: 48,
            padding: EdgeInsets.all(16.0),
            child: (widget.checked)
              ? Icon(Icons.check, color: Colors.white30, size: 40.0,)
              : (widget.selected)
                ? Icon(Icons.forward, size: 40.0,)
                : Icon(Icons.radio_button_unchecked, color: Colors.white60, size: 40.0,),
          ),
          Container(width: 20.0,),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                //print(constraints);

                final gap = 16.0;

                final size = (TextPainter(
                  text: TextSpan(text: getMinimumRaggedness(widget.action, maxLines: 3).toUpperCase(), style: textStyle,),
                  maxLines: 3,
                  textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  textDirection: ui.TextDirection.ltr,
                )
                  ..layout(maxWidth: (constraints.maxWidth + gap) / 2))
                  .size;

                //print(getMinimumRaggedness(widget.action, maxLines: 3));

                //print('action: ' + size.toString());

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: size.width,
                      child: Container(
                        //color: Colors.white10,
                        child: Text(getMinimumRaggedness(widget.action.toUpperCase(), maxLines: 3), style: textStyle, maxLines: 3,)
                      )
                    ),
                    Container(width: gap,),
                    Expanded(flex: 4,
                      child: Container(
                        //color: Colors.white10,
                        child: Text(widget.expectedResult.toUpperCase(), style: textStyle,
                          maxLines: 4,
                          textAlign: TextAlign.right,
                        )
                      )
                    ),
                  ]
                );
              },
            ),
          ),
          Container(width: 16.0,),
        ],
      ),
    );
  }
}

