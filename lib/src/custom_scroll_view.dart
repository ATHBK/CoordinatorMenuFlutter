import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CoordinatorMenuView extends MultiChildRenderObjectWidget {

  final Widget fixedView;
  final Widget extendView;
  final List<Widget> menus;

  CoordinatorMenuView({
    super.key,
    required this.fixedView,
    required this.extendView,
    required this.menus
  }): super(children: [
    extendView,
    fixedView,
    ...menus
  ]);

  @override
  RenderCoordinatorMenu createRenderObject(BuildContext context) {
    return RenderCoordinatorMenu();
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    // TODO: implement updateRenderObject
    super.updateRenderObject(context, renderObject);
  }
}

class CoordinatorMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderCoordinatorMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, CoordinatorMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, CoordinatorMenuData>{

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CoordinatorMenuData){
      child.parentData = CoordinatorMenuData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final maxWidth = constraints.maxWidth;
    double maxHeight = 0;
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null) {
      final CoordinatorMenuData childParentData = child.parentData! as CoordinatorMenuData;
      child.layout(constraints, parentUsesSize: true);
      final heightOfChildView = child.size.height;
      print("size: ${heightOfChildView}");
      if (index < 2){
        maxHeight += heightOfChildView;
      }
      index++;
      child = childParentData.nextSibling;
    }
    print("MaxHeight: $maxHeight");
    size = Size(maxWidth, maxHeight);
    child = firstChild;
    index = 0;
    final totalMenu = childCount - 2;
    final part = maxWidth / totalMenu;
    int indexMenu = 0;
    while(child != null){
      final CoordinatorMenuData childParentData = child.parentData! as CoordinatorMenuData;
      // fixedView
      if (index == 0){
        childParentData.offset = Offset.zero;
      }
      // extendView
      else if (index == 1){
        // childParentData.offset = Offset(0, heightOfFixedView);
        childParentData.offset = Offset(0, 80);
      }
      // menus
      else {
        final x = part * indexMenu + part / 4;
        final y = size.height + 80;
        childParentData.offset = Offset(x, y);
        print("x: $x, y: $y");
        indexMenu++;
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
      final childParentData = child.parentData as CoordinatorMenuData;
      if (index > 0) {
        context.paintChild(child, childParentData.offset);
        print("Offset: ${childParentData.offset}, ${child.size}");
      }
      index++;
      child = childParentData.nextSibling;
    }
    // final canvas = context.canvas;
    // canvas.save();
    // canvas.translate(offset.dx, offset.dy);
    // // paint bar
    // final barPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeWidth = 100;
    // final point1 = Offset(0, 60);
    // final point2 = Offset(size.width, 50);
    // canvas.drawLine(point1, point2, barPaint);
    // canvas.restore();
  }
}