# التوثيق الكامل لواجهات برمجة التطبيقات (API Documentation)

## جميع وحدات المشرفين (`Supervisor`) ورئيس المشرفين (`BossOfSupervisor`) — منصة برواح (`https://berwah.runasp.net`)

## 1. نظرة عامة ومعايير التشغيل (Overview & Standards)

يضم هذا التوثيق كافة الـ Endpoints الفعلية المنشورة في Swagger على `https://berwah.runasp.net/swagger/index.html` مع نموذج `Response` تفصيلي وشرح لكل نقطة في:

1. **`SupervisorForAd`** (إشراف الإعلانات الجديدة والمراجعة والتدقيق).

2. **`SupervisorForMerchant`** (إشراف التجار، المنتجات، الطلبات، السحوبات، والفعاليات).

3. **`SupervisorForSR`** (إشراف الخدمات / طلبات الخدمة، مزودي الخدمة، والشكاوى والتصعيدات).

4. **`SupervisorUsed`** (إشراف المنتجات المستعملة، طلبات وصلني، الشكاوى، والمحافظ).

5. **`BossOfSupervisor`** (الرقابة العليا، إدارة المشرفين، النزاعات، تذاكر رئيس المشرفين، الملف الرقابي، والمحفظة).

### **معايير المصادقة والتذاكر**

* **المصادقة:** `Bearer Token (JWT)` في ترويسة الطلب `Authorization: Bearer <token>`، مع دعم تعدد الجلسات والأجهزة لجميع الحسابات.

* **`TicketCategory`:** `General = 0`, `NewProducts = 1`, `UsedProducts = 2`, `Services = 3`, `BossOfSupervisors = 4`.

* **`TicketStatus`:** `Open`, `InProgress`, `Closed`.

## 2. مسار العمل العام (System Flow)

```
[1. تسجيل الدخول] ──► POST /api/SupervisorForAd/LoginForSupervisor (الحصول على JWT Token)
        │
        ├──► [إشراف الإعلانات - SupervisorForAd]
        │         └──► مراجعة المعلقة (/pending-ads)، اعتماد/تحديث/رفض/إخفاء، سجل التدقيق (/audit-log)، والتقارير (/reports)
        │
        ├──► [إشراف التجار - SupervisorForMerchant]
        │         └──► مراجعة التجار (/merchants)، قبول/رفض/طلب بيانات/تعليق/إعادة تفعيل، العمولة، المنتجات، الطلبات، والسحوبات (/withdrawals)
        │
        ├──► [إشراف الخدمات - SupervisorForSR]
        │         └──► متابعة الطلبات (/requests, /pending)، قبول/رفض/تحديث، مزودي الخدمة، الشكاوى والتصعيدات، والمحفظة المتقدمة (/advanced-wallet)
        │
        ├──► [إشراف المستعمل ووصلني - SupervisorUsed]
        │         └──► مراجعة إعلانات المستعمل (/SupervisorUsed)، طلبات وصلني (/wosally-orders)، الشكاوى والتصعيدات، والمحفظة (/wallet, /advanced-wallet)
        │
        └──► [رئيس المشرفين - BossOfSupervisor]
                  ├──► لوحة المعلومات (/dashboard-overview) وإدارة المشرفين (/supervisors/...)
                  ├──► العمليات والنزاعات (/orders-and-disputes)، إعادة المراجعة (/requests/{id}/reevaluate)، وحسم النزاعات (/disputes/{id}/resolve)
                  ├──► تذاكر وشكاوى BossOfSupervisors (/tickets, /merchant-complaints, /complaints/{complaintId}/...)
                  └──► الملف الرقابي (/profile) والمحفظة والسحب الفوري (/wallet, /wallet/payout)

```

## 3. وحدة `SupervisorForAd` (إشراف الإعلانات)

### **3.1 `POST /api/SupervisorForAd/LoginForSupervisor`**

