import 'dart:convert';

import 'package:mangovault/services/auth_service.dart';
import 'package:mangovault/services/encryption_service.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:mangovault/model/message.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:sqflite/sqflite.dart';

class MessageService with ChangeNotifier {
  final WebSocketService _webSocketService;
  final AuthService _authService;
  final EncryptionService _encryptionService;
  final _messages = <Message>[];

  late final Database _database;

  MessageService(
      this._webSocketService, this._authService, this._encryptionService) {
    _init();
  }

  List<Message> getMessages(String recipient) => _messages
      .where((message) =>
          message.recipient == recipient || message.sender == recipient)
      .toList();

  Future<void> sendMessage(Message message) async {
    _webSocketService.sendMessage(json.encode(
      Message(
        message.sender,
        message.recipient,
        await _encryptionService.encrypt(message.message, message.recipient),
        message.timestamp,
      ).toMap(),
    ));
    _messages.add(message);

    _saveToDb(message);

    notifyListeners();
  }

  Future<void> _init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'mango_history.db'),
      version: 1,
      onOpen: (db) async {
        await db.execute(
          '''
          DROP TABLE IF EXISTS messages''',
        );
        await db.execute(
          '''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender TEXT,
            recipient TEXT,
            message TEXT,
            timestamp INTEGER
          )''',
        );
      },
      onCreate: (db, version) async => await db.execute(
        '''
        CREATE TABLE messages(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sender TEXT,
          recipient TEXT,
          message TEXT,
          timestamp INTEGER
        )''',
      ),
    );

    await _loadMessages();

    _webSocketService.subscribe(
      "/user/queue/chat",
      (frame) async {
        final message = Message.fromMap(json.decode(frame.body!));

        _messages.add(Message(
          message.sender,
          message.recipient,
          await _encryptionService.decrypt(message.message, message.sender),
          message.timestamp,
        ));

        _saveToDb(message);

        notifyListeners();
      },
    );

    notifyListeners();
  }

  Future<void> _saveToDb(Message message) async {
    await _database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _loadMessages() async {
    final List<Map<String, dynamic>> rows = await _database.query(
      'messages',
      where: 'sender = ?',
      whereArgs: [_authService.username],
    );

    for (var row in rows) {
      _messages.add(Message.fromMap(row));
    }
  }
}
