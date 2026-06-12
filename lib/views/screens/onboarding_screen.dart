import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:malist/core/constants/storage_keys.dart';
import 'package:malist/core/local/secure_storage_service.dart';
import 'package:malist/service_locator.dart';

import 'package:malist/data/models/onboarding/onboarding_page_data.dart';
import 'package:malist/views/widgets/onboarding/onboarding_atmosphere.dart';
import 'package:malist/views/widgets/onboarding/onboarding_page.dart';
import 'package:malist/views/widgets/onboarding/progress_rail.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _motionController;

  int _currentPage = 0;

  static const _pages = <OnboardingPageData>[
    OnboardingPageData(
      title: 'Welcome to Malist.',
      subtitle: 'Zero clutter. Absolute focus.',
      body:
          'Experience a completely unified digital vault. Notes, tasks, and passwords, refined into a single, distraction-free environment.',
      button: 'Next',
      glyph: GlyphType.focus,
    ),
    OnboardingPageData(
      title: 'True Black.',
      subtitle: 'Designed for your eyes and your battery.',
      body:
          'Malist features a deep #000000 AMOLED aesthetic. No harsh lights, no OLED smearing. Just pure, immersive contrast.',
      button: 'Next',
      glyph: GlyphType.black,
    ),
    OnboardingPageData(
      title: 'Uncompromising Security.',
      subtitle: 'Your data belongs only to you.',
      body:
          'Everything you store in Malist is secured locally using device-level hardware encryption. No cloud tracking. No external servers.',
      button: 'Next',
      glyph: GlyphType.vault,
    ),
    OnboardingPageData(
      title: 'Built for Speed.',
      subtitle: 'Keep the interface clean with intuitive gestures.',
      body:
          'Press and hold a task to delete it from your to-do list. Swipe left to instantly delete secure passwords. No extra buttons, just seamless control.',
      button: 'Next',
      glyph: GlyphType.gesture,
    ),
    OnboardingPageData(
      title: 'Ready to Focus.',
      subtitle: 'The vault is generated and locked to this device.',
      body:
          'Leave the noise behind. Start building your secure, minimalist digital workspace.',
      button: 'Enter Malist',
      glyph: GlyphType.ready,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await sl<SecureStorageService>().setBool(
      StorageKeys.hasCompletedOnboarding,
      true,
    );

    if (mounted) context.go('/home');
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 580),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _motionController,
                builder: (context, child) {
                  return OnboardingAtmosphere(
                    progress: _motionController.value,
                    page: _currentPage,
                  );
                },
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                  child: Row(
                    children: [
                      Text(
                        'M A L I S T',
                        style: theme.textTheme.labelLarge?.copyWith(
                          letterSpacing: 4,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: _currentPage == _pages.length - 1 ? 0 : 1,
                        duration: const Duration(milliseconds: 220),
                        child: IgnorePointer(
                          ignoring: _currentPage == _pages.length - 1,
                          child: TextButton(
                            onPressed: _skip,
                            child: const Text('SKIP'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (value) {
                      setState(() => _currentPage = value);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        data: _pages[index],
                        index: index,
                        currentIndex: _currentPage,
                        motion: _motionController,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  child: Column(
                    children: [
                      ProgressRail(
                        length: _pages.length,
                        activeIndex: _currentPage,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.28),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _pages[_currentPage].button.toUpperCase(),
                              key: ValueKey(_currentPage),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
