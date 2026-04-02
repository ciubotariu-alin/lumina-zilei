import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

// Înlocuiește cu username-ul tău Revolut (fără @)
const String _revolutUsername = 'andrea0cli';
const String _revolutHost = 'revolut.me';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  int? _selectedAmount;
  final TextEditingController _customController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  static const _presetAmounts = [1, 5, 10];

  @override
  void dispose() {
    _customController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectPreset(int amount) {
    setState(() {
      _selectedAmount = amount;
      _customController.clear();
    });
    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  void _onCustomChanged(String value) {
    setState(() {
      _selectedAmount = null;
    });
  }

  int? get _effectiveAmount {
    if (_customController.text.isNotEmpty) {
      return int.tryParse(_customController.text);
    }
    return _selectedAmount;
  }

  Future<void> _donate() async {
    final amount = _effectiveAmount;
    if (amount == null || amount <= 0) return;

    if (_revolutUsername.trim().isEmpty || _revolutUsername == 'USERNAME') {
      _showError('Username-ul Revolut nu este configurat în aplicație.');
      return;
    }

    setState(() => _isLoading = true);

    // Format corect Revolut.me: /username/suma/moneda
    final url = 'https://revolut.me/$_revolutUsername/$amount/RON';
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        await Clipboard.setData(ClipboardData(text: url));
        _showError(
          'Nu am putut deschide Revolut. Link-ul a fost copiat în clipboard.',
        );
      }
    } catch (e) {
      if (mounted) {
        await Clipboard.setData(ClipboardData(text: url));
        _showError('Eroare: $e — link-ul a fost copiat în clipboard.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.deepRedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _effectiveAmount;
    final canDonate = amount != null && amount > 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: AppTheme.goldColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DONAȚII',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(letterSpacing: 3),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      width: 120,
                      color: AppTheme.goldColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),

            // Description
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.church,
                          color: AppTheme.goldColor, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Susține misiunea noastră',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Donația ta ajută la menținerea și îmbunătățirea aplicației Lumina Zilei, aducând credința ortodoxă mai aproape de fiecare suflet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.creamColor.withOpacity(0.8),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Preset amounts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            color: AppTheme.goldColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Alege suma',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: _presetAmounts
                          .map((a) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        a != _presetAmounts.last ? 12.0 : 0.0,
                                  ),
                                  child: _AmountButton(
                                    amount: a,
                                    isSelected: _selectedAmount == a &&
                                        _customController.text.isEmpty,
                                    onTap: () => _selectPreset(a),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Custom amount
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            color: AppTheme.goldColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Sau introdu altă sumă',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: _onCustomChanged,
                      style: const TextStyle(
                        color: AppTheme.creamColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppTheme.creamColor.withOpacity(0.3),
                        ),
                        suffixText: 'lei',
                        suffixStyle: const TextStyle(
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.goldColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Revolut badge + donate button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    // Revolut branding
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191C1F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Plată prin Revolut',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: canDonate && !_isLoading ? _donate : null,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.favorite, size: 20),
                        label: Text(
                          canDonate
                              ? 'Donează $amount ${amount == 1 ? 'leu' : 'lei'}'
                              : 'Donează',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: AppTheme.dividerColor,
                          disabledForegroundColor:
                              AppTheme.creamColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Se deschide pagina ta Revolut.me pentru finalizarea donației.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.creamColor.withOpacity(0.65),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.goldColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.goldColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(
              '$amount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.creamColor,
              ),
            ),
            Text(
              amount == 1 ? 'leu' : 'lei',
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : AppTheme.accentGoldLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
