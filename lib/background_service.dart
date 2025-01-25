import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'traitement.dart';
import 'database.dart';


class BackgroundServiceManager {
  final FlutterBackgroundService _service = FlutterBackgroundService();
  static Timer? _timer;
  late final AppDatabase _database;
  late final Traitement _traitement;

  static final BackgroundServiceManager _instance = BackgroundServiceManager._internal(); // Instance privée

  factory BackgroundServiceManager() {
    return _instance; // Retourner l'instance unique
  }

  BackgroundServiceManager._internal() {
    _database = AppDatabase();
    _traitement = Traitement();
  }

  AppDatabase get database => _database;

  Traitement get traitement => _traitement;

  final _messageStreamController = StreamController<List<Message>>.broadcast();

  get messageStreamController => _messageStreamController;

  Stream<List<Message>> get messageStream => _messageStreamController.stream;

  bool isRunning = false;
  get dataStream => null;

  Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
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
    DartPluginRegistrant.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    // Accéder à l'instance unique via BackgroundServiceManager()
    final backgroundServiceManager = BackgroundServiceManager();


    final completer = Completer<void>();
    backgroundServiceManager._traitement.completer = completer;

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "Service actif",
        content: "Exécution en arrière-plan",
      );

      service.on('stopService').listen((event) async {
        if (backgroundServiceManager._traitement.completer!.isCompleted) {
          await backgroundServiceManager._database.close(); // Fermeture de la base de données
          service.stopSelf();
        } else {
          print("Attente fin de traitement");
          await backgroundServiceManager._traitement.completer!.future;
          await backgroundServiceManager._database.close(); // Fermeture de la base de données
          service.stopSelf();
        }
      });

      service.on('startTraitement').listen((event) {
        backgroundServiceManager._traitement.doWork(service, prefs);
        _startTimer(service, backgroundServiceManager._traitement); // Démarrer le timer ici
      });

      service.on('stopTraitement').listen((event) {
        backgroundServiceManager._traitement.stopProcessing();
      });

      service.on('pause').listen((_) {
        backgroundServiceManager._traitement.pause();
        _stopTimer();
        service.invoke('update', {"current_time": 'Pause'});
      });

      service.on('resume').listen((_) {
        backgroundServiceManager._traitement.resume();
        backgroundServiceManager._traitement.doWork(service, prefs);
        _startTimer(service, backgroundServiceManager._traitement);
      });
    }
  }

  static void _startTimer(ServiceInstance service, Traitement traitement) {
    _timer=Timer.periodic(const Duration(seconds: 5), (timer) async {
      print("Heure actuelle : ${DateTime.now()}");
      service.invoke('update', {
        "current_time": DateTime.now().toIso8601String(),
      });
    });
  }
  static void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer=null;
    }
  }

  //Méthode pour declencher startProcessing depuis Accueil
  void startTraitement() {
    _service.invoke("startTraitement");
  }

  //Méthode pour declencher stopProcessing depuis Accueil
  void stopTraitement() {
    _service.invoke("stopTraitement");
  }

  void pauseTraitement() {
    _service.invoke('pause');
  }

  void resumeTraitement() {
    _service.invoke('resume');
  }

  void dispose() {
    _database.close();
  }

  static bool onIosBackground(ServiceInstance service) {
    print("iOS Background Task exécutée");
    return true;
  }
}

