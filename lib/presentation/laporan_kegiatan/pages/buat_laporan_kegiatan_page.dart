import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:sajadah/common/auth/role_helper.dart';
import 'package:sajadah/common/utils/android_document_picker.dart';
import 'package:sajadah/common/widgets/profile_avatar.dart';
import 'package:sajadah/domain/entities/masjid/masjid_entity.dart';
import 'package:sajadah/data/models/Event/event.dart';
import 'package:sajadah/domain/usecases/laporan_kegiatan/create_laporan_kegiatan.dart';
import 'package:sajadah/service_locator.dart';

class BuatLaporanKegiatanPage extends StatefulWidget {
  final MasjidEntity? masjid;

  const BuatLaporanKegiatanPage({super.key, this.masjid});

  @override
  State<BuatLaporanKegiatanPage> createState() =>
      _BuatLaporanKegiatanPageState();
}

class _BuatLaporanKegiatanPageState extends State<BuatLaporanKegiatanPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _participantController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  File? _imageFile;
  File? _documentFile;
  String? _documentName;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _participantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
    });
  }

  Future<void> _pickDocument() async {
    try {
      final picked = await AndroidDocumentPicker.pickDocument();
      if (picked == null) return;

      setState(() {
        _documentFile = File(picked.path);
        _documentName = picked.name;
      });
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Picker dokumen belum aktif. Coba rebuild aplikasi.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih dokumen: $e')));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;
    if (!mounted) return;

    setState(() {
      _selectedDate = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  Future<void> _saveReport() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul laporan harus diisi')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi laporan harus diisi')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal laporan harus dipilih')),
      );
      return;
    }

    final role = await RoleHelper.currentRole();
    if (role != 'admin') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak: hanya admin yang dapat menyimpan laporan',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final masjidId = widget.masjid?.id;
      final eventModel = EventModel(
        title: title,
        deskripsi: description,
        dateTime: _selectedDate!,
        location: widget.masjid?.title ?? 'Masjid',
        masjidId: masjidId,
      );
      final result = await sl<CreateLaporanKegiatanUseCase>().call(
        params: CreateLaporanKegiatanParams(
          laporan: eventModel,
          imageFile: _imageFile,
          documentFile: _documentFile,
          documentName: _documentName,
        ),
      );

      if (!mounted) return;

      result.fold(
        (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$error')));
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan kegiatan berhasil disimpan')),
          );
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan laporan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Kegiatan'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const ProfileAvatar(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Laporan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Divider(height: 20),
              _FormLabel('Judul Laporan'),
              const SizedBox(height: 6),
              _TextFieldBox(controller: _titleController, hintText: ''),
              const SizedBox(height: 18),
              _FormLabel('Deskripsi Laporan'),
              const SizedBox(height: 6),
              _TextFieldBox(
                controller: _descriptionController,
                hintText: '',
                maxLines: 4,
              ),
              const SizedBox(height: 18),
              _FormLabel('Tanggal Laporan'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isLoading ? null : _selectDate,
                child: IgnorePointer(
                  child: _TextFieldBox(
                    controller: _dateController,
                    hintText: 'dd/mm/yyyy',
                    suffixIcon: const Icon(Icons.calendar_month_outlined),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _FormLabel('Jumlah Peserta (opsional)'),
              const SizedBox(height: 6),
              _TextFieldBox(
                controller: _participantController,
                hintText: '',
                keyboardType: TextInputType.number,
                suffixIcon: const Icon(Icons.unfold_more),
              ),
              const SizedBox(height: 18),
              _FormLabel('Upload Gambar (opsional)'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  height: 96,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile == null
                      ? const Center(
                          child: Icon(Icons.upload_outlined, size: 34),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              _FormLabel('Upload Document'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isLoading ? null : _pickDocument,
                child: Container(
                  height: 38,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _documentName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _documentName == null
                                ? Colors.transparent
                                : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.upload_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13));
  }
}

class _TextFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;

  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
