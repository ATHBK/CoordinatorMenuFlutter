import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

import 'container_menu_view.dart';

class LayerBackgroundMenuView extends MultiChildRenderObjectWidget {

  final Widget background;
  final Widget header;
  final Widget containerMenuView;
  final Widget firstMenu;
  final List<Widget> listBgMenu;
  final EdgeInsets? paddingMenu;
  final EdgeInsets? paddingCollapseMenu;
  final ScrollController scrollable;

  LayerBackgroundMenuView({
    super.key,
    required this.background,
    required this.header,
    required this.containerMenuView,
    required this.firstMenu,
    required this.listBgMenu,
    this.paddingMenu,
    this.paddingCollapseMenu,
    required this.scrollable
  }): super(
    children: [
      background,
      header,
      containerMenuView,
      firstMenu,
      ...listBgMenu
    ]
  );

  @override
  RenderLayerBackgroundMenu createRenderObject(BuildContext context) {
    return RenderLayerBackgroundMenu(
      paddingMenu: paddingMenu ?? const EdgeInsets.symmetric(vertical: 8.0),
      paddingCollapseMenu: paddingCollapseMenu ?? const EdgeInsets.symmetric(vertical: 8.0),
      scrollable: scrollable,
      countMenu: listBgMenu.length
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderLayerBackgroundMenu renderObject) {
    renderObject
        ..paddingMenu = paddingMenu ?? const EdgeInsets.symmetric(vertical: 8.0)
        ..paddingCollapseMenu = paddingCollapseMenu ?? const EdgeInsets.symmetric(vertical: 8.0)
        ..countMenu = listBgMenu.length
        ..scrollable = scrollable;
  }
}

class LayerBackgroundMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderLayerBackgroundMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, LayerBackgroundMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, LayerBackgroundMenuData> {

  RenderLayerBackgroundMenu({
    required EdgeInsets paddingMenu,
    required EdgeInsets paddingCollapseMenu,
    required ScrollController scrollable,
    required int countMenu
  }): _scrollable = scrollable,
      _paddingCollapseMenu = paddingCollapseMenu,
      _countMenu = countMenu,
      _paddingMenu = paddingMenu;

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

  EdgeInsets _paddingMenu;
  EdgeInsets get paddingMenu => _paddingMenu;
  set paddingMenu(EdgeInsets value){
    if (value != _paddingMenu){
      _paddingMenu = value;
      markNeedsLayout();
    }
  }

  EdgeInsets _paddingCollapseMenu;
  EdgeInsets get paddingCollapseMenu => _paddingCollapseMenu;
  set paddingCollapseMenu(EdgeInsets value){
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

  final int _indexBg = 0;
  final int _indexHeaderView = 1;
  final int _indexContainer = 2;
  final int _indexFirstOfMenu = 3;
  final int _indexFirstBgMenu = 4;

  List<double> _menuDestinationPositionX = [];
  double _menuDestinationPositionY = 16;

  double _heightCoordinatorView = 1;
  double _heightHeaderView = 0;
  double _heightContainer = 0;

  double _positionCoordinatorView = 0;
  // double _positionBgHeaderView = 0;
  // double _positionContainerMenuView = 0;

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
    if (child.parentData is! LayerBackgroundMenuData){
      child.parentData = LayerBackgroundMenuData();
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
    double heightBg = 0;
    if(child != null){
      // background
      heightBg = child.getMaxIntrinsicHeight(width);
    }
    return heightBg;
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
    double width = constraints.maxWidth;
    double height = constraints.minHeight;
    double maxHeight = 0;
    RenderBox? child = firstChild;
    int index = 0;
    while(child != null){
      final childParentData = child.parentData! as LayerBackgroundMenuData;
      final Size childSize = layoutChild(child, constraints);
      // bg
      if (index == _indexBg){
        _heightCoordinatorView = childSize.height;
      }
      else if (index == _indexHeaderView){
        _heightHeaderView = childSize.height;
      }
      else if (index == _indexContainer) {
        _heightContainer = childSize.height;
      }
      index++;
      child = childParentData.nextSibling;
    }
    height = math.max(_heightCoordinatorView, maxHeight);
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
    final part = (constraints.maxWidth - paddingMenu.left - paddingMenu.right) / _countMenu;
    double widthMenu = 0;
    double heightMenu = 0;
    _positionCoordinatorView = _heightCoordinatorView - _heightHeaderView - _heightContainer / 2;
    // _positionBgHeaderView = size.height - _heightHeaderView;
    // _positionContainerMenuView = size.height / 2;
    while(child != null){
      final childParentData = child.parentData! as LayerBackgroundMenuData;
      child.layout(constraints, parentUsesSize: true);
      if (index == _indexBg || index == _indexHeaderView || index == _indexContainer || index == _indexFirstOfMenu){
        childParentData.offset = Offset.zero;
      }
      // set menu view
      else if (index - _indexFirstBgMenu < _countMenu){
        final x = paddingMenu.left + part * (index - _indexFirstBgMenu) + (part / 2 - child.size.width /2);
        final y = size.height - _heightContainer + _paddingMenu.top;
        childParentData.offset = Offset(x, y);
        widthMenu = math.max(widthMenu, child.size.width);
        heightMenu = math.max(heightMenu, child.size.height);
      }
      index++;
      child = childParentData.nextSibling;
    }
    _menuDestinationPositionX = _computeDestinationXPosition(_countMenu, size, _paddingCollapseMenu, widthMenu);
    _menuDestinationPositionY = _computeDestinationYPosition(0, _heightHeaderView, heightMenu);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final childParentData = child.parentData as LayerBackgroundMenuData;
      final scrollDy = scrollable.offset;
      final fraction = scrollDy / _positionCoordinatorView;
      // _onFinishProgress?.call(fraction);
      if (index == _indexBg || index == _indexHeaderView || index == _indexContainer || index == _indexFirstOfMenu) {
        // do not draw extend View
      }
      else if (index - _indexFirstBgMenu < _countMenu) {
        _paintMenu(context, offset, fraction, index - _indexFirstBgMenu, child, childParentData);
      }
      index++;
      child = childParentData.nextSibling;
    }
  }

