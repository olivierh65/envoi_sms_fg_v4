import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:talker_flutter/talker_flutter.dart';
import 'app_preferences.dart';
import 'database.dart'; // fichier Drift
import 'package:another_telephony/telephony.dart' as telephony;

class Traitement {
  // Déclarez un Completer pour suivre l'état du traitement
  Completer<void>? completer;
  static bool _isPaused = false;
  late StreamController<void> _pauseController;
  late final telephony.SmsSendStatusListener _SmsSendStatusListener;
  late final AppDatabase _database;
  late final AppPreferences _preferences;
  late final Function(String message, {TalkerLogType level}) _logMessage;
  late final Function(String title, String body) _notification;
  late List<dynamic> _jsonData;
  static late DateTime _lastGetMessages;
  static late DateTime _lastSmsSent;

  Traitement(AppDatabase database,
      {
        required AppPreferences preferences,
        bool paused = true,
      required void Function(String message, {TalkerLogType level}) logMessage,
      required void Function(String title, String body) notification}) {
    _isPaused = paused;
    _database = database;
    _preferences = preferences;
    _pauseController = StreamController<void>.broadcast();
    _logMessage = logMessage;
    _notification = notification;
    _SmsSendStatusListener = (telephony.SendStatus status) {
      _logMessage("Suivi de l'envoi : ${status.toString()}",
          level: TalkerLogType.debug);
    };
    _lastGetMessages = DateTime.fromMicrosecondsSinceEpoch(0);
    _lastSmsSent = DateTime.fromMicrosecondsSinceEpoch(0);
  }

  Future<void> doWork(ServiceInstance service, SharedPreferences prefs) async {
    final List<Message> messages = await _database.getMessagesNotSent();
    _notification(
        "Traitement terminé", "Nombre de messages : ${messages.length}");
    debugPrint("requete terminee");
    _database.customStatement('select 1');
    _logMessage("Update Stream Drift", level: TalkerLogType.info);
    // _notification("doWork", "Update Stream Drift");

    debugPrint("Entree doWork");

    while (true) {
      await _checkPause();
      // Reprend les traitements sauvegardés et les traite
      await _traiteCache(service, _preferences);
      await _checkPause();

      // Recupere les données depuis le serveur
      await _getMessages(service, _preferences);
      await _checkPause();
    }
    if (!completer!.isCompleted) {
      completer!.complete(); // Signaler la fin du traitement
    }
  }

  Future<void> _getMessages(
      ServiceInstance service, AppPreferences prefs) async {
    Duration nextQuery = _lastGetMessages
        .add(prefs.getDuration('queryInterval')!)
        .difference(DateTime.now());
    if (!nextQuery.isNegative) {
      await Future.delayed(nextQuery);
    }
    // Recupere les données depuis le serveur
    service.invoke('querydb', {'show': 'Query DB ...'});
    Response? resp = await _getList(prefs);
    service.invoke('querydb', {'hide': ''});

    _lastGetMessages = DateTime.now();

    if ((resp != null) && (resp.contentLength! > 0)) {
      _jsonData = jsonDecode(resp.body);

      for (var item in _jsonData) {
        try {
          if (await _database.isMessageExist(
                  item['messageId'], item['jobId']) ==
              0) {
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
  }

  Future<void> _traiteCache(
      ServiceInstance service, AppPreferences prefs) async {
    final List<Message> messages = await _database.getMessagesNotSent();
    _notification(
        "Traitement terminé", "Nombre de messages : ${messages.length}");
    debugPrint("requete terminee");

    for (var message in messages) {
      await _checkPause();
      debugPrint("envoi de ${message.id}");

      Duration nextSms = _lastSmsSent
          .add(prefs.getDuration('sendInterval')!)
          .difference(DateTime.now());
      if (!nextSms.isNegative) {
        await Future.delayed(nextSms);
      }
      await telephony.Telephony.instance.sendSms(
          to: "(650) 555-1212",
          message: "Traitement - May the force be with you!",
          statusListener: _SmsSendStatusListener);
      _lastSmsSent = DateTime.now();

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
      _pauseController
          .add(null); // Envoie le signal pour débloquer `_checkPause`
    }
  }

  _getList(AppPreferences prefs) async {
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
