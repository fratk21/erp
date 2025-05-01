import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _siparisLinkController = TextEditingController();
  final TextEditingController _musteriLinkController = TextEditingController();
  final TextEditingController _stokLinkController = TextEditingController();
  final TextEditingController _ekstreLinkController = TextEditingController();
  final Box box = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _siparisLinkController.text = box.get('siparisLink', defaultValue: '');
    _musteriLinkController.text = box.get('musteriLink', defaultValue: '');
    _stokLinkController.text = box.get('stokLink', defaultValue: '');
    _ekstreLinkController.text = box.get('ekstreLink', defaultValue: '');
  }

  void _saveLink(String key, String value) {
    box.put(key, value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Link kaydedildi")),
    );
  }

  void _deleteLink(String key, TextEditingController controller) {
    box.delete(key);
    controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑 Link silindi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚙️ Ayarlar")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLinkCard(
              title: "📦 Siparişler Linki",
              controller: _siparisLinkController,
              keyName: 'siparisLink',
              icon: Icons.link,
              color: Colors.blue.shade50,
            ),
            const SizedBox(height: 20),
            _buildLinkCard(
              title: "👤 Müşteriler Linki",
              controller: _musteriLinkController,
              keyName: 'musteriLink',
              icon: Icons.people_alt,
              color: Colors.green.shade50,
            ),
            const SizedBox(height: 20),
            _buildLinkCard(
              title: "📦 Ürünler / Stoklar Linki",
              controller: _stokLinkController,
              keyName: 'stokLink',
              icon: Icons.inventory,
              color: Colors.amber.shade50,
            ),
            const SizedBox(height: 20),
            _buildLinkCard(
              title: "📄 Cari Ekstre Linki",
              controller: _ekstreLinkController,
              keyName: 'ekstreLink',
              icon: Icons.receipt_long,
              color: Colors.purple.shade50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard({
    required String title,
    required TextEditingController controller,
    required String keyName,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black54),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "https://example.com/...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveLink(keyName, controller.text),
                    icon: const Icon(Icons.save),
                    label: const Text("Kaydet"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteLink(keyName, controller),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Sil"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _testLink(controller.text),
                  icon: const Icon(Icons.refresh),
                  tooltip: "Linki Test Et",
                  color: Colors.green,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _testLink(String url) async {
    if (url.isEmpty || !url.startsWith("http")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Geçerli bir link girin")),
      );
      return;
    }

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Link çalışıyor")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Link döndü: \${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Linke ulaşılamadı")),
      );
    }
  }
}