  void _paintBgHeaderView(PaintingContext context, Offset offset, double fraction, int index, RenderBox child, LayerBackgroundMenuData childParentData){
    if (fraction >= 1){
      context.paintChild(child, offset + childParentData.offset);
    }
    else if (fraction > 0) {
      context.pushOpacity(
          offset, ui.Color.getAlphaFromOpacity(fraction), (
          PaintingContext context, Offset offset) {
        context.paintChild(child, offset + childParentData.offset);
      });
    }
  }


  void _paintMenu(PaintingContext context, Offset offset, double fraction, int index, RenderBox child, LayerBackgroundMenuData childParentData){
    final originOffset = childParentData.offset;
    final distanceX = originOffset.dx - _menuDestinationPositionX[index];
    final distanceY = originOffset.dy - _menuDestinationPositionY;
    if (fraction <= 1) {
      void painter(PaintingContext context, Offset offset) {
        context.paintChild(child, offset);
      }

      final newDx = originOffset.dx - distanceX * fraction;
      final newDy = originOffset.dy - distanceY * fraction;
      final newOffset = offset + Offset(newDx, newDy);
      // context.paintChild(child, newOffset);

      // context.pushOpacity(
      //     newOffset, ui.Color.getAlphaFromOpacity(1 - fraction), (
      //     PaintingContext context, Offset offset) {
      //   context.paintChild(child, newOffset);
      // });
      context.pushOpacity(
          newOffset, ui.Color.getAlphaFromOpacity(1 - fraction), (
          PaintingContext context, Offset offset) {
        context.pushTransform(
            needsCompositing, offset, Matrix4.identity(), painter);
      });
    }
    else {
      final newOffset = offset +
          Offset(_menuDestinationPositionX[index].toDouble(), _menuDestinationPositionY);
      context.paintChild(child, newOffset);
    }
  }

  List<double> _computeDestinationXPosition(int countCollapseMenu, Size size, EdgeInsets? padding, double widthChild){
    final edgeInset = padding ?? EdgeInsets.zero;
    final maxWidthOfView = size.width - edgeInset.left - edgeInset.right;
    final eachWidthOfView = maxWidthOfView / countCollapseMenu;
    return List<double>.generate(countCollapseMenu, (index) {
      return edgeInset.left + index * eachWidthOfView + (eachWidthOfView / 2 - widthChild / 2);
    }, growable: false);
  }

  double _computeDestinationYPosition(double yOfFixView, double heightOfFixView, double heightChild){
    return yOfFixView + heightOfFixView / 2 - heightChild / 2;
  }
}