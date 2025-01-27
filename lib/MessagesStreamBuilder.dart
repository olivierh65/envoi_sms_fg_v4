import 'package:flutter/material.dart';

import 'database.dart';

class MessagesStreamBuilder extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> mapStream;

  MessagesStreamBuilder({Key? key, required this.mapStream})
      : super(key: key) {
    // print("MessagesStreamBuilder - construit");
  }

  @override
  Widget build(BuildContext context) {
    // print("MessagesStreamBuilder - reconstruit");
    // Convertir le Stream de Map en Stream de Message
    final streamOfMessages = convertStream(mapStream);

    return StreamBuilder<List<Message>>(
      stream: streamOfMessages,
      builder: (context, snapshot) {
        print("StreamBuilder - snapshot mis à jour");
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Erreur : ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune donnée disponible"));
        }
        // Les données sont prêtes
        final messages = snapshot.data ?? [];
        if (messages.isEmpty &&
            snapshot.connectionState == ConnectionState.done) {
          return const Center(child: Text("Aucun message"));
        }
        return MessagesListView(messages: messages);
      },
    );
  }
  Stream<List<Message>> convertStream(
      Stream<List<Map<String, dynamic>>> mapStream
      ) {
    return mapStream.map((listOfMaps) {
      // Convertir chaque élément de la liste (Map<String, dynamic>) en Message
      return listOfMaps.map((map) => Message.fromJson(map)).toList();
    });
  }
}

class MessagesListView extends StatelessWidget {
  final List<Message> messages;
  final ScrollController _scrollController = ScrollController();

  MessagesListView({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true, // Pour afficher la scrollbar en permanence
      child: ListView.builder(
        controller: _scrollController, // Associer le même ScrollController au ListView
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];

          // Déterminer l'icône de statut
          late final Icon icon;
          if (message.sentDate == null) {
            icon = _getStatusIcon('waiting');
          } else if (message.sentDate != null && message.deliveredDate == null) {
            icon = _getStatusIcon('sending');
          } else if (message.sentDate != null && message.deliveredDate != null) {
            icon = _getStatusIcon('delivered');
          } else {
            icon = _getStatusIcon('other');
          }

          return ListTile(
            leading: icon, // Icône en début de ligne
            title: Text(message.number ?? 'xx'),
            subtitle: Text(
              message.message ?? '....',
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(message.messageId ?? 'yy'),
          );
        },
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case "waiting":
        return const Icon(Icons.access_time, color: Colors.grey);
      case "sending":
        return const Icon(Icons.send, color: Colors.blue);
      case "delivered":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "failed":
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
