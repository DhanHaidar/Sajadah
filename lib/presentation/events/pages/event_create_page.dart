import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/common/enums/kategori_event.dart';
import 'package:sajadah/domain/usecases/event/create_event.dart';
import 'package:sajadah/domain/usecases/event/create_event_for_masjid.dart';
import 'package:sajadah/service_locator.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';

class EventCreatePage extends StatefulWidget {
  final String? masjidId;
  final MasjidEntity? masjid;
  const EventCreatePage({super.key, this.masjidId, this.masjid});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _imageFile;
  DateTime? _selectedDateTime;
  KategoriEvent? _selectedKategori = KategoriEvent.agama;
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

  // Membuka date time picker
  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Validasi form dan upload event
  Future<void> _createEvent() async {
    // Validasi form
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul event harus diisi')));
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi event harus diisi')),
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi event harus diisi')));
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal dan waktu event harus dipilih')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Buat EventModel
      final eventModel = EventModel(
        title: _titleController.text,
        deskripsi: _descriptionController.text,
        speaker: _speakerController.text.isNotEmpty
            ? _speakerController.text
            : null,
        kategori: _selectedKategori?.value,
        dateTime: _selectedDateTime!,
        location: _locationController.text,
      );

      // Upload event dengan gambar
      late final result;
      final masjidId = widget.masjidId ?? widget.masjid?.id;
      if (masjidId != null) {
        result = await sl<CreateEventForMasjidUseCase>().call(
          params: CreateEventForMasjidParams(
            masjidId: masjidId,
            event: eventModel,
            imageFile: _imageFile,
          ),
        );
      } else {
        result = await sl<CreateEventUseCase>().call(
          params: CreateEventParams(event: eventModel, imageFile: _imageFile),
        );
      }

      if (!mounted) return;

      result.fold(
        (error) {
          setState(() {
            _isLoading = false;
          });

          // Determine error type
          String errorMessage = error.toString();
          String displayMessage = 'Gagal membuat event';

          if (errorMessage.contains('PERMISSION_DENIED')) {
            displayMessage =
                'Error: Firebase permissions not configured. Hubungi admin atau check FIREBASE_SETUP.md';
          } else if (errorMessage.contains('object-not-found')) {
            displayMessage =
                'Error: Storage bucket not found. Check FIREBASE_SETUP.md';
          } else if (errorMessage.contains('Network')) {
            displayMessage = 'Error: Koneksi internet bermasalah. Coba lagi.';
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
              ? 'Event berhasil dibuat dengan gambar!'
              : 'Event berhasil dibuat! (tanpa gambar)';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          // Kembali ke halaman sebelumnya dengan signal refresh
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
    _descriptionController.dispose();
    _speakerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.masjid?.title ?? 'Buat Event Baru')),
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
              'Judul Event',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Masukkan judul event',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description field
            const Text(
              'Deskripsi Event',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              enabled: !_isLoading,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi event',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Speaker field
            const Text(
              'Pembicara (Opsional)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _speakerController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pembicara',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kategori event
            const Text(
              'Kategori Event',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<KategoriEvent>(
              value: _selectedKategori,
              items: KategoriEvent.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.label)))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (v) {
                      setState(() {
                        _selectedKategori = v;
                      });
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location field
            const Text(
              'Lokasi Event',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Masukkan lokasi event',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date and Time picker
            const Text(
              'Tanggal dan Waktu Event',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isLoading ? null : _selectDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isLoading ? Colors.grey[300]! : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: _isLoading ? Colors.grey[100] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDateTime == null
                          ? 'Pilih tanggal dan waktu'
                          : '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _selectedDateTime == null
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: _isLoading ? Colors.grey[300] : Colors.grey,
                    ),
                  ],
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
                      'Gambar bersifat opsional. Event dapat dibuat tanpa gambar.',
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
                onPressed: _isLoading ? null : _createEvent,
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
                    : const Text('Buat Event Sekarang'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
