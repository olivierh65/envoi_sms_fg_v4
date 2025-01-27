import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:envoi_sms_fg_v4/accueil.dart';
import 'package:envoi_sms_fg_v4/main.dart';
import 'package:envoi_sms_fg_v4/settings.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings, MyappArgs args, MyApp parent) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (context) => Accueil(
              title: "Appli Test",
              args: args,
              receivePort: parent.foregroundReceivePort, // Passer ReceivePort
                ),
            settings: RouteSettings(name: settings.name, arguments: args));
      case '/settings':
        return MaterialPageRoute(
            builder: (context) => Settings(
                  // args: args,
                ));
      case '/logs':
        return MaterialPageRoute(
            builder: (context) =>
                TalkerScreen(talker: AppLogger.talker,
                appBarTitle: 'Logs',)
        );
      default:
        return pageNotFound();
    }
  }

  static MaterialPageRoute pageNotFound() {
    return MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Error"), centerTitle: true),
            body: const Center(
              child: Text("Page not found"),
            )));
  }
}
