import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

class CoordinatorMenuView extends MultiChildRenderObjectWidget {

  final Widget fixedView;
  final Widget extendView;
  final List<Widget> menus;
  final List<Widget> collapseMenus;
  final ScrollController scrollController;
  final EdgeInsets? paddingMenu;
  final EdgeInsets? paddingCollapseMenu;

  CoordinatorMenuView({
    super.key,
    required this.fixedView,
    required this.extendView,
    required this.menus,
    required this.scrollController,
    this.paddingMenu,
    this.paddingCollapseMenu,
    this.collapseMenus = const []
  }): super(children: [
    extendView,
    fixedView,
    ...menus,
    ...collapseMenus
  ]);

  @override
  RenderCoordinatorMenu createRenderObject(BuildContext context) {
    return RenderCoordinatorMenu(
        scrollable: scrollController,
        countMenu: menus.length * 2,
        paddingMenu: paddingMenu,
        paddingCollapseMenu: paddingCollapseMenu
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderCoordinatorMenu renderObject) {
    renderObject
      .._scrollable = scrollController
      .._paddingMenu = paddingMenu
      .._paddingCollapseMenu = paddingCollapseMenu
      ..countMenu = menus.length * 2;
  }
}

class CoordinatorMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderCoordinatorMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, CoordinatorMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, CoordinatorMenuData>{

  RenderCoordinatorMenu({
    required ScrollController scrollable,
    required int countMenu,
    EdgeInsets? paddingMenu,
    EdgeInsets? paddingCollapseMenu
  }): _scrollable = scrollable,
      _paddingMenu = paddingMenu,
      _countMenu = countMenu;

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

  EdgeInsets? _paddingMenu;
  EdgeInsets? get paddingMenu => _paddingMenu;
  set paddingMenu(EdgeInsets? value){
    if (value != _paddingMenu){
      _paddingMenu = value;
      markNeedsLayout();
    }
  }

  EdgeInsets? _paddingCollapseMenu;
  EdgeInsets? get paddingCollapseMenu => _paddingCollapseMenu;
  set paddingCollapseMenu(EdgeInsets? value){
    if (value != _paddingCollapseMenu){
      _paddingCollapseMenu = value;
      markNeedsLayout();
    }
  }

  int _countMenu;
  int get countMenu => _countMenu;
  set countMenu(int value){
    if (value != _countMenu){
      _countMenu = value;
      markNeedsLayout();
    }
  }

  double _positionCoordinatorView = 0;
  List<double> _menuDestinationPositionX = [];

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
  double computeMinIntrinsicWidth(double height) {
    return constraints.smallest.width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return constraints.biggest.width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicHeight(width);
  }

  double _getIntrinsicHeight(double width){
    RenderBox? child = firstChild;
    double height = 0;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as CoordinatorMenuData;
      if (index < 2){
        height += child.getMaxIntrinsicHeight(width);
        child = childParentData.nextSibling;
        index++;
      }
      else {
        child = null;
      }
    }
    return height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild
    );
  }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}){
    if (childCount == 0){
      return (constraints.biggest.isFinite) ? constraints.biggest : constraints.smallest;
    }
    double width = constraints.minWidth;
    double height = constraints.minHeight;
    double maxHeight = 0;
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as CoordinatorMenuData;
      if (index < 2) {
        final Size childSize = layoutChild(child, constraints);
        maxHeight += childSize.height;
        height = math.max(height, maxHeight);
      }
      index++;
      child = childParentData.nextSibling;
    }
    return Size(width, height);
  }

  @override
  void performLayout() {
    size = _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.layoutChild,
    );
    RenderBox? child = firstChild;
    int index = 0;
    final totalMenu = childCount - 2;
    final part = constraints.maxWidth / totalMenu;
    while(child != null){
      final childParentData = child.parentData! as CoordinatorMenuData;
      child.layout(constraints, parentUsesSize: true);
      //  set extendView
      if(index == 0){
        _positionCoordinatorView = child.size.height;
        childParentData.offset = Offset.zero;
      }
      // set fixView
      else if (index == 1){
        childParentData.offset = Offset.zero;
      }
      // set menu view
      else {
        final x = part * (index - 2) + part / 4;
        final y = size.height - 16 - child.size.height;
        childParentData.offset = Offset(x, y);
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
        // do not draw extend View
      }
      else if (index == 1) {
        context.paintChild(child, offset + childParentData.offset);
      }
      else {
        final scrollDy = scrollable.offset;
        final fraction = scrollDy / _positionCoordinatorView;
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

    List<double> _computeDestinationPosition(Size size, EdgeInsets? padding, double widthChild){
      final edgeInset = padding ?? EdgeInsets.zero;
      final maxWidthOfView = size.width - edgeInset.left - edgeInset.right;
      return List.generate(_countMenu ~/ 2, (index) {
        edgeInset.left + index * widthChild
      });
    }
}