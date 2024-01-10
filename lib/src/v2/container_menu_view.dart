import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

class ContainerMenuView extends MultiChildRenderObjectWidget {

  final Widget background;
  final List<Widget> listMenu;
  final List<Widget> listTitle;
  final EdgeInsets? paddingTitle;
  final EdgeInsets? paddingMenu;

  ContainerMenuView({
    super.key,
    required this.background,
    required this.listMenu,
    required this.listTitle,
    this.paddingTitle,
    this.paddingMenu
  }): super(
    children: [
      background,
      listMenu.first,
      ...listTitle,
    ]
  );

  @override
  RenderContainerMenu createRenderObject(BuildContext context) {
    return RenderContainerMenu(
      paddingMenu: paddingMenu ?? EdgeInsets.zero,
      paddingTitle: paddingTitle ?? EdgeInsets.zero
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderContainerMenu renderObject) {
    renderObject
      ..paddingMenu = paddingMenu ?? EdgeInsets.zero
      ..paddingTitle = paddingTitle ?? EdgeInsets.zero;
  }
}

class ContainerMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderContainerMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, ContainerMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, ContainerMenuData> {

  RenderContainerMenu({
    required EdgeInsets paddingMenu,
    required EdgeInsets paddingTitle
  }): _paddingMenu = paddingMenu,
      _paddingTitle = paddingTitle;


  EdgeInsets _paddingMenu;
  EdgeInsets get paddingMenu => _paddingMenu;
  set paddingMenu(EdgeInsets value){
    if (value != _paddingMenu){
      _paddingMenu = value;
      markNeedsLayout();
    }
  }

  EdgeInsets _paddingTitle;
  EdgeInsets get paddingTitle => _paddingTitle;
  set paddingTitle(EdgeInsets value){
    if (value != _paddingTitle){
      _paddingTitle = value;
      markNeedsLayout();
    }
  }

  final _indexFirstTitle = 2;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ContainerMenuData){
      child.parentData = ContainerMenuData();
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

  // @override
  // double computeMinIntrinsicHeight(double width) {
  //   return _getIntrinsicHeight(width);
  // }
  //
  // @override
  // double computeMaxIntrinsicHeight(double width) {
  //   return _getIntrinsicHeight(width);
  // }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild
    );
  }

  @override
  void performLayout() {
    size = _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.layoutChild);
    RenderBox? child = firstChild;
    int index = 0;
    final totalTitle = childCount - 2;
    final partTitle = (constraints.maxWidth - paddingTitle.left - paddingTitle.right) / totalTitle;

    while(child != null){
      final childParentData = child.parentData! as ContainerMenuData;
      if (index == 0 || index == 1){
        child.layout(constraints, parentUsesSize: true);
        childParentData.offset = Offset.zero;
      }
      else {
        child.layout(
            constraints.copyWith(maxWidth: (size.width - paddingMenu.left - paddingMenu.right)/(childCount - 2)), parentUsesSize: true);
        final x = paddingTitle.left + partTitle * (index - _indexFirstTitle) + partTitle / 4;
        final y = size.height - child.size.height - paddingTitle.bottom;
        childParentData.offset = Offset(x, y);
      }
      child = childParentData.nextSibling;
      index++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final childParentData = child.parentData! as ContainerMenuData;
      // not draw first menu
      if (index != 1){
        context.paintChild(child, offset + childParentData.offset);
      }
      child = childParentData.nextSibling;
      index++;
    }
  }

  // double _getIntrinsicHeight(double width){
  //   RenderBox? child = firstChild;
  //   double height = 0;
  //   double heightBg = 0;
  //   double heightBgMenu = 0;
  //   int index = 0;
  //   while(child != null){
  //     final childParentData = child.parentData! as BackgroundMenuData;
  //     // background
  //     if (index == 0){
  //       heightBg = child.getMaxIntrinsicHeight(width);
  //     }
  //     else if (index < _indexFirstOfMenu){
  //       height += child.getMaxIntrinsicHeight(width);
  //       if (index == _indexBgHeaderView){
  //         // not cal
  //         height = height - child.getMaxIntrinsicHeight(width);
  //       }
  //       // bg menu view
  //       else if (index == _indexBgMenu){
  //         heightBgMenu = child.getMaxIntrinsicHeight(width);
  //       }
  //       child = childParentData.nextSibling;
  //       index++;
  //     }
  //     else {
  //       // first menu
  //       if (index == _indexFirstOfMenu){
  //         if (heightBgMenu == 0){
  //           height += child.getMaxIntrinsicHeight(width);
  //         }
  //       }
  //       child = null;
  //     }
  //   }
  //   return math.max(heightBg, height);
  // }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}){
    double width = constraints.maxWidth;
    double height = constraints.minHeight;
    RenderBox? child = firstChild;
    int index = 0;
    double hBg = 0;
    double hContentInside = 0;
    double hMaxTitle = 0;
    while(child != null){
      final childParentData = child.parentData! as ContainerMenuData;
      final Size childSize = layoutChild(child, constraints);
      // bg
      if (index == 0){
        hBg = childSize.height;
      }
      //
      else if (index == 1){
        hContentInside += childSize.height;
      }
      else {
        final Size childTextSize = layoutChild(child, constraints.copyWith(maxWidth: (width - paddingMenu.left - paddingMenu.right))/(childCount - 2));
        hMaxTitle = math.max(hMaxTitle, childTextSize.height);
      }
      child = childParentData.nextSibling;
      index++;
    }
    hContentInside += hMaxTitle + paddingTitle.top + paddingTitle.bottom + paddingMenu.top + paddingMenu.bottom;
    return Size(width, math.max(height, math.max(hBg, hContentInside)));
  }


}