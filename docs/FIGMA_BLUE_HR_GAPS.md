# مراجعة توافق التطبيق مع Figma — Blue HR

> **تصميم Figma:** [Blue-Hr](https://www.figma.com/design/UA0SAA5w7BA96DaS6sCr41/Blue-Hr?node-id=0-1)  
> **fileKey:** `UA0SAA5w7BA96DaS6sCr41`  
> **تاريخ المراجعة:** 2026-06-06 (مراجعة جديدة كاملة)  
> **نطاق المراجعة:** الشاشات النشطة في `lib/features/` فقط  
> **مستثنى:** `lib/screens/` (legacy — غير مستخدم، الملفات محفوظة دون حذف)

---

## منهجية المراجعة

| المصدر | الحالة |
|--------|--------|
| Figma MCP (`get_design_context` / `get_metadata`) | ❌ غير متاح — حد خطة Starter |
| تدقيق كود `lib/features/` | ✅ كامل — layout، ألوان، typography، routes |
| عقد Figma المعروفة سابقاً | Login `3-104` · Register Face `14-61` |

> **تقييم التوافق:** لكل شاشة — ✅ متوافق جزئياً · ⚠️ فجوات تصميم · ❌ غير متوافق / مفقود · 🔴 خلل وظيفي في الكود

---

## النتيجة الإجمالية

| الشاشة | التوافق التقريبي | أهم فجوة |
|--------|------------------|----------|
| تسجيل الدخول | ⚠️ ~65% | لا شعار، لا إخفاء كلمة مرور |
| تسجيل الوجه | ⚠️ ~70% | لا AppBar، placeholder بسيط |
| الرئيسية | ⚠️ ~55% | بيانات وهمية، لا bottom nav |
| الحضور | ⚠️ ~60% | mock في تفاصيل الأسبوع |
| الإجازات | ❌ ~40% | شاشة طلب إجازة معطّلة + route مكسور |
| الرواتب | ✅ ~75% | بيانات حقيقية، تفاصيل بسيطة |
| الملف الشخصي | ⚠️ ~65% | أيقونة خروج خاطئة، لا صورة موظف |
| الإشعارات | ⚠️ ~70% | fallback تاريخ hardcoded |

**تقدير عام:** التطبيق يتبع **نظام تصميم داخلي متسق** لكنه **ليس pixel-perfect** مع Blue-Hr Figma.

---

## نظام التصميم المُنفَّذ (Baseline الكود)

### إعدادات عامة
- **ScreenUtil:** `375 × 812`
- **الخط:** `NotoSansArabic`
- **Padding افتراضي:** `20` (`CustomScreen`)
- **خلفية الشاشة:** `#FFFFFF`

### ألوان `AppColors` — تضارب محتمل مع Figma

| Token | Hex | الاستخدام |
|-------|-----|-----------|
| `appPrimaryColor` | `#22004C` | عناوين، AppBar، payslip |
| `app670379Sedondary2` | `#670379` | أزرار، هيدر Profile |
| `primary` (Theme) | `#6B46C1` | Material theme فقط |
| `appFAFAFABackGround2` | `#FAFAFA` | حقول، بطاقات |
| `appE5E5E5Border` | `#E5E5E5` | حدود |
| `app1A1A1AText1` | `#1A1A1A` | نص أساسي |
| `appA0A0A0Text2` | `#A0A0A0` | نص ثانوي |

**فجوة Figma:** ثلاث درجات بنفسجي بدل لون primary واحد من التصميم.

### Typography

| العنصر | القيمة |
|--------|--------|
| عنوان شاشة | `16.w` / `w700` |
| وصف | `13.w` / `w500` |
| زر | `18.sp` / `w600` |
| AppBar | `17.w` / `w700` |
| CustomText افتراضي | `16` / `w500` |

**فجوة Figma:** لا ربط بـ Text Styles من Figma — كل القيم hardcoded.

### Border Radius

| القيمة | أين |
|--------|-----|
| `5` | فلاتر إشعارات، mini-cards حضور |
| `8` | تفاصيل إجازة |
| `10` | أزرار، حقول، بطاقات رئيسية |
| `12` | بطاقات إحصاء حضور، dropdown menu |

**فجوة Figma:** عدم اتساق `5` / `10` / `12`.

### مكونات مشتركة

| المكوّن | المواصفات |
|---------|-----------|
| `CustomButton` | عرض كامل، `48.h`، `#670379`، radius `10` |
| `CustomTextField` | fill `#FAFAFA`، radius `10`، **بدون obscureText** |
| `CustomAppBar` | أبيض، home + notification، عنوان `#22004C` |
| `CustomDropDown` | `55.h`، حد `Colors.grey` ⚠️ (ليس `#E5E5E5`) |

### أصول بصرية (`app_image.dart`)
- أيقونات SVG (حضور، إجازة، راتب، شخص، شمس، قمر، إشعار…)
- ❌ **لا يوجد شعار Blue HR**

---

## مصفوفة المسارات (Routes)

| المسار | الشاشة | مسجّل؟ | يُفتح من UI؟ |
|--------|--------|--------|-------------|
| `/login` | LoginScreen | ✅ | ✅ (initial) |
| `/register-face` | RegisterFaceScreen | ✅ | ✅ بعد الدخول |
| `/home` | HomeScreen | ✅ | ✅ |
| `/notifications` | NotificationScreen | ✅ | ✅ |
| `/attendance` | AttendanceScreen | ✅ | ✅ |
| `/holidays` | HolidaysScreen | ✅ | ✅ |
| `/payslips` | PayslipScreen | ✅ | ✅ |
| `/profile` | ProfileScreen | ✅ | ✅ |
| `/requestHoliday` | RequestHolidayScreen | ❌ **معطّل** | 🔴 FAB يستدعيه لكن **لا GetPage** |

---

## مراجعة شاشة بشاشة

---

### 1. تسجيل الدخول — Figma `3-104`
**الملف:** `lib/features/auth/presentation/pages/login_screen.dart`

#### المُنفَّذ
```
CustomScreen (pad 20)
└─ Column
   ├─ زر لغة (40×40, #FAFAFA, r10)
   ├─ 80px فراغ
   ├─ عنوان + وصف (l10n)
   ├─ حقل email + password (label أعلى)
   ├─ زر دخول (#670379)
   └─ زر بصمة (إن مُفعّل)
```

#### ✅ متوافق محتمل مع Figma
- خلفية بيضاء، padding موحّد
- حقول بخلفية `#FAFAFA` وحد `#E5E5E5`
- زر رئيسي بنفسجي بعرض كامل
- زر تغيير اللغة أعلى اليمين
- كل النصوص من l10n

#### ❌ غير متوافق / مفقود
| البند | التفاصيل |
|-------|----------|
| شعار Blue HR | لا asset ولا widget |
| Hero / illustration | يبدأ النموذج مباشرة بعد فراغ 80 |
| إخفاء كلمة المرور | `CustomTextField` بدون `obscureText` |
| أيقونات الحقول | لا prefix (بريد / قفل) |
| نسيت كلمة المرور | غير موجود |
| AppBar | غير موجود |

#### ⚠️ قد يكون خارج Figma
- زر تسجيل الدخول بالبصمة (`loginWithBiometric`)

---

### 2. تسجيل الوجه — Figma `14-61`
**الملف:** `lib/features/auth/presentation/pages/register_face_screen.dart`

#### المُنفَّذ
- عنوان + وصف مركزيان
- دائرة معاينة `200×200`
- زر «التقاط صورة» + زر «حفظ ومتابعة»
- placeholder: `default_profile.svg`

#### ✅ متوافق محتمل
- تدفق: عنوان → معاينة → التقاط → متابعة
- ألوان وأزرار متسقة مع Login

#### ❌ / ⚠️ فجوات
| البند | الحالة |
|-------|--------|
| AppBar / رجوع | ❌ مفقود |
| إطار كاميرا / دليل محاذاة الوجه | ⚠️ placeholder SVG فقط |
| تعليمات (إضاءة، وضع الوجه) | ❌ |
| زر معطّل قبل التقاط | ⚠️ alpha 0.45 — تحقق من Figma |

---

### 3. الرئيسية — `home_screen.dart`
**الملف:** `lib/features/home/presentation/pages/home_screen.dart`

#### المُنفَّذ
```
SafeArea → Column
├─ GreetingWidget (ترحيب + اسم + أيقونة إشعار)
├─ AttendanceWidget (تاريخ، موقع، وقت، check-in/out)
├─ شبكة 2×2 (حضور | إجازات | راتب | ملف شخصي)
└─ قسم «آخر الإشعارات»
```

#### ✅ متوافق محتمل
- بطاقة حضور علوية
- 4 اختصارات للميزات الرئيسية
- ألوان بطاقات `#FAFAFA` / `#E1CDE4`

#### ❌ فجوات تصميم
| البند | التفاصيل |
|-------|----------|
| Bottom Navigation | ❌ التنقل عبر بطاقات فقط |
| شعار / هوية | ❌ |
| إشعارات حقيقية | ❌ mock hardcoded |

#### 🔴 أخطاء كود (تؤثر على التصميم)
```dart
// home_screen.dart:106-107
title: 'تم الموافقة على طلب الإجازة'  // hardcoded — ليس l10n ولا API
date: 'منذ يومين'
itemCount: 1  // يتجاهل controller.lastNotivication
```

#### ⚠️ widgets غير مستخدمة
- `home_appbar_widget.dart` — معلّق بالكامل
- `quick_state_widget` / `time_box_widget` — مستوردة لكن UI معلّق

---

### 4. الحضور — `attendance_screen.dart`

#### المُنفَّذ
- AppBar + فلتر تاريخ
- صف 4 بطاقات إحصاء (`64.h`, radius `12`)
- قائمة أسابيع قابلة للتوسيع (`WeakInfoWidget`)

#### ✅ متوافق محتمل
- هيكل: فلتر → إحصائيات → تفاصيل أسابيع
- ألوان حالات (تأخير، غياب، إجازة، مغادرة مبكرة)

#### 🔴 mock data
```dart
// weak_info_widget.dart:73
value: '3 أيام (اجازه مرضية)'  // hardcoded + خطأ إملائي
List.generate(2, ...)  // صفين وهميين عند التوسيع
```

#### ⚠️ فجوات Figma
- لا رابط لتقرير حضور من UI النشط
- لا قائمة أيام تفصيلية للأسبوع المحدد
- widgets قديمة في نفس المجلد (`today_record_widget`…) بألوان `#667eea` — **غير مستخدمة**

---

### 5. الإجازات — `holidays_screen.dart`

#### المُنفَّذ
- فلتر نوع + تاريخ بداية
- شريط فلاتر حالة (الكل، موافق، معلّق…)
- قائمة تفاصيل الإجازة
- FAB «طلب إجازة»

#### 🔴 خلل حرج
| المشكلة | التفاصيل |
|---------|----------|
| Route مكسور | `AppRoutes.requestHoliday` **معطّل** في `app_route.dart:117` |
| شاشة طلب إجازة | `request_holiday_screen.dart` **معلّق بالكامل** |
| FAB | يستدعي `Get.toNamed('/requestHoliday')` → **لا شاشة** |

#### 🔴 mock / bugs
```dart
itemList: ['1', '2', '3']  // dropdown نوع الإجازة
itemCount: 1  // يتجاهل controller.leaves.length
```

#### ❌ فجوات Figma
- شاشة طلب إجازة كاملة (نوع، تواريخ، سبب، إرسال)
- رصيد الإجازات
- فلتر تاريخ نهاية

---

### 6. الرواتب — `payslip_screen.dart`

#### المُنفَّذ
- فلتر تاريخ
- بطاقة راتب `130.h` + `salary_card.svg`
- 3 صفوف: بدلات / خصومات / صافي
- FAB تحميل

#### ✅ الأقرب للتصميم
- بيانات من API (`PayslipController`) — **ليس mock**
- ألوان صفوف منطقية (أخضر صافي، أحمر خصومات)

#### ⚠️ فجوات Figma
- لا تفاصيل بنود الراتب (line items)
- لا قائمة كشوف سابقة
- لا تنسيق عملة واضح

---

### 7. الملف الشخصي — `profile_screen.dart`

#### المُنفَّذ
- هيدر بنفسجي `#670379` (ليس AppBar أبيض)
- صورة دائرية `100×100` + sheet أبيض
- بطاقتا معلومات (مدير، قسم، فرع / هاتف، بريد)
- صف لغة + صف خروج

#### ✅ متوافق محتمل
- تخطيط avatar فوق sheet
- بطاقات معلومات `#FAFAFA`

#### ❌ فجوات
| البند | التفاصيل |
|-------|----------|
| صورة الموظف | `defaultProfile` دائماً — لا `image` من API |
| أيقونة الخروج | ❌ نفس `AppImage.changeLang` |
| نصوص اللغة | `'اللغه العربية'` hardcoded (خطأ: اللغة) |
| `change_japanese_widget` | موجود غير مدمج |

---

### 8. الإشعارات — `notification_screen.dart`

#### المُنفَّذ
- AppBar بدون أيقونة إشعار
- 3 فلاتر (الكل / مقروء / غير مقروء)
- قائمة بطاقات أو empty state

#### ✅ متوافق محتمل
- فلاتر بحالة
- بطاقة: أيقونة + عنوان + تاريخ
- empty state مع illustration

#### ⚠️ فجوات
```dart
date: ... ?? 'منذ يومين'  // hardcoded fallback
```
- لا badge غير مقروء على أيقونة Home
- لا شاشة تفاصيل إشعار
- radius فلاتر `5` vs `10` في بقية التطبيق

---

## ميزات في الكود قد لا تكون في Figma

| الميزة | الملف |
|--------|-------|
| تسجيل دخول بالبصمة | `login_screen.dart`, `biometric_auth_service.dart` |
| تسجيل الوجه بعد الدخول | `register_face_screen.dart` |
| خيار ياباني (غير مفعّل) | `change_japanese_widget.dart` |

---

## نصوص Hardcoded (يجب نقلها لـ l10n)

| الملف | السطر | النص |
|-------|-------|------|
| `home_screen.dart` | 106 | `تم الموافقة على طلب الإجازة` |
| `home_screen.dart` | 107 | `منذ يومين` |
| `weak_info_widget.dart` | 73 | `3 أيام (اجازه مرضية)` |
| `notification_screen.dart` | ~70 | `منذ يومين` |
| `change_lang_widget.dart` | 63 | `اللغه العربية` / `English` |
| `holidays_screen.dart` | 46 | `['1','2','3']` |

---

## أولويات الإصلاح

### 🔴 حرجة (وظيفية + تصميم)
1. تفعيل route `/requestHoliday` + إلغاء تعليق `request_holiday_screen.dart`
2. إصلاح `itemCount: 1` في Home و Holidays
3. استبدال النصوص الوهمية ببيانات API + l10n

### 🟠 عالية (فجوات Figma واضحة)
4. إضافة شعار Blue HR لشاشة الدخول
5. `obscureText` + أيقونة عين لكلمة المرور
6. إصلاح أيقونة تسجيل الخروج في Profile
7. عرض صورة الموظف من API

### 🟡 متوسطة
8. توحيد لون Primary واحد حسب Figma tokens
9. توحيد border radius (`10` موحّد أو حسب التصميم)
10. إصلاح `CustomDropDown` border → `#E5E5E5`
11. نقل نصوص `change_lang_widget` إلى arb

### 🟢 منخفضة
12. Bottom Nav vs بطاقات Home — قرار تصميم
13. ربط Text Styles بـ Figma variables
14. تفاصيل payslip (line items)

---

## عقد Figma للمراجعة اليدوية

عند توفر وصول Figma MCP، قارن هذه العقد أولاً:

| الشاشة | node-id | ملف الكود |
|--------|---------|-----------|
| تسجيل الدخول | `3-104` | `login_screen.dart` |
| تسجيل الوجه | `14-61` | `register_face_screen.dart` |
| بقية الشاشات | **غير موثّقة** | أضف node-id من Figma |

---

## مسارات الملفات المرجعية

```
lib/features/auth/presentation/pages/login_screen.dart
lib/features/auth/presentation/pages/register_face_screen.dart
lib/features/home/presentation/pages/home_screen.dart
lib/features/attendance/presentation/pages/attendance_screen.dart
lib/features/holidays/presentation/pages/holidays_screen.dart
lib/features/holidays/presentation/pages/request_holiday_screen.dart  ← معلّق
lib/features/payslip/presentaion/pages/payslip_screen.dart
lib/features/profile/presentation/pages/profile_screen.dart
lib/features/notification/presentation/pages/notification_screen.dart
lib/app/app_route.dart
lib/theme/app_theme.dart
lib/app/app_image.dart
```

---

## كيفية تحديث هذا الملف

1. افتح [Figma Blue-Hr](https://www.figma.com/design/UA0SAA5w7BA96DaS6sCr41/Blue-Hr?node-id=0-1).
2. لكل شاشة: أضف `node-id` + لقطة شاشة + نسبة التوافق المحدّثة.
3. عند إصلاح بند: ضع ✅ بجانبه.
4. أعد تشغيل Figma MCP عند ترقية الخطة لمقارنة pixel-perfect.

---

*آخر تحديث: مراجعة كود كاملة — Figma MCP غير متاح في هذه الجلسة.*
