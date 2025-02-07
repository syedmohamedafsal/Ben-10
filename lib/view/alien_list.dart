import 'package:ben_ten/view/alien_details.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // For rootBundle

class OmnitrixSymbol extends StatefulWidget {
  final double size;

  const OmnitrixSymbol({
    super.key,
    required this.size,
  });

  @override
  _OmnitrixSymbolState createState() => _OmnitrixSymbolState();
}

class _OmnitrixSymbolState extends State<OmnitrixSymbol>
    with TickerProviderStateMixin {
  bool _isRotating = false; // Flag to indicate if rotation is happening
  bool _isTapped = false; // Flag to trigger the animation
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _aliens = [
    {
      'name': 'Big Chil',
      'image': 'assets/images/alien/ultimate-alien/bigchil.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3'
    },
    {
      'name': 'Spider Monkey',
      'image': 'assets/images/alien/ultimate-alien/siper-monkey.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3'
    },
    {
      'name': 'Humungousaur',
      'image': 'assets/images/alien/ultimate-alien/humangasore.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3'
    },
    {
      'name': 'swamp Fire',
      'image': 'assets/images/alien/ultimate-alien/swamp-fire.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3'
    },
    {
      'name': 'Cannon Bolt',
      'image': 'assets/images/alien/ultimate-alien/cannon-bolt.png',
      'sound': 'lib/sounds/ben10_omni_sound.mp3'
    },
  ];

  int _currentAlienIndex = 0;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  // Function for 360-degree rotation on double-tap
  void _rotate360() {
    setState(() {
      _isRotating = true;
      _currentAlienIndex = (_currentAlienIndex + 1) % _aliens.length;
    });

    // Play sound on alien change
    playSound(_aliens[_currentAlienIndex]['sound']!);

    // Rotate to 360 degrees smoothly using animation
    _rotationController.forward(from: 0).whenComplete(() {
      setState(() {
        _isRotating = false;
      });
    });
  }

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

  // Handle user tap (single tap)
  void _onTap() {
    setState(() {
      _isTapped = true;
    });

    // Play Omnitrix transformation sound on single tap
    playSound('lib/sounds/omnitrix-transform.mp3');

    // Navigate to AlienDetail page after animation completes
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlienDetail(
            alien: _aliens[_currentAlienIndex],
          ),
        ),
      ).then((_) {
        // Reset the state when navigating back
        setState(() {
          _isTapped = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap:
          _rotate360, // Trigger the animation and alien change on double tap
      onTap: _onTap, // Trigger the animation on single tap
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            StrapDesign(size: 400),
            // Border and rotating elements with smooth animation
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value *
                      2 *
                      3.14159, // Full 360 rotation
                  child: OmnitrixBorder(size: widget.size),
                );
              },
            ),

            // Keeping the alien image and text fixed while rotation happens
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Center(
                  child: OmnitrixCore(
                    size: widget.size * 0.8,
                    alienImage: _aliens[_currentAlienIndex]['image']!,
                    alienName: _aliens[_currentAlienIndex]['name']!,
                    isRotating: _isRotating,
                  ),
                );
              },
            ),

            // Nano light animation
            if (_isTapped)
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, double value, child) {
                  return Container(
                    width: MediaQuery.of(context).size.width * value,
                    height: MediaQuery.of(context).size.height * value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.3),
                    ),
                  );
                },
              ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Double Tap To Change the Alien',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Orbitron-Regular',
                  color: Colors.white, // Set the text color to white
                  decoration: TextDecoration.none, // Remove underline
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Single Tap To Click Alien',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Orbitron-Regular',
                    color: Colors.white, // Set the text color to white
                    decoration: TextDecoration.none, // Remove underline
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OmnitrixBorder extends StatelessWidget {
  final double size;

  const OmnitrixBorder({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.green.shade800,
            Colors.green.shade900,
          ],
        ),
      ),
      child: Stack(
        children: [
          for (var i = 0; i < 4; i++)
            Positioned.fill(
              child: Transform.rotate(
                angle: i * (3.14159 / 2),
                child: Align(
                  alignment: const Alignment(0, -0.85),
                  child: BoltDecoration(size: size * 0.15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BoltDecoration extends StatelessWidget {
  final double size;

  const BoltDecoration({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class StrapDesign extends StatelessWidget {
  final double size;

  const StrapDesign({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.6, // Strap width
      height: size * 2.5, // Strap height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          6, // Number of stripes
          (index) {
            // Adjust the color to alternate between green, black, green
            if (index % 3 == 0) {
              return Expanded(
                child: Container(
                  color: Colors.green.shade700, // Green
                ),
              );
            } else if (index % 3 == 1) {
              return Expanded(
                child: Container(
                  color: Colors.black, // Black
                ),
              );
            } else {
              return Expanded(
                child: Container(
                  color: Colors.green.shade700, // Green
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class OmnitrixCore extends StatelessWidget {
  final double size;
  final String alienImage;
  final String alienName;
  final bool isRotating;

  // Add a mapping for alien names to their corresponding images
  final Map<String, String> alienNameImages = {
    'Big Chil': 'assets/images/alien/alien-name/Big Chill.png',
    'Spider Monkey': 'assets/images/alien/alien-name/SpiderMonkey.png',
    'Humungousaur': 'assets/images/alien/alien-name/Humungousaur.png',
    'swamp Fire': 'assets/images/alien/alien-name/Frame 1.png',
    'Cannon Bolt': 'assets/images/alien/alien-name/CannonBolt.png',
  };

  OmnitrixCore({
    super.key,
    required this.size,
    required this.alienImage,
    required this.alienName,
    required this.isRotating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isRotating)
            Image.asset(
              'assets/images/alien/ultimate-alien/bent10-ultimtate-alien-background.png',
              width: size * 0.6, // Adjust size to fit the container
              height: size * 0.6,
              fit: BoxFit.fitHeight,
            ),
          if (!isRotating)
            // Alien image will only appear after the rotation
            Image.asset(
              alienImage,
              width: size * 0.6,
              height: size * 0.6,
              fit: BoxFit.fitHeight,
            ),
          if (!isRotating)
            // Display the alien name image at the bottom
            Positioned(
              bottom: 10,
              child: Image.asset(
                alienNameImages[alienName]
                    .toString(), // Fetch the image based on the current alien's name
                width: size * 0.4, // Adjust the size of the name image
                height: size * 0.2, // Adjust the height as needed
                fit: BoxFit.fitWidth,
              ),
            ),
        ],
      ),
    );
  }
}
