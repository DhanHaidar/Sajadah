enum KategoriEvent { agama, sosial, pendidikan, kesehatan, olahraga, lainnya }

extension KategoriEventX on KategoriEvent {
  String get value {
    switch (this) {
      case KategoriEvent.agama:
        return 'agama';
      case KategoriEvent.sosial:
        return 'sosial';
      case KategoriEvent.pendidikan:
        return 'pendidikan';
      case KategoriEvent.kesehatan:
        return 'kesehatan';
      case KategoriEvent.olahraga:
        return 'olahraga';
      case KategoriEvent.lainnya:
        return 'lainnya';
    }
  }

  String get label {
    switch (this) {
      case KategoriEvent.agama:
        return 'Agama';
      case KategoriEvent.sosial:
        return 'Sosial';
      case KategoriEvent.pendidikan:
        return 'Pendidikan';
      case KategoriEvent.kesehatan:
        return 'Kesehatan';
      case KategoriEvent.olahraga:
        return 'Olahraga';
      case KategoriEvent.lainnya:
        return 'Lainnya';
    }
  }

  static KategoriEvent? fromString(String? s) {
    if (s == null) return null;
    final low = s.toLowerCase();
    switch (low) {
      case 'agama':
        return KategoriEvent.agama;
      case 'sosial':
        return KategoriEvent.sosial;
      case 'pendidikan':
        return KategoriEvent.pendidikan;
      case 'kesehatan':
        return KategoriEvent.kesehatan;
      case 'olahraga':
        return KategoriEvent.olahraga;
      case 'lainnya':
      case 'lain':
        return KategoriEvent.lainnya;
      default:
        return null;
    }
  }
}
