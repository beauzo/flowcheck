import 'package:flutter/material.dart';

enum ListBottomButtonBarActionState { check, back, forward }

class ListBottomButtonBar extends StatefulWidget {
  final ListBottomButtonBarActionState actionState;
  final VoidCallback onUndoPressed;
  final VoidCallback onResetPressed;
  final VoidCallback onEmergencyPressed;
  final VoidCallback onCheckPressed;
  final VoidCallback onCheckLongPress;

  const ListBottomButtonBar(
    {Key key,
      this.actionState,
      this.onUndoPressed,
      this.onResetPressed,
      this.onEmergencyPressed,
      this.onCheckPressed,
      this.onCheckLongPress})
    : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListBottomButtonBarState();
}

class _ListBottomButtonBarState extends State<ListBottomButtonBar> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _animation;

  static const FLASH_DURATION_MS = 150;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: FLASH_DURATION_MS),
    );

    _animation = ColorTween(begin: Colors.lightGreenAccent, end: Colors.green[1000]).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _flashNextButton(4);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flashNextButton(int times) {
    if (mounted) {
      TickerFuture tickerFuture = _controller.repeat(reverse: true);
      tickerFuture.timeout(Duration(milliseconds: FLASH_DURATION_MS * times * 2), onTimeout: () {
        if (mounted) {
          _controller.forward(from: 0);
          _controller.stop(canceled: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const buttonPadding = EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0);
    var actionIcon = _getActionIcon();
    return Container(
      color: Theme.of(context).primaryColor,
      height: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: buttonPadding,
              child: FlatButton(
                child: Text('EMERG'),
                color: Theme.of(context).errorColor,
                onPressed: widget.onEmergencyPressed,
              ))),
          Expanded(
            child: Container(
              padding: buttonPadding,
              child: FlatButton(
                child: Text('RESET'),
                onPressed: widget.onResetPressed,
              ))),
          Expanded(
            child: Container(
              padding: buttonPadding,
              child: FlatButton(
                child: Text('UNDO'),
                onPressed: widget.onUndoPressed,
              ))),
          Expanded(
            child: Container(
              padding: buttonPadding,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) => FlatButton(
                  child: actionIcon,
                  //color: Colors.lightGreenAccent,
                  color: _animation.value,
                  //(widget.checklist.isAllChecked()) ? Colors.lightGreenAccent : Colors.white10,
                  onPressed: () {
                    _flashNextButton(1);
                    widget.onCheckPressed();
                  },
                  onLongPress: widget.onCheckLongPress,
                ))))
        ],
      ),
    );
  }

  Icon _getActionIcon() {
    const iconSize = 32.0;
    if (widget.actionState == ListBottomButtonBarActionState.check) {
      return Icon(Icons.check, color: Colors.black, size: iconSize);
    } else if (widget.actionState == ListBottomButtonBarActionState.forward) {
      return Icon(Icons.navigate_next, color: Colors.black, size: iconSize);
    } else {
      return Icon(Icons.navigate_before, color: Colors.black, size: iconSize);
    }
  }
}
