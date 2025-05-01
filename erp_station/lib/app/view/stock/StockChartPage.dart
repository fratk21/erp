import 'package:erp_station/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StockAnalysisDashboardPage extends StatefulWidget {
  const StockAnalysisDashboardPage({super.key});

  @override
  State<StockAnalysisDashboardPage> createState() =>
      _StockAnalysisDashboardPageState();
}

class _StockAnalysisDashboardPageState
    extends State<StockAnalysisDashboardPage> {
  String _selectedKategori = 'Tümü';
  Widget _buildKategoriDropdown(List<Map<String, dynamic>> stocks) {
    final kategoriler = <String>{
      'Tümü',
      ...stocks.map((s) => s['kategori']?.toString() ?? 'Belirsiz')
    }.toList();

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 20, color: Colors.blueGrey),
            const SizedBox(width: 12),
            const Text(
              "Kategori:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedKategori,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: kategoriler
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(
                                k,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedKategori = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stok Analiz Paneli")),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: DataService().stoklar,
        builder: (context, stocks, _) {
          if (stocks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final filteredStocks = _selectedKategori == 'Tümü'
              ? stocks
              : stocks
                  .where((s) => s['kategori'] == _selectedKategori)
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKategoriDropdown(stocks),
              const SizedBox(height: 24),
              _buildSectionTitle("📦 Ürünlere Göre Stok Adedi"),
              _buildProductCountBar(filteredStocks),
              const SizedBox(height: 24),
              _buildSectionTitle("💰 Ürünlere Göre Toplam Değer"),
              _buildProductValueBar(filteredStocks),
              const SizedBox(height: 24),
              _buildSectionTitle("📊 Kategoriye Göre Dağılım"),
              _buildCategoryPie(stocks),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductCountBar(List<Map<String, dynamic>> stocks) {
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];

    for (int i = 0; i < stocks.length; i++) {
      final urun = stocks[i]['urun_adi'] ?? stocks[i]['urun'] ?? 'Ürün $i';
      final adet = (stocks[i]['miktar'] ?? stocks[i]['adet'] ?? 0).toDouble();
      labels.add(urun);
      barGroups.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: adet, color: Colors.indigo, width: 16),
        ]),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 250,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: stocks.length * 90, // her çubuk için alan (60 px)

              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return SideTitleWidget(
                            meta: meta,
                            child: Transform.rotate(
                              angle: -0.5, // yaklaşık -30 derece
                              child: Text(
                                labels[index],
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductValueBar(List<Map<String, dynamic>> stocks) {
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];

    for (int i = 0; i < stocks.length; i++) {
      final urun = stocks[i]['urun_adi'] ?? stocks[i]['urun'] ?? 'Ürün $i';
      final adet = (stocks[i]['miktar'] ?? stocks[i]['adet'] ?? 0).toDouble();
      final fiyat = (stocks[i]['satis_fiyati'] ?? stocks[i]['birimFiyat'] ?? 0)
          .toDouble();
      final toplam = adet * fiyat;
      labels.add(urun);
      barGroups.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: toplam, color: Colors.deepOrange, width: 16),
        ]),
      );
    }

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 250,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: stocks.length * 90, // her çubuk için alan (60 px)

              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return SideTitleWidget(
                            meta: meta,
                            child: Transform.rotate(
                              angle: -0.5, // yaklaşık -30 derece
                              child: Text(
                                labels[index],
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPie(List<Map<String, dynamic>> stocks) {
    final Map<String, int> categoryCounts = {};
    for (var stock in stocks) {
      final kategori = stock['kategori'] ?? 'Belirsiz';
      final int adet = (stock['miktar'] ?? stock['adet'] ?? 0).toInt();
      categoryCounts[kategori] = (categoryCounts[kategori] ?? 0) + adet;
    }

    final total = categoryCounts.values.fold(0, (a, b) => a + b);
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int index = 0;
    categoryCounts.forEach((kategori, adet) {
      final percent = (adet / total) * 100;
      sections.add(
        PieChartSectionData(
          value: adet.toDouble(),
          title: '${percent.toStringAsFixed(1)}%',
          color: colors[index % colors.length],
          radius: 70,
          titleStyle:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      index++;
    });

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: categoryCounts.entries.map((e) {
                final color = colors[
                    categoryCounts.keys.toList().indexOf(e.key) %
                        colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: color),
                    const SizedBox(width: 6),
                    Text('${e.key} (${e.value})'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
