import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/common/widgets/app_drawer.dart';

class KeuanganPage extends StatelessWidget {
  final MasjidEntity? masjid;
  const KeuanganPage({super.key, this.masjid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(masjid: masjid),
      appBar: AppBar(title: Text(masjid?.title ?? 'Keuangan')),
      body: const Center(child: Text('Halaman Keuangan - (kosong)')),
    );
  }
}
