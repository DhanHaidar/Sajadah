import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/domain/usecases/jamaah/get_jamaah.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/presentation/jamaah/pages/jamaah_create_page.dart';
import 'package:sajadah/common/enums/kategori_jamaah.dart';
import 'package:sajadah/domain/usecases/jamaah/delete_jamaah.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';

class JamaahManagePage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;
  const JamaahManagePage({super.key, this.masjidId, this.masjid});

  @override
  State<JamaahManagePage> createState() => _JamaahManagePageState();
}

class _JamaahManagePageState extends State<JamaahManagePage> {
  late Future<List<JamaahEntity>> _jamaahsFuture;

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
      appBar: AppBar(title: Text(widget.masjid?.title ?? 'Kelola Jama\'ah')),
      body: FutureBuilder<List<JamaahEntity>>(
        future: _jamaahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final jamaahs = snapshot.data ?? [];
          final total = jamaahs.length;

          // contoh data request (UI only)
          final requestList = [
            {
              'name': 'Amelia Putri',
              'account': 'amel@gmail.com',
              'status': 'Pending',
            },
            {
              'name': 'Fandi Romadhon',
              'account': 'Fnd@gmail.com',
              'status': 'Pending',
            },
          ];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kelola Jama\'ah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JamaahCreatePage(
                                masjidId: widget.masjidId ?? widget.masjid?.id,
                                masjid: widget.masjid,
                              ),
                            ),
                          );
                          if (res == true) {
                            _loadJamaahs();
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Request card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: const Text(
                            'Request Jama\'ah',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Nama',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Akun',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Status',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ...requestList.map((r) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(r['name'] ?? ''),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(r['account'] ?? ''),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Text(r['status'] ?? ''),
                                            const Spacer(),
                                            const Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Main table card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            'Menampilkan ${jamaahs.length} dari $total jama\'ah',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Nama',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Jenis Kelamin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Kategori',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Aksi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ...jamaahs.asMap().entries.map((entry) {
                                final j = entry.value;
                                final isEven = entry.key % 2 == 0;
                                return Container(
                                  color: isEven
                                      ? Colors.grey[100]
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 2, child: Text(j.name)),
                                      Expanded(
                                        flex: 2,
                                        child: Text(j.jenisKelamin),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          KategoriJamaahX.fromString(
                                                j.kategori,
                                              )?.label ??
                                              j.kategori,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                final res = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        JamaahCreatePage(
                                                          masjidId:
                                                              widget.masjidId ??
                                                              widget.masjid?.id,
                                                          masjid: widget.masjid,
                                                          initialJamaah: j,
                                                        ),
                                                  ),
                                                );
                                                if (res == true) {
                                                  _loadJamaahs();
                                                  setState(() {});
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.black54,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                final docId = j.userId;
                                                if (docId == null ||
                                                    docId.isEmpty) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Tidak dapat menghapus: ID dokumen tidak tersedia',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final confirmed =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text(
                                                          'Konfirmasi hapus',
                                                        ),
                                                        content: Text(
                                                          'Hapus jamaah "${j.name}"?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Batal',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Hapus',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                if (confirmed != true) return;

                                                final result =
                                                    await sl<
                                                          DeleteJamaahUseCase
                                                        >()
                                                        .call(
                                                          params:
                                                              DeleteJamaahParams(
                                                                docId: docId,
                                                                masjidId:
                                                                    j.masjidId,
                                                              ),
                                                        );

                                                result.fold(
                                                  (l) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Gagal menghapus jamaah: $l',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  (r) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Jamaah berhasil dihapus',
                                                        ),
                                                      ),
                                                    );
                                                    _loadJamaahs();
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: Colors.black54,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
