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

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
        body: CoordinatorMenuWidget(
            functionView: _getListFunction(),
            extendView: _getExtendView(),
            fixedView: _getFixedView(),
            alphaEffect: true,
            paddingMenu: const EdgeInsets.symmetric(vertical: 16),
            paddingCollapseMenu: const EdgeInsets.symmetric(horizontal: 50),
            menus: [
              _getItemMenu(Icons.catching_pokemon, "Catch"),
              _getItemMenu(Icons.catching_pokemon, "Cloud"),
              _getItemMenu(Icons.catching_pokemon, "Download"),
              _getItemMenu(Icons.catching_pokemon, "Upload")
            ],
            collapseMenus: [
              _getItemMenuCollapse(Icons.catching_pokemon),
              _getItemMenuCollapse(Icons.cloud_circle),
              _getItemMenuCollapse(Icons.cloud_download),
              _getItemMenuCollapse(Icons.cloud_upload),
            ],
        ));
  }


  Widget _getItemMenu(IconData iconData, String text){
    return Container(
      height: 50.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54))
        ],
      ),
    );
  }

  Widget _getItemMenuCollapse(IconData iconData){
    return Icon(
      iconData,
      color: Colors.white,
      size: 30.0,
    );
  }

  Widget _getFixedView(){
    return Container(
      height: 50.0,
      color: Colors.blue,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_circle),
          Icon(Icons.circle_notifications),
        ],
      ),
    );
  }

  Widget _getExtendView(){
    return Container(
      height: 200,
      color: Colors.blue,
    );
  }

  Widget _getListFunction() {
    return SliverGrid.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4
    ), itemBuilder: (context, index) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance),
          Text("Function")
        ],
      );
    },
    itemCount: 4);
  }

}
