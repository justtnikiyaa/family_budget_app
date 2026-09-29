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

    // Preload user data in parallel
    _preloadUserData();

    // 1300ms duration: fast, fluid, eliminates lag and freeze
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    // Smooth easeOutCubic curve across the full duration - no stalling at 90-100%
    _progressAnimation = Tween<double>(begin: 0.08, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    // Dynamic status text update timed cleanly with progress
    Timer(const Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() {
          _statusText = 'Synchronizing household ledger...';
        });
      }
    });

    Timer(const Duration(milliseconds: 950), () {
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
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Light, luminous modern slate & mint aura gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFC),
              Color(0xFFF0FDF4),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft decorative ambient glow circles for premium depth
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                      blurRadius: 70,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F766E).withValues(alpha: 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                      blurRadius: 80,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final progressVal = _progressAnimation.value.clamp(0.0, 1.0);
                  final progressPercent = (progressVal * 100).toInt();

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Top Sri Lanka National Finance Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇱🇰', style: TextStyle(fontSize: 13)),
                                SizedBox(width: 6),
                                Text(
                                  'SMART SRI LANKAN FAMILY BUDGET',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F766E),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 3),

                          // Center Crisp White Glassmorphic Emblem Card
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: const Color(0xFF14B8A6).withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F766E).withValues(alpha: 0.14),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
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

                          const SizedBox(height: 28),

                          // Title: Smart Family Budget
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Smart Family\n',
                                  style: TextStyle(color: Color(0xFF0F172A)),
                                ),
                                TextSpan(
                                  text: 'Budget',
                                  style: TextStyle(
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Subtitle: SHARED HOUSEHOLD FINANCES
                          const Text(
                            'SHARED HOUSEHOLD FINANCES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.2,
                              color: Color(0xFF0D9488),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Multi-Gen Sync Card Pill with live status dot
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                                  blurRadius: 16,
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
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 4),

                          // Progress Bar & Percentage Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF0F766E),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _statusText,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: Color(0xFF475569),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '$progressPercent%',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF0F766E),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Sleek Progress Track
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Stack(
                                    children: [
                                      // Background Track
                                      Container(
                                        height: 5.0,
                                        width: double.infinity,
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      // Animated Active Gradient Bar
                                      FractionallySizedBox(
                                        widthFactor: progressVal,
                                        child: Container(
                                          height: 5.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF14B8A6),
                                                Color(0xFF0F766E),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF0F766E).withValues(alpha: 0.35),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Security Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Secured by Cloud Firestore • Multi-Device Sync',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
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
            child: _buildAvatarCircle(label: 'M', color: const Color(0xFF0D9488)),
          ),
          Positioned(
            left: 14,
            child: _buildAvatarCircle(label: 'F', color: const Color(0xFF0284C7)),
          ),
          Positioned(
            left: 28,
            child: _buildAvatarCircle(label: 'K', color: const Color(0xFFF59E0B)),
          ),
          Positioned(
            left: 42,
            child: _buildAvatarCircle(label: '+', color: const Color(0xFF8B5CF6)),
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
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Custom Vector Painter for Shield + House + Upward Growth Chart on Light Canvas
class _ShieldHouseGrowthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield Outline & Soft Wash
    final shieldFillPaint = Paint()
      ..color = const Color(0xFFF0FDF4)
      ..style = PaintingStyle.fill;

    final shieldStrokePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.75, h * 0.1, w * 0.9, h * 0.22, w * 0.9, h * 0.45)
      ..cubicTo(w * 0.9, h * 0.7, w * 0.65, h * 0.88, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.35, h * 0.88, w * 0.1, h * 0.7, w * 0.1, h * 0.45)
      ..cubicTo(w * 0.1, h * 0.22, w * 0.25, h * 0.1, w * 0.5, h * 0.1)
      ..close();

    canvas.drawPath(shieldPath, shieldFillPaint);
    canvas.drawPath(shieldPath, shieldStrokePaint);

    // House Outline (Deep Emerald)
    final housePaint = Paint()
      ..color = const Color(0xFF0F766E)
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

    // Upward Neon Growth Line (Vibrant Teal / Bright Emerald)
    final trendPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trendPath = Path()
      ..moveTo(w * 0.22, h * 0.64)
      ..lineTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.52, h * 0.58)
      ..lineTo(w * 0.74, h * 0.34);

    canvas.drawPath(trendPath, trendPaint);

    // Arrowhead at peak
    final arrowPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(w * 0.74, h * 0.34)
      ..lineTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.74, h * 0.42)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);

    // Glowing circle dot at peak
    final dotOuterPaint = Paint()..color = const Color(0xFF0F766E);
    final dotInnerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.74, h * 0.34), 4.0, dotOuterPaint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.34), 2.2, dotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
