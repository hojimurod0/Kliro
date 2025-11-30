import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_state.dart';

class OsagoSuccessScreen extends StatelessWidget {
  const OsagoSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OsagoBloc, OsagoState>(
      builder: (context, state) {
        final check = state.checkResponse;
        final calc = state.calcResponse;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Tasdiqlash'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 12),
                const Text(
                  'Polis muvaffaqiyatli rasmiylashtirildi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildInfoTile('Polisa raqami', check?.policyNumber ?? '—'),
                _buildInfoTile(
                  'Sana',
                  check?.issuedAt != null
                      ? '${check!.issuedAt!.day.toString().padLeft(2, '0')}.${check.issuedAt!.month.toString().padLeft(2, '0')}.${check.issuedAt!.year}'
                      : '—',
                ),
                _buildInfoTile(
                  'Summa',
                  calc == null
                      ? '—'
                      : '${calc.amount.toStringAsFixed(2)} ${calc.currency.toUpperCase()}',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: check?.downloadUrl == null
                      ? null
                      : () => _openUrl(context, check!.downloadUrl!),
                  child: const Text('Polisni yuklab olish'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _share(context, check?.downloadUrl),
                  child: const Text('Ulashish'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Yopish'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final success = await launchUrlString(url);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL ni ochib bo\'lmadi')));
    }
  }

  Future<void> _share(BuildContext context, String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yuklab olish havolasi mavjud emas')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Havola nusxalandi')));
  }
}
