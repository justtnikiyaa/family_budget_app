import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/page_transitions.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  AppLanguage _selectedLanguage = AppLanguage.english;
  bool _isButtonPressed = false;
  bool _isNavigating = false;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'assets/images/onboarding_family_budget.jpg',
      'title': 'Track Family Spending Together',
      'title_si': 'පවුලේ වියදම් එක්ව කළමනාකරණය කරමු',
      'title_ta': 'குடும்பச் செலவுகளை ஒன்றாகக் கண்காணிக்கவும்',
      'desc':
          'Manage household expenses, stay within limits, and achieve savings goals as a family in real-time.',
      'desc_si':
          'ගෙදර දොරේ වියදම් කළමනාකරණය කර, සීමාවන් තුළ රැඳී, පවුලක් ලෙස එකමුතුව ඉතිරි කර ගැනීමේ ඉලක්ක සපුරා ගන්න.',
      'desc_ta':
          'வீட்டுச் செலவுகளை நிர்வகிக்கவும், வரம்புகளுக்குள் இருக்கவும், குடும்பமாக சேமிப்பு இலக்குகளை அடையவும்.',
    },
    {
      'image': 'assets/images/onboarding_family_savings.jpg',
      'title': 'Smart Savings & Shared Goals',
      'title_si': 'බුද්ධිමත් ඉතිරිකිරීම් සහ පොදු ඉලක්ක',
      'title_ta': 'புத்திசாலித்தனமான சேமிப்பு மற்றும் பகிரப்பட்ட இலக்குகள்',
      'desc':
          'Encourage kids and family members to save collectively with visual milestones, piggy banks, and progress rewards.',
      'desc_si':
          'දරුවන් සහ පවුලේ සැමට එකමුතුව ඉතිරි කිරීමට මඟ පෙන්වා, සිහින ඉලක්ක කරා පහසුවෙන්ම ළඟා වන්න.',
      'desc_ta':
          'சேமிப்பு மைல்கற்கள் மற்றும் இலக்குகளுடன் குடும்ப உறுப்பினர்களை ஒன்றாகச் சேமிக்க ஊக்குவிக்கவும்.',
    },
  ];

  String _getTitle(Map<String, dynamic> item) {
    switch (_selectedLanguage) {
      case AppLanguage.sinhala:
        return item['title_si'] ?? item['title'];
      case AppLanguage.tamil:
        return item['title_ta'] ?? item['title'];
      case AppLanguage.english:
        return item['title'];
    }
  }

  String _getDesc(Map<String, dynamic> item) {
    switch (_selectedLanguage) {
      case AppLanguage.sinhala:
        return item['desc_si'] ?? item['desc'];
      case AppLanguage.tamil:
        return item['desc_ta'] ?? item['desc'];
      case AppLanguage.english:
        return item['desc'];
    }
  }

  String _getContinueText() {
    switch (_selectedLanguage) {
      case AppLanguage.sinhala:
        return 'ඉදිරියට යන්න';
      case AppLanguage.tamil:
        return 'தொடரவும்';
      case AppLanguage.english:
        return 'Continue';
    }
  }

  void _handleContinue() async {
    if (_isNavigating) return;

    if (_currentPage < 1) {
      setState(() => _isButtonPressed = true);
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _isButtonPressed = false);

      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      // Navigating from Language screen to LoginScreen
      setState(() {
        _isNavigating = true;
        _isButtonPressed = true;
      });

      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      Navigator.push(
        context,
        SmoothSlideUpRoute(page: const LoginScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isNavigating = false;
            _isButtonPressed = false;
          });
        }
      });
    }
  }

  void _showLanguagePickerModal() {
    var tempLang = _selectedLanguage;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'භාෂාව / மொழி',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...AppLanguages.list.map((lang) {
                    final isSelected = tempLang == lang.code;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildLanguageCard(
                        lang: lang,
                        isSelected: isSelected,
                        onTap: () {
                          setModalState(() {
                            tempLang = lang.code;
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedLanguage = tempLang);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF046A38),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getContinueText(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_outline, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Pill Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Pill: App Name + Icon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.home_work_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Pill: Country / Language Trigger
                  GestureDetector(
                    onTap: _showLanguagePickerModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            AppConstants.countryBadge,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3730A3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Slide 1: Welcome & Overview (Image 1 from UI design)
                  _buildIntroSlide(_carouselItems[0]),

                  // Slide 2: Language Selection & Family Savings (Image 2 from UI design)
                  _buildLanguageSelectionSlide(_carouselItems[1]),
                ],
              ),
            ),

            // Bottom Continue Button with Press Feedback Animation
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 24.0, top: 8.0),
              child: AnimatedScale(
                scale: _isButtonPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF046A38),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isNavigating) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        _isNavigating ? 'Opening...' : _getContinueText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isNavigating) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 1 View
  Widget _buildIntroSlide(Map<String, dynamic> item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Illustration with ambient glow
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                item['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => Container(
                  color: Colors.white,
                  child: const Icon(Icons.family_restroom, size: 80, color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Pagination Dots (Slide 1 active)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageDot(isActive: _currentPage == 0),
              const SizedBox(width: 8),
              _buildPageDot(isActive: _currentPage == 1),
              const SizedBox(width: 8),
              _buildPageDot(isActive: false),
            ],
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            _getTitle(item),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              _getDesc(item),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Slide 2 View: Language Selection
  Widget _buildLanguageSelectionSlide(Map<String, dynamic> item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Illustration
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                item['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => Container(
                  color: Colors.white,
                  child: const Icon(Icons.savings_rounded, size: 70, color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Language',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'භාෂාව / மொழி',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Language Cards
          ...AppLanguages.list.map((lang) {
            final isSelected = _selectedLanguage == lang.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildLanguageCard(
                lang: lang,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedLanguage = lang.code);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // Language Card Widget
  Widget _buildLanguageCard({
    required LanguageItem lang,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F4F1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : const Color(0x06000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Indicator
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF046A38) : const Color(0xFFE0E7FF),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),

            // Language Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? const Color(0xFF046A38) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Right Greeting Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFCCFBF1) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lang.greeting,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dots
  Widget _buildPageDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black : Colors.transparent,
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
    );
  }
}
