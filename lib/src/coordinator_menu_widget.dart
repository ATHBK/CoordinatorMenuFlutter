import 'package:flutter/material.dart';

import 'coordinator_view.dart';
import 'sliver_fill_remain_need_to_scroll.dart';

class CoordinatorMenuWidget extends StatefulWidget {

  final Widget functionView;
  final Widget extendView;
  final Widget fixedView;
  final List<Widget> menus;
  final List<Widget> collapseMenus;
  final EdgeInsets? paddingMenu;
  final EdgeInsets? paddingCollapseMenu;

  const CoordinatorMenuWidget({
    super.key,
    required this.functionView,
    required this.extendView,
    required this.fixedView,
    required this.menus,
    this.collapseMenus = const [],
    this.paddingMenu,
    this.paddingCollapseMenu
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
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: widget.fixedView),
                  SliverToBoxAdapter(child: widget.extendView),
                  widget.functionView,
                  SliverFillRemainNeedToScroll(child: widget.extendView),
                ],
              ),
              CoordinatorMenuView(
                scrollController: _scrollController,
                fixedView: widget.fixedView,
                extendView: widget.extendView,
                menus: widget.menus,
                collapseMenus: widget.collapseMenus,
                paddingMenu: widget.paddingMenu,
                paddingCollapseMenu: widget.paddingCollapseMenu,
              )
            ],
          ),
        ),
      ],
    );
  }
}