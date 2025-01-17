import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:linear_timer/linear_timer.dart';
import 'app_singleton.dart';
import 'background_service.dart';
import 'main.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'database.dart'; // Import pour la classe Message
import 'traitement.dart';
import 'package:talker_flutter/talker_flutter.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key, required this.title, required this.args});

  final String title;
  final MyappArgs args;

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with TickerProviderStateMixin {
  late AppDatabase _database;
  late BackgroundServiceManager _backgroundServiceManager;
  String currentTime = "Pas encore reçu";

  bool light = false;
  late Traitement traitement;
  List<dynamic>? _liste;

  late LinearTimerController timerController = LinearTimerController(this);

  @override
  void initState() {
    super.initState();
    if (widget.args.backgroundService == null) {
      print("Erreur: backgroundService est null (ceci ne devrait pas arriver si l'initialisation dans main.dart est correcte)");
      return; // Très important de retourner ici pour éviter l'erreur
    }
    _backgroundServiceManager = widget.args.backgroundService!; // Assuming args is non-nullable
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
      }
      else if (data != null && data.containsKey('hide')) {
        EasyLoading.dismiss();
      }
    });
  }

  @override
  void dispose() {
// Nettoyer les ressources dans Traitement
    traitement.dispose();
    // Fermer la base Drift
    _database.close();

    timerController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    // Accéder au logger depuis n'importe où
    final logger = AppLogger();

    // Initialiser le singleton
    final appSingleton = AppSingleton();

    // Utiliser les instances partagées
    final database = appSingleton.database;
    final traitement = appSingleton.traitement;

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
            child:
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
                      child: StreamBuilder<List<Message>>(
                        stream: traitement.messageStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("Aucune donnée disponible"));
                          }
                          final messages = snapshot.data!;
                          return ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return ListTile(
                                title: Text(message.destinataire),
                                subtitle: Text(message.message),
                                trailing: Text(message.messageId),
                              );
                            },
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
            arguments: widget.args?['Logger']);
        break;
      case 'Settings':
        Navigator.pushNamed(context, '/settings', arguments: widget.args);
        break;
    }
  }

  updateTimer(var a) {
    a.timerController.value;
  }

}
