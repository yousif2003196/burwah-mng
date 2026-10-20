import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../head_supervisor_text.dart';
import '../../data/head_supervisor_audit_store.dart';
import '../../data/head_supervisor_roster_store.dart';
import '../../../wasalny_supervisor/data/wasalny_local_event_store.dart';

class HeadSupervisorBroadcastSheet extends StatefulWidget {
  const HeadSupervisorBroadcastSheet({super.key});

  @override
  State<HeadSupervisorBroadcastSheet> createState() =>
      _HeadSupervisorBroadcastSheetState();
}

class _HeadSupervisorBroadcastSheetState
    extends State<HeadSupervisorBroadcastSheet> {
  final _messageController = TextEditingController();
  final _eventStore = WasalnyLocalEventStore();
  final _rosterStore = HeadSupervisorRosterStore();
  List<HeadSupervisorRecord> _activeSupervisors = const [];
  bool _sendToAll = true;
  String? _selectedSupervisorId;
  bool _sending = false;
  bool _loadingRecipients = true;
  String? _error;

  HeadSupervisorRecord? get _selectedSupervisor {
    for (final supervisor in _activeSupervisors) {
      if (supervisor.id == _selectedSupervisorId) return supervisor;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    HeadSupervisorRosterStore.revision.addListener(_loadActiveSupervisors);
    _loadActiveSupervisors();
  }

  @override
  void dispose() {
    HeadSupervisorRosterStore.revision.removeListener(_loadActiveSupervisors);
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveSupervisors() async {
    try {
      final supervisors = await _rosterStore.getActive();
      if (!mounted) return;
      setState(() {
        _activeSupervisors = supervisors;
        _loadingRecipients = false;
        if (!supervisors.any((item) => item.id == _selectedSupervisorId)) {
          _selectedSupervisorId = supervisors.isEmpty ? null : supervisors.first.id;
        }
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor broadcast recipients',
      ));
      if (mounted) {
        setState(() {
          _loadingRecipients = false;
          _error = headSupervisorText(context, arabic: 'تعذر تحميل قائمة المشرفين النشطين.', english: 'Could not load active supervisors.');
        });
      }
    }
  }

  Future<void> _send() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _error = headSupervisorText(context, arabic: 'اكتب نص التوجيه قبل الإرسال.', english: 'Enter the instruction before sending.'));
      return;
    }
    if (_activeSupervisors.isEmpty) {
      setState(() => _error = headSupervisorText(context, arabic: 'لا يوجد مشرفون نشطون لإرسال الإشعار إليهم.', english: 'There are no active supervisors to notify.'));
      return;
    }
    if (_sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    final recipients = _sendToAll
        ? _activeSupervisors
        : _activeSupervisors
            .where((item) => item.id == _selectedSupervisorId)
            .toList();
    if (recipients.isEmpty) {
      setState(() {
        _sending = false;
        _error = headSupervisorText(context, arabic: 'اختر مشرفاً نشطاً لإرسال الإشعار.', english: 'Select an active supervisor to send the notice.');
      });
      return;
    }
    final sentAt = DateTime.now();
    final audience = _sendToAll
        ? 'جميع المشرفين النشطين (${recipients.length})'
        : '${recipients.single.name} ${recipients.single.id}';
    final recipientNames = recipients
        .map((item) => '${item.name} (${item.id})')
        .join('، ');
    final eventBaseId = 'head-broadcast-${sentAt.microsecondsSinceEpoch}';
    final accountIds = recipients.map((item) => item.accountId).toSet();

    try {
      await _eventStore.publishAll([
        for (final accountId in accountIds)
          WasalnyLocalEvent(
            id: '$eventBaseId-$accountId',
            recipient: accountId,
            source: 'head',
            titleAr: 'توجيه من رئيس المشرفين',
            titleEn: 'Direction from the head supervisor',
            messageAr:
                'إلى: ${recipients.where((item) => item.accountId == accountId).map((item) => '${item.name} (${item.id})').join('، ')}\n$message',
            messageEn:
                'To: ${recipients.where((item) => item.accountId == accountId).map((item) => '${item.name} (${item.id})').join(', ')}\n$message',
            createdAt: sentAt,
          ),
      ]);
      await HeadSupervisorAuditStore().record(
        HeadSupervisorAuditRecord(
          id: eventBaseId,
          subjectId: _sendToAll
              ? 'ALL-SUPERVISORS'
              : recipients.single.id.replaceFirst('#', ''),
          kind: 'broadcast',
          title: headSupervisorText(context, arabic: 'إشعار رقابي إلى $audience', english: 'Oversight notice to $audience'),
          details: 'المستلمون: $recipientNames\n$message',
          department: _sendToAll ? 'تعميم' : recipients.single.department,
          occurredAt: sentAt,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'head supervisor broadcast',
      ));
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = headSupervisorText(context, arabic: 'تعذر حفظ الإشعار وإرساله. حاول مرة أخرى.', english: 'Could not save and send the notice. Try again.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .88),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 5, decoration: BoxDecoration(color: const Color(0xFFD6DCE3), borderRadius: BorderRadius.circular(8))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                IconButton(
                  onPressed: _sending ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F2F4)),
                ),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(headSupervisorText(context, arabic: 'إشعار المشرفين', english: 'Notify supervisors'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  Text(headSupervisorText(context, arabic: 'توجيه إداري مباشر من رئيس المشرفين', english: 'Direct instruction from the Head Supervisor'), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                ]),
                const SizedBox(width: 8),
                const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE8F0FF), child: Icon(Icons.campaign_outlined, size: 18, color: AppColors.primaryDark)),
              ]),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 14), shrinkWrap: true, children: [
                Text(headSupervisorText(context, arabic: 'اختر المستلمين', english: 'Choose recipients'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _AudienceChoice(label: headSupervisorText(context, arabic: 'مشرف واحد', english: 'One supervisor'), selected: !_sendToAll, onTap: () => setState(() => _sendToAll = false))),
                  const SizedBox(width: 8),
                  Expanded(child: _AudienceChoice(label: headSupervisorText(context, arabic: 'جميع المشرفين', english: 'All supervisors'), selected: _sendToAll, onTap: () => setState(() => _sendToAll = true))),
                ]),
                if (!_sendToAll) ...[
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: _selectedSupervisorId,
                    decoration: InputDecoration(
                      labelText: headSupervisorText(context, arabic: 'المشرف المستلم', english: 'Recipient supervisor'),
                      labelStyle: const TextStyle(fontSize: 10),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: [
                      for (final supervisor in _activeSupervisors)
                        DropdownMenuItem(
                          value: supervisor.id,
                          child: Text('${supervisor.name} • ${supervisor.id}', style: const TextStyle(fontSize: 11)),
                        ),
                    ],
                    onChanged: _sending ? null : (value) => setState(() => _selectedSupervisorId = value),
                  ),
                ],
                const SizedBox(height: 14),
                Text(headSupervisorText(context, arabic: 'نص التوجيه أو الإشعار', english: 'Instruction or notice'), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 7),
                TextField(
                  controller: _messageController,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 500,
                  textAlign: TextAlign.right,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(
                    hintText: headSupervisorText(context, arabic: 'اكتب التوجيه الذي تريد إيصاله للمشرفين...', english: 'Enter the instruction to send to supervisors...'),
                    hintStyle: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    errorText: _error,
                    filled: true,
                    fillColor: const Color(0xFFF5F6F8),
                    contentPadding: const EdgeInsets.all(13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE1E5E9))),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(11)),
                  child: Text(
                    _sendToAll
                        ? headSupervisorText(context, arabic: 'سيصل الإشعار إلى ${_activeSupervisors.length} مشرف نشط حالياً.', english: 'The notice will reach ${_activeSupervisors.length} active supervisors.')
                        : _selectedSupervisor == null
                            ? headSupervisorText(context, arabic: 'لا يوجد مشرف نشط متاح للاختيار.', english: 'No active supervisor is available to select.')
                            : headSupervisorText(context, arabic: 'سيُوجَّه إلى ${_selectedSupervisor!.name} عبر حساب القسم المرتبط به.', english: 'The notice will go to ${_selectedSupervisor!.name} through their linked department account.'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF315F9A)),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _sending || _loadingRecipients ? null : _send,
                  icon: _sending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_outlined, size: 17),
                  label: Text(_sending ? headSupervisorText(context, arabic: 'جارٍ الإرسال...', english: 'Sending...') : headSupervisorText(context, arabic: 'إرسال الإشعار الآن', english: 'Send notice now'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _AudienceChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AudienceChoice({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.primaryDark : const Color(0xFFF0F2F4),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 15, color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
            ]),
          ),
        ),
      );
}
