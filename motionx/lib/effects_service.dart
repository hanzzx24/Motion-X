import 'dart:io';
import 'package:flutter/material.dart';

class VideoEffect {
  final String id, name, icon;
  final String category;
  VideoEffect(this.id, this.name, this.icon, this.category);
}

final List<VideoEffect> onlineEffects = [
  VideoEffect('none', 'Tidak Ada', '🚫', 'Semua'),
  VideoEffect('vignette', 'Vinyet Dark', '🌑', 'Sedang tren'),
  VideoEffect('blur', 'Kabur Halus', '💧', 'Sedang tren'),
  VideoEffect('flash', 'Kedipan Retro', '⚡', 'Klasik'),
  VideoEffect('cyber', 'Cyber Neon', '🔮', 'Penuh Imajinasi'),
  VideoEffect('bw', 'Film Noir', '🎞️', 'Klasik'),
];

Future<bool> checkInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