تسجيل دخول المشرف وإصدار JWT وRefresh Token.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تسجيل الدخول بنجاح",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "def50200...",
  "data": {
    "userId": 7,
    "email": "supervisor@berwah.sa",
    "name": "سعد العتيبي",
    "role": "Supervisor",
    "lastLogin": "2026-11-20T15:00:00Z"
  }
}

```

### **3.2 `GET /api/SupervisorForAd/pending-ads`**

جلب الإعلانات المعلقة بانتظار المراجعة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 101,
      "title": "إعلان سيارة مستعملة",
      "status": "Pending",
      "createdAt": "2026-11-20T14:10:00Z"
    }
  ]
}

```

### **3.3 `GET /api/SupervisorForAd/stats`**

إحصائيات مراجعة الإعلانات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "pendingCount": 12,
    "approvedCount": 85,
    "rejectedCount": 9,
    "hiddenCount": 3
  }
}

```

### **3.4 `POST /api/SupervisorForAd/update-ad-status/{id}`**

تحديث حالة إعلان محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تحديث حالة الإعلان بنجاح",
  "data": {
    "id": 101,
    "status": "Approved"
  }
}

```

### **3.5 `GET /api/SupervisorForAd/ads`**

جلب قائمة الإعلانات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 101,
      "title": "إعلان سيارة مستعملة",
      "status": "Approved",
      "createdAt": "2026-11-20T14:10:00Z"
    }
  ]
}

```

### **3.6 `GET /api/SupervisorForAd/ad/{id}`**

جلب تفاصيل إعلان محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 101,
    "title": "إعلان سيارة مستعملة",
    "description": "تفاصيل الإعلان الكاملة",
    "status": "Pending",
    "images": []
  }
}

```

### **3.7 `PUT /api/SupervisorForAd/ad/{id}`**

تعديل بيانات إعلان محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تعديل بيانات الإعلان بنجاح"
}

```

### **3.8 `POST /api/SupervisorForAd/reject/{id}`**

رفض إعلان مع تسجيل السبب.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم رفض الإعلان وتسجيل السبب"
}

```

### **3.9 `POST /api/SupervisorForAd/hide/{id}`**

إخفاء إعلان من الظهور.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إخفاء الإعلان بنجاح"
}

```

### **3.10 `GET /api/SupervisorForAd/audit-log`**

جلب سجل التدقيق الرقابي للإعلانات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 50,
      "adId": 101,
      "action": "Approved",
      "note": "مطابق للشروط",
      "createdAt": "2026-11-20T14:20:00Z"
    }
  ]
}

```

### **3.11 `POST /api/SupervisorForAd/audit-log`**

إضافة قيد في سجل التدقيق.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إضافة القيد إلى سجل التدقيق بنجاح"
}

```

### **3.12 `GET /api/SupervisorForAd/reports`**

تقارير أداء ومراجعة الإعلانات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "totalReviewed": 94,
    "approvalRate": "90.4%",
    "period": "last_30_days"
  }
}

```

## 4. وحدة `SupervisorForMerchant` (إشراف التجار)

### **4.1 `GET /api/supervisor/merchant/stats`**

إحصائيات التجار وحالات الحسابات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "totalMerchants": 120,
    "activeMerchants": 105,
    "suspendedMerchants": 5,
    "pendingReview": 10
  }
}

```

### **4.2 `GET /api/supervisor/merchant/merchants`**

قائمة التجار المسجلين.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 301,
      "name": "متجر الألق للتجارة",
      "status": "Active",
      "commissionRate": 5.0
    }
  ]
}

```

### **4.3 `GET /api/supervisor/merchant/merchants/{id}`**

تفاصيل تاجر محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 301,
    "name": "متجر الألق للتجارة",
    "email": "merchant@example.com",
    "phone": "+966500000301",
    "status": "Active",
    "commissionRate": 5.0
  }
}

```

### **4.4 `POST /api/supervisor/merchant/merchants/{id}/approve`**

اعتماد حساب التاجر وتفعيله.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم اعتماد حساب التاجر وتفعيله بنجاح"
}

```

