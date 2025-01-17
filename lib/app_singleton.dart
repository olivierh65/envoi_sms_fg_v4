import 'database.dart';
import 'traitement.dart';

// Utiliser un singleton pour partager une instance unique dans toute l'application.

class AppSingleton {
  static final AppSingleton _instance = AppSingleton._internal();

  late final AppDatabase database;
  late final Traitement traitement;

  factory AppSingleton() {
    return _instance;
  }

  AppSingleton._internal() {
    database = AppDatabase();
    traitement = Traitement(database);
  }

  static AppDatabase getDatabase() => _instance.database;
  static Traitement getTraitement() => _instance.traitement;
}
