import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

enum LayerType { video, image, text, shape, effect, audio }

class KeyPoint {
  double t, v;
  KeyPoint({required this.t, required this.v});
  KeyPoint clone() => KeyPoint(t: t, v: v);
}

class LayerItem {
  String id, name; LayerType type; bool visible = true, locked = false;
  double startMs = 0, durMs = 5000; Color color; String path = '', text = 'Motion X';
  VideoPlayerController? vc; BoxFit fit = BoxFit.cover; double x = 0, y = 0, scale = 1;
  Map<String, List<KeyPoint>> keys = {'x': [], 'y': [], 'scale': []};

  LayerItem({required this.id, required this.name, required this.type, required this.color, this.path = '', this.text = 'Motion X', this.vc, double? dur, double? start}) {
    if (dur != null && dur > 0) durMs = dur;
    if (start != null) startMs = start;
  }
  
  bool inRange(double t) => visible && t >= startMs && t <= (startMs + durMs);

  LayerItem clone() {
    return LayerItem(id: id, name: name, type: type, color: color, path: path, text: text, vc: vc, dur: durMs, start: startMs)
      ..visible = visible
      ..locked = locked
      ..fit = fit
      ..x = x
      ..y = y
      ..scale = scale
      ..keys = { for (var k in keys.keys) k: keys[k]!.map((kp) => kp.clone()).toList() };
  }
}

class MotionXStudio extends StatefulWidget {
  final String projectName; final double aspectRatio; final Color bgColor; final int fps;
  const MotionXStudio({super.key, this.projectName = 'Proyek Baru 1', this.aspectRatio = 9 / 16, this.bgColor = Colors.black, this.fps = 30});
  @override State<MotionXStudio> createState() => _MotionXStudioState();
}

class _MotionXStudioState extends State<MotionXStudio> {
  static const ch = MethodChannel('mx/media');
  final List<LayerItem> layers = []; int sel = -1;
  final ValueNotifier<double> timeNotifier = ValueNotifier<double>(0.0);
  bool play = false, autoKey = true, showGrid = false;
  Timer? timer; double totalMs = 60000.0;
  static const double pxPerSec = 60.0, pxPerMs = 0.06, leftPanelW = 68.0, rowH = 44.0;

  final List<List<LayerItem>> _undoStack = [];
  final List<List<LayerItem>> _redoStack = [];

  @override void initState() { super.initState(); ch.invokeMethod('reqPerm'); }
  @override void dispose() { 
    timer?.cancel(); timeNotifier.dispose(); 
    final Set<VideoPlayerController> allVc = {};
    for (var l in layers) { if (l.vc != null) allVc.add(l.vc!); }
    for (var stack in _undoStack) { for (var l in stack) { if (l.vc != null) allVc.add(l.vc!); } }
    for (var vc in allVc) { vc.dispose(); }
    super.dispose(); 
  }

  LayerItem? get active => (sel >= 0 && sel < layers.length) ? layers[sel] : null;

  void saveState() {
    _undoStack.add(layers.map((l) => l.clone()).toList());
    if (_undoStack.length > 30) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(layers.map((l) => l.clone()).toList());
    layers.clear();
    layers.addAll(_undoStack.removeLast());
    sel = -1;
    setState((){});
    updTotal();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(layers.map((l) => l.clone()).toList());
    layers.clear();
    layers.addAll(_redoStack.removeLast());
    sel = -1;
    setState((){});
    updTotal();
  }

  void updTotal() {
    double m = 60000.0;
    for (var l in layers) {
      if (l.vc != null && l.vc!.value.isInitialized) {
        double vd = l.vc!.value.duration.inMilliseconds.toDouble();
        if (vd > 100 && (l.durMs == 5000.0 || l.durMs < vd)) l.durMs = vd;
      }
      if ((l.startMs + l.durMs) > m) m = l.startMs + l.durMs;
    }
    setState(() => totalMs = m);
  }

