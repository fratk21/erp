import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

/// 📦 Tüm uygulama boyunca kullanılacak Singleton Veri Servisi
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> siparisler =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> musteriler =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> stoklar = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> ekstreler = ValueNotifier([]);

  Timer? _timer;

  final testSiparisLink =
      "https://raw.githubusercontent.com/fratk21/Test_json/main/orders.json";
  final testMusteriLink =
      "https://raw.githubusercontent.com/fratk21/Test_json/main/costumer.json";
  final testStokLink =
      "https://raw.githubusercontent.com/fratk21/Test_json/main/stok.json";
  final testEkstreLink =
      "https://raw.githubusercontent.com/fratk21/Test_json/main/cari.json";

  Future<void> start() async {
    await _fetchAll();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    final box = Hive.box('settings');

    final siparisLink = box.get('siparisLink', defaultValue: testSiparisLink);
    final musteriLink = box.get('musteriLink', defaultValue: testMusteriLink);
    final stokLink = box.get('stokLink', defaultValue: testStokLink);
    final ekstreLink = box.get('ekstreLink', defaultValue: testEkstreLink);

    final fetchedSiparisler = await _fetchJsonData(siparisLink);
    final fetchedMusteriler = await _fetchJsonData(musteriLink);
    final fetchedStoklar = await _fetchJsonData(stokLink);
    final fetchedEkstreler = await _fetchJsonData(ekstreLink);

    if (fetchedSiparisler != null) siparisler.value = fetchedSiparisler;
    if (fetchedMusteriler != null) musteriler.value = fetchedMusteriler;
    if (fetchedStoklar != null) stoklar.value = fetchedStoklar;
    if (fetchedEkstreler != null) ekstreler.value = fetchedEkstreler;
  }

  Future<List<Map<String, dynamic>>?> _fetchJsonData(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint("Veri çekme hatası ($url): $e");
    }
    return null;
  }

  void dispose() {
    _timer?.cancel();
  }
}