### **4.5 `POST /api/supervisor/merchant/merchants/{id}/reject`**

رفض طلب التاجر.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم رفض طلب التاجر بنجاح"
}

```

### **4.6 `POST /api/supervisor/merchant/merchants/{id}/request-info`**

طلب استكمال بيانات أو وثائق من التاجر.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال طلب استكمال البيانات للتاجر"
}

```

### **4.7 `POST /api/supervisor/merchant/merchants/{id}/suspend`**

تعليق حساب التاجر مؤقتاً.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تعليق حساب التاجر مؤقتاً"
}

```

### **4.8 `POST /api/supervisor/merchant/merchants/{id}/reactivate`**

إعادة تفعيل حساب التاجر.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إعادة تفعيل حساب التاجر بنجاح"
}

```

### **4.9 `POST /api/supervisor/merchant/merchants/{id}/commission`**

ضبط أو تحديث نسبة العمولة للتاجر.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تحديث نسبة العمولة بنجاح",
  "data": {
    "merchantId": 301,
    "commissionRate": 6.5
  }
}

```

### **4.10 `GET /api/supervisor/merchant/merchants/{id}/products`**

جلب منتجات تاجر محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "productId": 701,
      "name": "منتج رقم 1",
      "price": 250.0,
      "isHidden": false
    }
  ]
}

```

### **4.11 `POST /api/supervisor/merchant/products/{productId}/hide`**

إخفاء منتج محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إخفاء المنتج بنجاح"
}

```

### **4.12 `POST /api/supervisor/merchant/products/{productId}/show`**

إظهار منتج محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إظهار المنتج بنجاح"
}

```

### **4.13 `GET /api/supervisor/merchant/merchants/{id}/orders`**

جلب طلبات تاجر محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "orderId": 901,
      "totalAmount": 1200.0,
      "status": "Completed",
      "createdAt": "2026-11-19T12:00:00Z"
    }
  ]
}

```

### **4.14 `GET /api/supervisor/merchant/withdrawals`**

جلب طلبات سحب مستحقات التجار.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 41,
      "merchantId": 301,
      "amount": 5000.0,
      "status": "Pending"
    }
  ]
}

```

### **4.15 `POST /api/supervisor/merchant/withdrawals/{id}/recommend`**

إرسال توصية إشرافية بشأن طلب سحب.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تسجيل التوصية الإشرافية على طلب السحب"
}

```

### **4.16 `GET /api/supervisor/merchant/events`**

سجل الأحداث والأنشطة الخاصة بالتجار.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 15,
      "title": "تحديث بيانات سجل تجاري",
      "createdAt": "2026-11-20T11:30:00Z"
    }
  ]
}

```

## 5. وحدة `SupervisorForSR` (إشراف الخدمات وطلباتها)

### **5.1 `GET /api/SupervisorForSR/audit-log`**

سجل التدقيق الخاص بقسم الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "action": "Approved Request",
      "createdAt": "2026-11-20T10:00:00Z"
    }
  ]
}

```

### **5.2 `GET /api/SupervisorForSR/profile-overview`**

ملخص ملف المشرف ومؤشراته.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "supervisorId": 8,
    "completedRequests": 64,
    "activeEscalations": 2
  }
}

```

### **5.3 `GET /api/SupervisorForSR/reports`**

تقارير قسم الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "totalRequests": 150,
    "completedRequests": 128,
    "averageResolutionTime": "2.4 ساعة"
  }
}

```

### **5.4 `GET /api/SupervisorForSR/pending`**

الطلبات المعلقة في قسم الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 501,
      "title": "طلب صيانة منزلية",
      "status": "Pending"
    }
  ]
}

```

### **5.5 `GET /api/SupervisorForSR/requests`**

كافة طلبات الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 501,
      "title": "طلب صيانة منزلية",
      "status": "InProgress"
    }
  ]
}

```

### **5.6 `GET /api/SupervisorForSR/stats`**

إحصائيات قسم الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "pending": 8,
    "approved": 110,
    "rejected": 6,
    "escalated": 3
  }
}

```

