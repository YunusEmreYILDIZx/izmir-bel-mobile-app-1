import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // RouteObserver & RouteAware için
import 'package:provider/provider.dart';
import 'package:izmir_dayanisma_app/providers/event_provider.dart';
import 'package:izmir_dayanisma_app/widgets/event_card.dart';
import 'package:izmir_dayanisma_app/models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // RouteObserver nesnesi, main.dart’ta da kullanılacak
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  String _searchQuery = '';
  DateTime? _filterDate;
  final _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bu ekran yeniden göründüğünde (popNext) bizi dinleyecek
    HomeScreen.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    HomeScreen.routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Başka bir ekrandan geri döndüğümüzde listeyi yenile
    context.read<EventProvider>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = context.watch<EventProvider>().events;
    final q = _searchQuery.toLowerCase();

    // 1) Arama filtresi
    var filtered =
        allEvents.where((e) {
          return e.title.toLowerCase().contains(q) ||
              e.location.toLowerCase().contains(q);
        }).toList();

    // 2) Tarih filtresi
    if (_filterDate != null) {
      filtered =
          filtered.where((e) {
            return e.date.year == _filterDate!.year &&
                e.date.month == _filterDate!.month &&
                e.date.day == _filterDate!.day;
          }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _filterDate = picked);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-event').then((result) {
                if (result == true) {
                  context.read<EventProvider>().loadEvents();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Etkinlik eklendi'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Ara… (başlık veya konum)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          Expanded(
            child:
                filtered.isEmpty
                    ? const Center(child: Text('Bulunamadı'))
                    : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final e = filtered[i];
                        return EventCard(
                          event: e,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/event-detail',
                                arguments: e,
                              ),
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-event',
                              arguments: e,
                            ).then((result) {
                              if (result == true) {
                                context.read<EventProvider>().loadEvents();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Etkinlik güncellendi'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Silinsin mi?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hayır'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<EventProvider>()
                                              .removeEvent(e.id!);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Evet'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
