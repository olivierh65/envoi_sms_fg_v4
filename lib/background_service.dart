import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'app_singleton.dart';
import 'traitement.dart';
import 'database.dart';


class BackgroundServiceManager {
  final FlutterBackgroundService _service = FlutterBackgroundService();
  final AppDatabase _database;
  final Traitement _traitement; // Reçu via le constructeur
  static Timer? _timer;
  static Traitement get _traitementStatic => _backgroundServiceManagerStatic._traitement;
  static late BackgroundServiceManager _backgroundServiceManagerStatic;

  BackgroundServiceManager(this._database, this._traitement);

  bool isRunning = false;
  get dataStream => null;

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // Fonction qui sera appelée pour démarrer le service
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: 'my_foreground_channel',
        initialNotificationTitle: 'Service en cours',
        initialNotificationContent: 'Le service est en arrière-plan',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    // Démarre le service
    await _service.startService();
  }

  // Fonction qui sera exécutée lorsque le service démarre
  static void onStart(ServiceInstance service) async {
    final appSingleton = AppSingleton();
    final database = appSingleton.database;
    final traitement = appSingleton.traitement;
    // Obtenez l'instance de SharedPreferences dans le service en arrière-plan
    final prefs = await SharedPreferences.getInstance();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "Service actif",
        content: "Exécution en arrière-plan",
      );

      service.on('stopService').listen((event) async {
        if (traitement.completer.isCompleted) {
          service.stopSelf();
        } else {
          print("Attente fin de traitement");
          await traitement.completer.future;
        }
      });

      service.on('startTraitement').listen((event) {
        traitement.doWork(service, prefs);
        _startTimer(service, traitement); // Démarrer le timer ici
      });

      service.on('pause').listen((_) {
        traitement.pause();
        _stopTimer();
        service.invoke('update', {"current_time": 'Pause'});
      });

      service.on('resume').listen((_) {
        traitement.resume();
        traitement.doWork(service, prefs);
        _startTimer(service, traitement);
      });
    }
  }

  static void _startTimer(ServiceInstance service, Traitement traitement) {
    _timer=Timer.periodic(const Duration(seconds: 5), (timer) async {
      print("Heure actuelle : ${DateTime.now()}");
      service.invoke('update', {
        "current_time": DateTime.now().toIso8601String(),
      });
      traitement.doWork(service, await SharedPreferences.getInstance());
    });
  }
  static void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer=null;
    }
  }

  void startTraitement() {
    _service.invoke('startTraitement');
  }

  void pauseTraitement() {
    _service.invoke('pause');
  }

  void resumeTraitement() {
    _service.invoke('resume');
  }

  static bool onIosBackground(ServiceInstance service) {
    print("iOS Background Task exécutée");
    return true;
  }
}

