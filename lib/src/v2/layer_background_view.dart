import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Color, Gradient, Image, ImageFilter;

class LayerBackgroundView extends MultiChildRenderObjectWidget {

  final Widget background;
  final Color bgColorChange;
  final ScrollController scrollController;

  LayerBackgroundView({
    super.key,
    required this.background,
    required this.bgColorChange,
    required this.scrollController
  }): super(children: [
    background,
    Container(color: bgColorChange,)
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
    _scrollable.position.addListener(markNeedsPaint);
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
    while(child != null){
      final childParentData = child.parentData! as LayerBackgroundData;
      child.layout(constraints, parentUsesSize: true);
      childParentData.offset = Offset.zero;
      child = childParentData.nextSibling;
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
    final scrollDy = scrollable.offset;
    final fraction = scrollDy / size.height;
    context.pushOpacity(
        offset, ui.Color.getAlphaFromOpacity(fraction), (
        PaintingContext context, Offset offset) {
      context.paintChild(child, offset);
    });
  }
}