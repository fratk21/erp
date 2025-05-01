import 'package:erp_station/app/view/orders/OrderDetailPage.dart';
import 'package:erp_station/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarOrdersPage extends StatefulWidget {
  const CalendarOrdersPage({super.key});

  @override
  State<CalendarOrdersPage> createState() => _CalendarOrdersPageState();
}

class _CalendarOrdersPageState extends State<CalendarOrdersPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _allOrders = [];

  List<Map<String, dynamic>> getOrdersForDay(DateTime day) {
    return _allOrders.where((order) {
      final orderDate = DateTime.tryParse(
              order['teslimTarihi'] ?? order['olusturmaTarihi'] ?? '') ??
          DateTime.now();
      return orderDate.year == day.year &&
          orderDate.month == day.month &&
          orderDate.day == day.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    DataService().siparisler.addListener(_onOrdersUpdated);
    _allOrders = DataService().siparisler.value;
    _selectedDay = DateTime.now();
  }

  void _onOrdersUpdated() {
    setState(() {
      _allOrders = DataService().siparisler.value;
    });
  }

  @override
  void dispose() {
    DataService().siparisler.removeListener(_onOrdersUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = <DateTime, List<Map<String, dynamic>>>{};

    for (var order in _allOrders) {
      final date = DateTime.tryParse(
              order['teslimTarihi'] ?? order['olusturmaTarihi'] ?? '') ??
          DateTime.now();
      final key = DateTime(date.year, date.month, date.day);
      events.putIfAbsent(key, () => []).add(order);
    }

    final todayOrders = getOrdersForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(title: const Text('📆 Sipariş Takvimi')),
      body: Column(
        children: [
          TableCalendar<Map<String, dynamic>>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Ay',
            },
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) =>
                events[DateTime(day.year, day.month, day.day)] ?? [],
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const Divider(),

          // 📋 Sipariş Listesi
          Expanded(
            child: todayOrders.isEmpty
                ? const Center(child: Text("Seçilen tarihte sipariş yok."))
                : ListView.builder(
                    itemCount: todayOrders.length,
                    itemBuilder: (context, index) {
                      final order = todayOrders[index];
                      final durum = order['durum'] ?? 'Bilinmiyor';
                      final String paraBirim = order['parabirimi'] ?? '₺';

                      return Card(
                        color: getOrderCardColor(durum),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(order: order),
                              ),
                            );
                          },
                          title: Text(order['urun'] ?? ''),
                          subtitle: Text(
                              "Adet: ${order['adet']} • Teslim: ${order['teslimTarihi'] ?? '-'}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${order['birimFiyat'] ?? 0} $paraBirim"),
                              Chip(
                                label: Text(durum),
                                backgroundColor: getOrderCardColor(durum),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color getOrderCardColor(String durum) {
    switch (durum.toLowerCase()) {
      case 'bekliyor':
        return Colors.orange.shade100;
      case 'tamamlandı':
        return Colors.green.shade100;
      case 'iptal edildi':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
