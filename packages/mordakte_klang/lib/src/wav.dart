import 'dart:typed_data';

/// Schreibt Mono-PCM (16 Bit) als WAV-Datei.
Uint8List wavMono16(Float64List proben, int rate) {
  final n = proben.length;
  final daten = ByteData(44 + n * 2);
  void kennung(int o, String s) {
    for (var i = 0; i < 4; i++) {
      daten.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  kennung(0, 'RIFF');
  daten.setUint32(4, 36 + n * 2, Endian.little);
  kennung(8, 'WAVE');
  kennung(12, 'fmt ');
  daten.setUint32(16, 16, Endian.little);
  daten.setUint16(20, 1, Endian.little);
  daten.setUint16(22, 1, Endian.little);
  daten.setUint32(24, rate, Endian.little);
  daten.setUint32(28, rate * 2, Endian.little);
  daten.setUint16(32, 2, Endian.little);
  daten.setUint16(34, 16, Endian.little);
  kennung(36, 'data');
  daten.setUint32(40, n * 2, Endian.little);
  for (var i = 0; i < n; i++) {
    final v = (proben[i].clamp(-1.0, 1.0) * 32767).round();
    daten.setInt16(44 + i * 2, v, Endian.little);
  }
  return daten.buffer.asUint8List();
}