### **5.7 `POST /api/SupervisorForSR/approve/{id}`**

اعتماد طلب خدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم اعتماد طلب الخدمة بنجاح"
}

```

### **5.8 `POST /api/SupervisorForSR/reject/{id}`**

رفض طلب خدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم رفض طلب الخدمة بنجاح"
}

```

### **5.9 `GET /api/SupervisorForSR/details/{id}`**

تفاصيل طلب خدمة محدد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 501,
    "title": "طلب صيانة منزلية",
    "description": "تفاصيل الخدمة المطلوبة",
    "status": "Pending"
  }
}

```

### **5.10 `POST /api/SupervisorForSR/update-and-approve/{id}`**

تعديل بيانات الطلب واعتماده.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تعديل بيانات الطلب واعتماده بنجاح"
}

```

### **5.11 `GET /api/SupervisorForSR/providers-directory`**

دليل مزودي الخدمة المعتمدين.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "providerId": 21,
      "name": "مركز الصيانة المعتمد",
      "rating": 4.9,
      "isActive": true
    }
  ]
}

```

### **5.12 `POST /api/SupervisorForSR/reassign/{requestId}`**

إعادة إسناد الطلب لمزود خدمة آخر.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إعادة إسناد الطلب لمزود الخدمة الجديد بنجاح"
}

```

### **5.13 `GET /api/SupervisorForSR/complaint/stats`**

إحصائيات شكاوى الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "openComplaints": 4,
    "resolvedComplaints": 29
  }
}

```

### **5.14 `GET /api/SupervisorForSR/list`**

قائمة شكاوى/حالات الخدمات.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 801,
      "title": "تأخر وصول مزود الخدمة",
      "status": "Open"
    }
  ]
}

```

### **5.15 `POST /api/SupervisorForSR/escalate/{id}`**

تصعيد حالة أو شكوى.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تصعيد الحالة بنجاح"
}

```

### **5.16 `POST /api/SupervisorForSR/enforce-compensation/{id}`**

إلزام بتعويض مالي أو خدمي.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تطبيق قرار التعويض بنجاح"
}

```

### **5.17 `GET /api/SupervisorForSR/provider-professional-profile/{providerId}`**

الملف المهني لمزود الخدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "providerId": 21,
    "name": "مركز الصيانة المعتمد",
    "completedJobs": 210,
    "rating": 4.9
  }
}

```

### **5.18 `GET /api/SupervisorForSR/advanced-wallet`**

تفاصيل المحفظة المتقدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "balance": 14500.0,
    "availableBalance": 12000.0,
    "lockedBalance": 2500.0
  }
}

```

### **5.19 `POST /api/SupervisorForSR/advanced-wallet/withdraw`**

طلب سحب من المحفظة المتقدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تسجيل طلب السحب بنجاح",
  "data": {
    "withdrawnAmount": 2000.0,
    "remainingBalance": 10000.0
  }
}

```

### **5.20 `POST /api/SupervisorForSR/request-info/{id}`**

طلب معلومات إضافية على الطلب.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال طلب المعلومات الإضافية بنجاح"
}

```

### **5.21 `POST /api/SupervisorForSR/escalate-request/{id}`**

تصعيد طلب خدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تصعيد طلب الخدمة بنجاح"
}

```

### **5.22 `POST /api/SupervisorForSR/escalate-provider/{providerId}`**

تصعيد ملف مزود خدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تصعيد مزود الخدمة بنجاح"
}

```

### **5.23 `GET /api/SupervisorForSR/provider-escalations`**

قائمة تصعيدات مزودي الخدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "providerId": 21,
      "reason": "تكرار الشكاوى",
      "status": "InProgress"
    }
  ]
}

```

### **5.24 `POST /api/SupervisorForSR/close-provider-escalation/{providerId}`**

إغلاق تصعيد مزود الخدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إغلاق تصعيد مزود الخدمة بنجاح"
}

```

