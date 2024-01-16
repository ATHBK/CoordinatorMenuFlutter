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

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RemainViewData){
      child.parentData = RemainViewData();
    }
  }

  double getIntrinsicDimension(RenderBox? firstChild, double Function(RenderBox child) mainChildSizeGetter) {
    RenderBox? child = firstChild;
    double heightOfHeader = 0;
    double maxHeight = 0;
    int index = 0;
    while (child != null) {
      final RemainViewData childParentData = child.parentData! as RemainViewData;
      final childSizeHeight = mainChildSizeGetter(child);
      print("Height child size: $childSizeHeight");
      // extent += math.max(extent, mainChildSizeGetter(child));
      if (index == 0){
        heightOfHeader = childSizeHeight;
      }
      else {
        maxHeight = childSizeHeight - heightOfHeader;
      }
      index++;
      child = childParentData.nextSibling;
    }
    return maxHeight;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    RenderBox? child = firstChild;
    while(child != null){
      final childParentData = child.parentData as RemainViewData;
      child.layout(constraints, parentUsesSize: true);
      child = childParentData.nextSibling;
    }
  }
}