import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class ExtraViewRemain extends MultiChildRenderObjectWidget {

  final Widget fixedView;
  final Widget? middleView;
  final Widget background;
  final Widget? backgroundMenu;
  final Widget firstMenu;
  final EdgeInsets paddingMenu;

  ExtraViewRemain({
    super.key,
    required this.background,
    required this.fixedView,
    required this.firstMenu,
    this.backgroundMenu,
    this.middleView,
    this.paddingMenu = EdgeInsets.zero
  }): super(
      children: [
        background,
        fixedView,
        firstMenu,
        backgroundMenu ?? const SizedBox.shrink(),
        middleView ?? const SizedBox.shrink()
      ]
  );

  @override
  RenderExtraViewRemain createRenderObject(BuildContext context) {
    return RenderExtraViewRemain(paddingMenu: paddingMenu);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderExtraViewRemain renderObject) {
    renderObject._paddingMenu = paddingMenu;
  }
}

class ExtraViewRemainData extends ContainerBoxParentData<RenderBox> {}

class RenderExtraViewRemain extends RenderBox with ContainerRenderObjectMixin<RenderBox, ExtraViewRemainData>,
    RenderBoxContainerDefaultsMixin<RenderBox, ExtraViewRemainData> {

  RenderExtraViewRemain({
    EdgeInsets paddingMenu = EdgeInsets.zero,
  }): _paddingMenu = paddingMenu;

  EdgeInsets _paddingMenu;
  EdgeInsets get paddingMenu => _paddingMenu;
  set paddingMenu(EdgeInsets value){
    if (value != _paddingMenu){
      _paddingMenu = value;
      markNeedsLayout();
    }
  }

  double _heightMenu = 0;
  double _heightFixedView = 0;
  double _heightMiddleView = 0;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ExtraViewRemainData){
      child.parentData = ExtraViewRemainData();
    }
  }

  static double getIntrinsicDimension(RenderBox? firstChild, double Function(RenderBox child) mainChildSizeGetter) {
    RenderBox? child = firstChild;
    double heightOfBg = 0;
    double heightMenu = 0;
    double heightFixedView = 0;
    double maxHeight = 0;
    int index = 0;
    while (child != null) {
      final ExtraViewRemainData childParentData = child.parentData! as ExtraViewRemainData;
      final childSizeHeight = mainChildSizeGetter(child);
      print("Height child size: $childSizeHeight");
      // extent += math.max(extent, mainChildSizeGetter(child));
      if (index == 0){
        heightOfBg = childSizeHeight;
      }
      else {
        // height of fixed view
        if (index == 1){
          heightFixedView = childSizeHeight;
          maxHeight += heightFixedView;
        }
        // height of first menu
        else if (index == 2){
          heightMenu = childSizeHeight;
          maxHeight += heightMenu;
        }
        // check bgMenu exist
        // background menu
        else if (index == 3 && childSizeHeight > 0){
          maxHeight = maxHeight - heightMenu;
          heightMenu = childSizeHeight;
          print("Height Menu: ${childSizeHeight}");
          maxHeight += heightMenu;
        }
        // middle view
        else if (index == 4){
          maxHeight += childSizeHeight;
        }
      }
      index++;
      child = childParentData.nextSibling;
    }
    return math.max(heightOfBg, maxHeight);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}){
    if (childCount == 0){
      return (constraints.biggest.isFinite) ? constraints.biggest : constraints.smallest;
    }
    double width = constraints.maxWidth;
    double height = constraints.minHeight;
    double heightOfBg = 0;
    double maxHeight = 0;
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as ExtraViewRemainData;
      final Size childSize = layoutChild(child, constraints);
      // bg
      if (index == 0){
        heightOfBg = childSize.height;
      }
      else {
        // height of fixed view
        if (index == 1){
          _heightFixedView = childSize.height;
          maxHeight += _heightFixedView;
        }
        // height of first menu
        else if (index == 2){
          _heightMenu = childSize.height + _paddingMenu.top + _paddingMenu.bottom;
          maxHeight += _heightMenu;
        }
        // check bgMenu exist
        // background menu
        else if (index == 3 && childSize.height > 0){
          maxHeight = maxHeight - _heightMenu;
          _heightMenu = childSize.height;
          print("Height Menu: ${_heightMenu}");
          maxHeight += _heightMenu;
        }
        // middle view
        else if (index == 4){
          _heightMiddleView = childSize.height;
          maxHeight += _heightMiddleView;
        }
      }
      index++;
      child = childParentData.nextSibling;
    }
    print("Height Menu 1: ${heightOfBg}, $maxHeight");

    height = math.max(heightOfBg, maxHeight);
    return Size(width, height);
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    // size = _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.dryLayoutChild);
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData as ExtraViewRemainData;
      // middle view
      if (index == 4 && _heightMiddleView > 0){
        child.layout(constraints, parentUsesSize: true);
        final remainView = size.height - _heightFixedView - _heightMenu;
        childParentData.offset = Offset(0, (remainView - _heightMiddleView)/2);
      }
      else {
        child.layout(constraints, parentUsesSize: true);
        childParentData.offset = Offset.zero;
      }
      index++;
      child = childParentData.nextSibling;
    }
  }
}

