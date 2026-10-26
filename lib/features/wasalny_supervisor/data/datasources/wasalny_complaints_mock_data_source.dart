import 'package:barwah_app/features/wasalny_supervisor/data/datasources/wasalny_complaints_data_source.dart';
import 'package:barwah_app/features/wasalny_supervisor/data/models/wasalny_complaint_model.dart';
import 'package:barwah_app/features/wasalny_supervisor/domain/entities/wasalny_complaint.dart';

class WasalnyComplaintsMockDataSource implements WasalnyComplaintsDataSource {
  final List<WasalnyComplaintModel> _complaints = [
    const WasalnyComplaintModel(
      id: 'WS-CMP-4088',
      titleAr: 'اختلاف في حالة السلعة عن الوصف المعتمد',
      titleEn: 'Discrepancy in item condition from approved description',
      descriptionAr:
          'يوجد خدش غير مذكور في ذراع التحكم الإضافي، ولم يظهر بالصور، مع تأخر بالرد من البائع',
      descriptionEn:
          'There is an unmentioned scratch on the additional controller, which did not appear in the photos, along with delayed response from the seller',
      timeAgoAr: 'منذ 25 دقيقة',
      timeAgoEn: '25 mins ago',
      status: WasalnyComplaintStatus.underReview,
      dealCode: 'صفقة وصلني #WS-4088',
      itemTitleAr: 'جهاز بلايستيشن 5 مع ملحقاته',
      itemTitleEn: 'PlayStation 5 with accessories',
      heldAmount: '1,850 ج.م',
      buyerNameAr: 'سلطان الحربي',
      buyerNameEn: 'Sultan Al-Harbi',
      sellerNameAr: 'محمد الدوسري',
      sellerNameEn: 'Mohammed Al-Dossari',
      warrantyTextAr: 'الضمان الميداني: تسليم معتمد ومطابقة أرقام تسلسلية',
      warrantyTextEn:
          'Field warranty: certified delivery & serial number verification',
      sellerPhone: '050 000 1042',
      buyerPhone: '055 000 2042',
    ),
    const WasalnyComplaintModel(
      id: 'WS-CMP-4089',
      titleAr: 'اختلاف في حالة السلعة عن الوصف المعتمد',
      titleEn: 'Discrepancy in item condition from approved description',
      descriptionAr:
          'يوجد خدش غير مذكور في ذراع التحكم الإضافي ولم يظهر بالصور، مع تأخر بالرد من البائع',
      descriptionEn:
          'There is an unmentioned scratch on the additional controller, which did not appear in the photos, along with delayed response from the seller',
      timeAgoAr: 'منذ 25 دقيقة',
      timeAgoEn: '25 mins ago',
      status: WasalnyComplaintStatus.underReview,
      itemTitleAr: 'جهاز بلايستيشن 5 مع ملحقاته',
      itemTitleEn: 'PlayStation 5 with accessories',
      heldAmount: '1,850 ج.م',
      buyerNameAr: 'سلطان الحربي',
      buyerNameEn: 'Sultan Al-Harbi',
      sellerNameAr: 'محمد الدوسري',
      sellerNameEn: 'Mohammed Al-Dossari',
      warrantyTextAr: 'الضمان الميداني: تسليم معتمد ومطابقة أرقام تسلسلية',
      warrantyTextEn:
          'Field warranty: certified delivery & serial number verification',
      sellerPhone: '050 000 1042',
      buyerPhone: '055 000 2042',
    ),
    const WasalnyComplaintModel(
      id: 'WS-CMP-3012',
      titleAr: 'إعلان مخالف: ادعاء السلعة جديدة وهي مستعملة',
      titleEn: 'Violating ad: Claiming item is new while it is used',
      descriptionAr:
          'الإعلان يصنف الجهاز بـ "جديد كلياً بالكرتون"، بينما الصور المرفقة توضح ملصق ضمان منزوع وخدوش بمدخل الشاحن',
      descriptionEn:
          'The ad classifies the device as "brand new in box", while the attached photos show a peeled warranty sticker and scratches at the charging port',
      timeAgoAr: 'أمس 18:40',
      timeAgoEn: 'Yesterday 18:40',
      status: WasalnyComplaintStatus.actionTakenBlocked,
      itemTitleAr: 'لابتوب ديل XPS 13 مع الملحقات',
      itemTitleEn: 'Dell XPS 13 laptop with accessories',
      sellerNameAr: 'تقنية المستقبل (موثّق)',
      sellerNameEn: 'Future Tech (Verified)',
      actionNoteAr:
          'قام المشرف بتعليق ظهور الإعلان وإخطار رئيس القسم لاعتماد الحظر في حال التكرار.',
      actionNoteEn:
          'Supervisor suspended ad visibility and notified department head to approve blocking upon repetition.',
      isAdViolation: true,
      isBlocked: true,
      sellerPhone: '054 000 3012',
      buyerPhone: '050 000 0000',
    ),
    const WasalnyComplaintModel(
      id: 'WS-CMP-4091',
      titleAr: 'عدم تطابق الرقم التسلسلي لكاميرا كانون',
      titleEn: 'Serial number mismatch on Canon camera',
      descriptionAr:
          'الرقم التسلسلي المسجل يختلف برقمين عن الكرتون الخارجي، مطلوب إعادة فحص',
      descriptionEn:
          'The registered serial number differs by two digits from outer box, re-inspection required',
      timeAgoAr: 'منذ ساعتين',
      timeAgoEn: '2 hours ago',
      status: WasalnyComplaintStatus.underReview,
      dealCode: 'صفقة وصلني #WS-3910',
      itemTitleAr: 'كاميرا كانون EOS R6',
      itemTitleEn: 'Canon EOS R6 Camera',
      heldAmount: '6,200 ج.م',
      buyerNameAr: 'فيصل الغامدي',
      buyerNameEn: 'Faisal Al-Ghamdi',
      sellerNameAr: 'عبد الله السالم',
      sellerNameEn: 'Abdullah Al-Salem',
      warrantyTextAr: 'الضمان الميداني: تسليم معتمد ومطابقة أرقام تسلسلية',
      warrantyTextEn:
          'Field warranty: certified delivery & serial number verification',
      sellerPhone: '056 000 4091',
      buyerPhone: '053 000 5091',
    ),
    const WasalnyComplaintModel(
      id: 'WS-CMP-4092',
      titleAr: 'تأخر تسليم الشحنة وتجاوز المهلة المحددة',
      titleEn: 'Delivery delayed beyond scheduled time limit',
      descriptionAr:
          'لم يتم تسليم المنتج الميداني في نقطة الالتقاء المعتمدة مع تعذر التواصل',
      descriptionEn:
          'Field item was not delivered at the approved meetup point with no communication',
      timeAgoAr: 'منذ 3 ساعات',
      timeAgoEn: '3 hours ago',
      status: WasalnyComplaintStatus.underReview,
      dealCode: 'صفقة وصلني #WS-3844',
      itemTitleAr: 'سماعات أبل إيربودز ماكس',
      itemTitleEn: 'Apple AirPods Max',
      heldAmount: '1,400 ج.م',
      buyerNameAr: 'سارة العتيبي',
      buyerNameEn: 'Sara Al-Otaibi',
      sellerNameAr: 'خالد المطيري',
      sellerNameEn: 'Khalid Al-Mutairi',
      warrantyTextAr: 'الضمان الميداني: تسليم معتمد ومطابقة أرقام تسلسلية',
      warrantyTextEn:
          'Field warranty: certified delivery & serial number verification',
      sellerPhone: '057 000 4092',
      buyerPhone: '052 000 6092',
    ),
    const WasalnyComplaintModel(
      id: 'WS-CMP-2001',
      titleAr: 'نزاع مالي ورفض فحص الجهاز عند الاستلام',
      titleEn: 'Financial dispute and refusal to inspect on delivery',
      descriptionAr:
          'تم رفع نزاع بسبب رفض استلام ومعاينة شاشة القيمنق في نقطة الفحص الميدانية',
      descriptionEn:
          'Dispute raised due to refusal of gaming monitor inspection at field inspection point',
      timeAgoAr: 'منذ 4 ساعات',
      timeAgoEn: '4 hours ago',
      status: WasalnyComplaintStatus.escalatedToChief,
      dealCode: 'صفقة وصلني #WS-2991',
      itemTitleAr: 'شاشة قيمنق سامسونج أوديسي G7',
      itemTitleEn: 'Samsung Odyssey G7 Gaming Monitor',
      heldAmount: '2,400 ج.م',
      buyerNameAr: 'تركي الشهري',
      buyerNameEn: 'Turki Al-Shehri',
      sellerNameAr: 'أحمد القحطاني',
      sellerNameEn: 'Ahmed Al-Qahtani',
      warrantyTextAr: 'الضمان الميداني: تسليم معتمد ومطابقة أرقام تسلسلية',
      warrantyTextEn:
          'Field warranty: certified delivery & serial number verification',
      actionNoteAr: 'تم تصعيد النزاع لرئيس المشرفين للبت المالي والنظامي.',
      actionNoteEn:
          'Dispute escalated to chief supervisor for financial & regulatory ruling.',
      sellerPhone: '058 000 2001',
      buyerPhone: '051 000 3001',
    ),
    const WasalnyComplaintModel(
      id: 'WS-CMP-2002',
      titleAr: 'شبهة احتيال في بيانات الفاتورة المرفقة',
      titleEn: 'Suspected fraud in attached invoice data',
      descriptionAr:
          'تم تصعيد البلاغ لرئيس المشرفين بعد اكتشاف تكرار الفاتورة بإعلانين مختلفين',
      descriptionEn:
          'Report escalated to chief supervisor after discovering invoice duplication across two listings',
      timeAgoAr: 'منذ يوم',
      timeAgoEn: '1 day ago',
      status: WasalnyComplaintStatus.escalatedToChief,
      dealCode: 'صفقة وصلني #WS-2850',
      itemTitleAr: 'آيباد برو 12.9 إنش M2',
      itemTitleEn: 'iPad Pro 12.9-inch M2',
      heldAmount: '3,100 ج.م',
      buyerNameAr: 'عمر باوزير',
      buyerNameEn: 'Omar Bawazeer',
      sellerNameAr: 'رياض الزهراني',
      sellerNameEn: 'Riyadh Al-Zahrani',
      warrantyTextAr: 'الضمان الميداني: تسليم معتمد ومطابقة أرقام تسلسلية',
      warrantyTextEn:
          'Field warranty: certified delivery & serial number verification',
      actionNoteAr: 'تم تجميد العملية وإحالتها للتدقيق المركزي العاجل.',
      actionNoteEn:
          'Transaction frozen and referred for urgent central auditing.',
      sellerPhone: '059 000 2002',
      buyerPhone: '050 000 4002',
    ),
  ];

