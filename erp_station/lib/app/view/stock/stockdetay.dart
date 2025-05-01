import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:erp_station/services/data_service.dart';

class StokDetayPage extends StatelessWidget {
  final Map<String, dynamic> urun;

  const StokDetayPage({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    final stokKodu = urun["stok_kodu"];
    final urunAdi = urun["urun_adi"] ?? "Ürün";
    final double fiyat = (urun["satis_fiyati"] ?? 0).toDouble();
    final double kdv = (urun["kdv_yuzdesi"] ?? 0).toDouble();
    final double fiyatKdvli = fiyat * (1 + kdv / 100);

    final siparisler = DataService().siparisler.value.where((siparis) {
      return siparis["urunid"].toString() == stokKodu.toString();
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Ürün Detay - $urunAdi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (urun["urun_fotograf_url"] != null &&
                urun["urun_fotograf_url"].toString().isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: urun["urun_fotograf_url"],
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _etiketliSatir(Icons.category, "Kategori", urun["kategori"]),
            _etiketliSatir(Icons.qr_code, "Barkod", urun["barkod"]),
            _etiketliSatir(Icons.inventory, "Stok",
                "${urun["miktar"]} ${urun["birim"] ?? ""}"),
            _etiketliSatir(
                Icons.price_change, "Fiyat", "₺${fiyat.toStringAsFixed(2)}"),
            if (kdv > 0)
              _etiketliSatir(Icons.percent, "KDV Dahil Fiyat",
                  "₺${fiyatKdvli.toStringAsFixed(2)} (%${kdv.toInt()})"),
            const SizedBox(height: 28),
            Text(
              "📦 Ürüne Ait Siparişler",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (siparisler.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text("Henüz bu ürüne ait sipariş yok.",
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: siparisler.length,
                itemBuilder: (context, index) {
                  final siparis = siparisler[index];
                  final double birimFiyat =
                      (siparis["birimFiyat"] ?? 0).toDouble();
                  final double kdvOrani = (siparis["kdv"] ?? 0).toDouble();
                  final int adet = siparis["adet"] ?? 0;
                  final double iskontoluTutar =
                      (birimFiyat * adet) - (siparis["iskontopara"] ?? 0);
                  final double toplamTutar = iskontoluTutar * (1 + kdvOrani);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🧾 Cari: ${siparis["cari"]}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Adet: $adet"),
                              Text("₺${toplamTutar.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              "Birim Fiyat: ₺${birimFiyat.toStringAsFixed(2)}"),
                          Text("İskonto: ₺${siparis["iskontopara"] ?? 0}"),
                          Text("KDV: %${(kdvOrani * 100).toInt()}"),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "Oluşturulma: ${siparis["olusturmaTarihi"]}"),
                              Text("Durum: ${siparis["durum"]}",
                                  style: const TextStyle(color: Colors.blue)),
                            ],
                          ),
                          Text("Teslim: ${siparis["teslimTarihi"]}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _etiketliSatir(IconData icon, String baslik, String? deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade700),
          const SizedBox(width: 8),
          Text("$baslik: ",
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Expanded(
            child: Text(deger ?? "-",
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
