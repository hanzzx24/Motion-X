import 'package:flutter/material.dart';

enum MotionLayerType { video, image, text, audio, sticker }

class LayerTransformData {
  double x;
  double y;
  double scale;
  double rotation;
  double opacity;

  LayerTransformData({
    this.x = 0.0,
    this.y = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  LayerTransformData copy() => LayerTransformData(
        x: x,
        y: y,
        scale: scale,
        rotation: rotation,
        opacity: opacity,
      );
}

class AdjustmentData {
  double brightness; // -1.0 to 1.0 (default 0)
  double contrast;   // 0.0 to 2.0 (default 1)
  double saturation; // 0.0 to 2.0 (default 1)
  double exposure;   // -1.0 to 1.0 (default 0)
  double temperature;// -1.0 to 1.0 (cool to warm)
  double tint;       // -1.0 to 1.0 (green to magenta)
  double highlights; // -1.0 to 1.0
  double shadows;    // -1.0 to 1.0
  double vignette;   // 0.0 to 1.0

  AdjustmentData({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.exposure = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.vignette = 0.0,
  });

  AdjustmentData copy() => AdjustmentData(
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
        exposure: exposure,
        temperature: temperature,
        tint: tint,
        highlights: highlights,
        shadows: shadows,
        vignette: vignette,
      );
}

class EffectData {
  double blur;       // 0.0 to 25.0
  double rgbSplit;   // 0.0 to 20.0
  double glow;       // 0.0 to 1.0
  double sharpen;    // 0.0 to 1.0

  EffectData({
    this.blur = 0.0,
    this.rgbSplit = 0.0,
    this.glow = 0.0,
    this.sharpen = 0.0,
  });

  EffectData copy() => EffectData(
        blur: blur,
        rgbSplit: rgbSplit,
        glow: glow,
        sharpen: sharpen,
      );
}

class TextConfig {
  String text;
  String fontFamily;
  double fontSize;
  bool isBold;
  bool isItalic;
  TextAlign align;
  Color color;
  Color shadowColor;
  Color strokeColor;
  double strokeWidth;
  Color? bgColor;

  TextConfig({
    this.text = 'Teks Baru',
    this.fontFamily = 'Roboto',
    this.fontSize = 28.0,
    this.isBold = false,
    this.isItalic = false,
    this.align = TextAlign.center,
    this.color = Colors.white,
    this.shadowColor = Colors.transparent,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0.0,
    this.bgColor,
  });

  TextConfig copy() => TextConfig(
        text: text,
        fontFamily: fontFamily,
        fontSize: fontSize,
        isBold: isBold,
        isItalic: isItalic,
        align: align,
        color: color,
        shadowColor: shadowColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        bgColor: bgColor,
      );
}

class AudioConfig {
  double volume;    // 0.0 to 2.0
  int fadeInMs;
  int fadeOutMs;
  double speed;
  bool isExtracted;

  AudioConfig({
    this.volume = 1.0,
    this.fadeInMs = 0,
    this.fadeOutMs = 0,
    this.speed = 1.0,
    this.isExtracted = false,
  });

  AudioConfig copy() => AudioConfig(
        volume: volume,
        fadeInMs: fadeInMs,
        fadeOutMs: fadeOutMs,
        speed: speed,
        isExtracted: isExtracted,
      );
}

class MotionLayerItem {
  final int id;
  String name;
  MotionLayerType type;
  String? filePath;
  int startMs;
  int durationMs;
  Color color;
  BlendMode blendMode;
  String activeFilter;

  LayerTransformData transform;
  AdjustmentData adjustment;
  EffectData effect;
  TextConfig textConfig;
  AudioConfig audioConfig;

  MotionLayerItem({
    required this.id,
    required this.name,
    required this.type,
    this.filePath,
    this.startMs = 0,
    required this.durationMs,
    this.color = const Color(0xFF00E676),
    this.blendMode = BlendMode.srcOver,
    this.activeFilter = 'Normal',
    LayerTransformData? transform,
    AdjustmentData? adjustment,
    EffectData? effect,
    TextConfig? textConfig,
    AudioConfig? audioConfig,
  })  : transform = transform ?? LayerTransformData(),
        adjustment = adjustment ?? AdjustmentData(),
        effect = effect ?? EffectData(),
        textConfig = textConfig ?? TextConfig(),
        audioConfig = audioConfig ?? AudioConfig();

  MotionLayerItem copy() => MotionLayerItem(
        id: id,
        name: name,
        type: type,
        filePath: filePath,
        startMs: startMs,
        durationMs: durationMs,
        color: color,
        blendMode: blendMode,
        activeFilter: activeFilter,
        transform: transform.copy(),
        adjustment: adjustment.copy(),
        effect: effect.copy(),
        textConfig: textConfig.copy(),
        audioConfig: audioConfig.copy(),
      );
}

class ColorMatrixHelper {
  static List<double> buildFilterMatrix(String filter, AdjustmentData adj) {
    List<double> m = List<double>.from(_baseFilter(filter));
    
    // Brightness & Exposure
    double b = (adj.brightness + adj.exposure) * 255.0;
    m[4] += b;
    m[9] += b;
    m[14] += b;

    // Contrast
    double c = adj.contrast;
    double t = 128.0 * (1.0 - c);
    m[0] *= c;
    m[6] *= c;
    m[12] *= c;
    m[4] += t;
    m[9] += t;
    m[14] += t;

    // Temperature (Warm: +R, -B | Cool: -R, +B)
    double temp = adj.temperature * 40.0;
    m[4] += temp;
    m[14] -= temp;

    // Tint (Green: +G | Magenta: +R, +B)
    double tint = adj.tint * 30.0;
    m[9] -= tint;
    m[4] += tint * 0.5;
    m[14] += tint * 0.5;

    return m;
  }

  static List<double> _baseFilter(String filter) {
    switch (filter) {
      case 'Warm':
        return [
          1.1, 0.0, 0.0, 0.0, 15.0,
          0.0, 1.0, 0.0, 0.0, 5.0,
          0.0, 0.0, 0.9, 0.0, -10.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'Cool':
        return [
          0.9, 0.0, 0.0, 0.0, -10.0,
          0.0, 1.0, 0.0, 0.0, 5.0,
          0.0, 0.0, 1.2, 0.0, 20.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'B&W':
        return [
          0.299, 0.587, 0.114, 0.0, 0.0,
          0.299, 0.587, 0.114, 0.0, 0.0,
          0.299, 0.587, 0.114, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'Vintage':
        return [
          0.393, 0.769, 0.189, 0.0, 20.0,
          0.349, 0.686, 0.168, 0.0, 10.0,
          0.272, 0.534, 0.131, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'Cinematic':
        return [
          0.9, 0.0, 0.1, 0.0, -10.0,
          0.0, 1.1, 0.1, 0.0, 5.0,
          0.0, 0.2, 1.3, 0.0, 25.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
      case 'Fade':
        return [
          0.9, 0.0, 0.0, 0.0, 30.0,
          0.0, 0.9, 0.0, 0.0, 30.0,
          0.0, 0.0, 0.9, 0.0, 30.0,
          0.0, 0.0, 0.0, 0.85, 0.0,
        ];
      default:
        return [
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ];
    }
  }
}
