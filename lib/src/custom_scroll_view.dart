import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

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
  final listPositionDesX = [30, 90, 160, 220];

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CoordinatorMenuData){
      child.parentData = CoordinatorMenuData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(100, 100);
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final maxWidth = constraints.maxWidth;
    double maxHeight = 0;
    double heightOfChild = 0;
    RenderBox? child = firstChild;
    int index = 0;
    double fraction = 1;
    if (heightExpandView > 0){
      final scrollDy = scrollable.offset;
      fraction = scrollDy / heightExpandView;
    }
    while(child != null) {
      final CoordinatorMenuData childParentData = child.parentData! as CoordinatorMenuData;
      if (child.hasSize && index >= 2){
        print("Child da co size");
        final maxWidth = 50 - 20 * fraction;
        final maxHeight = 50 - 20 * fraction;
        child.layout(BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight), parentUsesSize: true);
      }
      else {
        child.layout(constraints, parentUsesSize: true);
      }
      final heightOfChildView = child.size.height;
      heightOfChild = heightOfChildView;
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
        childParentData.offset = Offset.zero;
      }
      // menus
      else {
        final x = part * indexMenu + part / 4;
        final y = size.height - 16 - heightOfChild;
        childParentData.offset = Offset(x, y);
        // print("x: $x, y: $y");
        indexMenu++;
      }
      index++;
      child = childParentData.nextSibling;
    }
  }

  // @override
  // Size computeDryLayout(BoxConstraints constraints) {
  //   final BoxConstraints constraints = this.constraints;
  //   final maxWidth = constraints.maxWidth;
  //   double maxHeight = 0;
  //   double heightOfChild = 0;
  //   RenderBox? child = firstChild;
  //   int index = 0;
  //   while(child != null) {
  //     final CoordinatorMenuData childParentData = child.parentData! as CoordinatorMenuData;
  //     if (child.hasSize){
  //       final scrollDy = scrollable.offset;
  //       final fraction = scrollDy / heightExpandView;
  //       final size = 50 - fraction * 20;
  //       child.layout(BoxConstraints(maxHeight: size, maxWidth: size));
  //     }
  //     else {
  //       child.layout(constraints, parentUsesSize: true);
  //     }
  //     final heightOfChildView = child.size.height;
  //     heightOfChild = heightOfChildView;
  //     if(index == 0){
  //       heightExpandView = heightOfChildView;
  //     }
  //     // print("size: ${heightOfChildView}");
  //     if (index < 2){
  //       maxHeight += heightOfChildView;
  //     }
  //     index++;
  //     child = childParentData.nextSibling;
  //   }
  // }

  @override
  void performResize() {
    super.performResize();
    // RenderBox? child = firstChild;
    // int index = 0;
    // double maxHeight = 0;
    // final scrollDy = scrollable.offset;
    // final fraction = scrollDy / heightExpandView;
    // while(child != null) {
    //   final CoordinatorMenuData childParentData = child.parentData! as CoordinatorMenuData;
    //   child.layout(constraints, parentUsesSize: true);
    //   final heightOfChildView = child.size.height;
    //   index++;
    //   child = childParentData.nextSibling;
    // }
    print("resize");
  }

  // @override
  // OffsetLayer updateCompositedLayer({covariant required OffsetLayer? oldLayer}) {
  //   // TODO: implement updateCompositedLayer
  //   return super.updateCompositedLayer(oldLayer);
  // }


  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData as CoordinatorMenuData;
      if (index == 0){

      }
      else if (index == 1) {
        context.paintChild(child, offset + childParentData.offset);
        // print("Offset: ${childParentData.offset}, ${child.size}");
      }
      else {
        final scrollDy = scrollable.offset;
        final fraction = scrollDy / heightExpandView;
        final originOffset = childParentData.offset;
        final distanceX = originOffset.dx - listPositionDesX[index - 2];
        final distanceY = originOffset.dy - 34;
        if (fraction <= 1) {
          void painter(PaintingContext context, Offset offset) {
            context.paintChild(child!, offset);
          }

          final newDx = originOffset.dx - distanceX * fraction;
          final newDy = originOffset.dy - distanceY * fraction;
          final newOffset = offset + Offset(newDx, newDy);
          // context.paintChild(child, newOffset);
          if (fraction == 1.0) {
            context.pushTransform(needsCompositing, newOffset, Matrix4.identity(), painter);
          } else {
            context.pushOpacity(newOffset, ui.Color.getAlphaFromOpacity(1 - fraction), (PaintingContext context, Offset offset) {
              context.pushTransform(needsCompositing, offset, Matrix4.identity(), painter);
            });
          }
        }
        else {
          final newOffset = offset + Offset(listPositionDesX[index - 2].toDouble(), 34);
          context.paintChild(child, newOffset);
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