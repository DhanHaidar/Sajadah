import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/presentation/donasi/pages/donasi_page.dart'; 

class DonasiListPage extends StatelessWidget {
  final MasjidEntity? masjid;
  const DonasiListPage({super.key, this.masjid});

  @override
  Widget build(BuildContext context) {
    // Data sementara (dummy) sebelum kita hubungkan ke Firebase/Supabase
    final List<Map<String, dynamic>> dummyCampaigns = [
      {'title': 'Dana TPQ', 'total': 2300000.0, 'target': 5000000.0, 'image': 'https://picsum.photos/400/200?random=1'},
      {'title': 'Donasi Pembangunan Masjid', 'total': 10120000.0, 'target': 15600000.0, 'image': 'https://picsum.photos/400/200?random=2'},
      {'title': 'Bakti Sosial Ramadhan', 'total': 4200000.0, 'target': 5000000.0, 'image': 'https://picsum.photos/400/200?random=3'},
      {'title': 'Santunan Anak Yatim Piatu', 'total': 500000.0, 'target': 1000000.0, 'image': 'https://picsum.photos/400/200?random=4'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donasi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.green, size: 30),
            onPressed: () {
              // TODO: Arahkan ke halaman "Tambahkan Donasi" 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Tambah Donasi Segera Hadir')));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Kolom Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Donasi',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
              ],
            ),
          ),
          
          // List Donasi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dummyCampaigns.length,
              itemBuilder: (context, index) {
                final campaign = dummyCampaigns[index];
                return GestureDetector(
                  onTap: () {
                    // Jika diklik, arahkan ke halaman DonasiPage
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const DonasiPage(); // Gunakan const di sini karena DonasiPage punya const constructor
                        }
                      )
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        // Bagian Teks (Kiri)
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey.shade200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(campaign['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 12),
                                Text('Total   : Rp ${_formatCurrency(campaign['total'])}', style: const TextStyle(fontSize: 12)),
                                Text('Target : Rp ${_formatCurrency(campaign['target'])}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        // Bagian Gambar (Kanan)
                        Expanded(
                          flex: 2,
                          child: Image.network(
                            campaign['image'],
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    String result = amount.toInt().toString();
    result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return result;
  }
}