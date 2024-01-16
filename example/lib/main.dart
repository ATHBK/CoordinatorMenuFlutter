import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coordinator_menu/coordinator_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CoordinatorMenuWidget(
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
              ),
            ],
          ),
        )
    );
  }

  Widget _getBg(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bg.png", height: 160.0, width: double.infinity, fit: BoxFit.fill),
        const SizedBox(height: 80,)
      ],
    );
  }

  List<Widget> _getMenus(){
    return [
      _getItemMenu(Icons.account_balance_wallet),
      _getItemMenu(Icons.account_balance_wallet),
      _getItemMenu(Icons.account_balance_wallet),
      _getItemMenu(Icons.account_balance_wallet)
    ];
  }

  List<Widget> _getTitle(){
    return [
      _getTextMenu("Menu 1"),
      _getTextMenu("Menu 2"),
      _getTextMenu("Menu 3"),
      _getTextMenu("Menu 4")
    ];
  }

  Widget _getBgMenu(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(5)
      ),
      width: 50.0,
      height: 50.0,
    );
  }

  Widget _getItemMenu(IconData iconData){
    return Icon(
      iconData,
      color: Colors.white,
      size: 30.0,
    );
  }

  Widget _getTextMenu(String text){
    return Text(
      text,
      textAlign: TextAlign.center,
    );
  }

  Widget _getHeaderView(){
    return const SizedBox(
      width: double.maxFinite,
      height: 50.0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: Colors.white, size: 30,),
            Expanded(child: SizedBox()),
            Icon(Icons.notification_add_outlined, color: Colors.white, size: 30),
            SizedBox(width: 16.0,),
            Icon(Icons.message_outlined, color: Colors.white, size: 30,),
          ],
        ),
      ),
    );
  }

  Widget _getBgHeaderView(){
    return Container(
      width: double.maxFinite,
      height: 50.0,
      color: Colors.blue,
    );
  }


  SliverMultiBoxAdaptorWidget _getListFunction() {
    return SliverGrid.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4
    ), itemBuilder: (context, index) {
      return Container(
        color: Colors.white,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance),
            Text("Function")
          ],
        ),
      );
    },
    itemCount: 4);
  }

  Widget _getContainerView(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