class SliverFillRemainNeedToScroll extends StatelessWidget {

  final Widget? child;
  final Color? color;

  const SliverFillRemainNeedToScroll({
    super.key,
    this.child,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return _SliverFillRemainNeedToScrollable(color: color, child: child,);
  }
}

class _SliverFillRemainNeedToScrollable extends SingleChildRenderObjectWidget {

  final Color? color;

  const _SliverFillRemainNeedToScrollable({
    super.child,
    this.color
  });

  @override
  _RenderSliverRemainNeedToScroll createRenderObject(BuildContext context) {
    return _RenderSliverRemainNeedToScroll(color: color);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderSliverRemainNeedToScroll renderObject) {
    renderObject.setColor = color;
  }
}

class _RenderSliverRemainNeedToScroll extends RenderSliverSingleBoxAdapter {

  _RenderSliverRemainNeedToScroll({
    Color? color
  }): _color = color;

  Color? _color;
  Color? get color => _color;
  set setColor(Color? color){
    if (color != _color){
      _color = color;
      markNeedsPaint();
    }
  }

  double _sizeWidth = 1000;
  double _sizeHeight = 0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    // The remaining space in the viewportMainAxisExtent. Can be <= 0 if we have
    // scrolled beyond the extent of the screen.
    double extent = constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;
    // print("SliverConstaints 1 : $constraints");
    // print("SliverConstaints 2: ${constraints.precedingScrollExtent}");
    // print("SliverConstaints 3: ${constraints.viewportMainAxisExtent}");
    if (child != null) {
      final double childExtent;
      switch (constraints.axis) {
        case Axis.horizontal:
          childExtent = child!.getMaxIntrinsicWidth(constraints.crossAxisExtent);
        case Axis.vertical:
          childExtent = child!.getMaxIntrinsicHeight(constraints.crossAxisExtent);
          print("childExtend: $childExtent");
      }

      // If the childExtent is greater than the computed extent, we want to use
      // that instead of potentially cutting off the child. This allows us to
      // safely specify a maxExtent.
      if (extent >= 0) {
        extent = extent + childExtent;
      }
      else if (extent.abs() < childExtent){
        extent = childExtent;
      }
      else {
        extent = 0;
      }
      _sizeHeight = extent;
      child!.layout(constraints.asBoxConstraints(minExtent: extent, maxExtent: extent), parentUsesSize: true);
    }

    assert(extent.isFinite,
    'The calculated extent for the child of SliverFillRemaining is not finite. '
        'This can happen if the child is a scrollable, in which case, the '
        'hasScrollBody property of SliverFillRemaining should not be set to '
        'false.',
    );
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: extent);
    print("paintedChildSize: ${paintedChildSize}, $_sizeHeight");
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintedChildSize,
      maxPaintExtent: paintedChildSize,
      hasVisualOverflow: extent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    if (child != null) {
      setChildParentData(child!, constraints, geometry!);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(Rect.fromLTRB(0, 0, _sizeWidth, _sizeHeight), Paint()..color = _color ?? Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 1);
    canvas.restore();
  }
}