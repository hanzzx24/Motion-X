import 'package:flutter/material.dart';
import '../models/motionx_models.dart';

enum ActiveNavTab {
  none,
  edit,
  audio,
  teks,
  stiker,
  efek,
  overlay,
  filter,
  sesuaikan
}

class MotionBottomToolbar extends StatefulWidget {
  final MotionLayerItem? selectedLayer;
  final VoidCallback onStateChanged;
  final Function(String action) onEditAction;
  final VoidCallback onAddAudio;
  final VoidCallback onExtractAudio;
  final VoidCallback onAddText;
  final VoidCallback onAddSticker;
  final VoidCallback onAddOverlay;

  const MotionBottomToolbar({
    Key? key,
    required this.selectedLayer,
    required this.onStateChanged,
    required this.onEditAction,
    required this.onAddAudio,
    required this.onExtractAudio,
    required this.onAddText,
    required this.onAddSticker,
    required this.onAddOverlay,
  }) : super(key: key);

  @override
  State<MotionBottomToolbar> createState() => _MotionBottomToolbarState();
}

class _MotionBottomToolbarState extends State<MotionBottomToolbar> {
  ActiveNavTab _currentTab = ActiveNavTab.edit;

  final Color _bgDark = const Color(0xFF0D1017);
  final Color _subPanelBg = const Color(0xFF141923);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _inactiveColor = const Color(0xFF8E95A5);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sub Toolbar (Fitur Detail)
          if (_currentTab != ActiveNavTab.none)
            Container(
              height: 62,
              color: _subPanelBg,
              child: _buildSubToolbar(),
            ),
          
          // Divider tipis
          Container(height: 1, color: Colors.white.withOpacity(0.06)),

