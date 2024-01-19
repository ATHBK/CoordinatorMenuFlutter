import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import 'coordinator_menu_widget.dart';

class ContainerMenuView extends MultiChildRenderObjectWidget {

  final Widget background;
  final List<Widget> listMenu;
  final List<Widget> listTitle;
  final EdgeInsets? paddingTitle;
  final EdgeInsets? paddingMenu;
  final Widget? bgMenu;

  ContainerMenuView({
    super.key,
    required this.background,
    required this.listMenu,
    required this.listTitle,
    this.paddingTitle,
    this.paddingMenu,
    this.bgMenu
  }): super(
    children: [
      background,
      listMenu.first,
      bgMenu ?? const SizedBox.shrink(),
      ...listTitle,
    ]
  );

  @override
  RenderContainerMenu createRenderObject(BuildContext context) {
    return RenderContainerMenu(
      paddingMenu: paddingMenu ?? CoordinatorMenuWidget.defaultPaddingMenu,
      paddingTitle: paddingTitle ?? CoordinatorMenuWidget.defaultPaddingTitle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderContainerMenu renderObject) {
    renderObject
      ..paddingMenu = paddingMenu ?? CoordinatorMenuWidget.defaultPaddingMenu
      ..paddingTitle = paddingTitle ?? CoordinatorMenuWidget.defaultPaddingTitle;
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

  final _indexFirstTitle = 3;
  double _maxHeightText = 0;

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
    final totalTitle = childCount - _indexFirstTitle;
    final partTitle = (size.width - paddingMenu.left - paddingMenu.right)/ totalTitle;
    final maxWidthText = partTitle - paddingTitle.left - paddingTitle.right;

    while(child != null){
      final childParentData = child.parentData! as ContainerMenuData;
      // bg
      if (index == 0){
        child.layout(constraints.tighten(height: size.height), parentUsesSize: true);
        childParentData.offset = Offset.zero;
      }
      // first menu + bg menu
      else if (index == 1 || index == 2){
        child.layout(constraints, parentUsesSize: true);
        childParentData.offset = Offset.zero;
      }
      else {
        child.layout(
            constraints.copyWith(minWidth: maxWidthText, maxWidth: maxWidthText, minHeight: _maxHeightText, maxHeight: _maxHeightText), parentUsesSize: true);
        final x = paddingTitle.left + partTitle * (index - _indexFirstTitle) + paddingMenu.left;
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
      // not draw first menu and bg menu
      if (index != 1 && index != 2){
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
    double maxHeight = constraints.maxHeight;
    RenderBox? child = firstChild;
    int index = 0;
    double hBg = 0;
    double hContentInside = 0;
    final maxWidthText = ((width - paddingMenu.left - paddingMenu.right)/(childCount - _indexFirstTitle)) - paddingTitle.left - paddingTitle.right;
    while(child != null){
      final childParentData = child.parentData! as ContainerMenuData;
      final Size childSize = layoutChild(child, constraints);
      // bg
      if (index == 0){
        hBg = childSize.height;
      }
      // first menu
      else if (index == 1){
        hContentInside += childSize.height;
      } // bg menu
      else if (index == 2){
        hContentInside = math.max(hContentInside, childSize.height);
      }
      else {
        final Size childTextSize = layoutChild(child, constraints.copyWith(maxWidth: maxWidthText, minWidth: maxWidthText));
        _maxHeightText = math.max(_maxHeightText, childTextSize.height);
      }
      child = childParentData.nextSibling;
      index++;
    }
    hContentInside += _maxHeightText + paddingTitle.top + paddingTitle.bottom + paddingMenu.top + paddingMenu.bottom;
    return Size(width, math.max(height, math.max(hBg == maxHeight ? 0 : hBg, hContentInside)));
  }


}