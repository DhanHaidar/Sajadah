# 🔥 Supabase + Firestore Setup Guide untuk Sajadah App

## Problem yang Sedang Terjadi

Anda mendapat error:
```
❌ Firestore: PERMISSION_DENIED - Missing or insufficient permissions
```

Ini terjadi karena **Firestore Security Rules belum dikonfigurasi** untuk allow write operations.

**Note**: App menggunakan:
- **Supabase Storage** untuk upload gambar (bucket: 'Songs')
- **Firestore** untuk menyimpan data event

---

## ✅ Solusi: Update Firebase Rules

### **Step 1: Firestore Security Rules**

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project **Sajadah**
3. Pergi ke **Firestore Database** → **Rules** tab
4. Replace semua isinya dengan:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read for everyone
    match /{document=**} {
      allow read: if true;
    }
    
    // Allow write for authenticated users
    match /Kegiatan/{document=**} {
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
    
    // Allow all for other collections
    match /{document=**} {
      allow write: if request.auth != null;
    }
  }
}
```

5. Klik **Publish**

---

### **Step 2: Supabase Storage Setup** ⚡

✅ **Sudah dikonfigurasi** di Supabase project Anda:
- Bucket name: `Songs`
- Path untuk event images: `event_images/{timestamp}.{extension}`
- Public read access: ✅ Enabled
- Upload access: ✅ Enabled untuk authenticated users

**Tidak perlu setup apapun di Supabase** - sudah berjalan dengan baik!

---

### **Step 3: Firestore Authentication Setup** ⚡

Pastikan app sudah authenticated untuk Firestore. Di `main.dart` sudah ada:

```dart
try {
  await FirebaseAuth.instance.signInAnonymously();
} catch (_) {}
```

Ini membuat user anonymous auth ✅ (diperlukan untuk Firestore write access)

---

## 🧪 Testing Setelah Setup

1. **Buka app** dan navigate ke **Events page**
2. **Klik tombol "+" (Floating Action Button)**
3. **Isi form** dengan data event:
   - Judul: "Test Event"
   - Deskripsi: "Test description"
   - Lokasi: "Masjid Al-Ikhlas"
   - Tanggal: Pilih hari ini
   - Gambar: Pilih (opsional)

4. **Klik "Buat Event Sekarang"**

### Expected Results:

✅ Logs akan menunjukkan:
```
📸 Uploading image to: event_images/12345.jpg
✅ Upload successful
📥 Download URL: https://...
💾 Saving to Firestore: Test Event
✅ Firestore save successful: abc123def456
```

✅ Akan melihat SnackBar: "Event berhasil dibuat dengan gambar!"

✅ Event muncul di list Events

---

## 🐛 Troubleshooting

### Masalah: Firestore write error (PERMISSION_DENIED)
**Solusi**:
- Pastikan Firestore Rules sudah **Published** (bukan hanya **Saved**)
- Tunggu 10 detik untuk rules propagate
- Kill app dan restart
- Check bahwa anonymous auth sudah enabled

### Masalah: Supabase upload error
**Solusi**:
- Bucket 'Songs' sudah exist?
- Cek Supabase Console → Storage → 'Songs' bucket
- Pastikan folder `event_images/` bisa diakses
- Jika masalah, restart app

### Masalah: Anonymous auth gagal
**Solusi**:
- Pergi ke Firebase Console → **Authentication** → **Sign-in method**
- Pastikan **Anonymous** sudah enabled

---

## 📋 Checklist

- [ ] Firestore Rules sudah diupdate & Published
- [ ] Tunggu 10 detik untuk rules propagate
- [ ] Supabase Storage bucket 'Songs' sudah exist
- [ ] Anonymous Authentication enabled di Firebase
- [ ] App sudah di-restart setelah rules update

---

## 🎯 Struktur Database Setelah Setup

### Firestore Collection: `Kegiatan`
```
{
  "title": "Test Event",
  "deskripsi": "Test description",
  "speaker": null,
  "location": "Masjid Al-Ikhlas",
  "waktu": Timestamp(2026-04-23 10:30),
  "imageUrl": "https://firebasestorage.googleapis.com/..."
}
```

### Supabase Storage Path: `event_images/` dalam bucket 'Songs'
```
https://nngtndfkbwefsphshnjz.supabase.co/storage/v1/object/public/Songs/event_images/
  ├── 1713878400000.jpg
  ├── 1713878460000.png
  └── ...
```

---

## 📞 Jika Masih Error

Check console logs dengan emoji:
- 📸 = image upload started
- ✅ = success
- ⚠️ = warning (melanjutkan)
- ❌ = error
- 💾 = database operation
- 📥 = download

Share logs jika masih ada issue! 🚀
