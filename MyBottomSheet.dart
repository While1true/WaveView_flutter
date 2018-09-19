
//
// Created by ckckck on 2018/9/19.
//

import 'dart:async';

import 'package:flutter/material.dart';

const Duration _kBottomSheetDuration = Duration(milliseconds: 200);
const double _kMinFlingVelocity = 700.0;
const double _kCloseProgressThreshold = 0.5;
Color bgColor=Colors.transparent;
Future<T> showMyBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  bool barrierDismissible = false,
  bool enableDrag = true,
  Color bgcolor=Colors.white,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) {
  assert(context != null);
  assert(builder != null);
  bgColor=bgcolor;
  return Navigator.push(
      context,
      new _ModalBottomSheetRoute<T>(
        builder: builder,
        theme: Theme.of(context, shadowThemeOnly: true),
        barrierDismissiblex: barrierDismissible,
        enableDrag: enableDrag,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));
}

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    this.barrierDismissiblex = true,
    this.enableDrag = true,
    RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;
  final bool barrierDismissiblex;
  final bool enableDrag;

  @override
  Duration get transitionDuration => _kBottomSheetDuration;

  @override
  bool get barrierDismissible => barrierDismissiblex;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: new _ModalBottomSheet<T>(
        route: this,
        enableDrag: enableDrag,
      ),
    );
    if (theme != null) bottomSheet = new Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet(
      {Key key,
      this.route,
      this.enableDrag = true,
      })
      : super(key: key);

  final _ModalBottomSheetRoute<T> route;
  final bool enableDrag;

  @override
  _ModalBottomSheetState<T> createState() => new _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () => Navigator.pop(context),
        child: new AnimatedBuilder(
            animation: widget.route.animation,
            builder: (BuildContext context, Widget child) {
              return new ClipRect(
                  child: new CustomSingleChildLayout(
                      delegate: new _ModalBottomSheetLayout(
                          widget.route.animation.value),

                        child: new BottomSheet(
                            enableDrag: widget.enableDrag,
                            animationController:
                                widget.route._animationController,
                            onClosing: () => Navigator.pop(context),
                            builder: widget.route.builder),
                      ));
            }));
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight * 9.0 / 16.0);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return new Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
class BottomSheet extends StatefulWidget {
  /// Creates a bottom sheet.
  ///
  /// Typically, bottom sheets are created implicitly by
  /// [ScaffoldState.showBottomSheet], for persistent bottom sheets, or by
  /// [showModalBottomSheet], for modal bottom sheets.
  const BottomSheet({
    Key key,
    this.animationController,
    this.enableDrag = true,
    @required this.onClosing,
    @required this.builder
  }) : assert(enableDrag != null),
        assert(onClosing != null),
        assert(builder != null),
        super(key: key);

  /// The animation that controls the bottom sheet's position.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController animationController;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// If true, the bottom sheet can dragged up and down and dismissed by swiping
  /// downards.
  ///
  /// Default is true.
  final bool enableDrag;

  @override
  _BottomSheetState createState() => new _BottomSheetState();

  /// Creates an animation controller suitable for controlling a [BottomSheet].
  static AnimationController createAnimationController(TickerProvider vsync) {
    return new AnimationController(
      duration: _kBottomSheetDuration,
      debugLabel: 'BottomSheet',
      vsync: vsync,
    );
  }
}

class _BottomSheetState extends State<BottomSheet> {

  final GlobalKey _childKey = new GlobalKey(debugLabel: 'BottomSheet child');

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  bool get _dismissUnderway => widget.animationController.status == AnimationStatus.reverse;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dismissUnderway)
      return;
    widget.animationController.value -= details.primaryDelta / (_childHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dismissUnderway)
      return;
    if (details.velocity.pixelsPerSecond.dy > _kMinFlingVelocity) {
      final double flingVelocity = -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController.value > 0.0)
        widget.animationController.fling(velocity: flingVelocity);
      if (flingVelocity < 0.0)
        widget.onClosing();
    } else if (widget.animationController.value < _kCloseProgressThreshold) {
      if (widget.animationController.value > 0.0)
        widget.animationController.fling(velocity: -1.0);
      widget.onClosing();
    } else {
      widget.animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget bottomSheet = new Material(color:bgColor,
      key: _childKey,
      child: widget.builder(context),
    );
    return !widget.enableDrag ? bottomSheet : new GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: bottomSheet,
    );
  }
}