enum KategoriJamaah { anakAnak, remaja, dewasa, lansia }

extension KategoriJamaahX on KategoriJamaah {
  String get value {
    switch (this) {
      case KategoriJamaah.anakAnak:
        return 'anak-anak';
      case KategoriJamaah.remaja:
        return 'remaja';
      case KategoriJamaah.dewasa:
        return 'dewasa';
      case KategoriJamaah.lansia:
        return 'lansia';
    }
  }

  String get label {
    switch (this) {
      case KategoriJamaah.anakAnak:
        return 'Anak-anak';
      case KategoriJamaah.remaja:
        return 'Remaja';
      case KategoriJamaah.dewasa:
        return 'Dewasa';
      case KategoriJamaah.lansia:
        return 'Lansia';
    }
  }

  static KategoriJamaah? fromString(String? s) {
    if (s == null) return null;
    final low = s.toLowerCase();
    switch (low) {
      case 'anak-anak':
      case 'anak anak':
      case 'anak':
        return KategoriJamaah.anakAnak;
      case 'remaja':
        return KategoriJamaah.remaja;
      case 'dewasa':
        return KategoriJamaah.dewasa;
      case 'lansia':
      case 'lansia/tua':
        return KategoriJamaah.lansia;
      default:
        return null;
    }
  }
}
