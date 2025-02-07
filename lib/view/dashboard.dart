import 'package:ben_ten/view/alien_list.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late Animation<double> _tiltAnimation;

  final List<Map<String, String>> ben10Series = [
    {
      'name': 'Ben 10 Ultimate Alien',
      'logo': 'assets/images/ben10_list/ben-10 ultimate alien.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3',
    },
    {
      'name': 'Ben 10 Secret of the Omnitrix',
      'logo': 'assets/images/ben10_list/ben10-seceret of the omitirx.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Repeats the animation back and forth

    _tiltAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSound(String soundPath) async {
    try {
      final ByteData data = await rootBundle.load(soundPath);
      final Uint8List uint8ListBytes =
          Uint8List.fromList(data.buffer.asUint8List());
      await _audioPlayer.play(BytesSource(uint8ListBytes));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ben 10 Series',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron-Bold',
          ),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[800]!, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView.builder(
            itemCount: ben10Series.length,
            itemBuilder: (context, index) {
              final series = ben10Series[index];
              return GestureDetector(
                onTap: () async {
                  playSound(series['sound']!);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OmnitrixSymbol(size: 400,)));
                },
                child: AnimatedBuilder(
                  animation: _tiltAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // 3D tilt effect
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // Perspective
                            ..rotateX(_tiltAnimation.value) // Tilt effect
                            ..rotateY(-_tiltAnimation.value),
                          child: child,
                        ),
                      ],
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 3D Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 200, // Reduced height
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(series['logo']!),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        // Title at the bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              series['name']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Orbitron-Bold',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
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
      ),
    );
  }
}
