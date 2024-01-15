import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class RemainView extends MultiChildRenderObjectWidget {

  final Widget headerView;
  final Widget background;
  final double functionViewPaddingTop;

  RemainView({
    super.key,
    required this.headerView,
    required this.background,
    required this.functionViewPaddingTop,
  }): super(
      children: [
        headerView,
        background,
      ]
  );

  @override
  RenderRemainView createRenderObject(BuildContext context) {
    return RenderRemainView(functionPaddingTop: functionViewPaddingTop);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderRemainView renderObject) {
    renderObject._functionPaddingTop = functionViewPaddingTop;
  }
}

class RemainViewData extends ContainerBoxParentData<RenderBox> {}

class RenderRemainView extends RenderBox with ContainerRenderObjectMixin<RenderBox, RemainViewData>,
    RenderBoxContainerDefaultsMixin<RenderBox, RemainViewData> {

  RenderRemainView({
    required double functionPaddingTop,
  }): _functionPaddingTop = functionPaddingTop;

  double _functionPaddingTop;
  double get functionPaddingTop => _functionPaddingTop;
  set functionPaddingTop(double value){
    if (value != functionPaddingTop){
      functionPaddingTop = value;
      markNeedsLayout();
    }
  }

  double _heightMenu = 0;
  double _heightFixedView = 0;
  double _heightMiddleView = 0;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RemainViewData){
      child.parentData = RemainViewData();
    }
  }

  // static double getIntrinsicDimension(RenderBox? firstChild, double Function(RenderBox child) mainChildSizeGetter) {
  //   RenderBox? child = firstChild;
  //   double heightOfBg = 0;
  //   double heightMenu = 0;
  //   double heightFixedView = 0;
  //   double maxHeight = 0;
  //   int index = 0;
  //   while (child != null) {
  //     final RemainViewData childParentData = child.parentData! as RemainViewData;
  //     final childSizeHeight = mainChildSizeGetter(child);
  //     print("Height child size: $childSizeHeight");
  //     // extent += math.max(extent, mainChildSizeGetter(child));
  //     if (index == 0){
  //       heightOfBg = childSizeHeight;
  //     }
  //     else {
  //       // height of fixed view
  //       if (index == 1){
  //         heightFixedView = childSizeHeight;
  //         maxHeight += heightFixedView;
  //       }
  //       // height of first menu
  //       else if (index == 2){
  //         heightMenu = childSizeHeight;
  //         maxHeight += heightMenu;
  //       }
  //       // check bgMenu exist
  //       // background menu
  //       else if (index == 3 && childSizeHeight > 0){
  //         maxHeight = maxHeight - heightMenu;
  //         heightMenu = childSizeHeight;
  //         print("Height Menu: ${childSizeHeight}");
  //         maxHeight += heightMenu;
  //       }
  //       // middle view
  //       else if (index == 4){
  //         maxHeight += childSizeHeight;
  //       }
  //     }
  //     index++;
  //     child = childParentData.nextSibling;
  //   }
  //   return math.max(heightOfBg, maxHeight);
  // }
  //
  // @override
  // double computeMinIntrinsicWidth(double height) {
  //   return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicWidth(height));
  // }
  //
  // @override
  // double computeMaxIntrinsicWidth(double height) {
  //   return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicWidth(height));
  // }
  //
  // @override
  // double computeMinIntrinsicHeight(double width) {
  //   return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicHeight(width));
  // }
  //
  // @override
  // double computeMaxIntrinsicHeight(double width) {
  //   return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicHeight(width));
  // }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}){
    if (childCount == 0){
      return (constraints.biggest.isFinite) ? constraints.biggest : constraints.smallest;
    }
    double width = constraints.maxWidth;
    double height = constraints.minHeight;
    double heightOfHeader = 0;
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as RemainViewData;
      final Size childSize = layoutChild(child, constraints);
      // header view
      if (index == 0){
        heightOfHeader = childSize.height;
      }
      else {
        // height of fixed view
        height = childSize.height - heightOfHeader - _functionPaddingTop;
      }
      index++;
      child = childParentData.nextSibling;
    }
    return Size(width, height);
  }

  @override
  void performLayout() {
    size = _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.dryLayoutChild);
    RenderBox? child = firstChild;
    while(child != null){
      final childParentData = child.parentData as RemainViewData;
      child.layout(constraints, parentUsesSize: true);
      child = childParentData.nextSibling;
    }
  }
}