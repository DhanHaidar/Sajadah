import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:sajadah/domain/usecases/jamaah/get_jamaah.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/presentation/jamaah/pages/jamaah_create_page.dart';

class JamaahPage extends StatefulWidget {
  final String? masjidId;
  const JamaahPage({super.key, this.masjidId});

  @override
  State<JamaahPage> createState() => _JamaahPageState();
}

class _JamaahPageState extends State<JamaahPage> {
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
    if (widget.masjidId == null) {
      if (!mounted) return [];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masjid belum dipilih')));
      return [];
    }

    final result = await sl<GetJamaahsByMasjidUseCase>().call(
      params: GetJamaahsByMasjidParams(masjidId: widget.masjidId!),
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
      appBar: AppBar(title: const Text('Daftar Jamaah')),
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
          if (jamaahs.isEmpty) {
            return const Center(child: Text('Belum ada jamaah'));
          }

          return ListView.separated(
            itemCount: jamaahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final j = jamaahs[index];
              return ListTile(
                title: Text(j.name),
                subtitle: Text('Kategori: ${j.kategori} • ${j.jenisKelamin}'),
                trailing: j.noHp != null && j.noHp!.isNotEmpty
                    ? Text(j.noHp!)
                    : null,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(j.name),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kategori: ${j.kategori}'),
                          Text('Jenis Kelamin: ${j.jenisKelamin}'),
                          if (j.noHp != null && j.noHp!.isNotEmpty)
                            Text('No HP: ${j.noHp}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JamaahCreatePage(masjidId: widget.masjidId),
            ),
          );
          if (res == true) {
            setState(() {
              _loadJamaahs();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
