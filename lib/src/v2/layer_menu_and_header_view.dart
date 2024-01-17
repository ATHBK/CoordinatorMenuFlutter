import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'container_menu_view.dart';
import 'dart:math' as math;
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

import 'coordinator_menu_widget.dart';

class LayerMenuAndHeaderView extends MultiChildRenderObjectWidget {

  final Widget header;
  final Widget backgroundHeader;
  final Widget background;
  final ContainerMenuView containerMenu;
  final Widget bgMenu;

  final List<Widget> listMenu;
  final EdgeInsets? paddingMenu;
  final EdgeInsets? paddingCollapseMenu;
  final ScrollController scrollController;
  final ValueChanged<double>? onFinishProgress;

  LayerMenuAndHeaderView({
    super.key,
    required this.header,
    required this.backgroundHeader,
    required this.background,
    required this.containerMenu,
    required this.listMenu,
    required this.bgMenu,
    this.paddingMenu,
    this.paddingCollapseMenu,
    required this.scrollController,
    this.onFinishProgress
  }): super(
    children: [
      background,
      containerMenu,
      backgroundHeader,
      header,
      bgMenu,
      ...listMenu
    ]
  );

  @override
  RenderLayerMenuAndHeader createRenderObject(BuildContext context) {
    return RenderLayerMenuAndHeader(
      scrollable: scrollController,
      paddingMenu: paddingMenu ?? CoordinatorMenuWidget.defaultPaddingMenu,
      paddingCollapseMenu: paddingCollapseMenu ?? CoordinatorMenuWidget.defaultPaddingTitle,
      countMenu: listMenu.length,
      onFinishProgress: onFinishProgress
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderLayerMenuAndHeader renderObject) {
    renderObject
      ..paddingMenu = paddingMenu ?? CoordinatorMenuWidget.defaultPaddingMenu
      ..paddingCollapseMenu = paddingCollapseMenu ?? CoordinatorMenuWidget.defaultPaddingTitle
      ..onFinishProgress = onFinishProgress
      ..countMenu = listMenu.length;
  }

}

class LayerMenuAndHeaderData extends ContainerBoxParentData<RenderBox> {}

class RenderLayerMenuAndHeader extends RenderBox with ContainerRenderObjectMixin<RenderBox, LayerMenuAndHeaderData>,
    RenderBoxContainerDefaultsMixin<RenderBox, LayerMenuAndHeaderData> {

  RenderLayerMenuAndHeader({
    required ScrollController scrollable,
    required int countMenu,
    required EdgeInsets paddingMenu,
    required EdgeInsets paddingCollapseMenu,
    ValueChanged<double>? onFinishProgress
  }): _scrollable = scrollable,
        _paddingMenu = paddingMenu,
        _paddingCollapseMenu = paddingCollapseMenu,
        _countMenu = countMenu,
        _onFinishProgress = onFinishProgress;

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

  ValueChanged<double>? _onFinishProgress;
  ValueChanged<double>? get onFinishProgress => _onFinishProgress;
  set onFinishProgress(ValueChanged<double>? value){
    if (value != _onFinishProgress){
      _onFinishProgress = value;
    }
  }

  final int _indexBg = 0;
  final int _indexContainerMenu = 1;
  final int _indexBgHeaderView = 2;
  final int _indexHeaderView = 3;
  final int _indexBgMenu = 4;
  final int _indexFirstOfMenu = 5;

  List<double> _menuDestinationPositionX = [];
  double _menuDestinationPositionY = 16;

  double _heightContainerMenu = 0;
  double _heightCoordinatorView = 1;
  double _heightHeaderView = 0;
  double _heightBgMenu = 0;

  double _positionCoordinatorView = 0;
  double _positionBgHeaderView = 0;
  bool _isFinish = false;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(_listenerScroll);
    _scrollable.position.isScrollingNotifier.addListener(_listenerScrollStatus);
  }

  void _listenerScroll(){
    markNeedsPaint();
    final scrollDy = scrollable.offset;
    final fraction = scrollDy / (_heightCoordinatorView - _heightHeaderView);
    if (fraction >= 0 && fraction < 1) {
      _isFinish = false;
      onFinishProgress?.call(fraction);
    }
    else if (fraction >= 1 && _isFinish == false){
      _isFinish = true;
      onFinishProgress?.call(1);
    }
  }

  void _listenerScrollStatus(){
    if(!_scrollable.position.isScrollingNotifier.value) {
      // scroll is stop
      if (hasSize) {
        final scrollDy = scrollable.offset;
        final fraction = scrollDy / (_heightCoordinatorView - _heightHeaderView);
        _finishMove(fraction);
      }

    } else {
      // scroll is start
    }
  }

