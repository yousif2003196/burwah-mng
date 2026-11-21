# التوثيق التقني لواجهات برمجة التطبيقات (API Documentation)
## وحدة رئيس المشرفين والرقابة الميدانية (`BossOfSupervisor`) — منصة برواح

---

## 1. نظرة عامة والمعمارية (Overview & Architecture)

تُوفّر هذه الوحدة الصلاحيات الرقابية والإدارية العليا لرئيس المشرفين (`BossOfSupervisor`) والمدير العام (`Admin`) لمتابعة العمليات الحرجة، مراجعة قرارات المشرفين الميدانيين وتجاوزها (Override)، الفصل في النزاعات المالية والتعاقدية، التحقيق في تظلمات التجار، وإدارة المحفظة والمستحقات الإشرافية.

### **متطلبات المصادقة والصلاحيات (Authentication & Authorization)**
* **نوع المصادقة:** `Bearer Token (JWT)` يُرسل في ترويسة الطلب:
  ```http
  Authorization: Bearer <YOUR_JWT_TOKEN>
  ```
* **الأدوار المصرح لها (Roles):** `BossOfSupervisor`, `Admin`
* **تعدد الجلسات (Multi-Session Support):** يدعم النظام فتح الحساب من أكثر من جهاز أو متصفح في نفس الوقت دون إبطال الجلسات الأخرى طالما التوكن ساري المفعول.
* **الرابط الأساسي (Base URL):** `/api/BossOfSupervisor`

---

## 2. مسار العمل العام (System Flow)

```text
[1. تسجيل الدخول] ──► POST /api/Auth/LoginForSupervisor (الحصول على JWT Token)
        │
        ├──► [2. مراقبة الطلبات والنزاعات] ──► GET /orders-and-disputes
        │         ├──► إعادة مراجعة قرار مشرف ──► POST /requests/{id}/reevaluate
        │         └──► حسم نزاع مالي فوري ──► POST /disputes/{id}/resolve
        │
        ├──► [3. إدارة شكاوى وتظلمات التجار] ──► GET /merchant-complaints
        │         ├──► عرض تفاصيل التظلم والفحص الآلي ──► GET /final/complaints/{complaintId}/details
        │         ├──► استدعاء المشرف لشات فوري ──► POST /final/complaints/{complaintId}/summon-chat
        │         ├──► فك حظر الإعلان والتحقيق ──► POST /final/complaints/{complaintId}/unban-and-investigate
        │         └──► قرار إداري (تأييد / تصعيد) ──► POST /final/complaints/{complaintId}/decision
        │
        └──► [4. الملف الرقابي والمحفظة]
                  ├──► الملف الشخصي والسجل الرقابي ──► GET /final/profile
                  ├──► عرض رصيد المحفظة والسجل المالي ──► GET /final/wallet
                  └──► طلب سحب وتحويل فوري (SARIE) ──► POST /final/wallet/payout
```

---

## 3. تفاصيل الـ Endpoints

### القسم الأول: إدارة الطلبات الرقابية والنزاعات

#### **1.1 جلب كافة العمليات الحرجة والنزاعات**
يسترجع قائمة موحدة تجمع بين الإعلانات المرفوضة/المعلقة للمراجعة والطلبات المتنازع عليها مع إمكانية البحث والفلترة.

* **Endpoint:** `GET /api/BossOfSupervisor/orders-and-disputes`
* **Query Parameters:**
  * `search` *(string, optional)*: البحث برقم الطلب أو عنوان الإعلان أو نص النزاع.
  * `filterTab` *(string, optional)*: تصفية النتائج (`all` | `ads` | `disputes`) — الافتراضي `all`.

* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "totalOperations": 134,
    "data": [
      {
        "id": 3042,
        "type": "ad",
        "trackingNumber": "ADV-3042",
        "title": "صيانة مكيفات وتبريد - حي الياسمين",
        "category": "قسم الخدمات الميدانية",
        "reason": "عدم توفر فني معتمد في نطاق الحي خلال 30 دقيقة",
        "status": "Rejected",
        "createdAt": "2026-11-20T01:15:00Z"
      },
      {
        "id": 5510,
        "type": "dispute",
        "trackingNumber": "WAS-5510",
        "title": "نزاع طلب رقم #5510",
        "category": "المستعمل وخدمة وصلني",
        "reason": "رفض المشتري الاستلام لوجود خدش جانبي غير مذكور",
        "status": "مصعد لرئيس المشرفين",
        "createdAt": "2026-11-19T22:30:00Z"
      }
    ]
  }
}
```
* **شرح الحقول:**
  * `totalOperations`: إجمالي العمليات الحرجة التي تتطلب انتباهاً رقابياً.
  * `type`: يحدد ما إذا كان العنصر إعلاناً (`ad`) أو نزاع طلب (`dispute`) لتوجيه الواجهة للشاشة المناسبة.

---

#### **1.2 إعادة مراجعة قرار مشرف (Reevaluate Request)**
يُستخدم لتجاوز قرار الرفض الصادر من المشرف وإعادة إسناد الطلب أو طلب إفادة أو توجيه تنبيه إداري إلزامي.

* **Endpoint:** `POST /api/BossOfSupervisor/requests/{id}/reevaluate`
* **Path Parameter:** `id` *(int)* — رقم الإعلان أو الطلب المستهدف.
* **Request Body:**
```json
{
  "actionType": "reassign",
  "directiveText": "يرجى فحص خريطة الفنيين المعتمدين في النطاق الموسع وإسناد الطلب خلال 15 دقيقة."
}
```
  * قيم `actionType` المتاحة:
    * `"reassign"`: إعادة الطلب للمشرف مع توجيه ملزم.
    * `"explanation"`: تجميد الرفض مؤقتاً وطلب إفادة تبريرية.
    * `"warning"`: تسجيل تنبيه إداري ولفت نظر في سجل المشرف.

* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "message": "تم إرسال أمر إعادة المراجعة للمشرف فوراً"
}
```
* **حالات الخطأ:**
  * `400 Bad Request`: في حال ترك `directiveText` فارغاً أو تجاوز 300 حرف.
  * `404 Not Found`: إذا كان رقم الطلب غير موجود.

---

#### **1.3 التدخل الرقابي وحسم النزاعات (Resolve Dispute)**
إصدار حكم نهائي وملزم في النزاعات المعلقة أو المصعدة وتوثيق التسبيب الإداري في المحضر.

* **Endpoint:** `POST /api/BossOfSupervisor/disputes/{id}/resolve`
* **Path Parameter:** `id` *(int)* — رقم الطلب المتنازع عليه.
* **Request Body:**
```json
{
  "resolutionType": "full_refund",
  "officialRulingText": "بناءً على تقرير الفحص الفني المرفق، تقرر استرداد المشتري لكامل المبلغ وإرجاع السلعة للبائع."
}
```
  * قيم `resolutionType` المتاحة:
    * `"full_refund"`: إرجاع السلعة واسترداد كامل المبلغ للمشتري.
    * `"partial_refund"`: إلزام البائع بتعويض جزئي واستلام السلعة.
    * `"reject_claim"`: رفض طلب الإرجاع وإلزام المشتري بالاستلام.
    * `"legal_transfer"`: إحالة الملف للشؤون القانونية وتجميد الحسابات.

* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "message": "تم اعتماد قرار حسم النزاع وإنهاء البلاغ فوراً"
}
```

---

### القسم الثاني: شكاوى وتظلمات التجار ضد المشرفين

#### **2.1 قائمة شكاوى التجار ضد المشرفين**
عرض التظلمات المقدمة من التجار ضد قرارات الحجب أو التأخير غير المبرر من المشرفين الميدانيين.

* **Endpoint:** `GET /api/BossOfSupervisor/merchant-complaints`
* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "data": [
    {
      "id": 104,
      "code": "CMP-SUP-104",
      "title": "تعليق إعلان تجاري بدعوى مخالفة التسعير دون توجيه إنذار",
      "description": "تقدم التاجر بتظلم رسمي ضد إجراء المشرف بحجب الحملة الترويجية...",
      "complainant": "متجر الأفق للسيارات والتجارة",
      "status": "Open",
      "createdAt": "2026-11-20T00:10:00Z"
    }
  ]
}
```

---

#### **2.2 تفاصيل التظلم والفحص الآلي**
يعرض الملف الكامل للنزاع الإداري: بيانات الطرف الشاكي (التاجر)، المشكو في حقه (المشرف)، نتيجة الفحص الآلي ومطابقة اللائحة، إفادة المشرف، والمستندات الثبوتية.

