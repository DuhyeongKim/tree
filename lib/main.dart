import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:treeplanet/board.dart';
// import 'package:treeplanet/direct_message.dart';
import 'package:treeplanet/profile.dart';
import 'package:treeplanet/screens/chats/chats_screen.dart';

import 'home.dart';
import 'login.dart';
import 'productView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
      routes: {
        '/home': (context) => HomePage(),
        '/product': (context) => ProductPage(),
        '/board': (context) => BoardPage(),
        '/chat': (context) => ChatsScreen(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}