### **5.25 `POST /api/SupervisorForSR/return-request/{id}`**

إرجاع الطلب للمراجعة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرجاع الطلب بنجاح"
}

```

### **5.26 `POST /api/SupervisorForSR/provider-state/{providerId}`**

تحديث حالة مزود الخدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تحديث حالة مزود الخدمة بنجاح"
}

```

### **5.27 `POST /api/SupervisorForSR/suspend-request/{id}`**

تعليق طلب خدمة مؤقتاً.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تعليق طلب الخدمة مؤقتاً"
}

```

### **5.28 `GET /api/SupervisorForSR/subcategories/{requestId}`**

التصنيفات الفرعية المرتبطة بالطلب.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 11,
      "name": "تكييف وتبريد"
    }
  ]
}

```

### **5.29 `POST /api/SupervisorForSR/update-category/{id}`**

تحديث تصنيف الطلب.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تحديث تصنيف الطلب بنجاح"
}

```

### **5.30 `GET /api/SupervisorForSR/account-settings`**

إعدادات حساب المشرف.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "notificationsEnabled": true,
    "language": "ar"
  }
}

```

## 6. وحدة `SupervisorUsed` (إشراف المستعمل ووصلني)

### **6.1 `GET /api/SupervisorUsed/audit-log`**

سجل التدقيق لقسم المستعمل.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "action": "Approved Used Ad",
      "createdAt": "2026-11-20T09:30:00Z"
    }
  ]
}

```

### **6.2 `GET /api/SupervisorUsed/profile-overview`**

نظرة عامة على ملف المشرف.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "supervisorId": 9,
    "reviewedAdsCount": 115,
    "activeWosallyOrders": 14
  }
}

```

### **6.3 `GET /api/SupervisorUsed/reports`**

تقارير المنتجات المستعملة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "totalAds": 240,
    "approvedAds": 205,
    "penalizedAds": 7
  }
}

```

### **6.4 `GET /api/SupervisorUsed/stats`**

إحصائيات قسم المستعمل.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "pending": 11,
    "approved": 205,
    "suspended": 4
  }
}

```

### **6.5 `GET /api/SupervisorUsed`**

قائمة إعلانات المنتجات المستعملة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 601,
      "title": "لابتوب مستعمل بحالة ممتازة",
      "status": "Pending"
    }
  ]
}

```

### **6.6 `GET /api/SupervisorUsed/{id}`**

تفاصيل إعلان منتج مستعمل.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 601,
    "title": "لابتوب مستعمل بحالة ممتازة",
    "price": 1800.0,
    "status": "Pending"
  }
}

```

### **6.7 `POST /api/SupervisorUsed/{id}/approve`**

اعتماد إعلان منتج مستعمل.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم اعتماد إعلان المنتج المستعمل بنجاح"
}

```

### **6.8 `POST /api/SupervisorUsed/{id}/request-edit`**

طلب تعديل على الإعلان.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال طلب التعديل على الإعلان"
}

```

### **6.9 `POST /api/SupervisorUsed/{id}/suspend`**

تعليق الإعلان مؤقتاً.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تعليق الإعلان مؤقتاً"
}

```

### **6.10 `POST /api/SupervisorUsed/{id}/reject-with-penalty`**

رفض الإعلان مع تطبيق جزاء.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم رفض الإعلان وتطبيق الجزاء بنجاح"
}

```

### **6.11 `POST /api/SupervisorUsed/{id}/restore`**

استعادة إعلان مستعمل.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم استعادة الإعلان بنجاح"
}

```

### **6.12 `GET /api/SupervisorUsed/wosally-orders`**

قائمة طلبات خدمة وصلني.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 5510,
      "status": "InProgress",
      "amount": 3200.0
    }
  ]
}

```

### **6.13 `GET /api/SupervisorUsed/wosally-orders/{id}`**

تفاصيل طلب وصلني.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 5510,
    "buyerName": "أحمد علي",
    "sellerName": "محمود حسن",
    "status": "InProgress"
  }
}

