import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingItem(
      icon: Icons.account_balance_wallet,
      title: 'Welcome to Money Me',
      description: 'Take control of your finances. Track expenses, analyze spending, and reach your savings goals.',
    ),
    _OnboardingItem(
      icon: Icons.document_scanner,
      title: 'Scan Receipts',
      description: 'Snap a photo of any receipt. Our OCR engine extracts amounts, dates, and merchants automatically.',
    ),
    _OnboardingItem(
      icon: Icons.analytics,
      title: 'Smart Insights',
      description: 'Get personalized predictions, spending trends, and financial tips based on your real data.',
    ),
    _OnboardingItem(
      icon: Icons.wallet,
      title: 'Set Up Your Wallet',
      description: 'Add your accounts, set a preferred currency, and start tracking from day one.',
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages.map((p) => _buildPage(p)).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MoneyButton(
                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const _CurrencySetupPage()),
                    );
                  } else {
                    _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const _CurrencySetupPage()),
                ),
                child: const Text('Skip'),
              )
            else
              const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(item.icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Text(item.title, style: AppTypography.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(item.description, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingItem({required this.icon, required this.title, required this.description});
}

class _CurrencySetupPage extends StatefulWidget {
  const _CurrencySetupPage();
  @override
  State<_CurrencySetupPage> createState() => _CurrencySetupPageState();
}

class _CurrencySetupPageState extends State<_CurrencySetupPage> {
  String _selectedCurrency = 'USD';
  final _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': 'MX\$'},
    {'code': 'COP', 'name': 'Colombian Peso', 'symbol': 'COP\$'},
    {'code': 'ARS', 'name': 'Argentine Peso', 'symbol': 'AR\$'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text('Choose your currency', style: AppTypography.headlineLarge),
              const SizedBox(height: 8),
              Text('Select your preferred currency for all transactions', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _currencies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = _currencies[i];
                    final isSelected = _selectedCurrency == c['code'];
                    return Card(
                      color: isSelected ? AppColors.primary.withAlpha(15) : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected ? AppColors.primary : AppColors.border,
                          child: Text(c['symbol']!, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12)),
                        ),
                        title: Text('${c['code']} - ${c['name']}'),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                        onTap: () => setState(() => _selectedCurrency = c['code']!),
                      ),
                    );
                  },
                ),
              ),
              MoneyButton(label: 'Continue', onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _CompletePage()))),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletePage extends StatelessWidget {
  const _CompletePage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.check_circle, size: 56, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text('All set!', style: AppTypography.headlineLarge),
              const SizedBox(height: 8),
              Text("You're ready to start managing your finances", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              MoneyButton(label: 'Go to Dashboard', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false)),
            ],
          ),
        ),
      ),
    );
  }
}
