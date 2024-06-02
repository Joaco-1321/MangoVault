import 'dart:convert';

import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:mangovault/model/message.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:sqflite/sqflite.dart';

class MessageService with ChangeNotifier {
  final WebSocketService _webSocketService;

  late final Database _database;

  final _messages = <Message>[];

  List<Message> messages(String username) => _messages
      .where(
        (message) =>
            message.recipient == username || message.sender == username,
      )
      .toList();

  MessageService(this._webSocketService) {
    _init();
  }

  void sendMessage(Message message) {
    _webSocketService.sendMessage(json.encode(message.toMap()));
    _messages.add(message);

    saveToDb(message);

    notifyListeners();
  }

  Future<void> _init() async {
    final String path = join(await getDatabasesPath(), 'mango_history.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE messages(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sender TEXT,
          recipient TEXT,
          message TEXT,
          timestamp INTEGER
        )
      ''');
      },
    );

    await _loadMessages();

    _webSocketService.subscribe(
      "/user/queue/chat",
      (frame) {
        final message = Message.fromMap(json.decode(frame.body!));

        _messages.add(message);
        saveToDb(message);

        notifyListeners();
      },
    );

    notifyListeners();
  }

  Future<void> saveToDb(Message message) async {
    await _database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _loadMessages() async {
    final List<Map<String, dynamic>> rows = await _database.query('messages');

    for (var row in rows) {
      _messages.add(Message.fromMap(row));
    }
  }
}
