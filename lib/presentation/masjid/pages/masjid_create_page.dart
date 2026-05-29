import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajadah/data/models/masjid/masjid_model.dart';
import 'package:sajadah/domain/usecases/masjid/create_masjid.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/common/widgets/profile_avatar.dart';

class MasjidCreatePage extends StatefulWidget {
  const MasjidCreatePage({super.key});

  @override
  State<MasjidCreatePage> createState() => _MasjidCreatePageState();
}

class _MasjidCreatePageState extends State<MasjidCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  // Membuka galeri, lalu menyimpan file yang dipilih ke state untuk preview lokal
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Validasi form dan upload masjid
  Future<void> _createMasjid() async {
    // Validasi form
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama masjid harus diisi')));
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi masjid harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Buat MasjidModel
      final masjidModel = MasjidModel(
        title: _titleController.text,
        location: _locationController.text,
        imageUrl: '',
      );

      // Upload masjid dengan gambar
      final result = await sl<CreateMasjidUseCase>().call(
        params: CreateMasjidParams(masjid: masjidModel, imageFile: _imageFile),
      );

      if (!mounted) return;

      result.fold(
        (error) {
          setState(() {
            _isLoading = false;
          });

          String displayMessage = 'Gagal membuat masjid';
          if (error.toString().contains('PERMISSION_DENIED')) {
            displayMessage = 'Error: Firebase permissions not configured';
          } else if (error.toString().contains('Network')) {
            displayMessage = 'Error: Koneksi internet bermasalah';
          } else {
            displayMessage = 'Error: $error';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red[700],
            ),
          );
        },
        (success) {
          setState(() {
            _isLoading = false;
          });
          final message = _imageFile != null
              ? 'Masjid berhasil dibuat dengan gambar!'
              : 'Masjid berhasil dibuat! (tanpa gambar)';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Masjid Baru'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const ProfileAvatar(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview gambar atau tombol untuk memilih gambar
            Center(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Belum ada gambar dipilih',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '(Opsional)',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImage,
                    icon: const Icon(Icons.image_search),
                    label: const Text('Pilih Gambar (Opsional)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Title field
            const Text(
              'Nama Masjid',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Masukkan nama masjid',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location field
            const Text(
              'Lokasi Masjid',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat atau koordinat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gambar bersifat opsional. Masjid dapat dibuat tanpa gambar.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Create button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createMasjid,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Masjid'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
