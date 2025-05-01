import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erp_station/services/data_service.dart';
import 'package:hive/hive.dart';

class LinkStatusPanel extends StatefulWidget {
  const LinkStatusPanel({super.key});

  @override
  State<LinkStatusPanel> createState() => _LinkStatusPanelState();
}

class _LinkStatusPanelState extends State<LinkStatusPanel> {
  final List<Map<String, dynamic>> _links = [];
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _kontrolEt();
  }

  Future<void> _kontrolEt() async {
    setState(() {
      _loading = true;
    });

    final box = await Future.value(Hive.box('settings'));

    final testLinks = {
      'Sipariş':
          box.get('siparisLink', defaultValue: DataService().testSiparisLink),
      'Müşteri':
          box.get('musteriLink', defaultValue: DataService().testMusteriLink),
      'Stok': box.get('stokLink', defaultValue: DataService().testStokLink),
      'Ekstre':
          box.get('ekstreLink', defaultValue: DataService().testEkstreLink),
    };

    List<Map<String, dynamic>> results = [];

    for (var entry in testLinks.entries) {
      final String name = entry.key;
      final String url = entry.value;
      String status = "Bekleniyor...";
      bool success = false;

      try {
        final response =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          success = true;
          status = "Bağlantı başarılı";
        } else {
          status = "HTTP ${response.statusCode}";
        }
      } catch (e) {
        status = "Hata: $e";
      }

      results.add({
        "name": name,
        "url": url,
        "status": status,
        "success": success,
      });
    }

    setState(() {
      _links.clear();
      _links.addAll(results);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '🔗 Bağlantı Durumları',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _loading
                  ? "Kontrol ediliyor..."
                  : "${_links.where((l) => l['success'] == true).length} başarılı, "
                      "${_links.where((l) => l['success'] == false).length} başarısız",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: "Yenile",
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _kontrolEt,
                ),
                IconButton(
                  tooltip: _expanded ? "Kapat" : "Genişlet",
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) const Divider(),
          if (_expanded)
            _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: _links
                        .map((link) => ListTile(
                              leading: Icon(
                                link['success']
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color:
                                    link['success'] ? Colors.green : Colors.red,
                              ),
                              title: Text(link['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    link['url'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    link['status'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: link['success']
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ))
                        .toList(),
                  ),
        ],
      ),
    );
  }
}
