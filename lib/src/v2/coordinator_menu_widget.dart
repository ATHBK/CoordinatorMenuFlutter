import 'package:flutter/material.dart';
import 'package:flutter_coordinator_menu/src/v2/container_menu_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_background_item_menu_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_background_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_bound_menu_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_menu_and_header_view.dart';
import 'package:flutter_coordinator_menu/src/v2/remain_view.dart';

import 'sliver_fill_remain_need_to_scroll.dart';

class CoordinatorMenuWidget extends StatefulWidget {

  static const defaultPaddingTitle = EdgeInsets.fromLTRB(4.0, 0, 4.0, 8.0);
  static const defaultPaddingMenu = EdgeInsets.all(8.0);

  final SliverMultiBoxAdaptorWidget functionView;
  final Widget headerView;
  final Widget bg;
  final Widget? bgHeaderView;
  final Widget? containerMenuView;
  final List<Widget> menus;
  final List<Widget> listTitle;
  final Widget? bgMenu;
  final EdgeInsets? paddingMenu;
  final EdgeInsets? paddingCollapseMenu;
  final EdgeInsets? paddingTitle;
  final Color? colorBgChange;
  final Color? colorFillRemain;
  final double functionViewPaddingTop;
  final ValueChanged<double>? onFinishProgress;

  const CoordinatorMenuWidget({
    super.key,
    required this.functionView,
    required this.headerView,
    required this.bg,
    required this.menus,
    required this.listTitle,
    this.containerMenuView,
    this.paddingMenu,
    this.bgMenu,
    this.bgHeaderView,
    this.paddingCollapseMenu,
    this.paddingTitle,
    this.colorFillRemain = Colors.white,
    this.onFinishProgress,
    this.colorBgChange,
    this.functionViewPaddingTop = 16.0
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
    final containerView = _getContainerView();
    final customerScrollView = _getCustomScrollView();
    return Stack(
      children: [
        LayerBackgroundView(
            background: widget.bg,
            bgColorChange: widget.colorBgChange ?? Colors.transparent,
            header: widget.headerView,
            scrollController: _scrollController,
            containerMenu: containerView,
        ),
        customerScrollView,
        LayerBackgroundMenuView(
            background: widget.bg,
            header: widget.headerView,
            containerMenuView: containerView,
            firstMenu: widget.menus.first,
            listBgMenu: _generateListBgMenu(),
            scrollable: _scrollController,
            paddingCollapseMenu: widget.paddingCollapseMenu,
            paddingMenu: widget.paddingMenu,
        ),
        LayerMenuAndHeaderView(
            header: widget.headerView,
            backgroundHeader: widget.bgHeaderView ?? const SizedBox.shrink(),
            background: widget.bg,
            containerMenu: containerView,
            listMenu: widget.menus,
            scrollController: _scrollController,
            paddingMenu: widget.paddingMenu,
            paddingCollapseMenu: widget.paddingCollapseMenu,
            bgMenu: widget.bgMenu ?? const SizedBox.shrink(),
            onFinishProgress: widget.onFinishProgress,
        )
      ],
    );
  }

  Widget _getCustomScrollView(){
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: LayerBoundMenuView(
            background: widget.bg,
            backgroundMenu: _getContainerView()
        )),
        SliverToBoxAdapter(child: SizedBox(height: widget.functionViewPaddingTop,),),
        widget.functionView,
        SliverFillRemainNeedToScroll(color: widget.colorFillRemain, child: _getRemainView(),),
      ],
    );
  }

  ContainerMenuView _getContainerView(){
    return ContainerMenuView(
        background: widget.containerMenuView ?? const SizedBox.shrink(),
        listMenu: widget.menus,
        listTitle: widget.listTitle,
        paddingMenu: widget.paddingMenu,
        paddingTitle: widget.paddingTitle,
        bgMenu: widget.bgMenu,
    );
  }

  List<Widget> _generateListBgMenu(){
    return widget.listTitle.map((e) => widget.bgMenu ?? const SizedBox.shrink()).toList(growable: false);
  }

  RemainView _getRemainView(){
    return RemainView(
        headerView: widget.headerView,
        background: widget.bg,
        functionViewPaddingTop: widget.functionViewPaddingTop
    );
  }


}
