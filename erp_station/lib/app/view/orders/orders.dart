import 'package:erp_station/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum OrderFilter { last7Days, last1Month, last3Months, all }

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String query = '';
  OrderFilter selectedFilter = OrderFilter.all;

  bool isWithinFilter(DateTime date) {
    final now = DateTime.now();
    switch (selectedFilter) {
      case OrderFilter.last7Days:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case OrderFilter.last1Month:
        return date.isAfter(DateTime(now.year, now.month - 1, now.day));
      case OrderFilter.last3Months:
        return date.isAfter(DateTime(now.year, now.month - 3, now.day));
      case OrderFilter.all:
        return true;
    }
  }

  List<Map<String, dynamic>> getFilteredOrders(
      List<Map<String, dynamic>> allOrders) {
    return allOrders.where((order) {
      final cariUygun =
          order['cari'].toLowerCase().contains(query.toLowerCase());
      final orderDate =
          DateTime.tryParse(order['olusturmaTarihi'] ?? '') ?? DateTime.now();
      final tarihUygun = isWithinFilter(orderDate);
      return cariUygun && tarihUygun;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siparişler'),
      ),
      body: ValueListenableBuilder(
        valueListenable: DataService().siparisler,
        builder: (context, List<Map<String, dynamic>> allOrders, _) {
          final filteredOrders = getFilteredOrders(allOrders);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari adıyla ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => query = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _buildFilterButton('7 Günlük', OrderFilter.last7Days),
                      const SizedBox(width: 8),
                      _buildFilterButton('1 Aylık', OrderFilter.last1Month),
                      const SizedBox(width: 8),
                      _buildFilterButton('3 Aylık', OrderFilter.last3Months),
                      const SizedBox(width: 8),
                      _buildFilterButton('Tüm Zamanlar', OrderFilter.all),
                    ],
                  ),
                ),
              ),
              buildSummaryWidget(filteredOrders),
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Center(
                        child: Text("Hiç sipariş bulunamadı.",
                            style: TextStyle(fontSize: 16, color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final int adet = order['adet'] ?? 0;
                          final double birimFiyat =
                              (order['birimFiyat'] ?? 0).toDouble();
                          (order['iskontoYuzde'] ?? 0.0).toDouble();
                          (order['iskontoTL'] ?? 0).toDouble();
                          final double kdvOrani =
                              (order['kdv'] ?? 0.18).toDouble();

                          final double iskontoPara =
                              (order['iskontopara'] ?? order['iskontoTL'] ?? 0)
                                  .toDouble();
                          final double iskontoYuzdeDegeri =
                              (order['iskontoYuzde'] ?? 0.0).toDouble();
                          final double iskontoTutar =
                              (iskontoPara > 0 ? iskontoPara : 0) +
                                  (iskontoYuzdeDegeri > 0
                                      ? birimFiyat * adet * iskontoYuzdeDegeri
                                      : 0);
                          final double araToplam =
                              birimFiyat * adet - iskontoTutar;
                          final double kdvTutar = araToplam * kdvOrani;
                          final double toplamFiyat = araToplam + kdvTutar;

                          return GestureDetector(
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24)),
                              ),
                              builder: (_) => DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.6,
                                minChildSize: 0.4,
                                maxChildSize: 0.9,
                                builder: (_, controller) =>
                                    SingleChildScrollView(
                                  controller: controller,
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 5,
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      Text(order['cari'],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      _detailRow("Ürün", order['urun']),
                                      _detailRow("Adet", adet.toString()),
                                      _detailRow("Birim Fiyat",
                                          "${birimFiyat.toStringAsFixed(3)} ${order['parabirimi'] ?? '₺'}"),
                                      _detailRow(
                                          "İskonto",
                                          "${iskontoTutar.toStringAsFixed(3)} ${order['parabirimi'] ?? '₺'}" +
                                              (iskontoPara > 0 &&
                                                      iskontoYuzdeDegeri > 0
                                                  ? " (Direkt: ${iskontoPara.toStringAsFixed(2)} + %${(iskontoYuzdeDegeri * 100).toStringAsFixed(0)})"
                                                  : iskontoPara > 0
                                                      ? " (Direkt: ${iskontoPara.toStringAsFixed(2)})"
                                                      : iskontoYuzdeDegeri > 0
                                                          ? " (%${(iskontoYuzdeDegeri * 100).toStringAsFixed(0)})"
                                                          : "")),
                                      _detailRow("Ara Toplam",
                                          "${araToplam.toStringAsFixed(3)} ${order['parabirimi'] ?? '₺'}"),
                                      _detailRow("KDV",
                                          "${kdvTutar.toStringAsFixed(3)} ${order['parabirimi'] ?? '₺'}"),
                                      _detailRow("Toplam",
                                          "${toplamFiyat.toStringAsFixed(3)} ${order['parabirimi'] ?? '₺'}"),
                                      _detailRow(
                                          "Durum", order['durum'] ?? "-"),
                                      if (order.containsKey('olusturmaTarihi'))
                                        _detailRow("Oluşturma Tarihi",
                                            order['olusturmaTarihi']),
                                      if (order.containsKey('teslimTarihi'))
                                        _detailRow("Teslim Tarihi",
                                            order['teslimTarihi']),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: Card(
                              color: getCardColor(
                                  (order['durum'] ?? '').toString()),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                title: Text(order['cari'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text('${order['urun']} - $adet Adet'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.expand_more),
                                    Text('₺${toplamFiyat.toStringAsFixed(0)}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Color getCardColor(String durum) {
    switch (durum.toLowerCase()) {
      case 'bekliyor':
        return Colors.orange.shade50;
      case 'tamamlandı':
        return Colors.green.shade50;
      case 'iptal edildi':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget buildSummaryWidget(List<Map<String, dynamic>> orders) {
    final Map<String, double> summaryByCurrency = {};

    for (var order in orders) {
      final int adet = order['adet'] ?? 0;
      final double fiyat = (order['birimFiyat'] ?? 0).toDouble();
      final double iskontoPara =
          (order['iskontopara'] ?? order['iskontoTL'] ?? 0).toDouble();
      final double yuzde = (order['iskontoYuzde'] ?? 0.0).toDouble();
      final double kdv = (order['kdv'] ?? 0.18).toDouble();
      final String paraBirimi = (order['parabirimi'] ?? 'TL').toUpperCase();

      final double iskontoTutar = (iskontoPara > 0 ? iskontoPara : 0) +
          (yuzde > 0 ? fiyat * adet * yuzde : 0);
      final double araToplam = fiyat * adet - iskontoTutar;
      final double kdvTutar = araToplam * kdv;
      final double toplam = araToplam + kdvTutar;

      summaryByCurrency[paraBirimi] =
          (summaryByCurrency[paraBirimi] ?? 0) + toplam;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Sipariş: ${orders.length} adet',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 6),
            ...summaryByCurrency.entries.map((e) => Row(
                  children: [
                    const Icon(Icons.attach_money,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text(
                        'Toplam (${e.key}): ${e.key} ${e.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, OrderFilter filterType) {
    final isSelected = selectedFilter == filterType;

    IconData getIconForFilter(OrderFilter filter) {
      switch (filter) {
        case OrderFilter.last7Days:
          return Icons.timer;
        case OrderFilter.last1Month:
          return Icons.date_range;
        case OrderFilter.last3Months:
          return Icons.insights;
        case OrderFilter.all:
          return Icons.all_inclusive;
      }
    }

    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() => selectedFilter = filterType),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getIconForFilter(filterType),
                      size: 18,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