* **Endpoint:** `GET /api/BossOfSupervisor/final/complaints/{complaintId}/details`
* **Path Parameter:** `complaintId` *(int)* — رقم التذكرة/الشكوى.
* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "complaintId": 104,
    "code": "CMP-SUP-104",
    "title": "تعليق إعلان تجاري بدعوى مخالفة التسعير دون توجيه إنذار مسبق",
    "priorityBadge": "أولوية قصوى - قيد المراجعة والتحقيق",
    "classification": "تعسف إداري في اتخاذ إجراء رقابي فوري ضد منشأة موثقة",
    "complainant": {
      "id": 8821,
      "name": "متجر الألق للسيارات والتجارة",
      "badge": "موثق بالسجل"
    },
    "accusedSupervisor": {
      "name": "مشرف الرقابة الميدانية",
      "code": "SUP-409",
      "approvedDecisionsCount": 142
    },
    "automatedAudit": {
      "engineVersion": "v3.2",
      "commercialLicenseStatus": "ساري المفعول وموثق إلكترونياً",
      "protocolAlert": "التحقق الآلي من مطابقة الإشعار والمدد النظامية للقرار الرقابي"
    },
    "supervisorStatement": {
      "statementText": "تم حظر الإعلان فوراً لوجود نسبة خصم معلنة تتجاوز 40%...",
      "recordedAt": "2026-11-19T14:18:00Z",
      "legalAssessment": "قيد التحقق الرقابي"
    },
    "evidences": [
      {
        "title": "لقطة شاشة ومستندات البلاغ",
        "subtitle": "مرفقات القضية والتدقيق",
        "previewUrl": "https://res.cloudinary.com/..."
      }
    ]
  }
}
```

---

#### **2.3 استدعاء المشرف وبدء محادثة فورية موثقة**
فتح قناة تواصل رقابية مباشرة ومؤرشفة مع المشرف المشكو في حقه لطلب إيضاح فوري.

* **Endpoint:** `POST /api/BossOfSupervisor/final/complaints/{complaintId}/summon-chat`
* **Request Body:**
```json
{
  "summonTopic": "immediate_clarification",
  "initialMessage": "أ. سعد، مطلوب توضيح فوري لسبب تعليق حملة متجر الألق رغم وجود ترخيص وزارة التجارة المعتمد.",
  "attachCaseDocument": true
}
```
  * قيم `summonTopic` المتاحة: `"immediate_clarification"` | `"confront_documents"` | `"quick_interrogation"`.

* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "message": "تم إرسال الاستدعاء وبدء المحادثة الفورية الموثقة مع المشرف",
  "data": {
    "complaintId": 104,
    "code": "CMP-SUP-104",
    "summonTopic": "immediate_clarification",
    "initialMessage": "أ. سعد، مطلوب توضيح فوري لسبب تعليق حملة متجر الألق...",
    "caseDocumentAttached": true,
    "chatSessionId": "CHAT-SUP-104-20261120033000",
    "startedAt": "2026-11-20T03:30:00Z"
  }
}
```

---

#### **2.4 إلغاء حظر الإعلان وفتح تحقيق رسمي**
تنفيذ قرار فوري برفع الحجب عن إعلان التاجر وإعادته للبث، مع فتح مساءلة إدارية للمشرف وتعويض التاجر بأيام ترويج مجانية.

* **Endpoint:** `POST /api/BossOfSupervisor/final/complaints/{complaintId}/unban-and-investigate`
* **Request Body:**
```json
{
  "unbanAdImmediately": true,
  "openFormalInvestigation": true,
  "compensateMerchantPromotion": true,
  "promotionCompensationDays": 3,
  "justificationAndDirective": "ثبوت نظامية ترخيص الخصومات المرفق بالسجل وعدم توجيه إنذار مسبق."
}
```
* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "message": "تم تأكيد فك الحظر وبدء التحقيق الرقابي بنجاح"
}
```

---

#### **2.5 إصدار قرار إداري في الشكوى (تأييد المشرف أو التصعيد)**
يُستخدم في حال قرر رئيس المشرفين تأييد إجراء المشرف ورفض التظلم، أو تصعيد القضية للمدير العام.

* **Endpoint:** `POST /api/BossOfSupervisor/final/complaints/{complaintId}/decision`
* **Request Body:**
```json
{
  "decisionType": "uphold_supervisor",
  "notes": "إجراء المشرف سليم ومطابق للائحة حماية المستهلك."
}
```
  * قيم `decisionType` المتاحة: `"uphold_supervisor"` | `"escalate_legal_gm"`.

* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "message": "تم اعتماد القرار الرقابي بنجاح"
}
```

---

### القسم الثالث: الملف الرقابي ومحفظة المستحقات

#### **3.1 الملف الشخصي والسجل الرقابي لرئيس المشرفين**
يعرض البيانات الوظيفية لرئيس المشرفين، نطاق الإشراف، ملخص رصيد المحفظة، مؤشرات الامتثال، وآخر القرارات الرقابية الموثقة.