  @override
  Future<List<WasalnyComplaintModel>> getComplaints() async {
    return List<WasalnyComplaintModel>.from(_complaints);
  }

  @override
  Future<WasalnyComplaintModel> escalateComplaint(
    String id, {
    required String reason,
  }) async {
    final index = _complaints.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Complaint $id not found');
    }
    final existing = _complaints[index];
    final updated = WasalnyComplaintModel.fromEntity(
      existing.copyWith(
        status: WasalnyComplaintStatus.escalatedToChief,
        actionNoteAr: 'تم التصعيد لرئيس المشرفين: $reason',
        actionNoteEn: 'Escalated to chief supervisor: $reason',
      ),
    );
    _complaints[index] = updated;
    return updated;
  }

  @override
  Future<WasalnyComplaintModel> resolveComplaint(
    String id, {
    required String note,
  }) async {
    final index = _complaints.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Complaint $id not found');
    }
    final existing = _complaints[index];
    final updated = WasalnyComplaintModel.fromEntity(
      existing.copyWith(
        status: WasalnyComplaintStatus.resolved,
        actionNoteAr: 'تم حل الشكوى وديًا: $note',
        actionNoteEn: 'Complaint resolved amicably: $note',
      ),
    );
    _complaints[index] = updated;
    return updated;
  }

  @override
  Future<WasalnyComplaintModel> inspectComplaint(
    String id, {
    required String notes,
  }) async {
    final index = _complaints.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Complaint $id not found');
    }
    final existing = _complaints[index];
    final updated = WasalnyComplaintModel.fromEntity(
      existing.copyWith(
        actionNoteAr: 'ملاحظة الفحص الميداني: $notes',
        actionNoteEn: 'Field inspection note: $notes',
      ),
    );
    _complaints[index] = updated;
    return updated;
  }
}