```

### **6.14 `POST /api/SupervisorUsed/wosally-orders/{id}/send-joint-alert`**

إرسال تنبيه مشترك لأطراف الطلب.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال التنبيه المشترك لأطراف الطلب بنجاح"
}

```

### **6.15 `GET /api/SupervisorUsed/complaints`**

قائمة شكاوى المستعمل / وصلني.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 910,
      "subject": "اختلاف حالة المنتج عند الاستلام",
      "status": "Open"
    }
  ]
}

```

### **6.16 `POST /api/SupervisorUsed/complaints/{id}/follow-up`**

متابعة شكوى وإضافة إجراء.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تسجيل متابعة الشكوى بنجاح"
}

```

### **6.17 `POST /api/SupervisorUsed/complaints/{id}/escalate`**

تصعيد الشكوى للمستوى الأعلى.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تصعيد الشكوى بنجاح"
}

```

### **6.18 `GET /api/SupervisorUsed/complaints/{id}/details`**

تفاصيل الشكوى.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 910,
    "subject": "اختلاف حالة المنتج عند الاستلام",
    "description": "تفاصيل الشكوى والمرفقات",
    "status": "Open"
  }
}

```

### **6.19 `POST /api/SupervisorUsed/complaints/{id}/send-to-seller`**

توجيه الشكوى أو الاستفسار للبائع.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال الشكوى إلى البائع بنجاح"
}

```

### **6.20 `GET /api/SupervisorUsed/complaint-escalations`**

قائمة الشكاوى المصعدة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 910,
      "status": "InProgress"
    }
  ]
}

```

### **6.21 `POST /api/SupervisorUsed/complaints/{id}/resolve`**

حسم وإنهاء الشكوى.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم حسم الشكوى وإنهاؤها بنجاح"
}

```

### **6.22 `GET /api/SupervisorUsed/wallet`**

بيانات محفظة المشرف.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "balance": 9500.0
  }
}

```

### **6.23 `GET /api/SupervisorUsed/advanced-wallet`**

بيانات المحفظة المتقدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "balance": 9500.0,
    "availableBalance": 8000.0,
    "lockedBalance": 1500.0
  }
}

```

### **6.24 `POST /api/SupervisorUsed/advanced-wallet/withdraw`**

طلب سحب من المحفظة المتقدمة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تنفيذ طلب السحب بنجاح",
  "data": {
    "withdrawnAmount": 1500.0,
    "remainingBalance": 6500.0
  }
}

```

## 7. وحدة `BossOfSupervisor` (رئيس المشرفين)

### **7.1 `GET /api/BossOfSupervisor/dashboard-overview`**

المؤشرات العامة، المشرفين النشطين، تذاكر `BossOfSupervisors` غير المغلقة، وأداء الأقسام.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "pendingOrders": 12,
    "approvedToday": 28,
    "auditRate": "4.2 دقيقة",
    "activeSupervisors": 18,
    "bossOpenTickets": 5,
    "departmentsPerformance": {
      "merchants": "96%",
      "newAds": "92%",
      "usedAndWasalny": "89%",
      "servicesRequests": "85%"
    }
  }
}

```

### **7.2 `GET /api/BossOfSupervisor/supervisors`**

قائمة المشرفين وحالاتهم.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 7,
      "name": "سعد العتيبي",
      "supId": "SUP-7",
      "email": "saad@berwah.sa",
      "phone": "+966500000007",
      "status": "نشط ميدانياً",
      "rating": 4.8
    }
  ]
}

```

### **7.3 `GET /api/BossOfSupervisor/supervisors/{id}/profile`**

ملف مشرف ومؤشراته.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "id": 7,
    "name": "سعد العتيبي",
    "supId": "SUP-7",
    "metrics": {
      "completedAndApproved": 142,
      "pendingRequests": 4,
      "approvalNeeded": 7,
      "responseRate": "حسب الأداء الفعلي"
    }
  }
}

