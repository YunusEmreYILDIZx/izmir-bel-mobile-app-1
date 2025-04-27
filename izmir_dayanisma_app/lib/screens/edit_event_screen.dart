// lib/screens/edit_event_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:izmir_dayanisma_app/models/event.dart';
import 'package:izmir_dayanisma_app/providers/event_provider.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({Key? key}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late Event _event;
  late String _title, _description, _location;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _event = ModalRoute.of(context)!.settings.arguments as Event;
    _title = _event.title;
    _description = _event.description;
    _location = _event.location;
    _selectedDate = _event.date;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir tarih seçin.')),
        );
      }
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    final updated = Event(
      id: _event.id,
      title: _title,
      description: _description,
      date: _selectedDate!,
      location: _location,
    );
    await context.read<EventProvider>().editEvent(updated);

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    // 1 saniye sonra geri dön
    Timer(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlik Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator:
                    (v) =>
                        v != null && v.trim().isNotEmpty
                            ? null
                            : 'Başlık girin',
                onSaved: (v) => _title = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
                validator:
                    (v) =>
                        v != null && v.trim().isNotEmpty
                            ? null
                            : 'Açıklama girin',
                onSaved: (v) => _description = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Konum'),
                validator:
                    (v) =>
                        v != null && v.trim().isNotEmpty ? null : 'Konum girin',
                onSaved: (v) => _location = v!.trim(),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate == null
                      ? 'Tarih seçin'
                      : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 24),
              // Duruma göre buton/spinner/başarı ikonunu göster
              if (_isSuccess) ...[
                Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
              ] else if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else ...[
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Güncelle'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
