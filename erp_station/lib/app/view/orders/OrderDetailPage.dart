import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});
  pw.Widget _pdfRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 12, color: PdfColor.fromInt(0xFF444444))),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int adet = order['adet'] ?? 0;
    final double birimFiyat = (order['birimFiyat'] ?? 0).toDouble();
    final double iskontoTL =
        (order['iskontopara'] ?? order['iskontoTL'] ?? 0).toDouble();
    final double iskontoYuzde = (order['iskontoYuzde'] ?? 0).toDouble();
    final double kdvOrani = (order['kdv'] ?? 0.18).toDouble();
    final String paraBirim = order['parabirimi'] ?? '₺';

    final double iskontoTutar = (iskontoTL > 0 ? iskontoTL : 0) +
        (iskontoYuzde > 0 ? birimFiyat * adet * iskontoYuzde : 0);

    final double araToplam = birimFiyat * adet - iskontoTutar;
    final double kdvTutar = araToplam * kdvOrani;
    final double toplam = araToplam + kdvTutar;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sipariş Detayı"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdf = pw.Document();
              pdf.addPage(
                pw.Page(
                  margin: const pw.EdgeInsets.all(32),
                  build: (pw.Context context) => pw.Container(
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColor.fromInt(0xFFCCCCCC)),
                      borderRadius: pw.BorderRadius.circular(12),
                      color: PdfColor.fromInt(0xFFFDFDFD),
                    ),
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Center(
                          child: pw.Text("📦 Sipariş Özeti",
                              style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.SizedBox(height: 20),
                        _pdfRow("Ürün", order['urun']),
                        _pdfRow("Oluşturma Tarihi",
                            order['olusturmaTarihi'] ?? '-'),
                        _pdfRow("Teslim Tarihi", order['teslimTarihi'] ?? '-'),
                        _pdfRow("Adet", adet.toString()),
                        _pdfRow("Birim Fiyat",
                            "$paraBirim${birimFiyat.toStringAsFixed(2)}"),
                        _pdfRow("İskonto",
                            "$paraBirim${iskontoTutar.toStringAsFixed(2)}"),
                        _pdfRow("Ara Toplam",
                            "$paraBirim${araToplam.toStringAsFixed(2)}"),
                        _pdfRow(
                            "KDV", "$paraBirim${kdvTutar.toStringAsFixed(2)}"),
                        pw.Divider(),
                        _pdfRow(
                            "Toplam", "$paraBirim${toplam.toStringAsFixed(2)}",
                            isBold: true),
                        pw.SizedBox(height: 10),
                        _pdfRow("Durum", order['durum'] ?? '-')
                      ],
                    ),
                  ),
                ),
              );
              await Printing.sharePdf(
                  bytes: await pdf.save(), filename: 'siparis_detayi.pdf');
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("Ürün", order['urun'] ?? ''),
            _row("Oluşturma Tarihi", order['olusturmaTarihi'] ?? '-'),
            _row("Teslim Tarihi", order['teslimTarihi'] ?? '-'),
            _row("Adet", "$adet"),
            _row("Birim Fiyat", "${birimFiyat.toStringAsFixed(3)} $paraBirim"),
            _row(
                "İskonto",
                "${iskontoTutar.toStringAsFixed(3)} $paraBirim${iskontoTL > 0 && iskontoYuzde > 0 ? " (Direkt: $paraBirim${iskontoTL.toStringAsFixed(3)} + %${(iskontoYuzde * 100).toStringAsFixed(0)})" : iskontoTL > 0 ? " (Direkt: $paraBirim${iskontoTL.toStringAsFixed(3)})" : iskontoYuzde > 0 ? " (%${(iskontoYuzde * 100).toStringAsFixed(0)})" : ""}"),
            _row("Ara Toplam", "${araToplam.toStringAsFixed(2)} $paraBirim"),
            _row("KDV",
                "%${(kdvOrani * 100).toStringAsFixed(0)} (${kdvTutar.toStringAsFixed(3)} $paraBirim)"),
            const Divider(),
            _row("Toplam", "${toplam.toStringAsFixed(3)} $paraBirim",
                bold: true, color: Colors.green),
            const SizedBox(height: 20),
            Chip(
              avatar: const Icon(Icons.info_outline, size: 16),
              label: Text(
                order['durum'] ?? 'Durum yok',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: bold ? FontWeight.bold : FontWeight.w400,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
