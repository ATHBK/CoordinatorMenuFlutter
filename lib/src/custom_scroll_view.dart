import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CoordinatorMenuView extends MultiChildRenderObjectWidget {

  final Widget fixedView;
  final Widget extendView;
  final List<Widget> menus;
  final ScrollController scrollController;

  CoordinatorMenuView({
    super.key,
    required this.fixedView,
    required this.extendView,
    required this.menus,
    required this.scrollController
  }): super(children: [
    extendView,
    fixedView,
    ...menus
  ]);

  @override
  RenderCoordinatorMenu createRenderObject(BuildContext context) {
    return RenderCoordinatorMenu(scrollable: scrollController);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderCoordinatorMenu renderObject) {
    renderObject._scrollable = scrollController;
  }
}

class CoordinatorMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderCoordinatorMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, CoordinatorMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, CoordinatorMenuData>{

  RenderCoordinatorMenu({
    required ScrollController scrollable
  }): _scrollable = scrollable;

  ScrollController _scrollable;

  ScrollController get scrollable => _scrollable;

  set scrollable(ScrollController value){
    if (value != _scrollable){
      if (attached){
        _scrollable.position.removeListener(markNeedsPaint);
      }
      _scrollable = value;
      if (attached){
        _scrollable.position.addListener(markNeedsPaint);
      }
    }
  }

  double heightExpandView = 0;
  final listPositionDesX = [50, 150, 250, 350];

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CoordinatorMenuData){
      child.parentData = CoordinatorMenuData();
    }
  }

  @override
  void performLayout() {
    print("performLayout");
    
    final BoxConstraints constraints = this.constraints;
    final maxWidth = constraints.maxWidth;
    double maxHeight = 0;
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null) {
      final CoordinatorMenuData childParentData = child.parentData! as CoordinatorMenuData;
      child.layout(constraints, parentUsesSize: true);
      final heightOfChildView = child.size.height;
      if(index == 0){
        heightExpandView = heightOfChildView;
      }
      // print("size: ${heightOfChildView}");
      if (index < 2){
        maxHeight += heightOfChildView;
      }
      index++;
      child = childParentData.nextSibling;
    }
    // print("MaxHeight: $maxHeight");
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
        // print("x: $x, y: $y");
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
      if (index == 0){

      }
      else if (index == 1) {
        context.paintChild(child, childParentData.offset);
        // print("Offset: ${childParentData.offset}, ${child.size}");
      }
      else {
        final scrollDy = scrollable.offset;
        final fraction = scrollDy / heightExpandView;
        final originOffset = childParentData.offset;
        final distanceX = originOffset.dx - listPositionDesX[index - 2];
        final distanceY = originOffset.dy - 50.0;
        if (fraction <= 1) {
          final newDx = originOffset.dx - distanceX * fraction;
          final newDy = originOffset.dy - distanceY * fraction;
          context.paintChild(child, Offset(newDx, newDy));
        }
        else {
          context.paintChild(child, Offset(listPositionDesX[index - 2].toDouble(), 50));
        }
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

  void cal(){
    // Get the size of the scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    print("ViewPortDimension: $viewportDimension");
    // Calculate the global position of this list item.
    // final scrollableBox = scrollable.position.context.notificationContext?.findRenderObject() as RenderBox;
    // final backgroundOffset =
    // localToGlobal(size.centerLeft(Offset.zero), ancestor: scrollableBox);
    print("Scroll Offset: ${scrollable.offset}");
    // final scrollFraction =
    // (backgroundOffset.dy / viewportDimension).clamp(0.0, 1.0);
  }
}