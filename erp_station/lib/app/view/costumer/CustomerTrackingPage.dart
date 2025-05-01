import 'package:erp_station/app/view/costumer/CustomerDetailPage.dart';
import 'package:erp_station/services/data_service.dart';
import 'package:flutter/material.dart';

class CustomerTrackingPage extends StatefulWidget {
  const CustomerTrackingPage({super.key});

  @override
  State<CustomerTrackingPage> createState() => _CustomerTrackingPageState();
}

class _CustomerTrackingPageState extends State<CustomerTrackingPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> _allCustomers = [];

  @override
  void initState() {
    super.initState();
    DataService().musteriler.addListener(_onCustomersUpdated);
    _allCustomers = DataService().musteriler.value;
  }

  void _onCustomersUpdated() {
    setState(() {
      _allCustomers = DataService().musteriler.value;
    });
  }

  @override
  void dispose() {
    DataService().musteriler.removeListener(_onCustomersUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _allCustomers.where((customer) {
      final query = searchQuery.toLowerCase();
      return customer['name'].toLowerCase().contains(query) ||
          customer['phone'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Müşteri / Cari Takibi")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Müşteri adı veya telefon...",
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
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: filteredCustomers.isEmpty
                ? const Center(child: Text("Müşteri bulunamadı."))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(customer['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("📞 ${customer['phone']}\n"
                              "📧 ${customer['email'] ?? '-'}"),
                          trailing: Icon(Icons.arrow_right_sharp),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomerDetailPage(customer: customer),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
