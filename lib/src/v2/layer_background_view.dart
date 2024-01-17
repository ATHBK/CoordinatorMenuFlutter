import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

import 'container_menu_view.dart';

class LayerBackgroundView extends MultiChildRenderObjectWidget {

  final Widget background;
  final Widget header;
  final Widget containerMenu;
  final Color bgColorChange;
  final ScrollController scrollController;

  LayerBackgroundView({
    super.key,
    required this.background,
    required this.header,
    required this.bgColorChange,
    required this.scrollController,
    required this.containerMenu
  }): super(children: [
    background,
    Container(color: bgColorChange,),
    header,
    containerMenu
  ]);

  @override
  RenderLayerBackground createRenderObject(BuildContext context) {
    return RenderLayerBackground(scrollable: scrollController);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderLayerBackground renderObject) {
    renderObject._scrollable = scrollController;
  }
}

class LayerBackgroundData extends ContainerBoxParentData<RenderBox> {}

class RenderLayerBackground extends RenderBox with ContainerRenderObjectMixin<RenderBox, LayerBackgroundData>,
    RenderBoxContainerDefaultsMixin<RenderBox, LayerBackgroundData> {

  RenderLayerBackground({
    required ScrollController scrollable,
  }): _scrollable = scrollable;

  ScrollController _scrollable;

  ScrollController get scrollable => _scrollable;

  final int _positionHeader = 2;
  final int _positionContainer = 3;

  double _positionTopToScroll = 0;

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

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if(_scrollable.hasClients) {
      _scrollable.position.addListener(markNeedsPaint);
    }
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsPaint);
    super.detach();
  }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}){
    double width = constraints.maxWidth;
    double height = constraints.minHeight;
    RenderBox? child = firstChild;
    if (child != null) {
      final Size childSize = layoutChild(child, constraints);
      return Size(width, childSize.height);
    }
    return Size(width, height);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! LayerBackgroundData){
      child.parentData = LayerBackgroundData();
    }
  }

  @override
  void performLayout() {
    size = _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.layoutChild);
    RenderBox? child = firstChild;
    int index = 0;
    double heightContainer = 0;
    while(child != null){
      final childParentData = child.parentData! as LayerBackgroundData;
      child.layout(constraints, parentUsesSize: true);
      childParentData.offset = Offset.zero;
      if (index == _positionHeader){
        heightContainer = child.size.height;
      }
      else if (index == _positionContainer){
        _positionTopToScroll = size.height - child.size.height - heightContainer / 2;
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
      final childParentData = child.parentData! as LayerBackgroundData;
      // draw bg
      if (index == 0){
        _paintBg(context, offset, child);
      }
      else if (index == _positionHeader || index == _positionContainer){
        // do not draw
      }
      else {
        _paintBgChange(context, offset, child);
      }
      child = childParentData.nextSibling;
      index++;
    }
  }

  void _paintBg(PaintingContext context, Offset offset, RenderBox child){
    context.paintChild(child, offset);
  }

  void _paintBgChange(PaintingContext context, Offset offset, RenderBox child){
    if (scrollable.hasClients) {
      final scrollDy = scrollable.offset;
      final fraction = scrollDy / _positionTopToScroll;
      context.pushOpacity(
          offset, ui.Color.getAlphaFromOpacity(fraction), (
          PaintingContext context, Offset offset) {
        context.paintChild(child, offset);
      });
    }
  }
}