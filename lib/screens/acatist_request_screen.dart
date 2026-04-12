import 'package:flutter/material.dart';

import '../models/acatist_request.dart';
import '../models/parohie.dart';
import '../services/data_service.dart';
import '../services/email_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class AcatistRequestScreen extends StatefulWidget {
  const AcatistRequestScreen({super.key});

  @override
  State<AcatistRequestScreen> createState() => _AcatistRequestScreenState();
}

class _AcatistRequestScreenState extends State<AcatistRequestScreen> {
  // Pașii formularului
  int _step = 0; // 0=parohie, 1=cerere, 2=date personale

  // Pas 1 — selectare parohie
  List<Parohie> _parohii = [];
  List<Parohie> _filteredParohii = [];
  bool _loadingParohii = true;
  Parohie? _selectedParohie;
  final _searchController = TextEditingController();

  // Pas 2 — cerere
  final _intentieController = TextEditingController();
  DurataAcatist _selectedDurata = DurataAcatist.oLuna;

  // Pas 3 — date personale
  final _numeController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();

  // Trimitere
  bool _sending = false;

  // Form keys
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    AnalyticsService().logAcatistRequestScreenOpened();
    _loadParohii();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _intentieController.dispose();
    _numeController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadParohii() async {
    final parohii = await DataService().loadParohii();
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _parohii = parohii;
      _filteredParohii = query.isEmpty
          ? parohii
          : parohii
              .where((p) =>
                  p.denumire.toLowerCase().contains(query) ||
                  p.hram.toLowerCase().contains(query) ||
                  p.adresa.toLowerCase().contains(query))
              .toList();
      _loadingParohii = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParohii = query.isEmpty
          ? _parohii
          : _parohii
              .where((p) =>
                  p.denumire.toLowerCase().contains(query) ||
                  p.hram.toLowerCase().contains(query) ||
                  p.adresa.toLowerCase().contains(query))
              .toList();
    });
  }

  void _goToStep(int step) {
    setState(() => _step = step);
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (_step != 2 || _formKeyStep3.currentState == null) return;
    if (!_formKeyStep3.currentState!.validate()) return;

    final selected = _selectedParohie;
    if (selected == null) return;

    setState(() => _sending = true);

    final request = AcatistRequest(
      parohieId: selected.id,
      parohieDenumire: selected.denumire,
      parohieEmail: selected.email,
      intentie: _intentieController.text.trim(),
      durata: _selectedDurata,
      numeExpeditor: _numeController.text.trim(),
      telefonExpeditor: _telefonController.text.trim(),
      emailExpeditor: _emailController.text.trim(),
    );

    AnalyticsService().logAcatistRequestSubmitted(
      parohieId: request.parohieId,
      durata: request.durata.label,
    );

    final result = await emailService.sendAcatistRequest(request);

    if (!mounted) return;
    setState(() => _sending = false);

    if (result is EmailSuccess) {
      AnalyticsService().logAcatistRequestSuccess(parohieId: request.parohieId);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _ConfirmationScreen(parohie: selected),
        ),
      );
    } else {
      final failure = result as EmailFailure;
      AnalyticsService().logAcatistRequestFailed(parohieId: request.parohieId);
      _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.deepRedColor,
        action: SnackBarAction(
          label: 'Reîncearcă',
          textColor: Colors.white,
          onPressed: _submit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0 && !_sending,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _goToStep(_step - 1);
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
        title: const Text('Cerere Acatist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _sending
              ? null
              : () {
                  if (_step > 0) {
                    _goToStep(_step - 1);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (_step) {
                0 => _Step1SelectParohie(
                    key: const ValueKey(0),
                    parohii: _filteredParohii,
                    loading: _loadingParohii,
                    selected: _selectedParohie,
                    searchController: _searchController,
                    onSelected: (p) {
                      setState(() => _selectedParohie = p);
                      _goToStep(1);
                    },
                  ),
                1 => _Step2Cerere(
                    key: const ValueKey(1),
                    formKey: _formKeyStep2,
                    intentieController: _intentieController,
                    selectedDurata: _selectedDurata,
                    onDurataChanged: (d) => setState(() => _selectedDurata = d),
                    onNext: () {
                      if (_formKeyStep2.currentState?.validate() == true) {
                        _goToStep(2);
                      }
                    },
                  ),
                2 => _Step3DatePersonale(
                    key: const ValueKey(2),
                    formKey: _formKeyStep3,
                    numeController: _numeController,
                    telefonController: _telefonController,
                    emailController: _emailController,
                    parohie: _selectedParohie!,
                    sending: _sending,
                    onSubmit: _submit,
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Parohie', 'Cerere', 'Date'];
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                _StepDot(index: i + 1, isActive: isActive, isDone: isDone),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? AppTheme.goldColor
                          : isDone
                              ? AppTheme.accentGoldLight
                              : AppTheme.dividerColor,
                    ),
                  ),
                ),
                if (i < 2)
                  Container(
                    height: 1,
                    width: 12,
                    color: isDone ? AppTheme.goldColor : AppTheme.dividerColor,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isDone;

  const _StepDot({
    required this.index,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppTheme.goldColor
            : isDone
                ? AppTheme.accentGoldLight
                : AppTheme.dividerColor,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      isActive || isDone ? Colors.white : AppTheme.textBrownColor,
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pas 1 — Selectare parohie
// ---------------------------------------------------------------------------

class _Step1SelectParohie extends StatelessWidget {
  final List<Parohie> parohii;
  final bool loading;
  final Parohie? selected;
  final TextEditingController searchController;
  final ValueChanged<Parohie> onSelected;

  const _Step1SelectParohie({
    super.key,
    required this.parohii,
    required this.loading,
    required this.selected,
    required this.searchController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.goldColor),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: AppTheme.creamColor),
            decoration: InputDecoration(
              hintText: 'Caută parohia...',
              hintStyle:
                  TextStyle(color: AppTheme.creamColor.withOpacity(0.4)),
              prefixIcon:
                  const Icon(Icons.search, color: AppTheme.goldColor),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.goldColor),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.cardColor,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.goldColor, width: 2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            '${parohii.length} parohii disponibile',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: parohii.isEmpty
              ? Center(
                  child: Text(
                    'Nicio parohie găsită.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: parohii.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = parohii[i];
                    final isSelected = selected?.id == p.id;
                    return _ParohieCard(
                      parohie: p,
                      isSelected: isSelected,
                      onTap: () => onSelected(p),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ParohieCard extends StatelessWidget {
  final Parohie parohie;
  final bool isSelected;
  final VoidCallback onTap;

  const _ParohieCard({
    required this.parohie,
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
          color: isSelected
              ? AppTheme.goldColor.withOpacity(0.1)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.goldColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parohie.denumire,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.goldColor
                              : AppTheme.creamColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    parohie.hram,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentGoldLight,
                          fontSize: 11,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 11, color: AppTheme.dividerColor),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          parohie.adresa,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.dividerColor,
                                    fontSize: 11,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.goldColor, size: 22),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pas 2 — Completare cerere
// ---------------------------------------------------------------------------

class _Step2Cerere extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController intentieController;
  final DurataAcatist selectedDurata;
  final ValueChanged<DurataAcatist> onDurataChanged;
  final VoidCallback onNext;

  const _Step2Cerere({
    super.key,
    required this.formKey,
    required this.intentieController,
    required this.selectedDurata,
    required this.onDurataChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicație
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppTheme.goldColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.goldColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cererea va fi transmisă prin email parohiei selectate. '
                      'Preotul o va include în rugăciunile de la slujbă.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textBrownColor,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Intenție
            Text(
              'Intenția rugăciunii',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Scrieți pentru cine sau pentru ce doriți să fie citit acatistul.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: intentieController,
              maxLines: 5,
              maxLength: 500,
              style: const TextStyle(
                color: AppTheme.creamColor,
                fontSize: 14,
                height: 1.5,
              ),
              decoration: _inputDecoration(
                context,
                hintText:
                    'Ex: pentru sănătatea mamei mele Maria și a fiului meu Ioan...',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Vă rugăm introduceți intenția rugăciunii.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Durată
            Text(
              'Durata acatistului',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: DurataAcatist.values.map((d) {
                final isSelected = selectedDurata == d;
                return GestureDetector(
                  onTap: () => onDurataChanged(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.goldColor
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.goldColor
                            : AppTheme.dividerColor,
                      ),
                    ),
                    child: Text(
                      d.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppTheme.creamColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text('Continuă'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pas 3 — Date personale + trimitere
// ---------------------------------------------------------------------------

class _Step3DatePersonale extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController numeController;
  final TextEditingController telefonController;
  final TextEditingController emailController;
  final Parohie parohie;
  final bool sending;
  final VoidCallback onSubmit;

  const _Step3DatePersonale({
    super.key,
    required this.formKey,
    required this.numeController,
    required this.telefonController,
    required this.emailController,
    required this.parohie,
    required this.sending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card sumar parohie
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.goldColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.church,
                      color: AppTheme.goldColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parohie.denumire,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppTheme.goldColor),
                        ),
                        Text(
                          parohie.adresa,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Datele dvs. de contact',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Necesare pentru ca parohia să vă poată contacta în legătură cu cererea.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Nume
            TextFormField(
              controller: numeController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                  color: AppTheme.creamColor, fontSize: 14),
              decoration: _inputDecoration(context,
                  hintText: 'Nume și prenume', prefixIcon: Icons.person),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Introduceți numele dvs.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Telefon
            TextFormField(
              controller: telefonController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  color: AppTheme.creamColor, fontSize: 14),
              decoration: _inputDecoration(context,
                  hintText: 'Număr de telefon', prefixIcon: Icons.phone),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Introduceți numărul de telefon.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                  color: AppTheme.creamColor, fontSize: 14),
              decoration: _inputDecoration(context,
                  hintText: 'Adresă de email', prefixIcon: Icons.email),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Introduceți adresa de email.';
                }
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Introduceți o adresă de email validă.';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Notă transparență
            Text(
              'Datele dvs. vor fi transmise exclusiv parohiei selectate și nu vor fi stocate de aplicație.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.accentGoldLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: sending ? null : onSubmit,
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(sending ? 'Se trimite...' : 'Trimite cererea'),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppTheme.dividerColor,
                  disabledForegroundColor:
                      AppTheme.creamColor.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmare
// ---------------------------------------------------------------------------

class _ConfirmationScreen extends StatelessWidget {
  final Parohie parohie;

  const _ConfirmationScreen({required this.parohie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.goldColor.withOpacity(0.1),
                    border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.goldColor,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cererea a fost transmisă',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aplicația a transmis cererea dvs. de acatist la:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textBrownColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.church,
                          color: AppTheme.goldColor, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          parohie.denumire,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppTheme.goldColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'prin email, la adresa oficială a parohiei.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentGoldLight,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aceasta confirmă transmiterea cererii, nu că a fost deja preluată de preot.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.accentGoldLight.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Înapoi la Acasă'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

InputDecoration _inputDecoration(
  BuildContext context, {
  required String hintText,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle:
        TextStyle(color: AppTheme.creamColor.withOpacity(0.35), fontSize: 13),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: AppTheme.goldColor, size: 20)
        : null,
    filled: true,
    fillColor: AppTheme.cardColor,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.goldColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.deepRedColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          const BorderSide(color: AppTheme.deepRedColor, width: 2),
    ),
  );
}
