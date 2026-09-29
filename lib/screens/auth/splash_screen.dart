import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final AuthService _authService = AuthService();
  String _statusText = 'Connecting Sri Lankan household node...';

  UserModel? _preloadedUserModel;

  @override
  void initState() {
    super.initState();

    // Preload user data in parallel to eliminate end-of-animation stutter
    _preloadUserData();

    // 1.8s duration for snappy, elegant feel without dragging
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.05, 0.95, curve: Curves.fastOutSlowIn),
      ),
    );

    _animController.forward();

    // Dynamic status text update
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _statusText = 'Synchronizing household ledger...';
        });
      }
    });

    Timer(const Duration(milliseconds: 1350), () {
      if (mounted) {
        setState(() {
          _statusText = 'Household vault ready';
        });
      }
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  void _preloadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        _preloadedUserModel = await _authService.getUserModel(user.uid);
      } catch (_) {
        // Fallback default user model
        _preloadedUserModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Family Member',
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateNext() {
    if (!mounted) return;

    if (_preloadedUserModel != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) =>
              MainNavigationScreen(currentUser: _preloadedUserModel!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Lighter, more vibrant and luminous Emerald gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14B8A6), // Bright Emerald Teal
              Color(0xFF0F766E), // Core Deep Emerald
              Color(0xFF0D5D57), // Balanced Mid-Dark Emerald
              Color(0xFF06443E), // Rich Forest Base
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft luminous background ambient glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: MediaQuery.of(context).size.width * 0.15,
              right: MediaQuery.of(context).size.width * 0.15,
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5EEAD4).withValues(alpha: 0.18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.28),
                      blurRadius: 90,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          const Spacer(flex: 3),

                          // Center Glassmorphic Emblem Card
                          Center(
                            child: Container(
                              width: 126,
                              height: 126,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.28),
                                    Colors.white.withValues(alpha: 0.10),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.40),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                                    blurRadius: 36,
                                    spreadRadius: 6,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(64, 64),
                                  painter: _ShieldHouseGrowthPainter(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title: Smart Family Budget
                          const Text(
                            'Smart Family',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                  color: Color(0x30000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Budget',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                  color: Color(0x30000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle: SHARED HOUSEHOLD FINANCES
                          const Text(
                            'SHARED HOUSEHOLD FINANCES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.4,
                              color: Color(0xFFCCFBF1),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Multi-Gen Sync Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAvatarOverlap(),
                                const SizedBox(width: 10),
                                const Text(
                                  'Multi-Gen Sync',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 4),

                          // Sleek Progress Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  // Background Track
                                  Container(
                                    height: 4.5,
                                    width: double.infinity,
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                  // Animated Active Glow Bar
                                  FractionallySizedBox(
                                    widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                                    child: Container(
                                      height: 4.5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5EEAD4),
                                            Color(0xFF2DD4BF),
                                            Colors.white,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF5EEAD4).withValues(alpha: 0.8),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Dynamic Status Text & Spinner
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5EEAD4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _statusText,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Multi-Gen Sync Overlapping Avatars
  Widget _buildAvatarOverlap() {
    return SizedBox(
      width: 66,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildAvatarCircle(label: 'M', color: const Color(0xFF2DD4BF)),
          ),
          Positioned(
            left: 14,
            child: _buildAvatarCircle(label: 'F', color: const Color(0xFF38BDF8)),
          ),
          Positioned(
            left: 28,
            child: _buildAvatarCircle(label: 'K', color: const Color(0xFFFBBF24)),
          ),
          Positioned(
            left: 42,
            child: _buildAvatarCircle(label: '+', color: const Color(0xFFA855F7)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle({required String label, required Color color}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0F766E), width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Custom Vector Painter for Shield + House + Upward Growth Chart
class _ShieldHouseGrowthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield Outline
    final shieldPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.75, h * 0.1, w * 0.9, h * 0.22, w * 0.9, h * 0.45)
      ..cubicTo(w * 0.9, h * 0.7, w * 0.65, h * 0.88, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.35, h * 0.88, w * 0.1, h * 0.7, w * 0.1, h * 0.45)
      ..cubicTo(w * 0.1, h * 0.22, w * 0.25, h * 0.1, w * 0.5, h * 0.1)
      ..close();

    canvas.drawPath(shieldPath, shieldPaint);

    // House Outline
    final housePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final housePath = Path()
      // Roof
      ..moveTo(w * 0.32, h * 0.52)
      ..lineTo(w * 0.5, h * 0.38)
      ..lineTo(w * 0.68, h * 0.52)
      // Body
      ..moveTo(w * 0.36, h * 0.52)
      ..lineTo(w * 0.36, h * 0.68)
      ..lineTo(w * 0.64, h * 0.68)
      ..lineTo(w * 0.64, h * 0.52)
      // Door
      ..moveTo(w * 0.45, h * 0.68)
      ..lineTo(w * 0.45, h * 0.56)
      ..lineTo(w * 0.55, h * 0.56)
      ..lineTo(w * 0.55, h * 0.68);

    canvas.drawPath(housePath, housePaint);

    // Upward Neon Growth Line
    final trendPaint = Paint()
      ..color = const Color(0xFF5EEAD4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trendPath = Path()
      ..moveTo(w * 0.22, h * 0.64)
      ..lineTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.52, h * 0.58)
      ..lineTo(w * 0.74, h * 0.34);

    canvas.drawPath(trendPath, trendPaint);

    // Arrowhead & Glow Dot at peak
    final arrowPaint = Paint()
      ..color = const Color(0xFF5EEAD4)
      ..style = PaintingStyle.fill;

    // Arrow tip
    final arrowPath = Path()
      ..moveTo(w * 0.74, h * 0.34)
      ..lineTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.74, h * 0.42)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);

    // Glowing circle dot at peak
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.74, h * 0.34), 3.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