  @override
  void detach() {
    _scrollable.position.removeListener(_listenerScroll);
    _scrollable.position.isScrollingNotifier.removeListener(_listenerScrollStatus);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! LayerMenuAndHeaderData){
      child.parentData = LayerMenuAndHeaderData();
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
      final childParentData = child.parentData! as LayerMenuAndHeaderData;
      final Size childSize = layoutChild(child, constraints);
      // bg
      if (index == _indexBg){
        _heightCoordinatorView = childSize.height;
      }
      else if (index == _indexContainerMenu){
        _heightContainerMenu = childSize.height;
      }
      else if (index == _indexHeaderView) {
        _heightHeaderView = childSize.height;
      }
      else if (index == _indexBgMenu){
        _heightBgMenu = childSize.height;
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
    _positionCoordinatorView = _heightCoordinatorView - _heightHeaderView - _heightContainerMenu / 2;
    _positionBgHeaderView = size.height - 2 * _heightHeaderView  - _heightContainerMenu / 2;
    while(child != null){
      final childParentData = child.parentData! as LayerMenuAndHeaderData;
      if (index == _indexBgHeaderView){
        child.layout(constraints.copyWith(maxHeight: _heightHeaderView), parentUsesSize: true);
      }
      else {
        child.layout(constraints, parentUsesSize: true);
      }
      if (index == _indexBg ||
          index == _indexContainerMenu ||
          index == _indexHeaderView ||
          index == _indexBgHeaderView ||
          index == _indexBgMenu
      ){
        childParentData.offset = Offset.zero;
      }
      // set menu view
      else if (index - _indexFirstOfMenu < _countMenu){
        final x = paddingMenu.left + part * (index - _indexFirstOfMenu) + (part / 2 - child.size.width / 2);
        final extend = _heightBgMenu > 0 ? (_heightBgMenu / 2 - child.size.height/2) : 0;
        final y = size.height - _heightContainerMenu + _paddingMenu.top + extend;
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
      final childParentData = child.parentData as LayerMenuAndHeaderData;
      final scrollDy = scrollable.offset;
      final fraction = scrollDy / _positionCoordinatorView;
      // _onFinishProgress?.call(fraction);
      if (index == _indexBg || index == _indexContainerMenu || index == _indexBgMenu) {
        // do not draw extend View
      }
      else if (index == _indexBgHeaderView){
        final fractionHeaderView = scrollDy / _positionBgHeaderView;
        _paintBgHeaderView(context, offset, fractionHeaderView, index, child, childParentData);
      }
      // draw fixed view
      else if (index == _indexHeaderView) {
        context.paintChild(child, offset + childParentData.offset);
      }
      else if (index - _indexFirstOfMenu < _countMenu) {
        _paintMenu(context, offset, fraction, index - _indexFirstOfMenu, child, childParentData);
      }
      index++;
      child = childParentData.nextSibling;
    }
  }

  void _paintBgHeaderView(PaintingContext context, Offset offset, double fraction, int index, RenderBox child, LayerMenuAndHeaderData childParentData){
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


  void _paintMenu(PaintingContext context, Offset offset, double fraction, int index, RenderBox child, LayerMenuAndHeaderData childParentData){
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
      // if (fraction == 1.0) {
        context.pushTransform(
            needsCompositing, newOffset, Matrix4.identity(), painter);
      // } else {
      //   double opacity = 1;
      //   double scaleX = 1;
      //   double scaleY = 1;
      //   if (fraction < 0.7 && fraction > 0){
      //     opacity = 1 - fraction - 0.3;
      //     if (_rateWidth != 1 || _rateHeight != 1) {
      //       scaleX = 1 - (1 - _rateWidth) * fraction;
      //       scaleY = 1 - (1 - _rateHeight) * fraction;
      //     }
      //   }
      //   else if (fraction >= 0.7){
      //     opacity = 0.4 + fraction - 1;
      //     if (_rateWidth != 1 || _rateHeight != 1) {
      //       scaleX = (1 + _rateWidth) - _rateWidth * fraction;
      //       scaleY = (1 + _rateHeight) - _rateHeight * fraction;
      //     }
      //   }
      //   if (_alphaEffect) {
      //     context.pushOpacity(
      //         newOffset, ui.Color.getAlphaFromOpacity(opacity), (
      //         PaintingContext context, Offset offset) {
      //       context.pushTransform(
      //           needsCompositing, offset,
      //           Matrix4.identity().scaled(scaleX, scaleY), painter);
      //     });
      //   }
      //   else {
      //     context.pushTransform(
      //         needsCompositing, newOffset,
      //         Matrix4.identity().scaled(scaleX, scaleY), painter);
      //   }
      // }
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
      return edgeInset.left + index * eachWidthOfView + (eachWidthOfView / 2 - widthChild / 2).abs();
    }, growable: false);
  }

  double _computeDestinationYPosition(double yOfFixView, double heightOfFixView, double heightChild){
    return yOfFixView + heightOfFixView / 2 - heightChild / 2;
  }

  Future<void>? scrollAnimateToRunning;

  void _finishMove(double fraction) async {
    if (fraction < 1 && fraction >= 0.1 && _scrollable.position.userScrollDirection == ScrollDirection.reverse) {
      // up
      Future.delayed(Duration.zero, () async {
        if(scrollAnimateToRunning != null) {
          await scrollAnimateToRunning;
        }
        scrollAnimateToRunning = _scrollable.animateTo((_heightCoordinatorView - _heightHeaderView), duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      });
    }
    else if (fraction <= 0.9 && fraction > 0 && _scrollable.position.userScrollDirection == ScrollDirection.forward){
      //down
      Future.delayed(Duration.zero, () async {
        if(scrollAnimateToRunning != null) {
          await scrollAnimateToRunning;
        }
        scrollAnimateToRunning = _scrollable.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    }
  }

}