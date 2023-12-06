import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class SliverFillRemainNeedToScroll extends StatelessWidget {

  final Widget? child;

  const SliverFillRemainNeedToScroll({
    super.key,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    return _SliverFillRemainNeedToScrollable(child: child,);
  }
}

class _SliverFillRemainNeedToScrollable extends SingleChildRenderObjectWidget {

  const _SliverFillRemainNeedToScrollable({
    super.child
  });

  @override
  _RenderSliverRemainNeedToScroll createRenderObject(BuildContext context) {
    return _RenderSliverRemainNeedToScroll();
  }
}

class _RenderSliverRemainNeedToScroll extends RenderSliverSingleBoxAdapter {

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
      child!.layout(constraints.asBoxConstraints(
        minExtent: extent,
        maxExtent: extent,
      ));
    }

    assert(extent.isFinite,
    'The calculated extent for the child of SliverFillRemaining is not finite. '
        'This can happen if the child is a scrollable, in which case, the '
        'hasScrollBody property of SliverFillRemaining should not be set to '
        'false.',
    );
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: extent);
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
  }
}