import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:talker_flutter/talker_flutter.dart';
import 'database.dart'; // fichier Drift
import 'package:another_telephony/telephony.dart' as telephony;

class Traitement {
  // Déclarez un Completer pour suivre l'état du traitement
  Completer<void>? completer;
  static bool _isPaused  = false;
  late StreamController<void> _pauseController;
  late final telephony.SmsSendStatusListener _SmsSendStatusListener;
  late final AppDatabase _database;
  late final Function(String message, {TalkerLogType level}) _logMessage;
  late final Function(String title, String body) _notification;
  late List<dynamic> _jsonData;

  Traitement (AppDatabase database, {bool paused = true,
    required void Function(String message, {TalkerLogType level}) logMessage,
    required void Function(String title, String body) notification}) {
    _isPaused = paused;
    _database = database;
    _pauseController = StreamController<void>.broadcast();
    _logMessage = logMessage;
    _notification = notification;
    _SmsSendStatusListener = (telephony.SendStatus status) {
      _logMessage("Suivi de l'envoi : ${status.toString()}", level: TalkerLogType.debug);
    };
  }

  Future<void> loadState() async {
    // Simule la récupération de l'état sauvegardé
    debugPrint('État chargé : étape');
  }

  Future<void> saveState(int step) async {
    // Simule la sauvegarde de l'état
    debugPrint('Sauvegarde de l\'état : étape $step');
    await Future.delayed(Duration(milliseconds: 500)); // Simule une écriture en DB
    // _setSavedState(step);
  }

  Future<void> doWork(ServiceInstance service, SharedPreferences prefs) async {

    if (_isPaused) {
      _database.customStatement('select 1');
      _logMessage("Traitement en pause, sortie.", level: TalkerLogType.info);
      _notification("Traitement en pause", "Sortie du traitement.");

      return;
    }
    debugPrint("Entree doWork");

    await _checkPause();
    await _traiteCache(service, prefs);
    await _checkPause();

    service.invoke('querydb', {'show': 'Query DB ...'});
    Response? resp = await _getList(prefs);
    service.invoke('querydb', {'hide': ''});


    if ((resp != null) && (resp.contentLength! > 0)) {
      _jsonData = jsonDecode(resp.body);

      for (var item in _jsonData) {
        try {
          if (await _database.isMessageExist(item['messageId'], item['jobId']) == 0) {
            await _database.insertMessage(
              MessagesCompanion(
                number: drift.Value(item['number']),
                message: drift.Value(item['message']),
                messageId: drift.Value(item['messageId']),
                jobId: drift.Value(item['jobId']),
                retrieveDate: drift.Value(DateTime.now()),
              ),
            );
          }
        } catch (e) {
          debugPrint("Erreur lors de l'insertion du message : $e");
        }
      }
    }

    if (!completer!.isCompleted) {
      completer!.complete(); // Signaler la fin du traitement
    }
  }

  Future<void> _traiteCache(ServiceInstance service, SharedPreferences prefs) async {
    final List<Message> messages = await _database.getMessagesNotSent();

    _notification("Traitement terminé", "Nombre de messages : ${messages.length}");

    debugPrint("requete terminee");

    for (var message in messages) {
      await _checkPause();
      debugPrint("envoi de ${message.id}");
      await Future.delayed(const Duration(seconds: 2));
      telephony.Telephony.instance.sendSms(
          to: "1234567890",
          message: "May the force be with you!",
          statusListener: _SmsSendStatusListener
      );
      debugPrint("Envoyé");
      await _database.updateMessageSent(
        message.id,
        message.jobId,
      );

    }
  }

  Future<void> _checkPause() async {
    if (_isPaused) {
      debugPrint('Traitement mis en pause. Attente de la reprise...');
      await _pauseController.stream.first;
      debugPrint('Traitement repris.');
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
    _logMessage("Requête vers $url", level: TalkerLogType.info);
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

  void stopProcessing() {
    completer?.complete(); // Compléter le Completer si il existe
  }

  // Méthode pour nettoyer les ressources
  Future<void> dispose() async {
    await _database.close();
    _pauseController.close(); // Fermer aussi _pauseController
  }
}
