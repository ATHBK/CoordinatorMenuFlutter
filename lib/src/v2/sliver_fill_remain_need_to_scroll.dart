import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class SliverFillRemainNeedToScroll extends StatelessWidget {

  final Widget? child;
  final Color? color;

  const SliverFillRemainNeedToScroll({
    super.key,
    this.child,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return _SliverFillRemainNeedToScrollable(color: color, child: child,);
  }
}

class _SliverFillRemainNeedToScrollable extends SingleChildRenderObjectWidget {

  final Color? color;

  const _SliverFillRemainNeedToScrollable({
    super.child,
    this.color
  });

  @override
  _RenderSliverRemainNeedToScroll createRenderObject(BuildContext context) {
    return _RenderSliverRemainNeedToScroll(color: color);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderSliverRemainNeedToScroll renderObject) {
    renderObject.setColor = color;
  }
}

class _RenderSliverRemainNeedToScroll extends RenderSliverSingleBoxAdapter {

  _RenderSliverRemainNeedToScroll({
    Color? color
  }): _color = color;

  Color? _color;
  Color? get color => _color;
  set setColor(Color? color){
    if (color != _color){
      _color = color;
      markNeedsPaint();
    }
  }

  double _sizeWidth = 1000;
  double _sizeHeight = 0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    // The remaining space in the viewportMainAxisExtent. Can be <= 0 if we have
    // scrolled beyond the extent of the screen.
    double extent = constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;
    // print("SliverConstaints 1 : $constraints");
    // print("SliverConstaints 2: ${constraints.precedingScrollExtent}");
    // print("SliverConstaints 3: ${constraints.viewportMainAxisExtent}");
    if (child != null) {
      final double childExtent;
      switch (constraints.axis) {
        case Axis.horizontal:
          childExtent = child!.getMaxIntrinsicWidth(constraints.crossAxisExtent);
        case Axis.vertical:
          childExtent = child!.getMaxIntrinsicHeight(constraints.crossAxisExtent);
          // print("childExtend: $childExtent");
      }

      // If the childExtent is greater than the computed extent, we want to use
      // that instead of potentially cutting off the child. This allows us to
      // safely specify a maxExtent.
      if (extent >= 0) {
        extent = extent + childExtent;
      }
      else if (extent.abs() < childExtent){
        extent = childExtent;
      }
      else {
        extent = 0;
      }
      _sizeHeight = extent;
      child!.layout(constraints.asBoxConstraints(minExtent: extent, maxExtent: extent), parentUsesSize: true);
    }

    assert(extent.isFinite,
    'The calculated extent for the child of SliverFillRemaining is not finite. '
        'This can happen if the child is a scrollable, in which case, the '
        'hasScrollBody property of SliverFillRemaining should not be set to '
        'false.',
    );
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: extent);
    // print("paintedChildSize: ${paintedChildSize}, $_sizeHeight");
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintedChildSize,
      maxPaintExtent: paintedChildSize,
      hasVisualOverflow: extent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    if (child != null) {
      setChildParentData(child!, constraints, geometry!);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(Rect.fromLTRB(0, 0, _sizeWidth, _sizeHeight), Paint()..color = _color ?? Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 1);
    canvas.restore();
  }
}