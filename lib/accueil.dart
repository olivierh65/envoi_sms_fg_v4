import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:linear_timer/linear_timer.dart';
import 'MessagesStreamBuilder.dart';
import 'background_service.dart';
import 'main.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// Import pour la classe Message

class Accueil extends StatefulWidget {
  final String title;
  final MyappArgs args;
  final ReceivePort receivePort;

  const Accueil({
    required this.title,
    required this.args,
    required this.receivePort,
    super.key,
  });

  @override
  State<Accueil> createState() => _AccueilState();

}

class _AccueilState extends State<Accueil> with TickerProviderStateMixin {
  late final BackgroundServiceManager _backgroundServiceManager;
  String currentTime = "Pas encore reçu";

  bool _light = false;

  late LinearTimerController timerController = LinearTimerController(this);
  late final Stream<List<Map<String, dynamic>>> myDataStream;

  @override
  void initState() {
    super.initState();
    if (widget.args.backgroundService == null) {
      debugPrint(
          "Erreur: backgroundService est null (ceci ne devrait pas arriver si l'initialisation dans main.dart est correcte)");
      return; // Très important de retourner ici pour éviter l'erreur
    }

    _backgroundServiceManager =
        BackgroundServiceManager(); // recupere le singleton

    myDataStream = widget.receivePort.cast<List<Map<String, dynamic>>>().asBroadcastStream();
    // myDataStream = widget.receivePort.cast<List<Message>>().asBroadcastStream(); // Cast des données reçues en Stream<List<Message>>

  _initBackgroundService();
  }


  Future<void> _initBackgroundService() async {
    FlutterBackgroundService().on('update').listen((data) {
      debugPrint('Received update: $data');
      if (data != null && data.containsKey('current_time')) {
        setState(() {
          currentTime = data['current_time'];
        });
      }
    });

    FlutterBackgroundService().on('querydb').listen((data) {
      if (data != null && data.containsKey('show')) {
        String status = data['show'];
        // Afficher le statut dans EasyLoading
        EasyLoading.show(status: status);
      } else if (data != null && data.containsKey('hide')) {
        EasyLoading.dismiss();
      }
    });

    /*
    widget.args.backgroundService!.messageStream.listen(
      (List<Message> messages) {
        print('Nouvelles données du Stream : $messages');
        for (var message in messages) {
          print(
              "Message number : ${message.number}, message : ${message.message}");
        }
      },
      onError: (error) {
        print('Erreur dans le Stream : $error');
      },
      onDone: () {
        print('Stream terminé.');
      },
    );
     */
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  void _onSwitchChanged(bool value) {
    // This is called when the user toggles the switch.
    debugPrint("Changement switch");
    setState(() {
      _light = value;
    });

    if (!value) {
      AppLogger.talker.info("Arrêt");
      _backgroundServiceManager.pauseTraitement();
    } else {
      AppLogger.talker.info("Démarrage");
      _backgroundServiceManager.resumeTraitement();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accéder au logger depuis n'importe où

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          Switch(
            // This bool value toggles the switch.
            value: _light,
            activeColor: Colors.red,
            onChanged: _onSwitchChanged
          ),
          // CheckboxSend(widget.args!),
           PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logs', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: LinearTimer(
                            duration: const Duration(),
                            controller: timerController,
                            minHeight: 16,
                            color: Colors.indigoAccent,
                            onUpdate: updateTimer(this),
                            onTimerEnd: () {
                              Future.delayed(const Duration(seconds: 2), () {
                                timerController.reset();
                              });
                            },
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Delay before next DB query",
                            style: TextStyle(
                              fontSize: 25,
                              backgroundColor: Colors.transparent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(child: Text("Heure actuelle : $currentTime")),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                child: Center(
                   child: MessagesStreamBuilder(
                    mapStream: myDataStream, // Passer le Stream
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logs':
        /* Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TalkerScreen(talker: globals.Logger),*/
        Navigator.pushNamed(context, "/logs", arguments: widget.args['Logger']);
        break;
      case 'Settings':
        Navigator.pushNamed(context, '/settings', arguments: widget.args);
        break;
    }
  }

  updateTimer(var a) {
    a.timerController.value;
  }

  Icon getStatusIcon(String status) {
    switch (status) {
      case "waiting":
        return Icon(Icons.access_time, color: Colors.grey);
      case "in_progress":
        return Icon(Icons.autorenew, color: Colors.blue); // Icône de chargement
      case "sending":
        return Icon(Icons.send, color: Colors.blue);
      case "delivering":
        return Icon(Icons.delivery_dining, color: Colors.blue);
      case "delivered":
        return Icon(Icons.check_circle, color: Colors.green);
      case "failed":
        return Icon(Icons.error, color: Colors.red);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }
  // Méthode pour forcer la reconstruction du StreamBuilder
}
