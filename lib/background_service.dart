import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'traitement.dart';
import 'database.dart';

class BackgroundServiceManager {
  late final FlutterBackgroundService _service;
  static Timer? _timer;

  static late final SendPort? UISendPort;

  // Instance statique privée
  static final BackgroundServiceManager _instance =
      BackgroundServiceManager._internal();

  // Factory pour retourner l'instance unique
  factory BackgroundServiceManager() {
    return _instance;
  }

  // Constructeur privé
  BackgroundServiceManager._internal() {
    _service = FlutterBackgroundService();
  }

  bool isRunning = false;
  get dataStream => null;

  void initialize() async {
    // final service = FlutterBackgroundService();
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: 'my_foreground_channel',
        initialNotificationTitle: 'Service en cours',
        initialNotificationContent: 'Le service est en arrière-plan',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        // onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    // Démarre le service
    await _service.startService();
  }

  // Fonction qui sera exécutée lorsque le service démarre
  static void onStart(ServiceInstance service) async {
    debugPrint("onStart exécutée");

    // Ne peut etre executé que dans le process principal
    // DartPluginRegistrant.ensureInitialized();

    // Initialiser le ReceivePort pour l'isolate de fond
    final backgroundReceivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
        backgroundReceivePort.sendPort, 'messageStreamPort');
    final SendPort? UIStreamSendPort =
        IsolateNameServer.lookupPortByName('UIStreamPort');

    UISendPort = IsolateNameServer.lookupPortByName('UIPort');

    backgroundReceivePort.listen((message) {
      if (message is SendPort) {
        debugPrint("sendport recu");
        var mainSendPort = message;
      } else {
        debugPrint("Message reçu dans onStart: $message");
      }
    });

    final prefs = await SharedPreferences.getInstance();
    // Initialiser la base de données
    final database = AppDatabase();
    logMessage("Database initialized", level: TalkerLogType.info);


    // Initialiser le traitement
    final traitement = Traitement(database, logMessage: logMessage, notification: notification);
    logMessage("Traitement initialized", level: TalkerLogType.info);

    final completer = Completer<void>();
    traitement.completer = completer;

    // Créer un flux pour surveiller les messages
    database
        .watchAllMessages()
        /* .debounceTime(const Duration(milliseconds: 5000)) */
        .listen((messages) {
      // Envoyer les données au principal à chaque mise à jour
      debugPrint("Messages updated: ${messages.length} messages");
      UIStreamSendPort?.send(messages);
    });

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "Service actif",
        content: "Exécution en arrière-plan",
      );

      service.on('stopService').listen((event) async {
        if (traitement.completer!.isCompleted) {
          await database.close(); // Fermeture de la base de données
          service.stopSelf();
        } else {
          debugPrint("Attente fin de traitement");
          await traitement.completer!.future;
          await database.close(); // Fermeture de la base de données
          service.stopSelf();
        }
      });

      /*
      service.on('startTraitement').listen((event) {
        traitement.doWork(service, prefs);
        _startTimer(service, traitement); // Démarrer le timer ici
      });

      service.on('stopTraitement').listen((event) {
        traitement.stopProcessing();
      });
*/
      service.on('pause').listen((_) {
        traitement.pause();
        _stopTimer();
        service.invoke('update', {"current_time": 'Pause'});
        logMessage("Traitement en pause", level: TalkerLogType.info);
        // notification("Traitement en pause", "Le traitement est en pause.");
      });

      service.on('resume').listen((_) {
        traitement.resume();
        traitement.doWork(service, prefs);
        _startTimer(service, traitement);
        logMessage("Traitement repris", level: TalkerLogType.info);
        // notification("Traitement repris", "Le traitement a été repris.");
      });

      service.on('update').listen((event) {
        UIStreamSendPort?.send(event);
      });

      // Lance le Traitement, en pause
      traitement.pause();
      traitement.doWork(service, prefs);
    }
  }

  static void _startTimer(ServiceInstance service, Traitement traitement) {
    return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      debugPrint("Heure actuelle : ${DateTime.now()}");
      service.invoke('update', {
        "current_time": DateTime.now().toIso8601String(),
      });
    });
  }

  static void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  /*
  //Méthode pour declencher startProcessing depuis Accueil
  void startTraitement() {
    _service.invoke("startTraitement");
  }

  //Méthode pour declencher stopProcessing depuis Accueil
  void stopTraitement() {
    _service.invoke("stopTraitement");
  }
*/

  void pauseTraitement() {
    _service.invoke('pause');
  }

  void resumeTraitement() {
    _service.invoke('resume');
  }

  static void logMessage(String message, {TalkerLogType level = TalkerLogType.debug}) {
    UISendPort?.send({'command': 'logMessage', 'message': message, 'level': level.name});
  }

  static void notification(String title, String body) {
    UISendPort?.send({'command': 'notification', 'title': title, 'body': body});
  }

  static bool onIosBackground(ServiceInstance service) {
    debugPrint("iOS Background Task exécutée");
    return true;
  }
}
