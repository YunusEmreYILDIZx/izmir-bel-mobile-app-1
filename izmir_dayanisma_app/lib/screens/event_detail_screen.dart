import 'package:flutter/material.dart';
import 'package:izmir_dayanisma_app/models/event.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as Event;

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlik Detayı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${event.date.day}.${event.date.month}.${event.date.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 6),
                Text(event.location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Açıklama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(event.description, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Katılmak İstiyorum'),
                onPressed: () {
                  // İleride katılım mantığı eklenecek
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
