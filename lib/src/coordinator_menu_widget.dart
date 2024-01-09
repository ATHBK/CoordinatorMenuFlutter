import 'package:flutter/material.dart';
import 'package:flutter_coordinator_menu/src/extra_view_in_scroll_view.dart';

import 'coordinator_view.dart';
import 'sliver_fill_remain_need_to_scroll.dart';

class CoordinatorMenuWidget extends StatefulWidget {

  final Widget functionView;
  final Widget headerView;
  final Widget background;
  final Widget? backgroundHeaderView;
  final Widget? middleView;
  final Widget? backgroundMenu;
  final List<Widget> menus;
  final List<Widget> collapseMenus;
  final EdgeInsets? paddingMenu;
  final EdgeInsets? paddingCollapseMenu;
  final Color? colorFillRemain;
  final bool alphaEffect;
  final ValueChanged<double>? onFinishProgress;

  const CoordinatorMenuWidget({
    super.key,
    required this.functionView,
    required this.headerView,
    required this.background,
    required this.menus,
    this.middleView,
    this.backgroundMenu,
    this.collapseMenus = const [],
    this.paddingMenu,
    this.paddingCollapseMenu,
    this.alphaEffect = true,
    this.colorFillRemain = Colors.white,
    this.onFinishProgress,
    this.backgroundHeaderView
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
        widget.background,
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _getExtraViewInScrollView()),
            widget.functionView,
            SliverFillRemainNeedToScroll(color: widget.colorFillRemain, child: _getExtraViewRemain(),),
          ],
        ),
        CoordinatorMenuView(
          scrollController: _scrollController,
          headerView: widget.headerView,
          background: widget.background,
          backgroundMenu: widget.backgroundMenu,
          middleView: widget.middleView,
          menus: widget.menus,
          collapseMenus: widget.collapseMenus,
          paddingMenu: widget.paddingMenu,
          paddingCollapseMenu: widget.paddingCollapseMenu,
          alphaEffect: widget.alphaEffect,
          onFinishProgress: widget.onFinishProgress,
          backgroundHeaderView: widget.backgroundHeaderView,
        )
      ],
    );
  }

  Widget _getExtraViewInScrollView(){
    return ExtraViewInScrollView(
      fixedView: widget.headerView,
      background: widget.background,
      firstMenu: widget.menus.first,
      backgroundMenu: widget.backgroundMenu,
      middleView: widget.middleView,
      paddingMenu: widget.paddingMenu ?? EdgeInsets.zero,
    );
  }

  Widget _getExtraViewRemain(){
    return ExtraViewRemain(
      fixedView: widget.headerView,
      background: widget.background,
      firstMenu: widget.menus.first,
      backgroundMenu: widget.backgroundMenu,
      middleView: widget.middleView,
      paddingMenu: widget.paddingMenu ?? EdgeInsets.zero,
    );
  }
}