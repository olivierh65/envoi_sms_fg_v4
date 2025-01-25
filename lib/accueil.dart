import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:linear_timer/linear_timer.dart';
import 'background_service.dart';
import 'main.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'database.dart'; // Import pour la classe Message

class Accueil extends StatefulWidget {
  const Accueil({super.key, required this.title, required this.args});

  final String title;
  final MyappArgs args;

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with TickerProviderStateMixin {
  late BackgroundServiceManager _backgroundServiceManager;
  String currentTime = "Pas encore reçu";

  bool light = false;

  late LinearTimerController timerController = LinearTimerController(this);
  late final Stream<List<Message>> myDataStream;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    if (widget.args.backgroundService == null) {
      print(
          "Erreur: backgroundService est null (ceci ne devrait pas arriver si l'initialisation dans main.dart est correcte)");
      return; // Très important de retourner ici pour éviter l'erreur
    }

    _backgroundServiceManager =
        widget.args.backgroundService!; // Assuming args is non-nullable

    // Créer le Stream Drift une seule fois

    _initBackgroundService(); // Appel pour enregistrer les écouteurs
  }

  Future<void> _initBackgroundService() async {
    FlutterBackgroundService().on('update').listen((data) {
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
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accéder au logger depuis n'importe où
    final logger = AppLogger();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          Switch(
            // This bool value toggles the switch.
            value: light,
            activeColor: Colors.red,
            onChanged: (bool value) async {
              // This is called when the user toggles the switch.
              setState(() {
                light = value;
              });
              final service = FlutterBackgroundService();
              if (!value) {
                AppLogger.talker.info("Arrêt");
                _backgroundServiceManager.pauseTraitement();
              } else {
                AppLogger.talker.info("Démarrage");
                _backgroundServiceManager.resumeTraitement();
              }
            },
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
                  child: StreamBuilder<List<Message>>(
                    stream: _backgroundServiceManager.messageStream, // Utiliser le Stream de BackgroundServiceManager
                    // initialData: const [],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Aucune donnée disponible"));
                      }
                      final messages = snapshot.data ??
                          []; // snapshot.data ne sera jamais null
                      if (messages.isEmpty &&
                          snapshot.connectionState == ConnectionState.done) {
                        return const Center(child: Text("Aucun message"));
                      }
                      return Scrollbar(
                        controller: _scrollController,
                        thumbVisibility:
                            true, // Pour afficher la scrollbar en permanence
                        child: ListView.builder(
                          controller: _scrollController, // Associer le même ScrollController au ListView
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            late final icon;
                            if (message.sentDate == null) {
                              icon = getStatusIcon('waiting');
                            } else if (message.sentDate != null &&
                                message.deliveredDate == null) {
                              icon = getStatusIcon('sending');
                            } else if (message.sentDate != null &&
                                message.deliveredDate != null) {
                              icon = getStatusIcon('delivered');
                            } else {
                              icon = getStatusIcon('other');
                            }
                            return ListTile(
                              leading: icon, // Icône en début de ligne
                              title: Text(message.number ?? 'xx'),
                              subtitle: Text(message.message! ?? '....',
                                  overflow: TextOverflow.ellipsis),
                              trailing: Text(message.messageId! ?? 'yy'),
                            );
                          },
                        ),
                      );
                    },
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
        Navigator.pushNamed(context, "/logs",
            arguments: widget.args['Logger']);
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
