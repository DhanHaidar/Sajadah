import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/domain/usecases/jamaah/get_jamaah.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/presentation/jamaah/pages/jamaah_manage_page.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';
import 'package:sajadah/common/enums/kategori_jamaah.dart';

class JamaahPage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;
  const JamaahPage({super.key, this.masjidId, this.masjid});

  @override
  State<JamaahPage> createState() => _JamaahPageState();
}

class _JamaahPageState extends State<JamaahPage> {
  late Future<List<JamaahEntity>> _jamaahsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJamaahs();
  }

  void _loadJamaahs() {
    _jamaahsFuture = _getJamaahs();
  }

  Future<List<JamaahEntity>> _getJamaahs() async {
    final masjidId = widget.masjidId ?? widget.masjid?.id;
    if (masjidId == null) {
      if (!mounted) return [];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masjid belum dipilih')));
      return [];
    }

    final result = await sl<GetJamaahsByMasjidUseCase>().call(
      params: GetJamaahsByMasjidParams(masjidId: masjidId),
    );

    return result.fold((error) {
      if (!mounted) return [];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil jamaah: $error')));
      return [];
    }, (data) => data as List<JamaahEntity>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(masjid: widget.masjid),
      appBar: AppBar(title: Text(widget.masjid?.title ?? 'Daftar Jamaah')),
      body: FutureBuilder<List<JamaahEntity>>(
        future: _jamaahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allJamaahs = snapshot.data ?? [];

          // Filter berdasarkan search query
          final filteredJamaahs = allJamaahs
              .where(
                (j) =>
                    j.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

          // Hitung statistik
          final lakiLaki = allJamaahs
              .where((j) => j.jenisKelamin == 'Laki Laki')
              .length;
          final perempuan = allJamaahs
              .where((j) => j.jenisKelamin == 'Perempuan')
              .length;
          final total = allJamaahs.length;

          if (allJamaahs.isEmpty) {
            return const Center(child: Text('Belum ada jamaah'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Data Jama'ah dengan Search, Filter, dan Kelola
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Data Jama\'ah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar, Filter, dan Kelola
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari Jama\'ah',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.tune, color: Colors.grey[700]),
                        onPressed: () {
                          // TODO: Implement filter
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JamaahManagePage(
                                masjidId: widget.masjidId,
                                masjid: widget.masjid,
                              ),
                            ),
                          );
                          if (res == true) {
                            setState(() {
                              _loadJamaahs();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          'Kelola',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Statistik Kartu (sinkron dengan Firestore)
                  Builder(
                    builder: (context) {
                      final masjidId = widget.masjidId ?? widget.masjid?.id;
                      if (masjidId == null) {
                        // Fallback: gunakan perhitungan lokal jika masjidId tidak tersedia
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard('Laki Laki', lakiLaki),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard('Perempuan', perempuan),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: _buildStatCard('Total', total)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Menampilkan ${filteredJamaahs.length} dari $total jama\'ah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement export
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text('Export'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Masjid')
                            .doc(masjidId)
                            .collection('Jamaah')
                            .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Laki Laki',
                                        lakiLaki,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Perempuan',
                                        perempuan,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard('Total', total),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }

                          if (!snap.hasData) {
                            return const SizedBox.shrink();
                          }

                          final docs = snap.data!.docs;
                          int laki = 0;
                          int perempuanCount = 0;
                          for (final d in docs) {
                            final data = d.data();
                            String jk =
                                (data['jenisKelamin'] ??
                                        data['jenis_kelamin'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();
                            // normalize: remove non-letters, then check keywords
                            final norm = jk.replaceAll(RegExp(r'[^a-z]'), '');
                            if (norm.contains('laki')) {
                              laki++;
                            } else if (norm.contains('perempuan')) {
                              perempuanCount++;
                            }
                          }

                          final totalCount = docs.length;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard('Laki Laki', laki),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Perempuan',
                                      perempuanCount,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard('Total', totalCount),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Menampilkan ${filteredJamaahs.length} dari $totalCount jama\'ah',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // TODO: Implement export
                                    },
                                    icon: const Icon(Icons.download),
                                    label: const Text('Export'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Table Header
                  Container(
                    color: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Nama',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Jenis Kelamin',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Kategori',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Content
                  ...filteredJamaahs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final j = entry.value;
                    final isEven = index % 2 == 0;

                    return Container(
                      color: isEven ? Colors.grey[100] : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text(j.name)),
                          Expanded(flex: 1, child: Text(j.jenisKelamin)),
                          Expanded(
                            flex: 1,
                            child: Text(
                              KategoriJamaahX.fromString(j.kategori)?.label ??
                                  j.kategori,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