          // Main Navigation Bar (8 Menu persis gambar referensi)
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _navItem(ActiveNavTab.edit, Icons.content_cut, 'Edit'),
                  _navItem(ActiveNavTab.audio, Icons.music_note, 'Audio'),
                  _navItem(ActiveNavTab.teks, Icons.title, 'Teks'),
                  _navItem(ActiveNavTab.stiker, Icons.sentiment_satisfied_alt, 'Stiker'),
                  _navItem(ActiveNavTab.efek, Icons.auto_awesome, 'Efek'),
                  _navItem(ActiveNavTab.overlay, Icons.layers, 'Overlay'),
                  _navItem(ActiveNavTab.filter, Icons.bubble_chart, 'Filter'),
                  _navItem(ActiveNavTab.sesuaikan, Icons.tune, 'Sesuaikan'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(ActiveNavTab tab, IconData icon, String label) {
    final bool isActive = _currentTab == tab;
    final Color itemColor = isActive ? _accentGreen : _inactiveColor;

    return InkWell(
      onTap: () {
        setState(() {
          _currentTab = _currentTab == tab ? ActiveNavTab.none : tab;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23, color: itemColor),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: itemColor,
              ),
            ),
            const SizedBox(height: 3),
            // Indikator garis bawah hijau
            Container(
              height: 2.5,
              width: 18,
              decoration: BoxDecoration(
                color: isActive ? _accentGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubToolbar() {
    switch (_currentTab) {
      case ActiveNavTab.edit:
        return _buildEditSub();
      case ActiveNavTab.audio:
        return _buildAudioSub();
      case ActiveNavTab.teks:
        return _buildTextSub();
      case ActiveNavTab.stiker:
        return _buildStickerSub();
      case ActiveNavTab.efek:
        return _buildEffectSub();
      case ActiveNavTab.overlay:
        return _buildOverlaySub();
      case ActiveNavTab.filter:
        return _buildFilterSub();
      case ActiveNavTab.sesuaikan:
        return _buildAdjustSub();
      case ActiveNavTab.none:
        return const SizedBox.shrink();
    }
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color ?? Colors.white70),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color ?? Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSub() {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      children: [
        _actionBtn('Bagi (Split)', Icons.call_split, () => widget.onEditAction('split')),
        _actionBtn('Duplikat', Icons.copy, () => widget.onEditAction('duplicate')),
        _actionBtn('Hapus', Icons.delete_outline, () => widget.onEditAction('delete'), color: Colors.redAccent),
        _actionBtn('Kecepatan', Icons.speed, () => _showSpeedDialog()),
        _actionBtn('Transform', Icons.crop_rotate, () => _showTransformDialog()),
        _actionBtn('Volume', Icons.volume_up, () => _showVolumeDialog()),
        _actionBtn('Opasitas', Icons.opacity, () => _showOpacityDialog()),
      ],
    );
  }

  Widget _buildAudioSub() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _actionBtn('Tambah Musik', Icons.library_music, widget.onAddAudio),
        _actionBtn('Ekstrak Audio', Icons.multitrack_audio, widget.onExtractAudio, color: _accentGreen),
        _actionBtn('Bagi Audio', Icons.call_split, () => widget.onEditAction('split_audio')),
        _actionBtn('Volume', Icons.volume_up, () => _showVolumeDialog()),
        _actionBtn('Fade In', Icons.gradient, () => _adjustAudioFade(true)),
        _actionBtn('Fade Out', Icons.gradient, () => _adjustAudioFade(false)),
        _actionBtn('Hapus Audio', Icons.delete, () => widget.onEditAction('delete'), color: Colors.redAccent),
      ],
    );
  }

  Widget _buildTextSub() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _actionBtn('Tambah Teks', Icons.add, widget.onAddText, color: _accentGreen),
        if (widget.selectedLayer?.type == MotionLayerType.text) ...[
          _actionBtn('Edit Kata', Icons.edit, () => _showTextEditor()),
          _actionBtn('Ukuran', Icons.format_size, () => _showTextSizeDialog()),
          _actionBtn('Warna', Icons.color_lens, () => _showTextColorDialog()),
          _actionBtn('Tebal/Miring', Icons.format_bold, () {
            final l = widget.selectedLayer!;
            l.textConfig.isBold = !l.textConfig.isBold;
            widget.onStateChanged();
          }),
        ]
      ],
    );
  }

  Widget _buildStickerSub() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _actionBtn('Tambah Stiker', Icons.add_reaction, widget.onAddSticker, color: _accentGreen),
        if (widget.selectedLayer?.type == MotionLayerType.sticker) ...[
          _actionBtn('Duplikat', Icons.copy, () => widget.onEditAction('duplicate')),
          _actionBtn('Hapus', Icons.delete, () => widget.onEditAction('delete'), color: Colors.redAccent),
        ]
      ],
    );
  }

  Widget _buildEffectSub() {
    if (widget.selectedLayer == null) {
      return const Center(child: Text('Pilih layer terlebih dahulu', style: TextStyle(color: Colors.white54, fontSize: 11)));
    }
    final eff = widget.selectedLayer!.effect;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _sliderWidget('Blur', eff.blur, 0, 20, (v) {
          eff.blur = v;
          widget.onStateChanged();
        }),
        _sliderWidget('Glow', eff.glow, 0, 1, (v) {
          eff.glow = v;
          widget.onStateChanged();
        }),
        _sliderWidget('RGB Split', eff.rgbSplit, 0, 15, (v) {
          eff.rgbSplit = v;
          widget.onStateChanged();
        }),
      ],
    );
  }

  Widget _buildOverlaySub() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _actionBtn('+ Video/Foto Overlay', Icons.video_library, widget.onAddOverlay, color: _accentGreen),
        if (widget.selectedLayer != null) ...[
          _actionBtn('Blend Screen', Icons.filter_none, () {
            widget.selectedLayer!.blendMode = BlendMode.screen;
            widget.onStateChanged();
          }),
          _actionBtn('Blend Normal', Icons.layers_clear, () {
            widget.selectedLayer!.blendMode = BlendMode.srcOver;
            widget.onStateChanged();
          }),
        ]
      ],
    );
  }

  Widget _buildFilterSub() {
    if (widget.selectedLayer == null) {
      return const Center(child: Text('Pilih layer untuk menerapkan filter', style: TextStyle(color: Colors.white54, fontSize: 11)));
    }
    final filters = ['Normal', 'Warm', 'Cool', 'Cinematic', 'Vintage', 'B&W', 'Fade'];
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      itemBuilder: (ctx, idx) {
        final f = filters[idx];
        final isCur = widget.selectedLayer!.activeFilter == f;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: ChoiceChip(
            label: Text(f, style: TextStyle(fontSize: 11, color: isCur ? Colors.black : Colors.white)),
            selected: isCur,
            selectedColor: _accentGreen,
            backgroundColor: const Color(0xFF1F2533),
            onSelected: (val) {
              widget.selectedLayer!.activeFilter = f;
              widget.onStateChanged();
            },
          ),
        );
      },
    );
  }

  Widget _buildAdjustSub() {
    if (widget.selectedLayer == null) {
      return const Center(child: Text('Pilih layer untuk penyesuaian', style: TextStyle(color: Colors.white54, fontSize: 11)));
    }
    final adj = widget.selectedLayer!.adjustment;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _sliderWidget('Kecerahan', adj.brightness, -1, 1, (v) {
          adj.brightness = v;
          widget.onStateChanged();
        }),
        _sliderWidget('Kontras', adj.contrast, 0, 2, (v) {
          adj.contrast = v;
          widget.onStateChanged();
        }),
        _sliderWidget('Suhu', adj.temperature, -1, 1, (v) {
          adj.temperature = v;
          widget.onStateChanged();
        }),
        _sliderWidget('Tint', adj.tint, -1, 1, (v) {
          adj.tint = v;
          widget.onStateChanged();
        }),
      ],
    );
  }

  Widget _sliderWidget(String name, double val, double min, double max, ValueChanged<double> onChange) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$name: ${val.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: _accentGreen,
              thumbColor: _accentGreen,
              inactiveTrackColor: Colors.white24,
            ),
            child: Slider(value: val.clamp(min, max), min: min, max: max, onChanged: onChange),
          )
        ],
      ),
    );
  }

  void _showSpeedDialog() {
    if (widget.selectedLayer == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: _subPanelBg,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kecepatan Layer: ${widget.selectedLayer!.audioConfig.speed.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white)),
              Slider(
                value: widget.selectedLayer!.audioConfig.speed,
                min: 0.2,
                max: 3.0,
                activeColor: _accentGreen,
                onChanged: (v) {
                  setS(() => widget.selectedLayer!.audioConfig.speed = v);
                  widget.onStateChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransformDialog() {
    if (widget.selectedLayer == null) return;
    final tr = widget.selectedLayer!.transform;
    showModalBottomSheet(
      context: context,
      backgroundColor: _subPanelBg,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Skala: ${tr.scale.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
              Slider(
                value: tr.scale,
                min: 0.2,
                max: 3.0,
                activeColor: _accentGreen,
                onChanged: (v) {
                  setS(() => tr.scale = v);
                  widget.onStateChanged();
                },
              ),
              Text('Rotasi: ${(tr.rotation * 180 / 3.14159).toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white)),
              Slider(
                value: tr.rotation,
                min: -3.14159,
                max: 3.14159,
                activeColor: _accentGreen,
                onChanged: (v) {
                  setS(() => tr.rotation = v);
                  widget.onStateChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVolumeDialog() {
    if (widget.selectedLayer == null) return;
    final ac = widget.selectedLayer!.audioConfig;
    showModalBottomSheet(
      context: context,
      backgroundColor: _subPanelBg,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Volume: ${(ac.volume * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
              Slider(
                value: ac.volume,
                min: 0.0,
                max: 2.0,
                activeColor: _accentGreen,
                onChanged: (v) {
                  setS(() => ac.volume = v);
                  widget.onStateChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOpacityDialog() {
    if (widget.selectedLayer == null) return;
    final tr = widget.selectedLayer!.transform;
    showModalBottomSheet(
      context: context,
      backgroundColor: _subPanelBg,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Opasitas: ${(tr.opacity * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
              Slider(
                value: tr.opacity,
                min: 0.0,
                max: 1.0,
                activeColor: _accentGreen,
                onChanged: (v) {
                  setS(() => tr.opacity = v);
                  widget.onStateChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _adjustAudioFade(bool isFadeIn) {
    if (widget.selectedLayer == null) return;
    final ac = widget.selectedLayer!.audioConfig;
    if (isFadeIn) {
      ac.fadeInMs = ac.fadeInMs == 0 ? 1500 : 0;
    } else {
      ac.fadeOutMs = ac.fadeOutMs == 0 ? 1500 : 0;
    }
    widget.onStateChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isFadeIn ? "Fade In" : "Fade Out"}: ${isFadeIn ? ac.fadeInMs : ac.fadeOutMs}ms')),
    );
  }

  void _showTextEditor() {
    if (widget.selectedLayer?.type != MotionLayerType.text) return;
    final tc = TextEditingController(text: widget.selectedLayer!.textConfig.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _subPanelBg,
        title: const Text('Edit Teks', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: tc,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Tulis teks...', hintStyle: TextStyle(color: Colors.white30)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.selectedLayer!.textConfig.text = tc.text;
              widget.onStateChanged();
              Navigator.pop(ctx);
            },
            child: Text('Simpan', style: TextStyle(color: _accentGreen)),
          )
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    if (widget.selectedLayer?.type != MotionLayerType.text) return;
    final tc = widget.selectedLayer!.textConfig;
    showModalBottomSheet(
      context: context,
      backgroundColor: _subPanelBg,
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ukuran Font: ${tc.fontSize.toInt()}', style: const TextStyle(color: Colors.white)),
              Slider(
                value: tc.fontSize,
                min: 12.0,
                max: 72.0,
                activeColor: _accentGreen,
                onChanged: (v) {
                  setS(() => tc.fontSize = v);
                  widget.onStateChanged();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextColorDialog() {
    if (widget.selectedLayer?.type != MotionLayerType.text) return;
    final colors = [Colors.white, _accentGreen, Colors.yellow, Colors.redAccent, Colors.cyanAccent, Colors.purpleAccent];
    showModalBottomSheet(
      context: context,
      backgroundColor: _subPanelBg,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colors.map((col) {
            return GestureDetector(
              onTap: () {
                widget.selectedLayer!.textConfig.color = col;
                widget.onStateChanged();
                Navigator.pop(ctx);
              },
              child: CircleAvatar(backgroundColor: col, radius: 18),
            );
          }).toList(),
        ),
      ),
    );
  }
}
