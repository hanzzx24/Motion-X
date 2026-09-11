import 'package:flutter/material.dart';

void main() {
  runApp(const MotionXApp());
}

class MotionXApp extends StatelessWidget {
  const MotionXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotionX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF1E1E1E),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MotionX', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 1.2)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add, size: 28),
                label: const Text('New Project', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditorScreen()));
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text('Import Project'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Projects', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildProjectCard('Phonk Edit', '1080p • 60fps', context),
                  _buildProjectCard('Cinematic.mx', '4K • 24fps', context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.view_carousel_outlined), label: 'Templates'),
        ],
      ),
    );
  }

  Widget _buildProjectCard(String title, String specs, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white38, size: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(specs, style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EditorScreen extends StatelessWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNav(context),
            _buildCanvasPreview(),
            _buildTimelineToolbar(),
            _buildMultiLayerTimeline(),
            _buildBottomTools(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
          const Text('Project_1', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.undo, size: 20, color: Colors.white70), onPressed: () {}),
              IconButton(icon: const Icon(Icons.redo, size: 20, color: Colors.white70), onPressed: () {}),
              IconButton(icon: const Icon(Icons.ios_share, color: Color(0xFF00E676), size: 22), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCanvasPreview() {
    return Expanded(
      flex: 5,
      child: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: const Center(
              child: Text('9:16\nCanvas Preview', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF151515),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('00:00:03.450', style: TextStyle(fontFamily: 'Courier', color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
          Row(
            children: const [
              Icon(Icons.skip_previous, color: Colors.white70, size: 24),
              SizedBox(width: 16),
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              SizedBox(width: 16),
              Icon(Icons.skip_next, color: Colors.white70, size: 24),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMultiLayerTimeline() {
    return Expanded(
      flex: 4,
      child: Container(
        color: const Color(0xFF121212),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildTrack('Camera 1', Colors.grey, 0, 800),
                    _buildTrack('Null Object 1', Colors.redAccent, 50, 400),
                    _buildTrack('Adjustment Layer', Colors.purpleAccent, 100, 300),
                    _buildTrack('Text: "MotionX"', Colors.amber, 150, 200),
                    _buildTrack('Main Video.mp4', Colors.blueAccent, 0, 600),
                    _buildTrack('Audio Track.mp3', Colors.greenAccent, 0, 800),
                  ],
                ),
              ),
            ),
            Positioned(top: 0, bottom: 0, child: Container(width: 2, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrack(String name, Color color, double leftMargin, double width) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: Stack(
        children: [
          Positioned(
            left: leftMargin,
            child: Container(
              width: width,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.8), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.layers, size: 12, color: color),
                    const SizedBox(width: 6),
                    Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTools() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolBtn(Icons.cut, 'Split'),
          _buildToolBtn(Icons.diamond_outlined, 'Keyframe'),
          _buildToolBtn(Icons.auto_fix_high, 'Effects'),
          _buildToolBtn(Icons.speed, 'Graph'),
          _buildToolBtn(Icons.layers_outlined, 'Blend'),
        ],
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
