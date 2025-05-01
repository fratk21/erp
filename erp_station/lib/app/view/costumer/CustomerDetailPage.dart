import 'package:erp_station/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class CustomerDetailPage extends StatefulWidget {
  final Map<String, dynamic> customer;
  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  Widget build(BuildContext context) {
    bool showOpen = true;
    bool showCompleted = true;
    bool showCancelled = true;
    final List<Map<String, dynamic>> orders = DataService()
        .siparisler
        .value
        .where((o) =>
            o['cariid'].toString() == widget.customer['cariid'].toString())
        .toList();

    final List<Map<String, dynamic>> cariEkstre = DataService()
        .ekstreler
        .value
        .where((e) =>
            e['cariid'].toString() == widget.customer['cariid'].toString())
        .toList();

    int bakiye = 0;
    int toplamBorc = 0;
    int toplamAlacak = 0;
    for (var e in cariEkstre) {
      toplamBorc += e['borc'] as int;
      toplamAlacak += e['alacak'] as int;
    }
    final openOrders = orders
        .where((o) => o['durum'].toString().toLowerCase() == 'bekliyor')
        .toList();
    final completedOrders = orders
        .where((o) => o['durum'].toString().toLowerCase() == 'tamamlandı')
        .toList();
    final cancelledOrders = orders
        .where((o) => o['durum'].toString().toLowerCase().contains('iptal'))
        .toList();
    final customerDebt = (widget.customer['totaldebt'] ?? 0) == 0
        ? toplamBorc
        : widget.customer['totaldebt'];
    final customerClaim = (widget.customer['totalclaim'] ?? 0) == 0
        ? toplamAlacak
        : widget.customer['totalclaim'];
    print(widget.customer);
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer['name'])),
      body: orders.isEmpty && cariEkstre.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.customer['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text("📞 ${widget.customer['phone']}",
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.blue.shade50,
                            )
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.customer['email'] ?? '-',
                                style: const TextStyle(fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("💳 Borç:",
                                style: TextStyle(color: Colors.red.shade700)),
                            Text(
                                "$customerDebt ${widget.customer['parabirimi'] ?? ""}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700))
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("📥 Alacak:",
                                style: TextStyle(color: Colors.green.shade700)),
                            Text(
                                "$customerClaim ${widget.customer['parabirimi'] ?? ""}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700))
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("💰  Bakiye:",
                                style: TextStyle(color: Colors.green.shade700)),
                            Text(
                                "${customerDebt - customerClaim} ${widget.customer['parabirimi'] ?? ""}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700))
                          ],
                        ),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Chip(
                                label: Text("🧾 Açık: ${openOrders.length}"),
                                backgroundColor: Colors.orange.shade50),
                            Chip(
                                label: Text(
                                    "✅ Tamamlanan: ${completedOrders.length}"),
                                backgroundColor: Colors.green.shade50),
                            Chip(
                                label:
                                    Text("❌ İptal: ${cancelledOrders.length}"),
                                backgroundColor: Colors.red.shade50),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStyledExpansionTile(
                  title: "📦 Açık Siparişler",
                  color: Colors.orange,
                  isExpanded: showOpen,
                  onChanged: (val) => setState(() => showOpen = val),
                  children: _buildOrderCards(context, openOrders),
                ),
                _buildStyledExpansionTile(
                  title: "✅ Tamamlanan Siparişler",
                  color: Colors.green,
                  isExpanded: showCompleted,
                  onChanged: (val) => setState(() => showCompleted = val),
                  children: _buildOrderCards(context, completedOrders),
                ),
                _buildStyledExpansionTile(
                  title: "❌ İptal Edilen Siparişler",
                  color: Colors.red,
                  isExpanded: showCancelled,
                  onChanged: (val) => setState(() => showCancelled = val),
                  children: _buildOrderCards(context, cancelledOrders),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(top: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.description_outlined, size: 20),
                                SizedBox(width: 8),
                                Text("Cari Ekstresi",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf,
                                  color: Colors.redAccent),
                              tooltip: "PDF Olarak Paylaş",
                              onPressed: () async {
                                final pdf = pw.Document();
                                pdf.addPage(
                                  pw.Page(
                                    build: (pw.Context context) => pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text("Cari Ekstresi",
                                            style: pw.TextStyle(
                                                fontSize: 24,
                                                fontWeight:
                                                    pw.FontWeight.bold)),
                                        pw.SizedBox(height: 12),
                                        pw.Table.fromTextArray(
                                          headers: [
                                            "Tarih",
                                            "İşlem",
                                            "Açıklama",
                                            "Borç",
                                            "Alacak",
                                            "Bakiye"
                                          ],
                                          data: [
                                            ...cariEkstre.map((e) {
                                              bakiye += (e['borc'] as int) -
                                                  (e['alacak'] as int);
                                              return [
                                                e['tarih'],
                                                e['tip'],
                                                e['aciklama'],
                                                "₺${e['borc']}",
                                                "₺${e['alacak']}",
                                                "₺$bakiye",
                                              ];
                                            })
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                                await Printing.layoutPdf(
                                  onLayout: (PdfPageFormat format) async =>
                                      pdf.save(),
                                );
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.grey.shade100),
                            columns: const [
                              DataColumn(label: Text("Tarih")),
                              DataColumn(label: Text("İşlem")),
                              DataColumn(label: Text("Açıklama")),
                              DataColumn(label: Text("Borç")),
                              DataColumn(label: Text("Alacak")),
                              DataColumn(label: Text("Bakiye")),
                            ],
                            rows: cariEkstre.map((e) {
                              bakiye +=
                                  (e['borc'] as int) - (e['alacak'] as int);
                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                  if (e['borc'] > 0) return Colors.red.shade50;
                                  if (e['alacak'] > 0)
                                    return Colors.green.shade50;
                                  return null;
                                }),
                                cells: [
                                  DataCell(Text(e['tarih'])),
                                  DataCell(Text(e['tip'])),
                                  DataCell(Text(e['aciklama'])),
                                  DataCell(Text("₺${e['borc']}")),
                                  DataCell(Text("₺${e['alacak']}")),
                                  DataCell(Text("₺$bakiye")),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStyledExpansionTile({
    required String title,
    required Color color,
    required bool isExpanded,
    required Function(bool) onChanged,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: onChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          collapsedBackgroundColor: color.withOpacity(0.05),
          backgroundColor: color.withOpacity(0.08),
          title: Row(
            children: [
              Icon(Icons.folder_open, color: color),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          children: children,
        ),
      ),
    );
  }
}

List<Widget> _buildOrderCards(
    BuildContext context, List<Map<String, dynamic>> orders) {
  return orders.map((order) {
    final int adet = order['adet'] ?? 0;
    final double birimFiyat = (order['birimFiyat'] ?? 0).toDouble();
    final double kdvOrani = (order['kdv'] ?? 0.18).toDouble();
    final double iskontoYuzde = (order['iskontoYuzde'] ?? 0.0).toDouble();
    final double iskontoTL =
        (order['iskontopara'] ?? order['iskontoTL'] ?? 0).toDouble();

    final double iskontoTutar =
        iskontoTL > 0 ? iskontoTL : birimFiyat * adet * iskontoYuzde;

    final double araToplam = birimFiyat * adet - iskontoTutar;
    final double kdvTutar = araToplam * kdvOrani;
    final double toplamFiyat = araToplam + kdvTutar;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order['urun'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDetailRow(
                  "Oluşturma Tarihi", order['olusturmaTarihi'] ?? '-'),
              _buildDetailRow("Teslim Tarihi", order['teslimTarihi'] ?? '-'),
              _buildDetailRow("Adet", "$adet"),
              _buildDetailRow("Birim Fiyat", "₺$birimFiyat"),
              _buildDetailRow(
                "İskonto",
                iskontoTL > 0
                    ? "₺${iskontoTutar.toStringAsFixed(2)}"
                    : "%${(iskontoYuzde * 100).toStringAsFixed(0)} (${iskontoTutar.toStringAsFixed(2)}₺)",
              ),
              _buildDetailRow("Ara Toplam", "₺${araToplam.toStringAsFixed(2)}"),
              _buildDetailRow("KDV",
                  "%${(kdvOrani * 100).toStringAsFixed(0)} (₺${kdvTutar.toStringAsFixed(2)})"),
              _buildDetailRow("Toplam", "₺${toplamFiyat.toStringAsFixed(2)}"),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Durum: ",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Chip(
                    label: Text(order['durum']),
                    backgroundColor: getOrderCardColor(order['durum']),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      child: Card(
        color: getOrderCardColor(order['durum']),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(order['urun'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              "Teslim: ${order['teslimTarihi'] ?? '-'}\nOluşturma: ${order['olusturmaTarihi'] ?? '-'}\nAdet: $adet"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("₺${toplamFiyat.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }).toList();
}

Color getOrderCardColor(String durum) {
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

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ],
    ),
  );
}
