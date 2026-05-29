import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/donasi/donasi_entity.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/domain/usecases/donasi/watch_donasi_by_masjid.dart';
import 'package:sajadah/presentation/donasi/pages/donasi_page.dart';
import 'package:sajadah/presentation/donasi/pages/donasi_create_page.dart'; // Import halaman tambah donasi
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/common/widgets/profile_avatar.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';

class DonasiListPage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;
  const DonasiListPage({super.key, this.masjidId, this.masjid});

  @override
  State<DonasiListPage> createState() => _DonasiListPageState();
}

class _DonasiListPageState extends State<DonasiListPage> {
  late Stream<List<DonasiEntity>> _donasiStream;
  String _searchQuery = '';
  String? _resolvedMasjidId;

  @override
  void initState() {
    super.initState();
    _resolvedMasjidId = widget.masjidId ?? widget.masjid?.id;
    if (_resolvedMasjidId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Masjid belum dipilih')));
      });
      _donasiStream = const Stream<List<DonasiEntity>>.empty();
      return;
    }

    _donasiStream = sl<WatchDonasiByMasjidUseCase>().call(
      masjidId: _resolvedMasjidId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(masjid: widget.masjid),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Donasi', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const ProfileAvatar(),
        ],
      ),
      body: _resolvedMasjidId == null
          ? const Center(child: Text('Masjid belum dipilih'))
          : StreamBuilder<List<DonasiEntity>>(
              stream: _donasiStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allDonasi = snapshot.data ?? [];
                final filteredDonasi = allDonasi
                    .where(
                      (d) => d.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                return Column(
                  children: [
                    // Kolom Pencarian
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari Donasi',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () async {
                                final resolvedMasjidId =
                                    widget.masjidId ?? widget.masjid?.id;
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DonasiCreatePage(
                                      masjid: widget.masjid,
                                      masjidId: resolvedMasjidId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List Donasi
                    Expanded(
                      child: filteredDonasi.isEmpty
                          ? const Center(child: Text('Belum ada donasi'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredDonasi.length,
                              itemBuilder: (context, index) {
                                final campaign = filteredDonasi[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final resolvedMasjidId =
                                        widget.masjidId ?? widget.masjid?.id;
                                    // Jika diklik, arahkan ke halaman DonasiPage (form pembayaran QRIS)
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return DonasiPage(
                                            campaign: campaign,
                                            masjidId: resolvedMasjidId,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Card(
                                    clipBehavior:
                                        Clip.antiAlias, // Sudah fix bebas eror
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        // Bagian Teks (Kiri)
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            color: Colors.grey.shade200,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  campaign.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Total   : Rp ${_formatCurrency(campaign.collectedAmount)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  'Target : Rp ${_formatCurrency(campaign.targetAmount)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Bagian Gambar (Kanan)
                                        Expanded(
                                          flex: 2,
                                          child: _buildDonasiImage(
                                            campaign.imageUrl,
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
                );
              },
            ),
    );
  }

  Widget _buildDonasiImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 100,
        color: Colors.grey.shade300,
        child: Icon(Icons.image, color: Colors.grey.shade600),
      );
    }

    return Image.network(
      imageUrl,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          color: Colors.grey.shade300,
          child: Icon(Icons.broken_image, color: Colors.grey.shade600),
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    String result = amount.toInt().toString();
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }
}
