import 'package:flutter/material.dart';
import 'package:sajadah/domain/entities/jamaah/jamaah.dart';
import 'package:sajadah/domain/usecases/jamaah/create_jamaah.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';

class JamaahCreatePage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;
  const JamaahCreatePage({super.key, this.masjidId, this.masjid});

  @override
  State<JamaahCreatePage> createState() => _JamaahCreatePageState();
}

class _JamaahCreatePageState extends State<JamaahCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _noHpCtrl = TextEditingController();
  final TextEditingController _kategoriCtrl = TextEditingController();
  String? _jenisKelamin = 'Laki-laki';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
    });

    final JamaahEntity jamaah = JamaahEntity(
      userId: null,
      masjidId: widget.masjidId,
      name: _nameCtrl.text.trim(),
      jenisKelamin: _jenisKelamin ?? '',
      noHp: _noHpCtrl.text.trim().isEmpty ? null : _noHpCtrl.text.trim(),
      kategori: _kategoriCtrl.text.trim(),
    );

    final result = await sl<CreateJamaahUseCase>().call(
      params: CreateJamaahParams(jamaah: jamaah),
    );

    result.fold(
      (l) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat jamaah: $l')));
      },
      (r) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Jamaah berhasil dibuat')));
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noHpCtrl.dispose();
    _kategoriCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.masjid?.title ?? 'Buat Jamaah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox.shrink(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (v) => setState(() => _jenisKelamin = v),
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Pilih jenis kelamin' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noHpCtrl,
                decoration: const InputDecoration(
                  labelText: 'No HP (opsional)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kategoriCtrl,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
