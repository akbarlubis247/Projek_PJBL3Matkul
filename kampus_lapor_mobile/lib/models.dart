import 'dart:typed_data';

class CampusLocation {
  const CampusLocation({required this.name, this.area});

  final String name;
  final String? area;

  String get label {
    final cleanArea = area?.trim();
    if (cleanArea == null || cleanArea.isEmpty || cleanArea == '-') {
      return name;
    }

    return '$name - $cleanArea';
  }
}

class Report {
  Report({
    required this.title,
    required this.category,
    required this.location,
    required this.tag,
    required this.status,
    required this.date,
    required this.description,
    required this.reporter,
    this.photoBytes,
    this.remoteId,
    this.hasUnreadUpdate = false,
  });

  String title;
  String category;
  String location;
  String tag;
  String status;
  String date;
  String description;
  String reporter;
  Uint8List? photoBytes;
  String? remoteId;
  bool hasUnreadUpdate;
}

class ChatThread {
  ChatThread({
    required this.name,
    required this.role,
    required this.messages,
    this.time = 'Baru',
    this.hasUnread = false,
  });

  String name;
  String role;
  String time;
  List<ChatMessage> messages;
  bool hasUnread;
}

class ChatMessage {
  ChatMessage({required this.body, required this.isMine});

  String body;
  bool isMine;
}
