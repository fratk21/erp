import 'package:erp_station/app/view/stock/stockdetay.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:erp_station/services/data_service.dart';

class BarkodOkumaPage extends StatefulWidget {
  const BarkodOkumaPage({super.key});

  @override
  State<BarkodOkumaPage> createState() => _BarkodOkumaPageState();
}

class _BarkodOkumaPageState extends State<BarkodOkumaPage> {
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => barkodOku());
  }

  Future<void> barkodOku() async {
    if (isScanning) return;
    isScanning = true;

    try {
      var sonuc = await BarcodeScanner.scan();
      final barkod = sonuc.rawContent;

      if (barkod.isNotEmpty) {
        _barkodIslendi(barkod);
      } else {
        _barkodBulunamadi("Herhangi bir barkod okunamadı.");
      }
    } catch (e) {
      _barkodBulunamadi("Barkod okuma iptal edildi.");
    }
  }

  void _barkodIslendi(String barkod) {
    final stoklar = DataService().stoklar.value;
    final urun = stoklar.firstWhere(
      (s) => s["barkod"].toString() == barkod,
      orElse: () => {},
    );

    if (urun.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StokDetayPage(urun: urun)),
      );
    } else {
      _barkodBulunamadi("Ürün bulunamadı. Barkod: $barkod");
    }
  }

  void _barkodBulunamadi(String mesaj) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.blue),
            SizedBox(width: 8),
            Text("Barkod Okuma"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "İşlem tamamlanamadı:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mesaj,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              isScanning = false;
              barkodOku();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Tekrar Dene"),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text("Geri Dön"),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text("Barkod Okuma", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Kameradan barkod okunuyor...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
