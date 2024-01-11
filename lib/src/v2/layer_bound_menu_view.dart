import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_coordinator_menu/src/coordinator_view.dart';

class LayerBoundMenuView extends MultiChildRenderObjectWidget {

  final Widget background;
  final Widget backgroundMenu;

  LayerBoundMenuView({
    super.key,
    required this.background,
    required this.backgroundMenu
  }): super(
    children: [
      background,
      backgroundMenu
    ]
  );

  @override
  RenderLayoutBoundMenu createRenderObject(BuildContext context) {
    return RenderLayoutBoundMenu();
  }

}

class LayoutBoundMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderLayoutBoundMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, LayoutBoundMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, LayoutBoundMenuData> {

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! LayoutBoundMenuData){
      child.parentData = LayoutBoundMenuData();
    }
  }

  @override
  void performLayout() {
    size = _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.layoutChild);
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as LayoutBoundMenuData;
      child.layout(constraints, parentUsesSize: true);
      // background
      if (index == 0){
        childParentData.offset = Offset.zero;
      }
      // bg menu
      else {
        childParentData.offset = Offset(0, size.height - child.size.height);
      }
      child = childParentData.nextSibling;
      index++;
    }

  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as LayoutBoundMenuData;
      if (index == 1){
        context.paintChild(child, offset + childParentData.offset);
      }
      child = childParentData.nextSibling;
      index++;
    }
  }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}){
    double width = constraints.maxWidth;
    double height = constraints.minHeight;
    RenderBox? child = firstChild;
    if(child != null){
      final Size childSize = layoutChild(child, constraints);
      return Size(width, childSize.height);
    }
    return Size(width, height);
  }
}