import 'package:erp_station/app/view/barkod/barkod.dart';
import 'package:erp_station/app/view/calender/CalendarOrdersPage.dart';
import 'package:erp_station/app/view/home/linkstatus.dart';
import 'package:erp_station/app/view/settings/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:erp_station/services/data_service.dart';

class ERPHomePage extends StatelessWidget {
  const ERPHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ERP İzleyici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BarkodOkumaPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarOrdersPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinkStatusPanel(),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: DataService().siparisler,
              builder: (context, siparisler, _) {
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: DataService().stoklar,
                  builder: (context, stoklar, _) {
                    final bugun =
                        DateTime.now().toIso8601String().split('T')[0];
                    final bugunkuSiparisSayisi = siparisler
                        .where((s) =>
                            s["olusturmaTarihi"]
                                ?.toString()
                                .startsWith(bugun) ??
                            false)
                        .length;

                    final kritikStok =
                        stoklar.where((s) => (s["miktar"] ?? 0) < 10).length;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SummaryCard(
                              title: 'Toplam Sipariş',
                              value: siparisler.length.toString(),
                              icon: Icons.receipt_long,
                            ),
                            _SummaryCard(
                              title: 'Stok Sayısı',
                              value: stoklar.length.toString(),
                              icon: Icons.inventory,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SummaryCard(
                              title: 'Bugünkü Satış',
                              value: bugunkuSiparisSayisi.toString(),
                              icon: Icons.trending_up,
                            ),
                            _SummaryCard(
                              title: 'Kritik Ürün',
                              value: kritikStok.toString(),
                              icon: Icons.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('7 Günlük Satış Grafiği',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                            height: 200,
                            child: _buildSiparisGrafik(siparisler)),
                        const SizedBox(height: 24),
                        const Text('Son Siparişler',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...siparisler.take(5).map((s) => Card(
                              color: Colors.white,
                              child: ListTile(
                                leading:
                                    const Icon(Icons.local_shipping_outlined),
                                title: Text(
                                    "${s["cari"] ?? "Müşteri"} - ${s["adet"]} Adet"),
                                subtitle:
                                    Text("${s["olusturmaTarihi"] ?? "-"}"),
                              ),
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiparisGrafik(List<Map<String, dynamic>> siparisler) {
    final now = DateTime.now();
    final Map<int, int> gunlukSatis = {};

    // Son 7 güne ait tarihleri günIndex ile eşleştiriyoruz (0 = bugün, 6 = 6 gün önce)
    for (int i = 0; i < 7; i++) {
      gunlukSatis[i] = 0;
    }

    for (var siparis in siparisler) {
      final tarihStr = siparis["olusturmaTarihi"];
      if (tarihStr != null && tarihStr is String) {
        final tarih = DateTime.tryParse(tarihStr);
        if (tarih != null) {
          final fark = now.difference(tarih).inDays;
          if (fark >= 0 && fark < 7) {
            gunlukSatis[fark] = (gunlukSatis[fark] ?? 0) + 1;
          }
        }
      }
    }

    // FlSpot'lara günleri tersten yerleştiriyoruz (0 = en eski gün)
    final List<FlSpot> spots = List.generate(7, (index) {
      final tersIndex = 6 - index;
      return FlSpot(index.toDouble(), gunlukSatis[tersIndex]?.toDouble() ?? 0);
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                const labels = ['6g', '5g', '4g', '3g', '2g', 'Dün', 'Bugün'];
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(labels[value.toInt()]),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) => Text(value.toInt().toString()),
              reservedSize: 28,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
