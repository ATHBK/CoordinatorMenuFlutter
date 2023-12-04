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
        countMenu: menus.length,
        countCollapseMenu: collapseMenus.length,
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
      ..countMenu = menus.length
      ..countCollapseMenu = collapseMenus.length;

  }
}

class CoordinatorMenuData extends ContainerBoxParentData<RenderBox> {}

class RenderCoordinatorMenu extends RenderBox with ContainerRenderObjectMixin<RenderBox, CoordinatorMenuData>,
    RenderBoxContainerDefaultsMixin<RenderBox, CoordinatorMenuData>{

  RenderCoordinatorMenu({
    required ScrollController scrollable,
    required int countMenu,
    required int countCollapseMenu,
    EdgeInsets? paddingMenu,
    EdgeInsets? paddingCollapseMenu
  }): _scrollable = scrollable,
      _paddingMenu = paddingMenu,
      _paddingCollapseMenu = paddingCollapseMenu,
      _countMenu = countMenu,
      _countCollapseMenu = countCollapseMenu;


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

  int _countCollapseMenu;
  int get countCollapseMenu => _countCollapseMenu;
  set countCollapseMenu(int value){
    if (value != _countCollapseMenu){
      _countCollapseMenu = value;
      markNeedsLayout();
    }
  }

  double _positionCoordinatorView = 0;
  List<double> _menuDestinationPositionX = [];
  double _menuDestinationPositionY = 16;
  double _rateWidth = 1;
  double _rateHeight = 1;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsPaint);
    _scrollable.position.isScrollingNotifier.addListener(_listenerScrollStatus);
  }

  void _listenerScrollStatus(){
    if(!_scrollable.position.isScrollingNotifier.value) {
      // scroll is stop
      if (hasSize) {
        final scrollDy = scrollable.offset;
        final fraction = scrollDy / _positionCoordinatorView;
        _finishMove(fraction);
      }

    } else {
      // scroll is start
    }
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsPaint);
    _scrollable.position.isScrollingNotifier.removeListener(_listenerScrollStatus);
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
    double width = constraints.maxWidth;
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
    final totalMenu = _countMenu;
    final part = constraints.maxWidth / totalMenu;
    double widthMenu = 0;
    double heightMenu = 0;
    double widthCollapseMenu = 0;
    double heightCollapseMenu = 0;
    double heightFixView = 0;
    int countCollapseMenu = _countCollapseMenu;
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
        heightFixView = child.size.height;
      }
      // set menu view
      else if (index - 2 < _countMenu){
        final x = part * (index - 2) + part / 4;
        final y = size.height - child.size.height - (_paddingMenu?.bottom ?? 16);
        childParentData.offset = Offset(x, y);
        widthMenu = math.max(widthMenu, child.size.width);
        heightMenu = math.max(heightMenu, child.size.height);
        // not replace menu -> use this menu
        if (_countCollapseMenu == 0){
          widthCollapseMenu = math.max(widthCollapseMenu, child.size.width);
          heightCollapseMenu = math.max(heightCollapseMenu, child.size.height);
          countCollapseMenu = _countMenu;
        }
      }
      else {
        // collapse menu
        final x = part * (index - 2 - countMenu) + part / 4;
        final y = size.height - child.size.height - (_paddingMenu?.bottom ?? 16);
        childParentData.offset = Offset(x, y);
        widthCollapseMenu = math.max(widthCollapseMenu, child.size.width);
        heightCollapseMenu = math.max(heightCollapseMenu, child.size.height);
      }
      index++;
      child = childParentData.nextSibling;
    }
    _rateWidth = widthCollapseMenu / widthMenu;
    _rateHeight = heightCollapseMenu / heightMenu;
    _menuDestinationPositionX = _computeDestinationXPosition(countCollapseMenu, size, _paddingCollapseMenu, widthCollapseMenu);
    _menuDestinationPositionY = _computeDestinationYPosition(0, heightFixView, heightCollapseMenu);
    // print("menu des x: $_menuDestinationPositionX");
    // print("menu des y: $_menuDestinationPositionY");
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final childParentData = child.parentData as CoordinatorMenuData;
      final scrollDy = scrollable.offset;
      final fraction = scrollDy / _positionCoordinatorView;
      if (index == 0) {
        // do not draw extend View
      }
      else if (index == 1) {
        context.paintChild(child, offset + childParentData.offset);
      }
      else if (index - 2 < _countMenu) {
        if (fraction < 0.7 || _countCollapseMenu == 0) {
          _paintMenu(context, offset, fraction, index - 2, child, childParentData);
        }
      }
      else if (index - (2 + _countMenu) < _countCollapseMenu){
        if (fraction >= 0.7){
          _paintMenu(context, offset, fraction, index - (2 + _countMenu), child, childParentData);
        }
      }
      index++;
      child = childParentData.nextSibling;
    }
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

  void _paintMenu(PaintingContext context, Offset offset, double fraction, int index, RenderBox child, CoordinatorMenuData childParentData){
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
      if (fraction == 1.0) {
        context.pushTransform(
            needsCompositing, newOffset, Matrix4.identity(), painter);
      } else {
        double opacity = 1;
        double scaleX = 1;
        double scaleY = 1;
        if (fraction < 0.7 && fraction > 0){
          opacity = 1 - fraction - 0.3;
          if (_rateWidth != 1 || _rateHeight != 1) {
            scaleX = 1 - (1 - _rateWidth) * fraction;
            scaleY = 1 - (1 - _rateHeight) * fraction;
          }
        }
        else if (fraction >= 0.7){
          opacity = 0.4 + fraction - 1;
          if (_rateWidth != 1 || _rateHeight != 1) {
            scaleX = (1 + _rateWidth) - _rateWidth * fraction;
            scaleY = (1 + _rateHeight) - _rateHeight * fraction;
          }
        }
        context.pushOpacity(
            newOffset, ui.Color.getAlphaFromOpacity(opacity), (
            PaintingContext context, Offset offset) {
          context.pushTransform(
              needsCompositing, offset, Matrix4.identity().scaled(scaleX, scaleY), painter);
        });
      }
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

  void _finishMove(double fraction){
    if (fraction < 1 && fraction >= 0.1 && _scrollable.position.userScrollDirection == ScrollDirection.reverse) {
      // up
      _scrollable.animateTo(_positionCoordinatorView, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    }
    else if (fraction <= 0.9 && fraction > 0 && _scrollable.position.userScrollDirection == ScrollDirection.forward){
      //down
      _scrollable.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

}