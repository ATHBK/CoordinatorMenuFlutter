# Coordinator Menu Widget
[![pub package](https://img.shields.io/pub/v/coordinator_menu)](https://pub.dev/packages/coordinator_menu) [![License: APACHE-2.0](https://img.shields.io/badge/license-Apache-blue)](https://opensource.org/license/apache-2-0/)

Have you ever seen the ui/ux menu of e-wallet applications ? This library will cover that for you

## Demo

![demo](https://raw.githubusercontent.com/ATHBK/CoordinatorMenuFlutter/main/gif/vidma_recorder_17012024_163430-ezgif.com-video-to-gif-converter.gif)

## Understand layout

![layout](https://raw.githubusercontent.com/ATHBK/CoordinatorMenuFlutter/main/gif/Screenshot_layer.png)

## Usage
To use this plugin, add `coordinator_menu` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### Basic

```dart
CoordinatorMenuWidget(
headerView: _getHeaderView(),
bgHeaderView: _getBgHeaderView(),
bg: _getBg(),
colorBgChange: Colors.white,
containerMenuView: _getContainerView(),
bgMenu: _getBgMenu(),
menus: _getMenus(),
listTitle: _getTitle(),
paddingMenu: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
functionView: _getListFunction(),
paddingCollapseMenu: const EdgeInsets.fromLTRB(62, 8, 108, 8),
),
```

## Property

| Name | R/O | Description                                                                                                                  |
| ------ | ------ |------------------------------------------------------------------------------------------------------------------------------|
| bg | R | This view is the background from the header to the menu view container                                                       |
| headerView | R | Fixed view at the top. This view can contain child views on the left or right depending on your ui/ux                        |
| menus | R | A list widget. It is the main functions of the application. As the view is scrolled, the menu will slowly move up the header |
| listTitle | R | A list widget. Title of each menu. It should be a text widget.                                                               |
| functionView | R | The sliver list or sliver grid view. This view contains smaller functions of the application                                 |
| bgHeaderView | O | A background of header. It will appear when the user scrolls up and hide when scrolling down.                                |
| colorBgChange | O | Color of background view. It will gradually app appear as the user scrolls up. And gradually disappears as the user scrolls down.                                              |
| containerMenuView | O | View wraps the list menu and list Title.                                                                                                                             |
| bgMenu | O | A widget. It will display as the background of each menu.                                                                                                                             |
| paddingMenu | O | Distance of list menu between containerMenuView                                                                                                                             |
| paddingCollapseMenu | O | Distance of list menu on header view between headerView                                                                                                                             |
| paddingTitle | O | Distance of each tile between item menu                                                                                                                             |
| colorFillRemain | O | Color of view remain to scroll                                                                                                                             |
| functionViewPaddingTop | O | The sliver list or sliver grid view. This view contains smaller functions of the application                                 |
| onFinishProgress | O | Called when the view is scrolled. With a value range from 0 to 1.                                                                                                                             |
