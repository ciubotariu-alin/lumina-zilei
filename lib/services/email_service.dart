import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/acatist_request.dart';

/// Rezultatul unei trimiteri de email.
sealed class EmailResult {
  const EmailResult();
}

class EmailSuccess extends EmailResult {
  const EmailSuccess();
}

class EmailFailure extends EmailResult {
  final String message;
  const EmailFailure(this.message);
}

/// Interfață abstractă — ușor de înlocuit cu alt provider.
abstract class EmailService {
  Future<EmailResult> sendAcatistRequest(AcatistRequest request);
}

// ---------------------------------------------------------------------------
// EmailJS implementation
// ---------------------------------------------------------------------------
//
// Setup EmailJS (emailjs.com):
//   1. Creează un cont gratuit pe emailjs.com (200 emailuri/lună gratuit)
//   2. Adaugă un "Email Service" (ex. Gmail sau alt SMTP)
//   3. Creează un "Email Template" cu variabilele de mai jos:
//      - {{to_email}}       — adresa parohiei
//      - {{parohie_name}}   — denumirea parohiei
//      - {{intentie}}       — intenția/rugăciunea
//      - {{durata}}         — durata acatistului
//      - {{from_name}}      — numele expeditorului
//      - {{from_phone}}     — telefonul expeditorului
//      - {{from_email}}     — emailul expeditorului
//   4. Completează cele 3 constante de mai jos cu valorile din dashboard-ul EmailJS.
//
const String _emailjsServiceId = 'service_ae2r83u';
const String _emailjsTemplateId = 'template_sfvwpwg';
const String _emailjsPublicKey = 'MrwGg_tyDOe8nZ6XS';

class EmailJsService implements EmailService {
  static const _sendUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  @override
  Future<EmailResult> sendAcatistRequest(AcatistRequest request) async {
    try {
      final body = jsonEncode({
        'service_id': _emailjsServiceId,
        'template_id': _emailjsTemplateId,
        'user_id': _emailjsPublicKey,
        'template_params': {
          'to_email': request.parohieEmail,
          'parohie_name': request.parohieDenumire,
          'intentie': request.intentie,
          'durata': request.durata.label,
          'from_name': request.numeExpeditor,
          'from_phone': request.telefonExpeditor,
          'from_email': request.emailExpeditor,
        },
      });

      final response = await http
          .post(
            Uri.parse(_sendUrl),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return const EmailSuccess();
      } else {
        debugPrint('EmailJS error ${response.statusCode}: ${response.body}');
        return EmailFailure('Eroare server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('EmailJS exception: $e');
      return EmailFailure('Eroare de rețea. Verificați conexiunea.');
    }
  }
}

/// Singleton accesibil din toată aplicația.
/// Înlocuiește `EmailJsService()` cu alt provider când e necesar.
final EmailService emailService = EmailJsService();
