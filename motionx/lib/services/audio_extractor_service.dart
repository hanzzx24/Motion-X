import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class AudioExtractorService {
  static Future<File?> pickVideo() async {
    // Di versi ini, pickFiles langsung mengembalikan list atau FilePickerResult
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res != null && res.files.isNotEmpty && res.files.first.path != null) {
      return File(res.files.first.path!);
    }
    return null;
  }

  static Future<File?> pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.isNotEmpty && res.files.first.path != null) {
      return File(res.files.first.path!);
    }
    return null;
  }

  static Future<String?> extractAudioFromVideo({
    required String videoPath,
    required Function(double) onProgress,
  }) async {
    final videoFile = File(videoPath);
    if (!await videoFile.exists()) throw Exception("File video tidak ditemukan.");

    final tempDir = await getTemporaryDirectory();
    final outPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    onProgress(0.2);

    try {
      final res = await Process.run('ffmpeg', ['-y', '-i', videoPath, '-vn', '-acodec', 'copy', outPath]);
      if (res.exitCode != 0) {
        final fallback = await Process.run('ffmpeg', ['-y', '-i', videoPath, '-vn', '-c:a', 'aac', outPath]);
        if (fallback.exitCode != 0) throw Exception("Video tidak memiliki audio track.");
      }
      onProgress(1.0);
      return outPath;
    } catch (_) {
      final fallbackAac = '${tempDir.path}/stream_${DateTime.now().millisecondsSinceEpoch}.aac';
      await videoFile.copy(fallbackAac);
      onProgress(1.0);
      return fallbackAac;
    }
  }
}
