import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'models/motionx_models.dart';
import 'services/audio_extractor_service.dart';
import 'widgets/bottom_toolbar.dart';

class MotionXStudio extends StatelessWidget {
  final String? projectName;
  final double? aspectRatio;
  final Color? bgColor;
  final int? fps;

  const MotionXStudio({
    Key? key,
    this.projectName,
    this.aspectRatio,
    this.bgColor,
    this.fps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => const EditorScreen();
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final List<MotionLayerItem> _layers = [];
  final List<List<MotionLayerItem>> _undoStack = [];
  final List<List<MotionLayerItem>> _redoStack = [];

  int _selectedLayerIndex = -1;
  final ValueNotifier<int> _timeNotifier = ValueNotifier<int>(0);
  bool _isPlaying = false;
  final int _totalDurationMs = 5000;

  @override
  void initState() {
    super.initState();
    _layers.add(MotionLayerItem(
      id: 1,
      name: 'Video Utama',
      type: MotionLayerType.video,
      durationMs: 5000,
      color: const Color(0xFF1E88E5),
    ));
    _selectedLayerIndex = 0;
  }

  void _saveSnapshot() {
    _undoStack.add(_layers.map((l) => l.copy()).toList());
    _redoStack.clear();
    if (_undoStack.length > 30) _undoStack.removeAt(0);
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add(_layers.map((l) => l.copy()).toList());
      _layers.clear();
      _layers.addAll(_undoStack.removeLast());
      if (_selectedLayerIndex >= _layers.length) _selectedLayerIndex = _layers.length - 1;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add(_layers.map((l) => l.copy()).toList());
      _layers.clear();
      _layers.addAll(_redoStack.removeLast());
      if (_selectedLayerIndex >= _layers.length) _selectedLayerIndex = _layers.length - 1;
    });
  }

  MotionLayerItem? get _currentLayer =>
      (_selectedLayerIndex >= 0 && _selectedLayerIndex < _layers.length) ? _layers[_selectedLayerIndex] : null;

  void _handleEditAction(String action) {
    if (_currentLayer == null) return;
    _saveSnapshot();
    final l = _currentLayer!;
    setState(() {
      if (action == 'delete') {
        _layers.removeAt(_selectedLayerIndex);
        _selectedLayerIndex = _layers.isNotEmpty ? 0 : -1;
      } else if (action == 'duplicate') {
        final dup = l.copy();
        dup.name = '${l.name} (Salin)';
        _layers.insert(_selectedLayerIndex + 1, dup);
        _selectedLayerIndex++;
      } else if (action == 'split' || action == 'split_audio') {
        final curT = _timeNotifier.value;
        if (curT > l.startMs && curT < (l.startMs + l.durationMs)) {
          final firstPart = curT - l.startMs;
          final secondPart = l.durationMs - firstPart;
          l.durationMs = firstPart;

          final splitItem = l.copy();
          splitItem.startMs = curT;
          splitItem.durationMs = secondPart;
          splitItem.name = '${l.name} Part 2';
          _layers.insert(_selectedLayerIndex + 1, splitItem);
        }
      }
    });
  }

