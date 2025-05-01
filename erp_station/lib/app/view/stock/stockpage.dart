import 'package:erp_station/app/view/stock/StockChartPage.dart';
import 'package:erp_station/app/view/stock/stockdetay.dart';
import 'package:flutter/material.dart';
import 'package:erp_station/services/data_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoklarPage extends StatefulWidget {
  const StoklarPage({super.key});

  @override
  State<StoklarPage> createState() => _StoklarPageState();
}

class _StoklarPageState extends State<StoklarPage> {
  String searchQuery = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Takibi"),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StockAnalysisDashboardPage(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.black),
            label: const Text("Stok Analizi",
                style: TextStyle(color: Colors.black)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSearchBar(),
          _buildCategoryFilter(),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: DataService().stoklar,
              builder: (context, stoklar, _) {
                if (stoklar.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text("Henüz stok verisi yok",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                final filtrelenmis = stoklar.where((stok) {
                  final urunAdi = (stok["urun_adi"] ?? "").toLowerCase();
                  final kategori = (stok["kategori"] ?? "").toLowerCase();
                  final searchLower = searchQuery.toLowerCase();
                  final kategoriEslesiyor = selectedCategory == null ||
                      selectedCategory == 'Tümü' ||
                      kategori == selectedCategory!.toLowerCase();
                  return urunAdi.contains(searchLower) && kategoriEslesiyor;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtrelenmis.length,
                  itemBuilder: (context, index) {
                    final stok = filtrelenmis[index];
                    final String? resimUrl = stok["urun_fotograf_url"];
                    final double fiyat = (stok["satis_fiyati"] ?? 0).toDouble();
                    final double kdvYuzde =
                        (stok["kdv_yuzdesi"] ?? 0).toDouble();
                    final bool kdvVar = kdvYuzde > 0;
                    final double fiyatKdvli = fiyat * (1 + kdvYuzde / 100);
                    final int adet = stok["miktar"] ?? 0;

                    final Color stokRenk = adet <= 10
                        ? Colors.red.shade400
                        : adet <= 30
                            ? Colors.orange.shade400
                            : Colors.green.shade600;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StokDetayPage(urun: stok),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (resimUrl != null && resimUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: resimUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stok["urun_adi"] ?? "Ürün Adı Yok",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _etiket(stok["kategori"] ?? "Kategori",
                                            Colors.blue.shade100,
                                            textColor: Colors.blue.shade900),
                                        const SizedBox(width: 8),
                                        _etiket("Stok: $adet",
                                            stokRenk.withOpacity(0.2),
                                            textColor: stokRenk),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text("Barkod: ${stok["barkod"]}"),
                                    const SizedBox(height: 4),
                                    Text("Fiyat: ₺${fiyat.toStringAsFixed(2)}"),
                                    if (kdvVar)
                                      Text(
                                        "KDV Dahil: ₺${fiyatKdvli.toStringAsFixed(2)} (%${kdvYuzde.toInt()})",
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Ürün adında ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final stoklar = DataService().stoklar.value;
    final kategoriler = <String>{"Tümü"};
    for (var s in stoklar) {
      if (s["kategori"] != null) {
        kategoriler.add(s["kategori"]);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Kategori",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedCategory ?? "Tümü",
        items: kategoriler
            .map((kategori) => DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedCategory = value),
        isExpanded: true,
      ),
    );
  }

  Widget _etiket(String text, Color bg, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}
