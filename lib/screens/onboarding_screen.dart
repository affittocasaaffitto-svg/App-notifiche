import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'permission_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnbData(
      image: 'assets/images/onboarding1.png',
      title: 'Riduci il caos delle notifiche',
      subtitle:
          'Metti ordine nel rumore quotidiano. SuperNotify AI organizza tutto al posto tuo.',
    ),
    _OnbData(
      image: 'assets/images/onboarding2.png',
      title: 'Filtri intelligenti',
      subtitle:
          'Regole personalizzate e categorie automatiche per vedere solo ciò che conta.',
    ),
    _OnbData(
      image: 'assets/images/onboarding3.png',
      title: 'L\'AI capisce cosa è importante',
      subtitle:
          'Classificazione automatica: priorità alta, persone, gruppi e promozioni.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PermissionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Salta',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              p.image,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.mainGradient.createShader(b),
                          child: Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicatori
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: _page == i ? AppColors.mainGradient : null,
                    color: _page == i ? null : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: GradientButton(
                label: isLast ? 'Inizia' : 'Avanti',
                icon: isLast ? Icons.rocket_launch_rounded : null,
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbData {
  final String image;
  final String title;
  final String subtitle;
  const _OnbData(
      {required this.image, required this.title, required this.subtitle});
}
