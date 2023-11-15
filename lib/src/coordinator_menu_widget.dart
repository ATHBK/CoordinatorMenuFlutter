import 'package:flutter/material.dart';

import 'custom_scroll_view.dart';

class CoordinatorMenuWidget extends StatefulWidget {

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
  State<CoordinatorMenuWidget> createState() => _CoordinatorMenuWidgetState();
}

class _CoordinatorMenuWidgetState extends State<CoordinatorMenuWidget> {
  
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: Container(
              height: 100,
              color: Colors.orange,
            )),
            SliverToBoxAdapter(child: Container(
              height: 200,
              color: Colors.purple,
            )),
            widget.functionView
          ],
        ),
        CoordinatorMenuView(
          scrollController: _scrollController,
          fixedView: widget.fixedView,
          extendView: widget.extendView,
          menus: widget.menus,
        )
      ],
    );
  }
}