```

### **7.4 `POST /api/BossOfSupervisor/supervisors/add`**

إضافة حساب مشرف جديد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إضافة المشرف وتفعيل الصلاحيات فوراً"
}

```

### **7.5 `POST /api/BossOfSupervisor/supervisors/{id}/suspend`**

تعليق مشرف مؤقتاً.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تعليق المشرف مؤقتاً بنجاح وإشعار السجل الرقابي"
}

```

### **7.6 `POST /api/BossOfSupervisor/supervisors/{id}/delete-permanent`**

حذف/أرشفة حساب مشرف.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم رفع طلب الحذف للإدارة العليا وسحب التراخيص"
}

```

### **7.7 `PUT /api/BossOfSupervisor/supervisors/{id}/permissions`**

تحديث صلاحيات مشرف.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم حفظ وتحديث الصلاحيات فوراً"
}

```

### **7.8 `GET /api/BossOfSupervisor/orders-and-disputes`**

العمليات والطلبات مع دعم البحث.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "totalOperations": 20,
    "data": [
      {
        "id": 3042,
        "trackingNumber": "SRV-3042",
        "title": "صيانة مكيفات وتبريد",
        "category": "الخدمات",
        "status": "Pending",
        "createdAt": "2026-11-20T01:15:00Z"
      }
    ]
  }
}

```

### **7.9 `POST /api/BossOfSupervisor/requests/{id}/reevaluate`**

إعادة مراجعة قرار/طلب مع توجيه رقابي.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال أمر إعادة المراجعة للمشرف فوراً"
}

```

### **7.10 `POST /api/BossOfSupervisor/disputes/{id}/resolve`**

حسم نزاع.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم اعتماد قرار حسم النزاع وإنهاء البلاغ فوراً"
}

```

### **7.11 `GET /api/BossOfSupervisor/tickets`**

جلب تذاكر `TicketCategory.BossOfSupervisors` مع الفلترة حسب `TicketStatus` والبحث.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 104,
      "code": "CMP-SUP-104",
      "subject": "تعليق إعلان تجاري بدعوى مخالفة التسعير",
      "description": "تفاصيل التظلم المرفوع من التاجر...",
      "category": "BossOfSupervisors",
      "status": "Open",
      "complainant": "متجر الألق للسيارات والتجارة",
      "createdAt": "2026-11-20T00:10:00Z"
    }
  ]
}

```

### **7.12 `GET /api/BossOfSupervisor/merchant-complaints`**

جلب شكاوى التجار المرتبطة بـ `TicketCategory.BossOfSupervisors`.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": [
    {
      "id": 104,
      "code": "CMP-SUP-104",
      "subject": "تعليق إعلان تجاري بدعوى مخالفة التسعير",
      "description": "تفاصيل التظلم...",
      "category": "BossOfSupervisors",
      "status": "Open",
      "complainant": "متجر الألق للسيارات والتجارة",
      "createdAt": "2026-11-20T00:10:00Z"
    }
  ]
}

```

### **7.13 `POST /api/BossOfSupervisor/merchant-complaints/{id}/action`**

معالجة شكوى وإغلاقها (`TicketStatus.Closed`).

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تنفيذ الإجراء الإداري والرقابي بنجاح"
}

```

### **7.14 `GET /api/BossOfSupervisor/complaints/{complaintId}/details`**

تفاصيل التظلم والفحص الآلي وإفادة المشرف والأدلة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "complaintId": 104,
    "code": "CMP-SUP-104",
    "title": "تعليق إعلان تجاري بدعوى مخالفة التسعير",
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
      "statementText": "إفادة المشرف المسجلة بالواقعة",
      "recordedAt": "2026-11-19T14:18:00Z",
      "legalAssessment": "قيد التحقق الرقابي"
    },
    "evidences": [
      {
        "title": "لقطة شاشة ومستندات البلاغ",
        "subtitle": "مرفقات القضية والتدقيق",
        "previewUrl": "https://example.com/default-evidence.png"
      }
    ]
  }
}

```

### **7.15 `POST /api/BossOfSupervisor/complaints/{complaintId}/unban-and-investigate`**

