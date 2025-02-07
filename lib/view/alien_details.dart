import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // For rootBundle

class AlienDetail extends StatefulWidget {
  final Map<String, String> alien;

  const AlienDetail({super.key, required this.alien});

  @override
  // ignore: library_private_types_in_public_api
  _AlienDetailState createState() => _AlienDetailState();
}

class _AlienDetailState extends State<AlienDetail>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  late AnimationController _borderAnimationController;
  late Animation<Color?> _borderAnimation;
  late AnimationController _zoomAnimationController;
  late Animation<double> _zoomAnimation;

  // Map for alien descriptions based on names
  final Map<String, String> alienDescriptions = {
    'Big Chill':
        'Big Chill is an ice-themed alien with the ability to freeze anything in his path.',
    'Spider Monkey':
        'Spider Monkey is agile and spider-like, capable of swinging from webs and climbing walls.',
    'Humungousaur':
        'Humungousaur is a giant, dinosaur-like alien with immense strength and durability.',
    'Swamp Fire':
        'Swamp Fire can manipulate both fire and plant life, making him a versatile powerhouse.',
    'Cannon Bolt':
        'Cannon Bolt is a fast, rolling alien with a tough shell for defense and speed.',
  };

  // Function to play sound from assets
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

  // Handle back navigation with sound and color animation
  Future<bool> _onWillPop(BuildContext context) async {
    await playSound('lib/sounds/omnitrix-time-out.mp3');
    _borderAnimationController.repeat(
        reverse: true); // Trigger the border blinking effect
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      _borderAnimationController.stop();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    // Color animation setup for the app bar
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _colorAnimation = ColorTween(begin: Colors.green, end: Colors.red).animate(
      CurvedAnimation(
        parent: _colorAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Border color animation controller
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _borderAnimation = ColorTween(begin: Colors.green, end: Colors.red).animate(
      CurvedAnimation(
        parent: _borderAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Zoom animation setup
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _zoomAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    if (_colorAnimationController.isAnimating) {
      _colorAnimationController.stop();
    }
    if (_borderAnimationController.isAnimating) {
      _borderAnimationController.stop();
    }
    if (_zoomAnimationController.isAnimating) {
      _zoomAnimationController.stop();
    }
    _colorAnimationController.dispose();
    _borderAnimationController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alienName = widget.alien['name']!;
    final alienImage = widget.alien['image']!;
    final alienDescription =
        alienDescriptions[alienName] ?? "No description available";

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            alienName,
            style: const TextStyle(
              fontFamily: 'Orbitron-Bold',
              fontSize: 20,
            ),
          ),
          backgroundColor: _colorAnimation
              .value, // Use color animation for app bar background
          centerTitle: true,
          elevation: 0,
        ),
        body: AnimatedBuilder(
          animation: _borderAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _borderAnimation.value ?? Colors.green,
                  width: 5, // Border width
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Alien Image with Zoom Animation
                    GestureDetector(
                      onTap: () {
                        _zoomAnimationController.forward().then((value) {
                          _zoomAnimationController.reverse();
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _zoomAnimationController,
                        builder: (context, child) {
                          return Image.asset(
                            alienImage,
                            width: 200 * _zoomAnimation.value,
                            height: 250 * _zoomAnimation.value,
                            fit: BoxFit.fitWidth,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      alienName,
                      style: const TextStyle(
                        fontFamily: 'Orbitron-Bold',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.greenAccent,
                            offset: Offset(3.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Discover the powers of your favorite alien!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Orbitron-Black',
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Add any interaction on tapping the card
                        playSound('lib/sounds/alien-theme.mp3');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.6),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alien Power:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Orbitron-Medium',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                alienDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Orbitron-Black',
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
