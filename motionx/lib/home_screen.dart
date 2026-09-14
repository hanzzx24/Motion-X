import 'package:flutter/material.dart';
import 'project_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _nav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00C0FF)]), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Motion X', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                Text('Edit. Create. Bring Your Motion.', style: TextStyle(color: Colors.white54, fontSize: 9)),
              ]),
              const Spacer(),
              const Icon(Icons.search, color: Colors.white70, size: 22),
              const SizedBox(width: 12),
              const CircleAvatar(radius: 14, backgroundColor: Color(0xFF6C5CE7), child: Icon(Icons.person, color: Colors.white, size: 16)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 145, width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF171732), Color(0xFF0B1B3D)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2E335A))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('SELAMAT DATANG DI Motion X', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    const Text('Ubah ide kreatifmu jadi video luar biasa.', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: () => showNewProjectSheet(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C0FF)), child: const Text('Mulai Edit', style: TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  _btn(Icons.movie_creation_outlined, 'Proyek Baru', const Color(0xFF6C5CE7), () => showNewProjectSheet(context)),
                  _btn(Icons.auto_fix_high, 'Template', const Color(0xFF00C0FF), () => showNewProjectSheet(context)),
                  _btn(Icons.image_outlined, 'AI Tools', const Color(0xFF00D2D3), () => showNewProjectSheet(context)),
                  _btn(Icons.folder_outlined, 'Impor', const Color(0xFF5352ED), () => showNewProjectSheet(context)),
                ]),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: Container(
        height: 60, color: const Color(0xFF0D0E16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _navBtn(Icons.home_filled, 'Beranda', 0),
          _navBtn(Icons.play_circle_outline, 'Template', 1),
          GestureDetector(
            onTap: () => showNewProjectSheet(context),
            child: Container(width: 44, height: 44, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00C0FF), Color(0xFF6C5CE7)]), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 26)),
          ),
          _navBtn(Icons.layers_outlined, 'Proyek', 2),
          _navBtn(Icons.person_outline, 'Profil', 3),
        ]),
      ),
    );
  }

  Widget _btn(IconData ic, String t, Color c, VoidCallback fn) => Expanded(
    child: GestureDetector(
      onTap: fn,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF111320), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E2238))),
        child: Column(children: [Icon(ic, color: c, size: 22), const SizedBox(height: 4), Text(t, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))]),
      ),
    ),
  );

  Widget _navBtn(IconData ic, String t, int i) => GestureDetector(
    onTap: () => setState(() => _nav = i),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(ic, color: _nav == i ? const Color(0xFF6C5CE7) : Colors.white38, size: 20),
      Text(t, style: TextStyle(color: _nav == i ? const Color(0xFF6C5CE7) : Colors.white38, fontSize: 9)),
    ]),
  );
}