فك حظر الإعلان وفتح تحقيق/تحديث التذكرة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تأكيد فك الحظر وبدء التحقيق الرقابي بنجاح"
}

```

### **7.16 `POST /api/BossOfSupervisor/complaints/{complaintId}/decision`**

تأييد المشرف أو التصعيد وتحديث حالة التذكرة.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم اعتماد القرار الرقابي بنجاح"
}

```

### **7.17 `GET /api/BossOfSupervisor/profile`**

الملف الشخصي لرئيس المشرفين والسجل الرقابي.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "userId": 12,
    "fullName": "م. عادل الشمري",
    "roleTitle": "رئيس هيئة المشرفين والرقابة الميدانية",
    "badgeCode": "SUP-HEAD-01",
    "email": "boss@berwah.sa",
    "phoneNumber": "+966500008821",
    "supervisionScope": "الرياض، الغربية، الشرقية، الشمالي (4 قطاعات)",
    "totalBalance": 45800.0,
    "availableForWithdrawal": 45800.0,
    "lockedBalance": 0.0,
    "complianceMetrics": {
      "approvedInterventions": 6,
      "governanceScore": "98.4%",
      "managedSupervisors": 18
    },
    "recentAuditLogs": [],
    "securitySettings": {
      "twoFactorEnabled": true,
      "activeSessionsCount": 1,
      "urgentAlertsEnabled": true
    }
  }
}

```

### **7.18 `GET /api/BossOfSupervisor/wallet`**

رصيد المحفظة وسجل الحركات المالية.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "data": {
    "totalBalance": 45800.0,
    "availableForWithdrawal": 45800.0,
    "lockedBalance": 0.0,
    "minimumWithdrawal": 500.0,
    "payoutMethods": ["bank", "instapay", "wallet"],
    "transactions": []
  }
}

```

### **7.19 `POST /api/BossOfSupervisor/wallet/payout`**

تنفيذ طلب صرف فوري وخصم الرصيد.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم تأكيد طلب السحب والتحويل الفوري بنجاح",
  "data": {
    "transactionId": 501,
    "withdrawnAmount": 1500.0,
    "remainingBalance": 44300.0,
    "payoutMethod": "bank",
    "executedAt": "2026-11-20T16:05:00Z"
  }
}

```

### **7.20 `POST /api/BossOfSupervisor/complaints/{complaintId}/summon-chat`**

استدعاء المشرف وبدء محادثة فورية وتحديث التذكرة إلى `InProgress`.

* **Response (`200 OK`):**

```
{
  "status": "success",
  "message": "تم إرسال الاستدعاء وبدء المحادثة الفورية الموثقة مع المشرف",
  "data": {
    "complaintId": 104,
    "code": "CMP-SUP-104",
    "summonTopic": "immediate_clarification",
    "initialMessage": "مطلوب توضيح فوري لسبب تعليق الإعلان.",
    "caseDocumentAttached": true,
    "chatSessionId": "CHAT-SUP-104-20261120160000",
    "startedAt": "2026-11-20T16:00:00Z"
  }
}

```

## 8. جدول رموز الاستجابة (`HTTP Status Codes`)

| الرمز | المعنى | الوصف | 
| ----- | ----- | ----- | 
| `200 OK` | نجاح العملية | تم تنفيذ الطلب أو إرجاع البيانات بنجاح. | 
| `400 Bad Request` | خطأ في المدخلات (`status: "fail"`) | بيانات غير مكتملة، مبلغ سحب أقل من الحد الأدنى، أو رصيد غير كافٍ. | 
| `401 Unauthorized` | غير مصرح | التوكن مفقود أو منتهي الصلاحية. | 
| `403 Forbidden` | مرفوض | الحساب لا يملك الصلاحية المطلوبة (`BossOfSupervisor` / `Admin`). | 
| `404 Not Found` | غير موجود (`status: "fail"`) | المعرّف المطلوب غير موجود أو لا يطابق التصنيف المحدد. | 
