import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class ExtraViewInScrollView extends MultiChildRenderObjectWidget {

  final Widget fixedView;
  final Widget? middleView;
  final Widget background;
  final Widget? backgroundMenu;
  final Widget firstMenu;
  final EdgeInsets paddingMenu;

  ExtraViewInScrollView({
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
  RenderExtraViewInScrollView createRenderObject(BuildContext context) {
    return RenderExtraViewInScrollView(paddingMenu: paddingMenu);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderExtraViewInScrollView renderObject) {
    renderObject._paddingMenu = paddingMenu;
  }
}

class ExtraViewInScrollData extends ContainerBoxParentData<RenderBox> {}

class RenderExtraViewInScrollView extends RenderBox with ContainerRenderObjectMixin<RenderBox, ExtraViewInScrollData>,
RenderBoxContainerDefaultsMixin<RenderBox, ExtraViewInScrollData> {

  RenderExtraViewInScrollView({
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
    if (child.parentData is! ExtraViewInScrollData){
      child.parentData = ExtraViewInScrollData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return constraints.smallest.width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return constraints.biggest.width;
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
      final childParentData = child.parentData! as ExtraViewInScrollData;
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
    print("Height Menu: ${heightOfBg}, $maxHeight");
    height = math.max(height, math.max(heightOfBg, maxHeight));
    return Size(width, height);
  }

  @override
  void performLayout() {
    size = _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild
    );
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData as ExtraViewInScrollData;
      // middle view
      if (index == 4 && _heightMiddleView > 0){
        child.layout(constraints, parentUsesSize: true);
        childParentData.offset = Offset(0, _heightFixedView);
      }
      else {
        child.layout(constraints, parentUsesSize: true);
        childParentData.offset = Offset.zero;
      }
      index++;
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData as ExtraViewInScrollData;
      // draw middle view if exist
      if (index == 4 && _heightMiddleView > 0){
        context.paintChild(child, offset + childParentData.offset);
        print("draw child middle view");
      }
      index++;
      child = childParentData.nextSibling;
    }
  }
}