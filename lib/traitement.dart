import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'database.dart'; // fichier Drift

class Traitement {
  // Déclarez un Completer pour suivre l'état du traitement
  late final Completer<void> _completer;
  static bool _isPaused  = false;
  late StreamController<void> _pauseController;
  final AppDatabase database; // Base Drift injectée
  final StreamController<List<Message>> _streamController = StreamController.broadcast();

  Traitement (this.database, {bool paused = true}) {
    _isPaused = paused;
    _completer = Completer();
    _pauseController = StreamController<void>.broadcast();
  }

  Stream<List<Message>> get messageStream => _streamController.stream;

  Completer<void> get completer => _completer;

  Future<void> loadState() async {
    // Simule la récupération de l'état sauvegardé
    print('État chargé : étape');
  }

  Future<void> saveState(int step) async {
    // Simule la sauvegarde de l'état
    print('Sauvegarde de l\'état : étape $step');
    await Future.delayed(Duration(milliseconds: 500)); // Simule une écriture en DB
    // _setSavedState(step);
  }

  Future<void> doWork(ServiceInstance service, SharedPreferences prefs) async {
    late DateTime lastList;
    List<dynamic>? data;

    if (_isPaused) {
      print("Traitement en pause, sortie.");
      return;
    }
    print("Entree doWork");

    await _checkPause();

    service.invoke('querydb', {'show': 'Query DB ...'});
    Response? resp = await _getList(prefs);
    service.invoke('querydb', {'hide': ''});

    lastList = DateTime.now();

    if ((resp != null) && (resp.contentLength! > 0)) {
      List<dynamic> jsonData = jsonDecode(resp.body);

      for (var item in jsonData) {
        try {
          await database.insertMessage(
            MessagesCompanion(
              destinataire: Value(item['destinataire']),
              message: Value(item['message']),
              messageId: Value(item['messageId']),
              jobId: Value(item['jobId']),
              retrieveDate: Value(DateTime.now()),
            ),
          );
        } catch (e) {
          print("Erreur lors de l'insertion du message : $e");
        }
      }
      _updateMessageStream(); // Mettre à jour le stream après l'insertion
    }

    if (!completer.isCompleted) {
      completer.complete(); // Signaler la fin du traitement
    }
  }

  Future<void> _updateMessageStream() async {
    final updatedMessages = await database.getAllMessages();
    _streamController.add(updatedMessages);
  }

  Future<void> _checkPause() async {
    if (_isPaused) {
      print('Traitement mis en pause. Attente de la reprise...');
      await _pauseController.stream.first;
      print('Traitement repris.');
    }
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    if (_isPaused) {
      _isPaused = false;
      _pauseController.add(null); // Envoie le signal pour débloquer `_checkPause`
    }
  }

  _getList(SharedPreferences prefs) async {
    final String? url = prefs.getString('sendUrl');
    if (url == null) {
      return null;
    }
    try {
      Response response = await post(
        Uri.parse(url),
        body: jsonEncode(<String, String>{
          'deviceId': prefs.getString('deviceId')!,
          'apiKey': prefs.getString('webApiKey')!,
        }),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return response;
    } catch (e) {
      // Logger.error(e.toString());
      // sendPort.send('C$e');
      log(e.toString());
      return null;
    }
  }

  // Méthode pour nettoyer les ressources
  void dispose() {
    _streamController.close();
    _pauseController.close(); // Fermer aussi _pauseController
  }
}