* **Endpoint:** `GET /api/BossOfSupervisor/final/profile`
* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "userId": 12,
    "fullName": "م. عادل الشمري",
    "roleTitle": "رئيس هيئة المشرفين والرقابة الميدانية",
    "badgeCode": "SUP-HEAD-01",
    "email": "adel.alshammari@almazouri.sa",
    "phoneNumber": "+966500008821",
    "supervisionScope": "الرياض، الغربية، الشرقية، الشمالي (4 قطاعات)",
    "totalBalance": 45800.00,
    "availableForWithdrawal": 45800.00,
    "lockedBalance": 0.00,
    "complianceMetrics": {
      "approvedInterventions": 6,
      "governanceScore": "98.4%",
      "managedSupervisors": 18
    },
    "recentAuditLogs": [
      {
        "id": 3042,
        "code": "ADV-3042",
        "title": "صيانة مكيفات وتبريد - حي الياسمين",
        "status": "Approved",
        "note": "تم فك حظر الإعلان وإعادته للبث بقرار رئيس المشرفين",
        "reviewedAt": "2026-11-20T02:15:00Z"
      }
    ],
    "securitySettings": {
      "twoFactorEnabled": true,
      "activeSessionsCount": 1,
      "urgentAlertsEnabled": true
    }
  }
}
```

---

#### **3.2 عرض بيانات المحفظة وسجل عمليات الصرف**
استرجاع الرصيد المتاح للسحب الفوري، الحد الأدنى للصرف، وسجل الحركات المالية السابقة.

* **Endpoint:** `GET /api/BossOfSupervisor/final/wallet`
* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "totalBalance": 45800.00,
    "availableForWithdrawal": 45800.00,
    "lockedBalance": 0.00,
    "minimumWithdrawal": 500.00,
    "payoutMethods": ["bank", "instapay", "wallet"],
    "transactions": [
      {
        "id": 90218,
        "referenceCode": "TXN-90218",
        "kind": "Withdraw",
        "amount": -15000.00,
        "description": "سحب فوري (bank) إلى SA44 8000 0001 **** 5521",
        "createdAt": "2026-11-12T10:00:00Z",
        "status": "ناجح"
      }
    ]
  }
}
```

---

#### **3.3 طلب صرف وتحويل فوري (SARIE)**
تنفيذ عملية سحب مالي من محفظة المستحقات الإشرافية وخصم المبلغ مباشرة من الرصيد المتاح.

* **Endpoint:** `POST /api/BossOfSupervisor/final/wallet/payout`
* **Request Body:**
```json
{
  "amount": 5000,
  "payoutMethod": "bank",
  "destinationAccount": "SA4480000001000000005521",
  "otpCode": "482910"
}
```
  * قيود التحقق: يجب أن يكون `amount` أكبر من أو يساوي `500` وأقل من أو يساوي الرصيد المتاح.

* **Response Example (`200 OK`):**
```json
{
  "status": "success",
  "message": "تم تأكيد طلب السحب والتحويل الفوري بنجاح",
  "data": {
    "transactionId": 90225,
    "withdrawnAmount": 5000.00,
    "remainingBalance": 40800.00,
    "payoutMethod": "bank",
    "executedAt": "2026-11-20T03:35:00Z"
  }
}
```
* **حالات الخطأ (`400 Bad Request`):**
  * `"الحد الأدنى للسحب الفوري 500 ر.س"`
  * `"الرصيد المتاح غير كافٍ لإتمام طلب الصرف الفوري"`

---

## 4. جدول رموز الحالة الموحدة (HTTP Status Codes)

| الرمز (Status Code) | المعنى | متى يحدث؟ |
| :--- | :--- | :--- |
| **`200 OK`** | نجاح العملية | تم جلب البيانات أو تنفيذ القرار الرقابي وحفظه بنجاح. |
| **`400 Bad Request`** | خطأ في البيانات المرسلة | حقل إلزامي ناقص، مبلغ سحب أقل من 500، أو رصيد غير كافٍ. |
| **`401 Unauthorized`** | غير مصرح بالدخول | التوكن مفقود أو منتهي الصلاحية (أكثر من 30 دقيقة دون تجديد). |
| **`403 Forbidden`** | ممنوع الوصول | الحساب لا يمتلك دور `BossOfSupervisor` أو `Admin`. |
| **`404 Not Found`** | العنصر غير موجود | رقم الطلب أو النزاع أو الشكوى المطلوبة غير مسجل في قاعدة البيانات. |
| **`500 Internal Server Error`** | خطأ داخلي في الخادم | خطأ غير متوقع أثناء الاتصال بقاعدة البيانات أو معالجة الطلب. |