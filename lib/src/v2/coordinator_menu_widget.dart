import 'package:flutter/material.dart';
import 'package:flutter_coordinator_menu/src/v2/container_menu_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_background_item_menu_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_background_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_bound_menu_view.dart';
import 'package:flutter_coordinator_menu/src/v2/layer_menu_and_header_view.dart';
import 'package:flutter_coordinator_menu/src/v2/remain_view.dart';

import 'sliver_fill_remain_need_to_scroll.dart';

///
/// CoordinatorMenuWidget
///

class CoordinatorMenuWidget extends StatefulWidget {

  /// A widget that supports building UI/UX like e-wallet applications like momo
  ///
  /// Supports customizing many parameters to produce many different versions
  ///
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
    this.colorBgChange = Colors.white,
    this.functionViewPaddingTop = 16.0
  });

  ///  Default padding title
  ///
  static const defaultPaddingTitle = EdgeInsets.fromLTRB(4.0, 0, 4.0, 8.0);

  /// Default padding menu
  ///
  static const defaultPaddingMenu = EdgeInsets.all(8.0);

  /// The sliver list or sliver grid view. This view contains smaller functions of the application
  ///
  /// Function view is required
  final SliverMultiBoxAdaptorWidget functionView;

  ///Fixed view at the top. This view can contain child views on the left or right depending on your ui/ux.
  /// Note: if you have child views, you need to pay attention to the menu's padding collapse.
  /// The position of the collapse menu will be adjusted evenly within its possible width
  /// headerView is required
  final Widget headerView;

  /// This view is the background from the header to the menu view container.
  /// The height of this view determines the height of the coordinator menu.
  /// bg is required
  final Widget bg;

  /// A background of header
  /// It will appear when the user scrolls up and hide when scrolling down.
  /// Default: Container(color: Colors.blue)
  /// bgHeaderView is optional
  final Widget? bgHeaderView;

  /// View wraps the list menu and list Title.
  /// containerMenuView is optional
  final Widget? containerMenuView;

  /// A list widget.
  /// You should keep the amount appropriate to the screen size. Note: the number of menus and titles must be equal
  /// It is the main functions of the application.
  /// As the view is scrolled, the menu will slowly move up the header and sticky on there.
  /// menus is required
  final List<Widget> menus;

  /// A list widget.
  /// You should keep the amount appropriate to the screen size. Note: the number of menus and titles must be equal
  /// Title of each menu. It should be a text widget.
  /// listTitle is required
  final List<Widget> listTitle;

  /// A widget. It will display as the background of each menu.
  /// If not set it will not be displayed
  /// bgMenu is optional
  final Widget? bgMenu;

  /// Distance of list menu between containerMenuView
  /// Default: EdgeInsets.all(8.0)
  final EdgeInsets? paddingMenu;

  /// Distance of list menu on header view between headerView
  /// Default: EdgeInsets.all(8.0)
  final EdgeInsets? paddingCollapseMenu;

  /// Distance of each tile between item menu
  /// Default: EdgeInsets.fromLTRB(4.0, 0, 4.0, 8.0);
  final EdgeInsets? paddingTitle;

  /// Color of background view.
  /// It will gradually app appear as the user scrolls up.
  /// And gradually disappears as the user scrolls down.
  /// Default color = white
  final Color? colorBgChange;

  /// Color of view remain to scroll
  /// Default color = white
  final Color? colorFillRemain;

  /// Top distance between functionView and containerMenuView.
  /// Default: 16.0
  final double functionViewPaddingTop;

  /// Called when the view is scrolled. With a value range from 0 to 1.
  /// Value 0 corresponds to the position where the view has not scrolled,
  /// value 1 corresponds to the view scrolling to or past the position
  /// where the menu moves to the header
  final ValueChanged<double>? onFinishProgress;

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
            backgroundHeader: widget.bgHeaderView ?? Container(color: Colors.blue),
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
