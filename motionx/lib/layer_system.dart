import 'package:flutter/material.dart';

class MotionXLayerPanel extends StatelessWidget {
  final List<dynamic> layers;
  final int selectedIndex;

  final ValueChanged<int> onSelect;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final void Function(int index) onToggleVisible;
  final void Function(int index) onToggleLock;

  const MotionXLayerPanel({
    super.key,
    required this.layers,
    required this.selectedIndex,
    required this.onSelect,
    required this.onReorder,
    required this.onAdd,
    required this.onDuplicate,
    required this.onDelete,
    required this.onToggleVisible,
    required this.onToggleLock,
  });

  IconData _icon(dynamic layer) {
    final type = layer.type.toString();

    if (type.contains('video')) return Icons.video_library;
    if (type.contains('image')) return Icons.image;
    if (type.contains('text')) return Icons.text_fields;
    if (type.contains('shape')) return Icons.crop_square;
    if (type.contains('audio')) return Icons.music_note;

    return Icons.layers;
  }

  Color _layerColor(dynamic layer) {
    try {
      return layer.color;
    } catch (_) {
      return const Color(0xFF00E676);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF10121A),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HANDLE
            Container(
              margin: const EdgeInsets.only(top: 9),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.layers,
                    color: Color(0xFF00E676),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Layers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Tambah Layer',
                    onPressed: onAdd,
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF00E676),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: Colors.white10,
            ),

            // LAYER LIST
            Flexible(
              child: layers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(35),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.layers_clear,
                            color: Colors.white24,
                            size: 42,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada layer',
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      itemCount: layers.length,

                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }

                        onReorder(
                          oldIndex,
                          newIndex,
                        );
                      },

                      itemBuilder: (context, index) {
                        final layer = layers[index];
                        final selected = index == selectedIndex;

                        return Material(
                          key: ValueKey(
                            layer.id,
                          ),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              onSelect(index);
                            },
                            child: Container(
                              height: 58,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1C2930)
                                    : const Color(0xFF151721),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF00E676)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // DRAG
                                  const Icon(
                                    Icons.drag_indicator,
                                    color: Colors.white30,
                                    size: 19,
                                  ),

                                  const SizedBox(width: 5),

                                  // TYPE ICON
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: _layerColor(layer)
                                          .withOpacity(.18),
                                      borderRadius:
                                          BorderRadius.circular(7),
                                    ),
                                    child: Icon(
                                      _icon(layer),
                                      color: _layerColor(layer),
                                      size: 18,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // NAME
                                  Expanded(
                                    child: Text(
                                      layer.name,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),

                                  // VISIBILITY
                                  IconButton(
                                    visualDensity:
                                        VisualDensity.compact,
                                    onPressed: () {
                                      onToggleVisible(index);
                                    },
                                    icon: Icon(
                                      layer.visible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: layer.visible
                                          ? const Color(0xFF00E676)
                                          : Colors.white24,
                                      size: 18,
                                    ),
                                  ),

                                  // LOCK
                                  IconButton(
                                    visualDensity:
                                        VisualDensity.compact,
                                    onPressed: () {
                                      onToggleLock(index);
                                    },
                                    icon: Icon(
                                      layer.locked
                                          ? Icons.lock
                                          : Icons.lock_open,
                                      color: layer.locked
                                          ? Colors.redAccent
                                          : Colors.white24,
                                      size: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // BOTTOM ACTIONS
            Container(
              padding: const EdgeInsets.fromLTRB(
                10,
                8,
                10,
                8,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF141620),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _button(
                      icon: Icons.copy,
                      text: 'Duplikat',
                      onPressed:
                          selectedIndex >= 0
                              ? onDuplicate
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _button(
                      icon: Icons.delete_outline,
                      text: 'Hapus',
                      danger: true,
                      onPressed:
                          selectedIndex >= 0
                              ? onDelete
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    bool danger = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: danger
            ? const Color(0xFF32171B)
            : const Color(0xFF202431),
        foregroundColor: danger
            ? Colors.redAccent
            : Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon, size: 17),
      label: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}
