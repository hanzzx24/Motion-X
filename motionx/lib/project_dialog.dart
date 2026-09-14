import "editor_screen.dart";
import 'package:flutter/material.dart';
import 'editor_screen.dart';

void showNewProjectSheet(BuildContext context) {
  final nameCtrl = TextEditingController(text: 'Proyek Baru 1');
  int selRatio = 1; // 9:16 default
  final ratios = [
    {'lbl': '16:9', 'r': 16 / 9},
    {'lbl': '9:16', 'r': 9 / 16},
    {'lbl': '4:5', 'r': 4 / 5},
    {'lbl': '1:1', 'r': 1 / 1},
    {'lbl': '4:3', 'r': 4 / 3},
  ];
  String res = '540p (SD)';
  final resList = ['2K (1440p)', '1080p (FHD)', '720p (HD)', '540p (SD)', '480p', '360p'];
  int fps = 30;
  final fpsList = [20, 24, 25, 30, 48, 50, 60];
  Color bgCol = const Color(0xFFCCCCCC);
  String bgName = 'Abu-abu Muda';
  final bgList = [
    {'name': 'Hitam', 'c': Colors.black},
    {'name': 'Putih', 'c': Colors.white},
    {'name': 'Abu-abu Muda', 'c': const Color(0xFFCCCCCC)},
    {'name': 'Hijau', 'c': const Color(0xFF00C853)},
    {'name': 'Biru', 'c': const Color(0xFF2979FF)},
  ];
  showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (c, setS) => Container(
        margin: const EdgeInsets.only(top: 60), padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(color: Color(0xFFF2F2F4), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1E2333), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('PROYEK', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold))))),
            const SizedBox(width: 8),
            Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('ELEMEN', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold))))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder())),
          const SizedBox(height: 12),
          // Kotak Pilihan Rasio (16:9, 9:16, 4:5, 1:1, 4:3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(ratios.length, (i) {
              bool s = selRatio == i;
              return GestureDetector(
                onTap: () => setS(() => selRatio = i),
                child: Container(
                  width: 52, height: 44,
                  decoration: BoxDecoration(color: s ? const Color(0xFF00E676) : Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: s ? const Color(0xFF00E676) : Colors.black26)),
                  child: Center(child: Text(ratios[i]['lbl'] as String, style: TextStyle(color: s ? Colors.black : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12))),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          _row('Resolusi', DropdownButton<String>(
            value: res, dropdownColor: const Color(0xFF2A2E3D), underline: const SizedBox(),
            items: resList.map((x) => DropdownMenuItem(value: x, child: Text(x, style: const TextStyle(fontSize: 12, color: Colors.black87)))).toList(),
            onChanged: (v) => setS(() => res = v!),
          )),
          _row('Frame Rate', DropdownButton<int>(
            value: fps, dropdownColor: const Color(0xFF2A2E3D), underline: const SizedBox(),
            items: fpsList.map((x) => DropdownMenuItem(value: x, child: Text('$x fps', style: const TextStyle(fontSize: 12, color: Colors.black87)))).toList(),
            onChanged: (v) => setS(() => fps = v!),
          )),
          _row('Latar Belakang', DropdownButton<String>(
            value: bgName, dropdownColor: const Color(0xFF2A2E3D), underline: const SizedBox(),
            items: bgList.map((x) => DropdownMenuItem(value: x['name'] as String, child: Text(x['name'] as String, style: const TextStyle(fontSize: 12, color: Colors.black87)))).toList(),
            onChanged: (v) => setS(() { bgName = v!; bgCol = bgList.firstWhere((e) => e['name'] == v)['c'] as Color; }),
          )),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MotionXStudio(
                  projectName: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Proyek Baru',
                  aspectRatio: ratios[selRatio]['r'] as double,
                  bgColor: bgCol,
                  fps: fps,
                )));
              },
              child: const Text('BUAT PROYEK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(ctx)),
        ]),
      ),
    ),
  );
}

Widget _row(String t, Widget d) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 3),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(t, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
    Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)), child: d),
  ]),
);
