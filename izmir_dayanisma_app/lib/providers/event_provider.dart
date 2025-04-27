// lib/providers/event_provider.dart

import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/local_db_service.dart';
import '../services/notification_service.dart';

class EventProvider extends ChangeNotifier {
  final LocalDbService _dbService;
  List<Event> _events = [];

  EventProvider(this._dbService) {
    loadEvents();
  }

  List<Event> get events => _events;

  /// Veritabanından yükle
  Future<void> loadEvents() async {
    _events = await _dbService.getAllEvents();
    notifyListeners();
  }

  /// Yeni etkinlik ekle ve listeyi güncelle
  Future<void> addEvent(Event event) async {
    // 1. Etkinliği veritabanına ekle, dönen id’yi al
    final newId = await _dbService.insertEvent(event);
    // 2. Bildirimi planla (24 saat önce, saat 09:00’da)
    await NotificationService.scheduleEventNotification(
      id: newId,
      title: 'Yarın Etkinliğiniz Var!',
      body: event.title,
      dateTime: event.date,
      hoursBefore: 24,
      atHour: 9,
      atMinute: 0,
    );
    await loadEvents();
  }

  /// Etkinlik güncelle
  Future<void> editEvent(Event event) async {
    await _dbService.updateEvent(event);
    // 2. Yeniden bildirim planla
    await NotificationService.scheduleEventNotification(
      id: event.id!,
      title: 'Yarın Etkinliğiniz Var!',
      body: event.title,
      dateTime: event.date,
      hoursBefore: 24,
      atHour: 9,
      atMinute: 0,
    );

    await loadEvents();
  }

  /// Etkinlik sil
  Future<void> removeEvent(int id) async {
    await _dbService.deleteEvent(id);
    await loadEvents();
  }
}
