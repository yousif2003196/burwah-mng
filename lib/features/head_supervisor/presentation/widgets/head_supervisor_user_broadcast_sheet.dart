import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:barwah_app/core/di/injection_container.dart';
import 'package:barwah_app/core/network/api_consumer.dart';
import 'package:barwah_app/core/network/api_endpoints.dart';
import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/motion_icon.dart';
import 'package:barwah_app/features/head_supervisor/presentation/utils/head_supervisor_text.dart';

/// فئة المستلمين في تطبيق اليوزر.
enum UserBroadcastAudience {
  all('all', 'كل المستخدمين', 'Everyone', Icons.groups_outlined),
  customers('customers', 'العملاء', 'Customers', Icons.person_outline),
  merchants('merchants', 'التجار', 'Merchants', Icons.storefront_outlined),
  captains('captains', 'الكباتن', 'Captains', Icons.delivery_dining_outlined);

  const UserBroadcastAudience(this.key, this.ar, this.en, this.icon);
  final String key;
  final String ar;
  final String en;
  final IconData icon;
}

/// إشعار من رئيس المشرفين لمستخدمين تطبيق اليوزر (كلهم أو فئة)،
/// مع عدد المستلمين قبل الإرسال. يرجّع رسالة السيرفر لو اتبعت.
class HeadSupervisorUserBroadcastSheet extends StatefulWidget {
  const HeadSupervisorUserBroadcastSheet({super.key});

  @override
  State<HeadSupervisorUserBroadcastSheet> createState() =>
      _HeadSupervisorUserBroadcastSheetState();
}

class _HeadSupervisorUserBroadcastSheetState
    extends State<HeadSupervisorUserBroadcastSheet> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  ApiConsumer get _api => sl<ApiConsumer>(instanceName: 'berwah');

  var _audience = UserBroadcastAudience.all;
  int? _count;
  bool _counting = false;
  bool _sending = false;
  String? _error;
  int _countRequest = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadCount() async {
    final request = ++_countRequest;
    setState(() {
      _counting = true;
      _count = null;
    });
    int? count;
    try {
      final response = await _api.get<Object>(
        ApiEndpoints.bossBroadcastUsersCount,
        queryParameters: {'audience': _audience.key},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final raw = data is Map ? data['count'] : null;
      count = raw is num ? raw.toInt() : int.tryParse('$raw');
    } catch (_) {
      count = null;
    }
    if (!mounted || request != _countRequest) return;
    setState(() {
      _count = count;
      _counting = false;
    });
  }

  void _pick(UserBroadcastAudience audience) {
    if (audience == _audience || _sending) return;
    setState(() => _audience = audience);
    _loadCount();
  }

  Future<void> _send() async {
    final title = _title.text.trim();
    final message = _message.text.trim();
    if (title.length < 3 || message.length < 5) {
      setState(() => _error = headSupervisorText(context,
          arabic: 'اكتب عنوان (3 حروف على الأقل) ونص (5 حروف على الأقل).',
          english: 'Enter a title (3+ chars) and a message (5+ chars).'));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headSupervisorText(dialogContext,
            arabic: 'تأكيد الإرسال', english: 'Confirm sending')),
        content: Text(headSupervisorText(dialogContext,
            arabic:
                'الإشعار هيوصل لـ ${_count ?? '—'} من ${_audience.ar}. مش هينفع يتسحب بعد الإرسال.',
            english:
                'This reaches ${_count ?? '—'} ${_audience.en.toLowerCase()} and cannot be recalled.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(headSupervisorText(dialogContext, arabic: 'إلغاء', english: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(headSupervisorText(dialogContext, arabic: 'إرسال', english: 'Send')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response = await _api.post<Object>(
        ApiEndpoints.bossBroadcastUsers,
        data: {'audience': _audience.key, 'title': title, 'message': message},
      );
      final body = response.data;
      final text = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (!mounted) return;
      Navigator.of(context).pop(text.isEmpty
          ? headSupervisorText(context, arabic: 'تم إرسال الإشعار.', english: 'Notification sent.')
          : text);
    } on DioException catch (error) {
      final body = error.response?.data;
      final text = body is Map ? '${body['message'] ?? ''}'.trim() : '';
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = text.isNotEmpty
            ? text
            : headSupervisorText(context,
                arabic: 'تعذر الإرسال. تأكد من الاتصال وحاول مرة أخرى.',
                english: 'Could not send. Check the connection and retry.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + inset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              const Spacer(),
              Text(
                  headSupervisorText(context,
                      arabic: 'إشعار لمستخدمين التطبيق', english: 'Notify app users'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(width: 8),
              MotionIcon(Icons.campaign_outlined, color: AppColors.infoDark),
            ]),
            const SizedBox(height: 4),
            Text(
                headSupervisorText(context,
                    arabic: 'بيوصل كإشعار في تطبيق اليوزر للحسابات الشغالة بس.',
                    english: 'Delivered in the user app to active accounts only.'),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final audience in UserBroadcastAudience.values)
                  ChoiceChip(
                    selected: audience == _audience,
                    onSelected: (_) => _pick(audience),
                    avatar: Icon(audience.icon, size: 16),
                    label: Text(headSupervisorText(context,
                        arabic: audience.ar, english: audience.en)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                if (_counting)
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    onPressed: _loadCount,
                    icon: const MotionIcon(Icons.refresh, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                const Spacer(),
                Text(
                    _counting
                        ? headSupervisorText(context, arabic: 'بنحسب المستلمين…', english: 'Counting…')
                        : _count == null
                            ? headSupervisorText(context,
                                arabic: 'تعذر حساب العدد', english: 'Could not count recipients')
                            : headSupervisorText(context,
                                arabic: 'هيوصل لـ $_count من ${_audience.ar}',
                                english: 'Reaches $_count ${_audience.en.toLowerCase()}'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.infoDark)),
              ]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              maxLength: 80,
              textAlign: TextAlign.right,
              enabled: !_sending,
              decoration: InputDecoration(
                labelText: headSupervisorText(context, arabic: 'العنوان', english: 'Title'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _message,
              minLines: 3,
              maxLines: 6,
              maxLength: 500,
              textAlign: TextAlign.right,
              enabled: !_sending,
              decoration: InputDecoration(
                labelText: headSupervisorText(context, arabic: 'نص الإشعار', english: 'Message'),
                border: const OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(_error!,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: AppColors.dangerDark)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _sending || _counting || (_count ?? 0) == 0 ? null : _send,
                icon: _sending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(headSupervisorText(context,
                    arabic: 'إرسال الإشعار', english: 'Send notification')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
