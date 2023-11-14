import 'package:flutter/material.dart';

import 'custom_scroll_view.dart';

class CoordinatorMenuWidget extends StatelessWidget {

  final Widget functionView;
  final Widget extendView;
  final Widget fixedView;
  final List<Widget> menus;

  const CoordinatorMenuWidget({
    super.key,
    required this.functionView,
    required this.extendView,
    required this.fixedView,
    required this.menus
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Container(
              height: 100,
              color: Colors.orange,
            )),
            SliverToBoxAdapter(child: Container(
              height: 200,
              color: Colors.purple,
            )),
            functionView
          ],
        ),
        CoordinatorMenuView(
          fixedView: fixedView,
          extendView: extendView,
          menus: menus,
        )
      ],
    );
  }


}