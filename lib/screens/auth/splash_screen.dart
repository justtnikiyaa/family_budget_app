import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.15, 0.95, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Dynamic status text simulation
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _statusText = 'Synchronizing household ledger...';
        });
      }
    });

    Timer(const Duration(milliseconds: 2300), () {
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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userModel = await _authService.getUserModel(user.uid);
      if (mounted && userModel != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => MainNavigationScreen(currentUser: userModel),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
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
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.1),
            radius: 1.1,
            colors: [
              Color(0xFF0F5A4F),
              Color(0xFF084138),
              Color(0xFF042B25),
              Color(0xFF021B17),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
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

                      // Center Squircle Glassmorphic Icon
                      Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                                const Color(0xFF0F766E).withValues(alpha: 0.45),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withValues(alpha: 0.25),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
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

                      const SizedBox(height: 36),

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
                          letterSpacing: 2.2,
                          color: Color(0xFF99F6E4),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Multi-Gen Sync Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Overlapping Avatars (M, F, K, +)
                            _buildAvatarOverlap(),
                            const SizedBox(width: 10),
                            const Text(
                              'Multi-Gen Sync',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 4),

                      // Bottom Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            children: [
                              // Background Track
                              Container(
                                height: 4,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              // Active Bar
                              FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2DD4BF),
                                        Color(0xFF38BDF8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2DD4BF).withValues(alpha: 0.6),
                                        blurRadius: 6,
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

                      // Spinner & Dynamic Status Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF99F6E4).withValues(alpha: 0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
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
        border: Border.all(color: const Color(0xFF042B25), width: 1.5),
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
      ..color = Colors.white.withValues(alpha: 0.7)
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
      ..strokeWidth = 2.2
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
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
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
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.fill;

    // Arrow tip
    final arrowPath = Path()
      ..moveTo(w * 0.74, h * 0.34)
      ..lineTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.74, h * 0.42)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);

    // Glowing circle dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.74, h * 0.34), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