  void togglePlay() {
    setState(() => play = !play);
    timer?.cancel();
    if (play) {
      double maxT = layers.isEmpty ? 5000.0 : layers.map((l) => l.startMs + l.durMs).reduce(max);
      if (timeNotifier.value >= maxT - 50) seek(0);
      for (var l in layers) {
        if (l.vc != null && l.vc!.value.isInitialized && l.inRange(timeNotifier.value)) {
          l.vc!.seekTo(Duration(milliseconds: (timeNotifier.value - l.startMs).toInt()));
          l.vc!.play();
        }
      }
      timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
        double n = timeNotifier.value + 33;
        double endT = layers.isEmpty ? 5000.0 : layers.map((l) => l.startMs + l.durMs).reduce(max);
        if (n >= endT) {
          timeNotifier.value = endT; seek(endT);
          setState(() => play = false); timer?.cancel();
          for (var l in layers) { l.vc?.pause(); }
        } else { timeNotifier.value = n; }
      });
    } else {
      for (var l in layers) { l.vc?.pause(); }
    }
  }

  void seek(double ms) {
    double tgt = ms.clamp(0.0, totalMs);
    timeNotifier.value = tgt;
    for (var l in layers) {
      if (l.vc != null && l.vc!.value.isInitialized) {
        if (l.inRange(tgt)) l.vc!.seekTo(Duration(milliseconds: (tgt - l.startMs).clamp(0, l.durMs).toInt()));
        else l.vc!.pause();
      }
    }
  }
  void prevFrame() {
    double t = timeNotifier.value;
    double target = t - (1000 / widget.fps);
    if (active != null) {
      double closest = -1;
      for (var list in active!.keys.values) {
        for (var k in list) { if (k.t < t - 5 && k.t > closest) closest = k.t; }
      }
      if (closest >= 0 && (t - closest) < 1000) target = closest;
    }
    seek(target);
  }

  void nextFrame() {
    double t = timeNotifier.value;
    double target = t + (1000 / widget.fps);
    if (active != null) {
      double closest = totalMs + 1000;
      for (var list in active!.keys.values) {
        for (var k in list) { if (k.t > t + 5 && k.t < closest) closest = k.t; }
      }
      if (closest <= totalMs && (closest - t) < 1000) target = closest;
    }
    seek(target);
  }

  Future<void> pickMedia(bool isPhoto) async {
    try {
      final res = await ch.invokeMethod<Map>('pick', {'isPhoto': isPhoto});
      if (res != null) {
        saveState();
        final path = res['path'] as String, isImg = res['isPhoto'] as bool;
        VideoPlayerController? vc;
        double dur = (res['durMs'] != null && (res['durMs'] as num) > 100) ? (res['durMs'] as num).toDouble() : 5000.0;
        if (!isImg) {
          vc = VideoPlayerController.file(File(path));
          await vc.initialize();
          if (vc.value.duration.inMilliseconds > 100) dur = vc.value.duration.inMilliseconds.toDouble();
        }
        final newL = LayerItem(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          name: res['name'] ?? (isImg ? 'Foto' : 'Video'),
          type: isImg ? LayerType.image : LayerType.video,
          color: isImg ? const Color(0xFF00ACC1) : const Color(0xFF1976D2),
          path: path, vc: vc, dur: dur, start: timeNotifier.value,
        );
        setState(() { layers.insert(0, newL); sel = 0; });
        updTotal();

        if (!isImg && vc != null) {
          void syncD() {
            if (vc!.value.isInitialized && vc!.value.duration.inMilliseconds > 100) {
              double realD = vc!.value.duration.inMilliseconds.toDouble();
              if (newL.durMs != realD) setState(() { newL.durMs = realD; updTotal(); });
            }
          }
          vc.addListener(syncD);
          for (int d in [50, 150, 400, 1000]) Future.delayed(Duration(milliseconds: d), syncD);
        }
      }
    } catch (_) {}
  }

  String _fmt(double ms) {
    int s = (ms / 1000).floor();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}:${(((ms % 1000) / 1000) * widget.fps).floor().toString().padLeft(2, '0')}';
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: SafeArea(
        child: Column(children: [
          Container(
            height: 40, padding: const EdgeInsets.symmetric(horizontal: 8), color: const Color(0xFF12141C),
            child: Row(children: [
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context)),
              Expanded(child: Text(widget.projectName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              IconButton(icon: Icon(showGrid ? Icons.grid_on : Icons.grid_off, color: showGrid ? const Color(0xFF00E676) : Colors.white54, size: 18), onPressed: () => setState(() => showGrid = !showGrid)),
              const Text('AutoKey', style: TextStyle(color: Colors.white54, fontSize: 9)),
              Switch(value: autoKey, activeColor: const Color(0xFF00E676), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, onChanged: (v) => setState(() => autoKey = v)),
            ]),
          ),
          
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.all(4),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Container(
                  decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF262A3D))),
                  clipBehavior: Clip.antiAlias,
                  child: ValueListenableBuilder<double>(
                    valueListenable: timeNotifier,
                    builder: (_, t, __) => Stack(fit: StackFit.expand, children: [
                      for (int i = layers.length - 1; i >= 0; i--) if (layers[i].inRange(t)) _renderCanvas(layers[i]),
                      if (!play && active != null && active!.inRange(t))
                        IgnorePointer(child: Container(decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00E676), width: 1.5)))),
                      if (showGrid) const CustomPaint(painter: _GridP()),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 48, padding: const EdgeInsets.symmetric(horizontal: 16), color: const Color(0xFF10121A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.undo, undo, disabled: _undoStack.isEmpty),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.redo, redo, disabled: _redoStack.isEmpty),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.skip_previous, prevFrame),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: togglePlay, borderRadius: BorderRadius.circular(20),
                      child: Icon(play ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    _iconBtn(Icons.skip_next, nextFrame),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.library_add, _showAddModal, color: const Color(0xFF00E676)),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.crop_free, () {
                      if (active == null) return;
                      saveState();
                      setState(() {
                        if (active!.fit == BoxFit.cover) active!.fit = BoxFit.contain;
                        else if (active!.fit == BoxFit.contain) active!.fit = BoxFit.fill;
                        else active!.fit = BoxFit.cover;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),

          if (active != null)
            Container(
              height: 36, color: const Color(0xFF1B1E2B), padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _txtBtn('Split', () {
                  double t = timeNotifier.value;
                  if (t > active!.startMs && t < (active!.startMs + active!.durMs)) {
                    saveState();
                    double cut = t - active!.startMs, oldDur = active!.durMs;
                    setState(() {
                      active!.durMs = cut;
                      layers.insert(sel + 1, active!.clone()..id = '${DateTime.now().millisecondsSinceEpoch}'..name = '${active!.name} 2'..durMs = oldDur - cut..startMs = t);
                      sel++;
                    });
                    updTotal();
                  }
                }),
                _txtBtn('Duplikat', () {
                  saveState();
                  setState(() { layers.insert(sel + 1, active!.clone()..id = '${DateTime.now().millisecondsSinceEpoch}'..name = '${active!.name} Cpy'); sel++; });
                  updTotal();
                }),
                _txtBtn('Transform', _openTr),
                _txtBtn('Hapus', () {
                  saveState();
                  setState(() { layers.removeAt(sel); sel = -1; });
                  updTotal();
                }, col: Colors.redAccent),
              ]),
            ),
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFF141724),
              child: Row(children: [
                Container(
                  width: leftPanelW,
                  decoration: const BoxDecoration(color: Color(0xFF10131E), border: Border(right: BorderSide(color: Color(0xFF1F2436), width: 1.2))),
                  child: Column(children: [
                    Container(height: 18, alignment: Alignment.center, color: const Color(0xFF141724), child: const Text('LAYER', style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold))),
                    Expanded(
                      child: ListView.builder(
                        itemCount: layers.length,
                        itemBuilder: (_, i) {
                          final l = layers[i]; bool isS = (i == sel);
                          return Container(
                            height: rowH, margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                            decoration: BoxDecoration(color: isS ? const Color(0xFF1E243A) : const Color(0xFF141722), borderRadius: BorderRadius.circular(4), border: Border.all(color: isS ? const Color(0xFF00E676) : Colors.white10)),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: 60,
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                  GestureDetector(onTap: () { saveState(); setState(() => l.visible = !l.visible); }, child: Icon(l.visible ? Icons.visibility : Icons.visibility_off, color: l.visible ? const Color(0xFF00E676) : Colors.white24, size: 14)),
                                  Icon(l.type == LayerType.video ? Icons.movie : (l.type == LayerType.image ? Icons.image : Icons.title), color: Colors.white70, size: 14),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
                Expanded(
                  child: ClipRect(
                    child: LayoutBuilder(builder: (_, box) {
                      final double w = box.maxWidth, cx = w / 2;
                      final double fullTrackW = (totalMs * pxPerMs) + w + 3000.0;

                      return Stack(fit: StackFit.expand, children: [
                        Positioned.fill(child: Container(color: const Color(0xFF141724))),
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (d) => seek((timeNotifier.value - (d.primaryDelta ?? 0.0) / pxPerMs).clamp(0.0, totalMs)),
                          ),
                        ),
                        ValueListenableBuilder<double>(
                          valueListenable: timeNotifier,
                          builder: (_, t, __) => Transform.translate(
                            offset: Offset(cx - (t * pxPerMs), 0),
                            child: SizedBox(
                              width: fullTrackW,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  height: 18, width: fullTrackW, color: const Color(0xFF181B28),
                                  child: Stack(children: [
                                    for (int s = 0; s <= (totalMs / 1000).ceil(); s++)
                                      Positioned(left: s * pxPerSec, child: Text('${s}s', style: const TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'monospace'))),
                                  ]),
                                ),
                                for (int i = 0; i < layers.length; i++)
                                  _buildTrackRow(layers[i], i, fullTrackW),
                              ]),
                            ),
                          ),
                        ),
                        Positioned(left: cx - 1, top: 0, bottom: 0, child: IgnorePointer(child: Container(width: 2, color: Colors.white))),
                        Positioned(
                          left: cx - 36, top: 1,
                          child: IgnorePointer(
                            child: ValueListenableBuilder<double>(
                              valueListenable: timeNotifier,
                              builder: (_, t, __) => Container(
                                width: 72, alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 1),
                                decoration: BoxDecoration(color: const Color(0xFF1E2130), borderRadius: BorderRadius.circular(3), border: Border.all(color: const Color(0xFF00E676), width: 0.8)),
                                child: Text(_fmt(t), style: const TextStyle(color: Color(0xFF00E676), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTrackRow(LayerItem l, int i, double trackW) {
    bool isSel = (i == sel);
    double clipW = (l.durMs * pxPerMs).clamp(30.0, 999999.0);
    return Container(
      height: rowH, width: trackW, margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: const BoxDecoration(color: Color(0xFF1E2235), border: Border(bottom: BorderSide(color: Color(0xFF262C42), width: 0.8))),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(left: -3000.0, right: 0, top: 0, bottom: 0, child: Container(color: const Color(0xFF1E2235))),
        Positioned(
          left: l.startMs * pxPerMs, width: clipW, top: 2, bottom: 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => sel = i),
            onHorizontalDragStart: (_) { saveState(); setState(() => sel = i); },
            onHorizontalDragUpdate: (d) {
              if (!l.locked) {
                setState(() {
                  double deltaMs = d.delta.dx / pxPerMs;
                  l.startMs = max(0.0, l.startMs + deltaMs);
                  sel = i;
                });
                updTotal();
              }
            },
            child: Container(
              decoration: BoxDecoration(color: l.color.withOpacity(isSel ? 0.95 : 0.65), borderRadius: BorderRadius.circular(4), border: Border.all(color: isSel ? Colors.white : Colors.white24, width: isSel ? 1.5 : 0.8)),
              child: Row(children: [
                if (isSel)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) => saveState(),
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        double del = d.delta.dx / pxPerMs;
                        if (l.durMs - del > 300) { l.startMs += del; l.durMs -= del; }
                      });
                      updTotal();
                    },
                    child: Container(width: 18, color: Colors.white24, child: const Icon(Icons.chevron_left, size: 16, color: Colors.white)),
                  ),
                Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
                if (isSel)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) => saveState(),
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        double del = d.delta.dx / pxPerMs;
                        if (l.durMs + del > 300) l.durMs += del;
                      });
                      updTotal();
                    },
                    child: Container(width: 18, color: Colors.white24, child: const Icon(Icons.chevron_right, size: 16, color: Colors.white)),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _renderCanvas(LayerItem l) {
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(l.x, l.y),
        child: l.type == LayerType.video && l.vc != null && l.vc!.value.isInitialized
            ? SizedBox.expand(child: FittedBox(fit: l.fit, child: SizedBox(width: l.vc!.value.size.width, height: l.vc!.value.size.height, child: VideoPlayer(l.vc!))))
            : (l.type == LayerType.image && l.path.isNotEmpty
                ? SizedBox.expand(child: Image.file(File(l.path), fit: l.fit))
                : Center(child: Text(l.text, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
      ),
    );
  }

  Widget _iconBtn(IconData ic, VoidCallback fn, {Color color = Colors.white70, bool disabled = false}) => InkWell(
    onTap: disabled ? null : fn,
    child: Opacity(opacity: disabled ? 0.3 : 1.0, child: Padding(padding: const EdgeInsets.all(4), child: Icon(ic, color: color, size: 22))),
  );

  Widget _txtBtn(String t, VoidCallback fn, {Color col = Colors.white70}) => InkWell(onTap: fn, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), child: Text(t, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold))));

  void _showAddModal() {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF10131E),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _btn(Icons.video_collection, 'Video', const Color(0xFF1976D2), () { Navigator.pop(context); pickMedia(false); }),
          _btn(Icons.image, 'Foto', const Color(0xFF00ACC1), () { Navigator.pop(context); pickMedia(true); }),
          _btn(Icons.title, 'Teks', const Color(0xFF7C4DFF), () {
            Navigator.pop(context);
            saveState();
            setState(() { layers.insert(0, LayerItem(id: '${DateTime.now().millisecondsSinceEpoch}', name: 'Teks', type: LayerType.text, color: const Color(0xFF7C4DFF), dur: 4000, start: timeNotifier.value)); sel = 0; });
            updTotal();
          }),
        ]),
      ),
    );
  }

  Widget _btn(IconData ic, String t, Color c, VoidCallback fn) => InkWell(
    onTap: fn,
    child: Container(
      width: 70, height: 60,
      decoration: BoxDecoration(color: const Color(0xFF1A1E2E), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.5))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, color: c, size: 22), const SizedBox(height: 4), Text(t, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
    ),
  );

  void _openTr() {
    if (active == null) return; final l = active!;
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF141622), builder: (_) => StatefulBuilder(builder: (c, setS) => Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Transform: ${l.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      Slider(value: l.x.clamp(-250, 250), min: -250, max: 250, activeColor: const Color(0xFF00E676), onChangeStart: (_) => saveState(), onChanged: (v) { setS(() => l.x = v); setState(() {}); }),
      Slider(value: l.y.clamp(-250, 250), min: -250, max: 250, activeColor: const Color(0xFF00E676), onChangeStart: (_) => saveState(), onChanged: (v) { setS(() => l.y = v); setState(() {}); }),
    ]))));
  }
}

class _GridP extends CustomPainter {
  const _GridP();
  @override void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.white12..strokeWidth = 0.6;
    for (double x = 0; x < s.width; x += 20) c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    for (double y = 0; y < s.height; y += 20) c.drawLine(Offset(0, y), Offset(s.width, y), p);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}
