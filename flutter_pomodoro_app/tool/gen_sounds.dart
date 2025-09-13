// Generates simple .wav audio files for in-app preview playback.
// Produces: assets/audio/classic_bell.wav, gentle_chime.wav, beep.wav
// Run: dart run tool/gen_sounds.dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() async {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final wavs = <String>[
    'beep',
    'gentle_chime',
    'classic_bell',
  ];
  await _writeWav(
    File('${outDir.path}/beep.wav'),
    _tone(durationMs: 400, freqHz: 1000),
  );
  await _writeWav(
    File('${outDir.path}/gentle_chime.wav'),
    _bellLike(durationMs: 1400, baseFreqHz: 880, decay: 2.5),
  );
  await _writeWav(
    File('${outDir.path}/classic_bell.wav'),
    _bellLike(durationMs: 1600, baseFreqHz: 660, decay: 2.0),
  );
  stdout.writeln('Generated WAV files in ${outDir.path}');

  // Try to convert to MP4 (AAC) using ffmpeg; fallback to macOS afconvert when available.
  for (final base in wavs) {
    final wav = File('${outDir.path}/$base.wav');
    final mp4 = File('${outDir.path}/$base.mp4');
    var created = false;
    try {
      final result = await Process.run('ffmpeg', [
        '-y',
        '-hide_banner',
        '-loglevel',
        'error',
        '-i',
        wav.path,
        '-c:a',
        'aac',
        '-b:a',
        '96k',
        mp4.path,
      ]);
      if (result.exitCode == 0) {
        stdout.writeln('Created ${mp4.path}');
        created = true;
      } else {
        stderr.writeln('ffmpeg failed ($base): ${result.stderr}');
      }
    } catch (_) {}
    if (!created) {
      try {
        final m4a = File('${outDir.path}/$base.m4a');
        final result = await Process.run('afconvert', [
          '-f',
          'm4af',
          '-d',
          'aac',
          wav.path,
          m4a.path,
        ]);
        if (result.exitCode == 0 && await m4a.exists()) {
          await m4a.copy(mp4.path);
          await m4a.delete();
          stdout.writeln('Created ${mp4.path} via afconvert');
          created = true;
        } else {
          stderr.writeln('afconvert failed ($base): ${result.stderr}');
        }
      } catch (_) {}
    }
    if (!created) {
      stderr.writeln('Keeping WAV only for $base; no MP4 generated.');
    }
  }

  // Also copy WAVs into Android res/raw for system notification sounds (Android uses raw resource name).
  try {
    final rawDir = Directory('android/app/src/main/res/raw');
    if (!rawDir.existsSync()) rawDir.createSync(recursive: true);
    for (final base in wavs) {
      final src = File('${outDir.path}/$base.wav');
      final dst = File('${rawDir.path}/$base.wav');
      await src.copy(dst.path);
    }
    stdout.writeln('Copied WAVs to ${rawDir.path} for Android notification sounds.');
  } catch (e) {
    stderr.writeln('Could not copy WAVs to Android raw/: $e');
  }
}

const _sampleRate = 44100;

Float32List _tone({required int durationMs, required double freqHz, double volume = 0.3}) {
  final n = (_sampleRate * durationMs / 1000).round();
  final data = Float32List(n);
  for (var i = 0; i < n; i++) {
    final t = i / _sampleRate;
    data[i] = (sin(2 * pi * freqHz * t) * volume).toDouble();
  }
  // Add short linear fade in/out to avoid clicks
  final ramp = (_sampleRate * 0.01).round();
  for (var i = 0; i < min(ramp, n); i++) {
    data[i] *= i / ramp;
    data[n - 1 - i] *= i / ramp;
  }
  return data;
}

Float32List _bellLike({required int durationMs, required double baseFreqHz, double decay = 2.0}) {
  final n = (_sampleRate * durationMs / 1000).round();
  final data = Float32List(n);
  for (var i = 0; i < n; i++) {
    final t = i / _sampleRate;
    final env = exp(-t * decay);
    final s = 0.6 * sin(2 * pi * baseFreqHz * t) +
        0.3 * sin(2 * pi * baseFreqHz * 2.01 * t) +
        0.2 * sin(2 * pi * baseFreqHz * 2.99 * t);
    data[i] = (s * env * 0.5).toDouble();
  }
  // Gentle fade-out tail
  return data;
}

Future<void> _writeWav(File file, Float32List pcm) async {
  // Convert float32 [-1,1] to 16-bit little-endian PCM
  final bytesPerSample = 2;
  final channels = 1;
  final byteRate = _sampleRate * channels * bytesPerSample;
  final dataBytes = ByteData(pcm.length * bytesPerSample);
  for (var i = 0; i < pcm.length; i++) {
    final v = (pcm[i].clamp(-1.0, 1.0) * 32767).round();
    dataBytes.setInt16(i * 2, v, Endian.little);
  }
  final dataChunk = dataBytes.buffer.asUint8List();
  final header = BytesBuilder();
  void writeString(String s) => header.add(s.codeUnits);
  void write32(int v) {
    final b = ByteData(4)..setUint32(0, v, Endian.little);
    header.add(b.buffer.asUint8List());
  }

  void write16(int v) {
    final b = ByteData(2)..setUint16(0, v, Endian.little);
    header.add(b.buffer.asUint8List());
  }

  writeString('RIFF');
  write32(36 + dataChunk.length);
  writeString('WAVE');
  writeString('fmt ');
  write32(16); // PCM subchunk size
  write16(1); // PCM format
  write16(channels);
  write32(_sampleRate);
  write32(byteRate);
  write16(channels * bytesPerSample); // block align
  write16(bytesPerSample * 8); // bits per sample
  writeString('data');
  write32(dataChunk.length);

  final wav = BytesBuilder()
    ..add(header.toBytes())
    ..add(dataChunk);
  await file.writeAsBytes(wav.toBytes());
}