  Future<void> _handleExtractAudio() async {
    final video = await AudioExtractorService.pickVideo();
    if (video == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        backgroundColor: Color(0xFF141923),
        title: Text('Mengekstrak Audio...', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: LinearProgressIndicator(color: Color(0xFF00E676)),
      ),
    );

    try {
      final audioPath = await AudioExtractorService.extractAudioFromVideo(
        videoPath: video.path,
        onProgress: (_) {},
      );

      if (mounted) Navigator.pop(context);

      if (audioPath != null) {
        _saveSnapshot();
        setState(() {
          _layers.add(MotionLayerItem(
            id: DateTime.now().millisecondsSinceEpoch,
            name: 'Audio Ekstrak',
            type: MotionLayerType.audio,
            filePath: audioPath,
            durationMs: _totalDurationMs,
            color: const Color(0xFF00E676),
            audioConfig: AudioConfig(isExtracted: true),
          ));
          _selectedLayerIndex = _layers.length - 1;
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  void _handleAddText() {
    _saveSnapshot();
    setState(() {
      _layers.add(MotionLayerItem(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'Teks',
        type: MotionLayerType.text,
        durationMs: 3000,
        startMs: _timeNotifier.value,
        color: const Color(0xFFFFC107),
      ));
      _selectedLayerIndex = _layers.length - 1;
    });
  }

  void _handleAddSticker() {
    _saveSnapshot();
    setState(() {
      _layers.add(MotionLayerItem(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'Stiker ⭐',
        type: MotionLayerType.sticker,
        durationMs: 3000,
        startMs: _timeNotifier.value,
        color: const Color(0xFFE91E63),
      ));
      _selectedLayerIndex = _layers.length - 1;
    });
  }

  Future<void> _handleAddAudio() async {
    final audio = await AudioExtractorService.pickAudio();
    if (audio == null) return;
    _saveSnapshot();
    setState(() {
      _layers.add(MotionLayerItem(
        id: DateTime.now().millisecondsSinceEpoch,
        name: audio.path.split('/').last,
        type: MotionLayerType.audio,
        filePath: audio.path,
        durationMs: 4000,
        startMs: _timeNotifier.value,
        color: const Color(0xFF00E676),
      ));
      _selectedLayerIndex = _layers.length - 1;
    });
  }

  Future<void> _handleAddOverlay() async {
    final file = await AudioExtractorService.pickVideo();
    if (file == null) return;
    _saveSnapshot();
    setState(() {
      _layers.add(MotionLayerItem(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'Overlay Clip',
        type: MotionLayerType.image,
        filePath: file.path,
        durationMs: 3000,
        startMs: _timeNotifier.value,
        color: const Color(0xFF9C27B0),
      ));
      _selectedLayerIndex = _layers.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1017),
        elevation: 0,
        title: const Text('Motion X Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.undo, size: 20), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo, size: 20), onPressed: _redo),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E676), width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(
                  alignment: Alignment.center,
                  children: _layers.map((layer) => _buildLayerWidget(layer)).toList(),
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            color: const Color(0xFF10141E),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFF00E676)),
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                ),
                Expanded(
                  child: SliderTheme(
                    data: const SliderThemeData(
                      thumbColor: Color(0xFF00E676),
                      activeTrackColor: Color(0xFF00E676),
                      inactiveTrackColor: Colors.white24,
                      trackHeight: 3,
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _timeNotifier,
                      builder: (ctx, t, _) => Slider(
                        value: t.toDouble().clamp(0, _totalDurationMs.toDouble()),
                        min: 0,
                        max: _totalDurationMs.toDouble(),
                        onChanged: (v) => _timeNotifier.value = v.toInt(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          MotionBottomToolbar(
            selectedLayer: _currentLayer,
            onStateChanged: () {
              _saveSnapshot();
              setState(() {});
            },
            onEditAction: _handleEditAction,
            onAddAudio: _handleAddAudio,
            onExtractAudio: _handleExtractAudio,
            onAddText: _handleAddText,
            onAddSticker: _handleAddSticker,
            onAddOverlay: _handleAddOverlay,
          ),
        ],
      ),
    );
  }

  Widget _buildLayerWidget(MotionLayerItem layer) {
    if (layer.type == MotionLayerType.audio) return const SizedBox.shrink();

    final tr = layer.transform;
    final colorMatrix = ColorMatrixHelper.buildFilterMatrix(layer.activeFilter, layer.adjustment);

    Widget content;
    if (layer.type == MotionLayerType.text) {
      content = Text(
        layer.textConfig.text,
        style: TextStyle(
          fontSize: layer.textConfig.fontSize,
          fontWeight: layer.textConfig.isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: layer.textConfig.isItalic ? FontStyle.italic : FontStyle.normal,
          color: layer.textConfig.color,
        ),
      );
    } else if (layer.type == MotionLayerType.sticker) {
      content = const Icon(Icons.star, size: 70, color: Colors.amber);
    } else {
      content = Container(
        width: 260,
        height: 160,
        color: layer.color.withOpacity(0.3),
        child: Center(
          child: Icon(
            layer.type == MotionLayerType.video ? Icons.movie : Icons.image,
            size: 48,
            color: Colors.white70,
          ),
        ),
      );
    }

    return Positioned(
      left: 120 + tr.x,
      top: 60 + tr.y,
      child: Transform.rotate(
        angle: tr.rotation,
        child: Transform.scale(
          scale: tr.scale,
          child: Opacity(
            opacity: tr.opacity.clamp(0.0, 1.0),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(colorMatrix),
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: layer.effect.blur,
                  sigmaY: layer.effect.blur,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
