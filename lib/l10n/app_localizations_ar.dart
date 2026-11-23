// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navProspects => 'العملاء المحتملون';

  @override
  String get navPipeline => 'مسار المبيعات';

  @override
  String get navActivities => 'الأنشطة';

  @override
  String get navFollowUps => 'المتابعات';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navSalesStages => 'مراحل البيع';

  @override
  String get navLossReasons => 'أسباب الخسارة';

  @override
  String get navServerDisplay => 'الخادم والعرض';

  @override
  String get navSettingsSection => 'الإعدادات';

  @override
  String get themeLight => 'الوضع الفاتح';

  @override
  String get themeDark => 'الوضع الداكن';

  @override
  String get globalSearchHint =>
      'ابحث عن عميل محتمل (الاسم، الشركة، الهاتف…) ثم اضغط Enter';

  @override
  String get connOnline => 'متصل';

  @override
  String get connOffline => 'غير متصل';

  @override
  String get connChecking => 'جارٍ التحقق…';

  @override
  String get connUnknown => 'غير معروف';

  @override
  String connServer(Object url) {
    return 'الخادم: $url';
  }

  @override
  String connLastCheck(Object time) {
    return '\nآخر تحقق: $time';
  }

  @override
  String get connClickToCheck => '\nانقر للتحقق الآن.';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionSaving => 'جارٍ الحفظ…';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDeactivate => 'تعطيل';

  @override
  String get actionReactivate => 'إعادة التفعيل';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionReset => 'إعادة تعيين';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionSchedule => 'جدولة';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionMoveUp => 'تحريك لأعلى';

  @override
  String get actionMoveDown => 'تحريك لأسفل';

  @override
  String get actionOpenRecord => 'فتح البطاقة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get loadingRecord => 'جارٍ تحميل البطاقة…';

  @override
  String get loadingStages => 'جارٍ تحميل المراحل…';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get serverUnreachable => 'تعذّر الوصول إلى الخادم';

  @override
  String get serverSettings => 'إعدادات الخادم';

  @override
  String get errorUnknown => 'خطأ غير معروف.';

  @override
  String get noItems => 'لا توجد عناصر';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get searchHint => 'بحث…';

  @override
  String get filterAll => 'الكل';

  @override
  String get clearPeriod => 'مسح الفترة';

  @override
  String get period => 'الفترة';

  @override
  String get perPage => 'لكل صفحة';

  @override
  String get pageFirst => 'الصفحة الأولى';

  @override
  String get pagePrevious => 'الصفحة السابقة';

  @override
  String get pageNext => 'الصفحة التالية';

  @override
  String get pageLast => 'الصفحة الأخيرة';

  @override
  String pageOf(Object page, Object pages) {
    return 'الصفحة $page / $pages';
  }

  @override
  String rangeOfTotal(Object from, Object to, Object total) {
    return '$from–$to من $total';
  }

  @override
  String showMoreCount(Object count) {
    return 'عرض المزيد ($count)';
  }

  @override
  String get color => 'اللون';

  @override
  String get colDate => 'التاريخ';

  @override
  String get colStatus => 'الحالة';

  @override
  String get colActions => 'إجراءات';

  @override
  String get fieldDescription => 'الوصف';

  @override
  String get fieldDescriptionRequired => 'الوصف *';

  @override
  String get fieldOutcome => 'النتيجة';

  @override
  String get fieldDateTimeRequired => 'التاريخ والوقت *';

  @override
  String get fieldNameRequired => 'الاسم *';

  @override
  String get fieldLabelRequired => 'التسمية *';

  @override
  String get fieldTypeRequired => 'النوع *';

  @override
  String get fieldType => 'النوع';

  @override
  String get fieldNotes => 'ملاحظات';

  @override
  String get fieldAddress => 'العنوان';

  @override
  String get fieldCity => 'المدينة';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldContact => 'جهة الاتصال';

  @override
  String get colContactDetails => 'بيانات الاتصال';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusActiveFem => 'نشطة';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get statusInactiveFem => 'غير نشطة';

  @override
  String get optionOther => 'أخرى';

  @override
  String get validThisField => 'هذا الحقل';

  @override
  String validRequired(Object field) {
    return '$field مطلوب.';
  }

  @override
  String validMaxLength(Object max) {
    return '$max حرفًا كحد أقصى.';
  }

  @override
  String get validEmailInvalid => 'عنوان بريد إلكتروني غير صالح.';

  @override
  String get validPhoneChars =>
      'يجب أن يحتوي الرقم على أرقام ومسافات و + و - و . و () فقط.';

  @override
  String get validPhoneLength => 'يجب أن يحتوي الرقم على 6 إلى 20 رقمًا.';

  @override
  String get validColorInvalid => 'لون غير صالح (الصيغة #RRGGBB).';

  @override
  String get validServerRequired => 'عنوان الخادم مطلوب.';

  @override
  String get validServerInvalid =>
      'عنوان غير صالح. مثال: http://192.168.1.100:8000/api/v1';

  @override
  String get validServerScheme => 'يجب أن يبدأ العنوان بـ http:// أو https://';

  @override
  String get validFieldDescription => 'الوصف';

  @override
  String get validFieldName => 'الاسم';

  @override
  String get validFieldLabel => 'التسمية';

  @override
  String get validFieldCompany => 'اسم الشركة / العميل';

  @override
  String get validFixFields => 'يرجى تصحيح الحقول المحددة.';

  @override
  String get validSelectProspect => 'اختر عميلًا محتملًا.';

  @override
  String get validSelectStage => 'اختر مرحلة.';

  @override
  String get validDateRequired => 'التاريخ مطلوب.';

  @override
  String get validFollowUpFuture => 'يجب أن يكون تاريخ المتابعة في المستقبل.';

  @override
  String get validDateNotFuture => 'لا يمكن أن يكون التاريخ في المستقبل.';

  @override
  String get validNextFollowUpFuture =>
      'يجب أن تكون المتابعة التالية في المستقبل.';

  @override
  String get validNextFollowUpAfterActivity =>
      'يجب أن تكون المتابعة التالية بعد النشاط.';

  @override
  String get validActivityNotFuture =>
      'لا يمكن أن يكون النشاط في المستقبل: قم بجدولة متابعة بدلًا من ذلك.';

  @override
  String get validInitialStageRequired => 'المرحلة الأولية مطلوبة.';

  @override
  String get validStageDisabled => 'هذه المرحلة معطّلة.';

  @override
  String get validAlreadyInStage =>
      'العميل المحتمل موجود بالفعل في هذه المرحلة.';

  @override
  String get validLossReasonRequiredForLost =>
      'سبب الخسارة مطلوب للمرحلة «خسارة».';

  @override
  String get validLossReasonRequired => 'سبب الخسارة مطلوب.';

  @override
  String get validReasonNeedsDetails => 'يتطلب هذا السبب توضيحًا.';

  @override
  String get validDetailsRequired => 'التوضيح مطلوب لهذا السبب.';

  @override
  String get typeAtLeastTwo => 'اكتب حرفين على الأقل…';

  @override
  String errTimeout(Object server) {
    return 'لم يستجب الخادم ($server) في الوقت المحدد. تحقق من الشبكة ثم أعد المحاولة.';
  }

  @override
  String errConnection(Object server) {
    return 'تعذّر الوصول إلى الخادم ($server). تأكد من تشغيل الحاسوب المركزي، ومن اتصالك بشبكة الشركة، ومن صحة عنوان الخادم.';
  }

  @override
  String errConnectionShort(Object server) {
    return 'تعذّر الوصول إلى الخادم ($server). تحقق من الشبكة ومن عنوان الخادم.';
  }

  @override
  String errCertificate(Object server) {
    return 'تم رفض شهادة الخادم ($server).';
  }

  @override
  String get errCancelled => 'تم إلغاء الطلب.';

  @override
  String errReceiveTimeout(Object server) {
    return 'تعذّرت قراءة استجابة الخادم ($server) في الوقت المناسب.';
  }

  @override
  String errCommunication(Object details) {
    return 'خطأ في التواصل مع الخادم: $details';
  }

  @override
  String get errBadRequest => 'طلب غير صالح.';

  @override
  String get errNotFound => 'العنصر غير موجود على الخادم.';

  @override
  String get errNotSupported => 'العملية غير مدعومة من الخادم.';

  @override
  String get errConflict => 'تم رفض العملية: تعارض مع البيانات الحالية.';

  @override
  String get errValidation => 'بعض البيانات غير صالحة.';

  @override
  String errServer(Object status) {
    return 'خطأ داخلي في الخادم ($status). أعد المحاولة أو اتصل بالمسؤول.';
  }

  @override
  String errUnexpectedStatus(Object status) {
    return 'استجابة غير متوقعة من الخادم ($status).';
  }

  @override
  String errUnexpectedResponse(Object details) {
    return 'استجابة غير متوقعة من الخادم: $details';
  }

  @override
  String errUnexpected(Object details) {
    return 'خطأ غير متوقع: $details';
  }

  @override
  String get errExpectedObject =>
      'استجابة غير متوقعة من الخادم: كان متوقعًا كائن JSON.';

  @override
  String get errExpectedList =>
      'استجابة غير متوقعة من الخادم: كانت متوقعة قائمة JSON.';

  @override
  String get errExpectedPaged =>
      'استجابة غير متوقعة من الخادم: كانت متوقعة قائمة مقسّمة إلى صفحات.';

  @override
  String get errMissingProspect =>
      'استجابة غير متوقعة من الخادم: العميل المحتمل المحدَّث مفقود.';

  @override
  String get errBusy => 'العملية قيد التنفيذ بالفعل.';

  @override
  String relToday(Object time) {
    return 'اليوم $time';
  }

  @override
  String relTomorrow(Object time) {
    return 'غدًا $time';
  }

  @override
  String relYesterday(Object time) {
    return 'أمس $time';
  }

  @override
  String relInDays(Object days) {
    return 'بعد $days يوم';
  }

  @override
  String relDaysAgo(Object days) {
    return 'منذ $days يوم';
  }

  @override
  String get dashSubtitle => 'نظرة عامة على النشاط التجاري';

  @override
  String dashUpdatedAt(Object time) {
    return 'آخر تحديث $time';
  }

  @override
  String dashStale(Object error) {
    return 'قد تكون الأرقام قديمة: $error';
  }

  @override
  String get dashTodayActions => 'متابعات ومهام اليوم';

  @override
  String get dashAllCaughtUp => '🎉 كل مهام اليوم منجزة!';

  @override
  String dashOverdueCount(Object count) {
    return '$count متأخرة';
  }

  @override
  String get dashMarkDone => 'تحديد كمنجزة';

  @override
  String get dashNewLead => 'مهتم جديد';

  @override
  String get dashNewTicket => 'تذكرة دعم';

  @override
  String get dashNewMeeting => 'موعد جديد';

  @override
  String dashNewThisMonthCount(Object count) {
    return '$count جدد هذا الشهر';
  }

  @override
  String dashWelcome(Object name) {
    return 'مرحبًا، $name 👋';
  }

  @override
  String dashSummaryLine(Object appointments, Object urgent, Object leads) {
    return '$appointments مواعيد اليوم · $urgent تذاكر عاجلة · $leads مهتم نشط';
  }

  @override
  String get dashActiveClients => 'العملاء والتراخيص';

  @override
  String dashMaintenanceActive(Object count) {
    return '$count صيانة نشطة';
  }

  @override
  String dashMaintenanceExpiring(Object count) {
    return '$count تنتهي قريبًا';
  }

  @override
  String get dashPipelineDeals => 'مسار المبيعات والصفقات';

  @override
  String get dashOpenSupport => 'تذاكر الدعم المفتوحة';

  @override
  String dashUrgentAlert(Object count) {
    return '$count عاجلة';
  }

  @override
  String get dashAllClear => 'لا توجد تذاكر عاجلة';

  @override
  String get dashAppointmentsToday => 'مواعيد اليوم';

  @override
  String dashPendingRequests(Object count) {
    return '$count طلبات بوابة معلقة';
  }

  @override
  String get dashThisMonth => 'هذا الشهر';

  @override
  String get dashNewThisMonth => 'مهتمون جدد';

  @override
  String get dashNetConversion => 'نسبة التحويل الصافية';

  @override
  String get dashTodayHub => 'متابعات اليوم';

  @override
  String get dashTodayHubSubtitle => 'انقر لفتح القائمة';

  @override
  String dashActiveTrials(Object count) {
    return '$count تجربة نشطة';
  }

  @override
  String get stageTypeOpen => 'جارٍ';

  @override
  String get dashWon => 'مكسوبة';

  @override
  String get dashLost => 'خاسرة';

  @override
  String dashWinRate(Object rate) {
    return 'نسبة النجاح: $rate %';
  }

  @override
  String get dashFollowUpsToday => 'متابعات اليوم';

  @override
  String get dashFollowUpsOverdue => 'متابعات متأخرة';

  @override
  String get dashFollowUpsUpcoming => 'متابعات قادمة';

  @override
  String dashFollowUpsUpcomingDays(Object days) {
    return 'متابعات قادمة ($days يوم)';
  }

  @override
  String get dashProspectsByStage => 'العملاء المحتملون حسب المرحلة';

  @override
  String get dashClickStage => 'انقر على مرحلة لعرض عملائها المحتملين';

  @override
  String get noStages => 'لا توجد مراحل';

  @override
  String get dashOutcomes => 'نتائج الفرص';

  @override
  String get dashRecentActivities => 'الأنشطة الأخيرة';

  @override
  String get noRecentActivities => 'لا توجد أنشطة حديثة';

  @override
  String get dashWhyLose => 'لماذا نخسر المبيعات؟';

  @override
  String get dashLostByReason => 'العملاء الخاسرون حسب السبب';

  @override
  String get noLostProspects => 'لا يوجد عملاء خاسرون';

  @override
  String get prospectsSubtitle => 'إدارة العملاء المحتملين والفرص';

  @override
  String get newProspect => 'عميل محتمل جديد';

  @override
  String get editProspect => 'تعديل العميل المحتمل';

  @override
  String get createProspect => 'إنشاء العميل المحتمل';

  @override
  String get addProspect => 'إضافة عميل محتمل';

  @override
  String get noProspectMatchesFilters =>
      'لا يوجد عميل محتمل يطابق عوامل التصفية';

  @override
  String get noProspectsYet => 'لا يوجد عملاء محتملون حتى الآن';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get prospectSearchHint => 'الاسم، الشركة، الهاتف، المعرّف…';

  @override
  String get fieldStage => 'المرحلة';

  @override
  String stageInactiveSuffix(Object name) {
    return '$name (غير نشطة)';
  }

  @override
  String get allStages => 'كل المراحل';

  @override
  String get fieldProduct => 'المنتج';

  @override
  String get allProducts => 'كل المنتجات';

  @override
  String get fieldLossReason => 'سبب الخسارة';

  @override
  String get allReasons => 'كل الأسباب';

  @override
  String get filterCreatedDate => 'تاريخ الإنشاء';

  @override
  String filtersUnavailable(Object error) {
    return 'قوائم التصفية غير متاحة: $error\nانقر لإعادة المحاولة.';
  }

  @override
  String prospectCreated(Object name) {
    return 'تم إنشاء العميل المحتمل «$name».';
  }

  @override
  String get prospectUpdated => 'تم تحديث العميل المحتمل.';

  @override
  String prospectMovedTo(Object name, Object stage) {
    return 'انتقل «$name» إلى المرحلة «$stage».';
  }

  @override
  String get colCompanyContact => 'الشركة / جهة الاتصال';

  @override
  String get colLastActivity => 'آخر نشاط';

  @override
  String get colNextFollowUp => 'المتابعة التالية';

  @override
  String get colCreatedOn => 'تاريخ الإنشاء';

  @override
  String get changeStage => 'تغيير المرحلة';

  @override
  String get scheduleFollowUp => 'جدولة متابعة';

  @override
  String get addActivity => 'إضافة نشاط';

  @override
  String get sectionIdentity => 'الهوية';

  @override
  String get fieldCompanyRequired => 'الشركة / العميل *';

  @override
  String get fieldCompany => 'الشركة / العميل';

  @override
  String get fieldContactPerson => 'الشخص المسؤول';

  @override
  String get sectionSalesFollowUp => 'المتابعة التجارية';

  @override
  String get currentStage => 'المرحلة الحالية';

  @override
  String get currentStageLabel => 'المرحلة الحالية:  ';

  @override
  String get useChangeStageHint =>
      'استخدم «تغيير المرحلة» لتعديلها (يُحتفظ بالسجل).';

  @override
  String stagesUnavailable(Object error) {
    return 'المراحل غير متاحة: $error';
  }

  @override
  String get initialStageRequired => 'المرحلة الأولية *';

  @override
  String get markAsLost => 'تحديد كخسارة';

  @override
  String get confirmChange => 'تأكيد التغيير';

  @override
  String get newStageRequired => 'المرحلة الجديدة *';

  @override
  String get stageMarksWon => 'هذه المرحلة تعني صفقة مكسوبة.';

  @override
  String get lossReasonRequiredLabel => 'سبب الخسارة *';

  @override
  String get noActiveLossReason =>
      'لا يوجد سبب نشط: أضف أسبابًا في «أسباب الخسارة».';

  @override
  String reasonDetailsRequiredSuffix(Object label) {
    return '$label  (التوضيح مطلوب)';
  }

  @override
  String get detailsRequiredLabel => 'التوضيح *';

  @override
  String get details => 'التوضيح';

  @override
  String get interestedProducts => 'المنتجات المهتم بها';

  @override
  String get invalidProspectId => 'معرّف العميل المحتمل غير صالح.';

  @override
  String dataMaybeStale(Object error) {
    return 'قد تكون البيانات قديمة: $error';
  }

  @override
  String stageChanged(Object stage) {
    return 'تم تغيير المرحلة: «$stage».';
  }

  @override
  String createdOnDate(Object date) {
    return 'أُنشئ في $date';
  }

  @override
  String get sectionInformation => 'المعلومات';

  @override
  String get updatedLabel => 'آخر تحديث';

  @override
  String get productsUpdated => 'تم تحديث المنتجات.';

  @override
  String get noProductAssociated => 'لا يوجد منتج مرتبط.';

  @override
  String get sectionCommercialStage => 'المرحلة التجارية';

  @override
  String get opportunityLost => 'فرصة ضائعة';

  @override
  String get reason => 'السبب';

  @override
  String get saleWon => 'صفقة مكسوبة';

  @override
  String get stageHistory => 'سجل المراحل';

  @override
  String get noStageChanges => 'لا يوجد تغيير في المراحل مسجّل.';

  @override
  String get creationArrow => 'الإنشاء ←';

  @override
  String pendingCount(Object count) {
    return '$count قيد الانتظار';
  }

  @override
  String get noFollowUpScheduled => 'لا توجد متابعات مجدولة.';

  @override
  String closedFollowUps(Object count) {
    return 'متابعات منتهية أو ملغاة ($count)';
  }

  @override
  String get activityHistory => 'سجل الأنشطة';

  @override
  String get activityWord => 'نشاط';

  @override
  String get noActivitiesForProspect =>
      'لا توجد أنشطة مسجّلة لهذا العميل المحتمل.';

  @override
  String get showOlderActivities => 'عرض الأنشطة الأقدم';

  @override
  String get activitiesSubtitle => 'المكالمات والمواعيد والرسائل والملاحظات';

  @override
  String get newActivity => 'نشاط جديد';

  @override
  String get activitySearchHint => 'العنوان، الوصف، النتيجة…';

  @override
  String get allTypes => 'كل الأنواع';

  @override
  String get noActivityMatchesFilters => 'لا يوجد نشاط يطابق عوامل التصفية';

  @override
  String get noActivities => 'لا توجد أنشطة مسجّلة';

  @override
  String get colProspect => 'العميل المحتمل';

  @override
  String prospectNumber(Object id) {
    return 'العميل المحتمل #$id';
  }

  @override
  String outcomeLine(Object outcome) {
    return 'النتيجة: $outcome';
  }

  @override
  String get activityTypeLabel => 'نوع النشاط';

  @override
  String get activityDescriptionHint => 'ما قيل / ما تم…';

  @override
  String get activityOutcomeHint =>
      'مثال: مهتم، متردد بشأن السعر، يطلب عرضًا تجريبيًا…';

  @override
  String get nextStepsSection => 'الخطوات التالية';

  @override
  String get nextFollowUpOptional => 'المتابعة التالية (اختياري)';

  @override
  String get alsoScheduleFollowUp => 'جدولة متابعة في هذا التاريخ أيضًا';

  @override
  String get willAppearInFollowUps => 'ستظهر في «المتابعات».';

  @override
  String get followUpSubject => 'موضوع المتابعة';

  @override
  String get leaveEmptyAuto => 'اتركه فارغًا لنص تلقائي';

  @override
  String get activitySaved => 'تم حفظ النشاط.';

  @override
  String get activitySavedAndFollowUp => 'تم حفظ النشاط وجدولة المتابعة.';

  @override
  String get activitySavedFollowUpFailed =>
      'تم حفظ النشاط، لكن تعذّرت جدولة المتابعة:';

  @override
  String get activityTypeCall => 'مكالمة هاتفية';

  @override
  String get activityTypeAppointment => 'موعد / اجتماع';

  @override
  String get activityTypeMessage => 'رسالة';

  @override
  String get activityTypeNote => 'ملاحظة';

  @override
  String followUpAfterActivity(Object type, Object date) {
    return 'متابعة بعد: $type بتاريخ $date';
  }

  @override
  String get followUpsSubtitle => 'متابعة التذكيرات والمواعيد القادمة';

  @override
  String get followUpSearchHint => 'العميل المحتمل، الوصف…';

  @override
  String get noFollowUpsToday => 'لا توجد متابعات مخطط لها اليوم';

  @override
  String get noFollowUpsOverdue => 'لا توجد متابعات متأخرة';

  @override
  String get noFollowUpsUpcoming => 'لا توجد متابعات قادمة';

  @override
  String get noFollowUpsDone => 'لا توجد متابعات منجزة';

  @override
  String get noFollowUpsCancelled => 'لا توجد متابعات ملغاة';

  @override
  String get colDueDate => 'الموعد';

  @override
  String get markAsDone => 'تحديد كمنجزة';

  @override
  String get cancelFollowUp => 'إلغاء المتابعة';

  @override
  String get followUpStatusPending => 'قيد الانتظار';

  @override
  String get followUpStatusCompleted => 'منجزة';

  @override
  String get followUpStatusCancelled => 'ملغاة';

  @override
  String get followUpViewToday => 'اليوم';

  @override
  String get followUpViewOverdue => 'متأخرة';

  @override
  String get followUpViewUpcoming => 'قادمة';

  @override
  String get followUpViewCompleted => 'المنجزة';

  @override
  String get followUpViewCancelled => 'الملغاة';

  @override
  String get followUpScheduled => 'تمت جدولة المتابعة.';

  @override
  String get followUpUpdated => 'تم تعديل المتابعة.';

  @override
  String get followUpCompleted => 'تم تحديد المتابعة كمنجزة.';

  @override
  String followUpCompletedActivityFailed(Object error) {
    return 'تم تحديد المتابعة كمنجزة، لكن تعذّر حفظ النشاط ($error). تم الاحتفاظ بالنتيجة في ملاحظة المتابعة؛ أضف النشاط من بطاقة العميل المحتمل.';
  }

  @override
  String get followUpCancelled => 'تم إلغاء المتابعة.';

  @override
  String get editFollowUp => 'تعديل المتابعة';

  @override
  String get quickTomorrow => 'غدًا';

  @override
  String get quickIn3Days => 'بعد 3 أيام';

  @override
  String get quickIn1Week => 'بعد أسبوع';

  @override
  String get quickIn2Weeks => 'بعد أسبوعين';

  @override
  String get followUpDescriptionHint => 'مثال: الاتصال مجددًا لتأكيد عرض السعر';

  @override
  String get completeFollowUpTitle => 'تحديد المتابعة كمنجزة';

  @override
  String get finishFollowUp => 'إنهاء المتابعة';

  @override
  String dueOn(Object date) {
    return 'مقررة في $date';
  }

  @override
  String get recordOutcomeAsActivity => 'تسجيل النتيجة كنشاط';

  @override
  String get recommendedKeepsHistory => 'موصى به: يحفظ سجل التواصل.';

  @override
  String get completeOutcomeHint => 'مثال: موافقة مبدئية، يرغب في التفكير…';

  @override
  String companyDueOn(Object company, Object date) {
    return '$company — مقررة في $date';
  }

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get followUpOverdueTip => 'متابعة متأخرة';

  @override
  String get pipelineTitle => 'مسار المبيعات';

  @override
  String get pipelineSubtitle => 'العملاء المحتملون مجمّعون حسب المرحلة';

  @override
  String get pipelineFilterHint => 'تصفية كل المراحل…';

  @override
  String get noStagesConfigured => 'لم تتم تهيئة أي مرحلة بيع';

  @override
  String get configureStages => 'تهيئة المراحل';

  @override
  String prospectMovedToStage(Object name, Object stage) {
    return 'تم نقل «$name» إلى «$stage».';
  }

  @override
  String get dropCardHere => 'أفلت بطاقة هنا';

  @override
  String get stageDeactivated => 'مرحلة معطّلة';

  @override
  String get moveTo => 'نقل إلى…';

  @override
  String moveToStage(Object stage) {
    return 'نقل إلى «$stage»';
  }

  @override
  String productAdded(Object name) {
    return 'تمت إضافة المنتج «$name».';
  }

  @override
  String get productUpdated => 'تم تحديث المنتج.';

  @override
  String get productReactivated => 'تمت إعادة تفعيل المنتج.';

  @override
  String get productDeactivated => 'تم تعطيل المنتج.';

  @override
  String deactivateQuestion(Object name) {
    return 'تعطيل «$name»؟';
  }

  @override
  String get deactivateProductBody =>
      'لن يمكن ربط المنتج بعملاء محتملين جدد. تُحفظ الارتباطات الحالية والسجل.';

  @override
  String get productsSubtitle =>
      'البرمجيات والخدمات المعروضة على العملاء المحتملين';

  @override
  String get newProduct => 'منتج جديد';

  @override
  String get productSearchHint => 'ابحث عن منتج…';

  @override
  String get showInactiveProducts => 'عرض المنتجات غير النشطة';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get noProductMatches => 'لا يوجد منتج مطابق';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productActive => 'منتج نشط';

  @override
  String get productActiveHint =>
      'يمكن ربط المنتجات النشطة فقط بالعملاء المحتملين.';

  @override
  String get productPack => 'الحزمة / الباقة';

  @override
  String get productNoPack => 'منتج مستقل (بدون حزمة)';

  @override
  String get productNewPack => 'حزمة جديدة';

  @override
  String get productPackName => 'اسم الحزمة';

  @override
  String get productPackCode => 'رمز الحزمة (Code)';

  @override
  String get productDemoUrl => 'رابط النسخة التجريبية (Demo)';

  @override
  String get productDemoUrlHint =>
      'الرابط الثابت للنسخة التجريبية (مثال: https://...)';

  @override
  String get productUploadDemo => 'رفع ملف النسخة التجريبية إلى السيرفر';

  @override
  String get productDemoUploaded =>
      'تم رفع ملف النسخة التجريبية بنجاح وتحديث الرابط.';

  @override
  String get productUploadingDemo => 'جارٍ رفع الملف إلى السيرفر…';

  @override
  String get productActiveOnWeb => 'الموقع والبوابة';

  @override
  String get productActiveOnWebHint =>
      'يجعل هذا المنتج مرئياً وقابلاً للاختيار من قبل العملاء عبر الإنترنت.';

  @override
  String get productPacksTitle => 'إدارة الحزم والباقات';

  @override
  String selectedCount(Object count) {
    return '$count محدد';
  }

  @override
  String get noActiveProducts => 'لا يوجد منتج نشط. أضف منتجات في «المنتجات».';

  @override
  String productInactiveSuffix(Object name) {
    return '$name (غير نشط)';
  }

  @override
  String stageCreated(Object name) {
    return 'تم إنشاء المرحلة «$name».';
  }

  @override
  String get stageUpdated => 'تم تحديث المرحلة.';

  @override
  String get stageReactivated => 'تمت إعادة تفعيل المرحلة.';

  @override
  String get stageDeactivatedMsg => 'تم تعطيل المرحلة.';

  @override
  String get stageDeleted => 'تم حذف المرحلة.';

  @override
  String deleteQuestion(Object name) {
    return 'حذف «$name»؟';
  }

  @override
  String get deleteStageBody =>
      'لم تُستخدم هذه المرحلة قط. سيتم حذفها نهائيًا.';

  @override
  String get orderNotSaved => 'لم يتم حفظ الترتيب الجديد:';

  @override
  String get stagesSubtitle =>
      'حدّد مسار المبيعات: الترتيب واللون والنوع (جارٍ / مكسوب / خسارة). لا يمكن حذف المراحل المستخدمة، بل تعطيلها فقط.';

  @override
  String get newStage => 'مرحلة جديدة';

  @override
  String get savingNewOrder => 'جارٍ حفظ الترتيب الجديد…';

  @override
  String get createStagesHint =>
      'أنشئ مرحلة واحدة على الأقل من كل نوع: «جارٍ» و«مكسوب» و«خسارة».';

  @override
  String get createStage => 'إنشاء مرحلة';

  @override
  String prospectsCountShort(Object count) {
    return '$count عميل(عملاء) محتمل';
  }

  @override
  String get stageUsedNoDelete =>
      'مستخدمة من عملاء محتملين أو السجل: لا يمكن حذفها.';

  @override
  String get deleteImpossibleUsed => 'لا يمكن الحذف (المرحلة مستخدمة)';

  @override
  String get editStage => 'تعديل المرحلة';

  @override
  String get stageTypeLocked =>
      'المرحلة مستخدمة بالفعل: لا يمكن تغيير نوعها (حماية السجل).';

  @override
  String get lostRequiresReasonHint =>
      '«خسارة» تتطلب سبب خسارة عند تغيير المرحلة.';

  @override
  String get stageActive => 'مرحلة نشطة';

  @override
  String get stageUsedDeactivateInstead =>
      'هذه المرحلة مستخدمة من عملاء محتملين أو في سجلهم: عطّلها بدل حذفها.';

  @override
  String get stageTypeWon => 'مكسوب';

  @override
  String get stageTypeLost => 'خسارة';

  @override
  String get reasonAdded => 'تمت إضافة السبب.';

  @override
  String get reasonUpdated => 'تم تحديث السبب.';

  @override
  String get reasonReactivated => 'تمت إعادة تفعيل السبب.';

  @override
  String get reasonDeactivated => 'تم تعطيل السبب.';

  @override
  String get deactivateReasonBody =>
      'لن يُعرض هذا السبب بعد الآن. يحتفظ به العملاء الذين خسروا به سابقًا.';

  @override
  String get lossReasonsSubtitle =>
      'الأسباب المعروضة عند انتقال عميل محتمل إلى مرحلة «خسارة». تغذّي تحليل المبيعات الخاسرة.';

  @override
  String get newReason => 'سبب جديد';

  @override
  String get lossReasonsReadOnly =>
      'لا يسمح الخادم بإدارة أسباب الخسارة من التطبيق: قائمة للقراءة فقط.';

  @override
  String get noLossReasons => 'لا توجد أسباب خسارة';

  @override
  String get noActiveReasonWarning =>
      'بدون سبب نشط، لا يمكن لأي عميل محتمل الانتقال إلى مرحلة «خسارة».';

  @override
  String get detailsRequired => 'التوضيح مطلوب';

  @override
  String get editReason => 'تعديل السبب';

  @override
  String get newLossReason => 'سبب خسارة جديد';

  @override
  String get reasonLabelHint => 'مثال: سعر مرتفع';

  @override
  String get detailsMandatory => 'التوضيح إلزامي';

  @override
  String get detailsMandatoryHint => 'مثال: «اختار منافسًا» ← حدّد أيّهم.';

  @override
  String get reasonActive => 'سبب نشط';

  @override
  String get settingsSavedOnline => 'تم حفظ الإعدادات. الخادم متاح.';

  @override
  String get settingsSavedOffline =>
      'تم حفظ الإعدادات على هذا الحاسوب، لكن الخادم لا يستجيب حاليًا.';

  @override
  String get settingsSubtitle => 'إعدادات خاصة بهذا الحاسوب';

  @override
  String get firstLaunchHint =>
      'أول استخدام: أدخل عنوان الحاسوب المركزي (خادم Laravel) في شبكة الشركة، واختبر الاتصال ثم احفظ.';

  @override
  String get settingsServerTitle => 'خادم التطبيق';

  @override
  String get settingsServerSubtitle =>
      'واجهة Laravel المستضافة على الحاسوب المركزي (الشبكة المحلية)';

  @override
  String get fieldApiAddress => 'عنوان واجهة API *';

  @override
  String get apiAddressHelp =>
      'الصيغة: http://عنوان_IP:المنفذ/api/v1 — لا تستخدم «localhost» على حواسيب الموظفين.';

  @override
  String get fieldTimeout => 'المهلة القصوى';

  @override
  String secondsShort(Object seconds) {
    return '$seconds ث';
  }

  @override
  String get testing => 'جارٍ الاختبار…';

  @override
  String get testConnection => 'اختبار الاتصال';

  @override
  String connectionSuccess(Object url) {
    return 'نجح الاتصال بـ $url';
  }

  @override
  String get settingsDisplay => 'العرض';

  @override
  String get themeLightShort => 'فاتح';

  @override
  String get themeDarkShort => 'داكن';

  @override
  String get themeSystemShort => 'النظام';

  @override
  String get settingsAbout => 'حول';

  @override
  String get aboutApplication => 'التطبيق';

  @override
  String aboutClient(Object app) {
    return '$app — عميل Windows';
  }

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutData => 'البيانات';

  @override
  String get aboutDataBody =>
      'تُخزَّن جميع البيانات على الخادم المركزي. يُحفظ على هذا الحاسوب عنوان الخادم واللغة والمظهر فقط.';

  @override
  String get changeProspect => 'تغيير العميل المحتمل';

  @override
  String get prospectRequiredLabel => 'العميل المحتمل *';

  @override
  String get errNotJson =>
      'ردّ الخادم، لكن ليس بصيغة JSON. تأكد من أن العنوان ينتهي بـ /api/v1.';

  @override
  String countProspects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عميل محتمل',
      many: '$count عميلًا محتملًا',
      few: '$count عملاء محتملين',
      two: 'عميلان محتملان',
      one: 'عميل محتمل واحد',
      zero: 'لا يوجد عملاء محتملون',
    );
    return '$_temp0';
  }

  @override
  String countActivities(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نشاط',
      many: '$count نشاطًا',
      few: '$count أنشطة',
      two: 'نشاطان',
      one: 'نشاط واحد',
      zero: 'لا توجد أنشطة',
    );
    return '$_temp0';
  }

  @override
  String activitiesCountSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نشاط',
      many: '$count نشاطًا',
      few: '$count أنشطة',
      two: 'نشاطان',
      one: 'نشاط واحد',
    );
    return '$_temp0 — مكالمات ومواعيد ورسائل وملاحظات';
  }

  @override
  String pipelineCountSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عميل محتمل',
      many: '$count عميلًا محتملًا',
      few: '$count عملاء محتملين',
      two: 'عميلان محتملان',
      one: 'عميل محتمل واحد',
    );
    return '$_temp0 · اسحب بطاقة إلى مرحلة أخرى لنقلها';
  }

  @override
  String get donutProspects => 'عميل محتمل';

  @override
  String reasonLine(Object note) {
    return 'السبب: $note';
  }

  @override
  String lossReasonLine(Object reason) {
    return 'السبب: $reason';
  }

  @override
  String get deactivateStageIntro => 'لن يمكن اختيار المرحلة لتغييرات جديدة.';

  @override
  String deactivateStageProspects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوجد $count عميل محتمل فيها حاليًا وسيبقون فيها.',
      many: 'يوجد $count عميلًا محتملًا فيها حاليًا وسيبقون فيها.',
      few: 'يوجد $count عملاء محتملين فيها حاليًا وسيبقون فيها.',
      two: 'يوجد عميلان محتملان فيها حاليًا وسيبقيان فيها.',
      one: 'يوجد عميل محتمل واحد فيها حاليًا وسيبقى فيها.',
    );
    return '$_temp0';
  }

  @override
  String get deactivateStageOutro => 'يُحتفظ بالسجل.';

  @override
  String get sectionBusinessProfile => 'الملف التجاري';

  @override
  String get fieldBusinessActivity => 'نشاط الشركة';

  @override
  String get businessActivityHint => 'اختر أو اكتب نشاطًا';

  @override
  String get fieldSource => 'مصدر العميل المحتمل';

  @override
  String get fieldSourceOther => 'حدّد المصدر';

  @override
  String get fieldPreviousSoftware => 'البرنامج المستخدم سابقًا';

  @override
  String get previousSoftwareHint => 'اختر أو اكتب برنامجًا';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get allSources => 'كل المصادر';

  @override
  String get baWholesale => 'تجارة الجملة';

  @override
  String get baRetail => 'تجارة التجزئة';

  @override
  String get baManufacturing => 'صناعة / إنتاج';

  @override
  String get baConstruction => 'بناء وأشغال عمومية';

  @override
  String get baServices => 'خدمات';

  @override
  String get srcFacebook => 'فيسبوك';

  @override
  String get srcInstagram => 'إنستغرام';

  @override
  String get srcFriendReferral => 'صديق / توصية شخصية';

  @override
  String get srcCustomerReferral => 'توصية من عميل حالي';

  @override
  String get srcWebsite => 'الموقع الإلكتروني';

  @override
  String get srcPhoneCall => 'مكالمة هاتفية';

  @override
  String get swSage => 'Sage';

  @override
  String get swPcCompta => 'PC Compta';

  @override
  String get swExcel => 'Excel';

  @override
  String get swOtherSoftware => 'برنامج تسيير آخر';

  @override
  String get swNone => 'لا يوجد برنامج سابق';

  @override
  String get searchProspectTitle => 'البحث عن عميل محتمل';

  @override
  String get searchProspectHint => 'الاسم، الشركة، الهاتف أو رقم العميل…';

  @override
  String get searchProspectIdle =>
      'اكتب اسمًا أو شركة أو رقم هاتف أو رقم عميل.';

  @override
  String get searchProspectEmpty => 'لم يتم العثور على عميل محتمل';

  @override
  String searchProspectMore(Object total) {
    return 'دقّق البحث لعرض باقي النتائج (الإجمالي $total).';
  }

  @override
  String get searchAllStagesNote =>
      'يشمل البحث جميع المراحل (بما فيها المكسوبة والخاسرة).';

  @override
  String prospectIdShort(Object id) {
    return 'رقم $id';
  }

  @override
  String get prospectOptionalLabel => 'العميل المحتمل (اختياري)';

  @override
  String get pickProspect => 'اختيار عميل محتمل';

  @override
  String get activityTitleRequired => 'العنوان / الملخص *';

  @override
  String get activityTitleHint => 'مثال: اتصال العميل بخصوص عرض السعر';

  @override
  String get activityDiscussionLabel => 'النقاش، رد العميل، ملاحظات';

  @override
  String get colTitle => 'العنوان';

  @override
  String get linkStatusLinked => 'مرتبط';

  @override
  String get linkStatusUnlinked => 'غير مرتبط';

  @override
  String get linkToProspect => 'ربط بعميل محتمل';

  @override
  String get changeLinkedProspect => 'تغيير العميل المحتمل المرتبط';

  @override
  String get linkedProspectLabel => 'العميل المحتمل المرتبط';

  @override
  String get noProspectLinked => 'لا يوجد عميل محتمل مرتبط';

  @override
  String get openProspect => 'فتح العميل المحتمل';

  @override
  String get activityDetails => 'تفاصيل النشاط';

  @override
  String activityLinkedTo(Object name) {
    return 'تم ربط النشاط بـ «$name».';
  }

  @override
  String get relinkTitle => 'تغيير العميل المحتمل المرتبط؟';

  @override
  String relinkBody(Object from, Object to) {
    return 'هذا النشاط مرتبط بـ «$from». هل تريد نقله إلى «$to»؟ لن يتغير محتواه ولا تاريخه.';
  }

  @override
  String get relinkConfirm => 'نقل';

  @override
  String get originLabel => 'المصدر';

  @override
  String get originDirect => 'إدخال مباشر';

  @override
  String get originFollowUp => 'محوّل من متابعة';

  @override
  String get activityFromFollowUpLocked =>
      'هذا النشاط ناتج عن متابعة: يبقى مرتبطًا بعميله المحتمل.';

  @override
  String get filterLinkAll => 'الكل (مرتبط أو غير مرتبط)';

  @override
  String get filterLinkOnlyLinked => 'المرتبطة بعميل';

  @override
  String get filterLinkOnlyUnlinked => 'غير المرتبطة';

  @override
  String get colLink => 'العميل المرتبط';

  @override
  String get colLinkfllowup => 'المتابعة المرتبطة';

  @override
  String get activityOccurredAt => 'التاريخ والوقت';

  @override
  String get createdOnLabel => 'أُنشئ في';

  @override
  String get linkedOnLabel => 'رُبط في';

  @override
  String get typeLabelRequired => 'نوع النشاط *';

  @override
  String get followUpTypeLabel => 'نوع المتابعة';

  @override
  String get followUpTypeRequired => 'اختر نوع المتابعة.';

  @override
  String get followUpTypeMissing => 'النوع غير محدد';

  @override
  String followUpCompletedKeepsType(Object type) {
    return 'سيكون نوع النشاط هو نوع المتابعة: $type.';
  }

  @override
  String get activityTypeForLegacy => 'هذه المتابعة بلا نوع: اختر نوع النشاط.';

  @override
  String get followUpCompletedWithActivity =>
      'تم إنهاء المتابعة وتسجيل النشاط.';

  @override
  String get colType => 'النوع';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageHint => 'لغة الواجهة. يتم التغيير فورًا.';

  @override
  String get languageMenuTooltip => 'تغيير اللغة';

  @override
  String get themeToggleToDark => 'التبديل إلى الوضع الداكن';

  @override
  String get themeToggleToLight => 'التبديل إلى الوضع الفاتح';

  @override
  String get settingsAboutBody =>
      'يُحفظ على هذا الحاسوب عنوان الخادم واللغة والمظهر فقط.';

  @override
  String get validFieldTitle => 'العنوان';

  @override
  String validMinLength(Object min) {
    return '$min أحرف كحد أدنى.';
  }

  @override
  String get navAfterSales => 'التدخلات والدعم';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navEmployees => 'الموظفون';

  @override
  String get navGroupCrm => 'إدارة العملاء';

  @override
  String get navGroupCustomers => 'العملاء والمنتجات';

  @override
  String get navGroupService => 'الخدمة';

  @override
  String get navGroupTeam => 'الفريق';

  @override
  String get navWorkspaceAgenda => 'الرئيسية والأجندة';

  @override
  String get navWorkspaceSales => 'المبيعات والزبائن';

  @override
  String get navWorkspaceSupport => 'العمليات والدعم الفني';

  @override
  String get navWorkspaceBilling => 'الفوترة والاشتراكات';

  @override
  String get navWorkspaceProspects => 'المهتمين والمبيعات';

  @override
  String get navWorkspaceCustomers => 'الزبائن والعمليات';

  @override
  String get navWorkspaceProducts => 'المنتجات والإصدارات';

  @override
  String get navWorkspaceTeam => 'فريق العمل';

  @override
  String get navWorkspaceAnalytics => 'التقارير والإحصائيات';

  @override
  String get navOptionSources => 'مصادر المهتمين';

  @override
  String get navOptionActivities => 'الأنشطة التجارية';

  @override
  String get navOptionSoftware => 'البرمجيات السابقة';

  @override
  String get navOptionCities => 'المدن والولايات';

  @override
  String get navToggleSidebar => 'طي / توسيع القائمة';

  @override
  String get settingsGroupGeneral => 'عام وخادم الاتصال';

  @override
  String get settingsGroupSales => 'إعدادات المبيعات والعملاء المحتملين';

  @override
  String get settingsGroupSchedule => 'المواعيد وساعات العمل';

  @override
  String get settingsGroupCatalog => 'المنتجات والباقات والمصادر';

  @override
  String get settingsGroupAfterSales => 'الدعم الفني والتدخلات';

  @override
  String get hoursOpen => 'مفتوح';

  @override
  String get hoursClosed => 'مغلق';

  @override
  String get hoursDailySpan => 'مدة العمل اليومية';

  @override
  String get hoursPickTime => 'اختر الوقت';

  @override
  String get hoursSlotsPerDay => 'فترات في اليوم';

  @override
  String get unitMinutes => 'دقيقة';

  @override
  String get unitHours => 'س';

  @override
  String get unitDays => 'يوم';

  @override
  String get hoursBookingHorizonHint =>
      'إلى أي عدد من الأيام المسبقة يمكن للعميل أن يحجز.';

  @override
  String get hoursMinNoticeHint =>
      'أقل مدة بين الحجز والموعد حتى يتمكن الفريق من التحضير.';

  @override
  String get hoursHoldHint =>
      'تبقى الفترة المطلوبة محجوزة لهذه المدة قبل أن يتم تحريرها.';

  @override
  String get navRequests => 'الطلبات والحجوزات';

  @override
  String get navTraining => 'التكوين والمرافقة';

  @override
  String get navWorkflowSettings => 'المواعيد وما بعد البيع';

  @override
  String get wfYes => 'نعم';

  @override
  String get wfNo => 'لا';

  @override
  String get wfSaved => 'تم الحفظ.';

  @override
  String get wfDate => 'التاريخ';

  @override
  String get wfWhen => 'الموعد';

  @override
  String get wfToday => 'اليوم';

  @override
  String get wfPrevious => 'السابق';

  @override
  String get wfNext => 'التالي';

  @override
  String get wfTitle => 'العنوان';

  @override
  String get wfUpdated => 'آخر تحديث';

  @override
  String get wfReceived => 'تاريخ الاستلام';

  @override
  String get wfReference => 'المرجع';

  @override
  String get wfEmployee => 'الموظف';

  @override
  String get wfAssignedTo => 'مسند إلى';

  @override
  String get wfUnassigned => 'غير مسند';

  @override
  String get wfTrainer => 'المكوّن';

  @override
  String get wfCode => 'الرمز';

  @override
  String get wfCodeInvalid => 'أحرف صغيرة وأرقام و _ ؛ يجب أن يبدأ بحرف.';

  @override
  String get wfFieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get wfNumberInvalid => 'يُرجى إدخال عدد صحيح موجب.';

  @override
  String wfTooLong(Object max) {
    return '$max حرفًا كحد أقصى.';
  }

  @override
  String wfRangeError(Object min, Object max) {
    return 'بين $min و $max.';
  }

  @override
  String get wfUrl => 'الرابط';

  @override
  String get wfUrlInvalid => 'رابط http(s) غير صالح.';

  @override
  String get wfUrlRequired => 'الرابط مطلوب.';

  @override
  String get wfInvalidId => 'معرّف غير صالح.';

  @override
  String get wfStartInPast => 'وقت البدء في الماضي.';

  @override
  String get wfEndAfterStart => 'يجب أن تكون النهاية بعد البداية.';

  @override
  String get wfStarts => 'البداية';

  @override
  String get wfEnds => 'النهاية';

  @override
  String get wfStartTime => 'ساعة البدء';

  @override
  String get wfEndTime => 'ساعة الانتهاء';

  @override
  String get wfLanguage => 'اللغة';

  @override
  String get wfSortOrder => 'ترتيب العرض';

  @override
  String get wfSortOrderHint => 'الرقم الأصغر = الأكثر استعجالًا.';

  @override
  String get wfStatusHeld => 'محجوز مؤقتًا';

  @override
  String get wfStatusProposed => 'مقترح';

  @override
  String get wfStatusConfirmed => 'مؤكد';

  @override
  String get wfStatusRejected => 'مرفوض';

  @override
  String get wfStatusCancelled => 'ملغى';

  @override
  String get wfStatusExpired => 'منتهي';

  @override
  String get wfStatusCompleted => 'منجز';

  @override
  String get wfStatusNoShow => 'لم يحضر';

  @override
  String get wfKindAppointment => 'موعد';

  @override
  String get wfKindFollowUp => 'متابعة';

  @override
  String get wfKindIntervention => 'تدخل';

  @override
  String get wfKindActivity => 'الأنشطة المنجزة';

  @override
  String get wfGroupDemo => 'عرض تجريبي';

  @override
  String get wfGroupMeeting => 'اجتماع';

  @override
  String get wfGroupTraining => 'تكوين';

  @override
  String get wfGroup => 'المجموعة';

  @override
  String get wfGroupAccompaniment => 'مرافقة';

  @override
  String get wfConflictHoliday => 'يوم عطلة';

  @override
  String get wfConflictEmployee => 'الموظف مشغول';

  @override
  String get wfConflictCustomer => 'العميل مشغول';

  @override
  String get wfConflictsTitle => 'تم رفض الجدولة: توجد تعارضات';

  @override
  String wfConflictLine(Object occurrence, Object date, Object reason) {
    return 'الحصة $occurrence ($date): $reason';
  }

  @override
  String get wfConflictNothingSaved =>
      'تعارض في الجدولة: لم يُحفظ شيء. صحّح الحصص المذكورة.';

  @override
  String wfConflictExplain(Object reasons) {
    return 'تعارض: $reasons';
  }

  @override
  String get wfHoldExpired => 'انتهت مدة الحجز وتم تحرير الموعد. حدّث القائمة.';

  @override
  String get wfHoldExpiredChip => 'انتهى الحجز';

  @override
  String get wfHoldExpires => 'انتهاء الحجز';

  @override
  String wfExpiresIn(Object time) {
    return 'ينتهي بعد $time';
  }

  @override
  String get wfCalendarSubtitle =>
      'المواعيد والمتابعات والتدخلات المجدولة؛ الأنشطة المنجزة تظهر بلون خافت.';

  @override
  String get wfViewMonth => 'شهر';

  @override
  String get wfViewWeek => 'أسبوع';

  @override
  String get wfViewDay => 'يوم';

  @override
  String get wfLegendScheduled => 'مجدول';

  @override
  String get wfLegendCompleted => 'منجز';

  @override
  String get wfFilterCustomer => 'العميل';

  @override
  String get wfClearFilters => 'مسح الفلاتر';

  @override
  String wfMoreItems(Object count) {
    return '+$count أخرى';
  }

  @override
  String get wfNothingScheduled => 'لا شيء مجدول في هذا اليوم';

  @override
  String get wfNothingScheduledHint =>
      'تظهر هنا المواعيد المؤكدة والمتابعات والتدخلات.';

  @override
  String wfActivitiesNotLoaded(Object message) {
    return 'تعذر تحميل الأنشطة المنجزة: $message';
  }

  @override
  String get wfConfirmHoldTitle => 'تأكيد الموعد';

  @override
  String get wfRejectTitle => 'رفض الطلب';

  @override
  String get wfCancelAppointmentTitle => 'إلغاء الموعد';

  @override
  String get wfProposeTitle => 'اقتراح موعد آخر';

  @override
  String get wfRescheduleTitle => 'تغيير موعد الحصة';

  @override
  String get wfRecordOutcomeTitle => 'تسجيل النتيجة';

  @override
  String get wfReject => 'رفض';

  @override
  String get wfCancelAppointment => 'إلغاء الموعد';

  @override
  String get wfCancelProposal => 'سحب الاقتراح';

  @override
  String get wfProposeOther => 'اقتراح موعد آخر';

  @override
  String get wfSendProposal => 'إرسال الاقتراح';

  @override
  String get wfReschedule => 'تغيير الموعد';

  @override
  String get wfRecordOutcome => 'تسجيل النتيجة';

  @override
  String get wfMarkNoShow => 'تسجيل الغياب';

  @override
  String get wfMeetingLink => 'رابط الاجتماع';

  @override
  String get wfMeetingLinkHint => 'يظهر للعميل بعد التأكيد.';

  @override
  String get wfNewTime => 'الموعد الجديد';

  @override
  String get wfReasonVisible => 'السبب (يظهر للعميل)';

  @override
  String get wfMessageVisible => 'رسالة (تظهر للعميل)';

  @override
  String get wfCustomerVisibleHint => 'هذا النص يظهر للعميل في فضائه.';

  @override
  String get wfOutcome => 'النتيجة';

  @override
  String get wfOutcomeHint => 'سيتم إنشاء نشاط في النظام بهذه النتيجة.';

  @override
  String get wfOutcomeRequired => 'النتيجة مطلوبة.';

  @override
  String get wfActivityRecorded => 'تم تسجيل النشاط';

  @override
  String get wfCustomerMessage => 'رسالة إلى العميل';

  @override
  String get wfInternalNotes => 'ملاحظات داخلية';

  @override
  String get wfOpenProspectRecord => 'فتح الملف';

  @override
  String get wfNewProspect => 'عميل محتمل جديد';

  @override
  String get wfWaitingForCustomer => 'في انتظار رد العميل.';

  @override
  String get wfRequestsSubtitle =>
      'المواعيد المحجوزة للزوار والطلبات الواردة من الموقع.';

  @override
  String wfHoldsTab(Object count) {
    return 'الحجوزات ($count)';
  }

  @override
  String get wfWebsiteRequestsTab => 'طلبات الموقع';

  @override
  String get wfNoHolds => 'لا توجد حجوزات معلقة';

  @override
  String get wfNoHoldsHint => 'تظهر هنا المواعيد المطلوبة من الموقع حتى تقرر.';

  @override
  String get wfNoRequests => 'لا توجد طلبات';

  @override
  String get wfRequestDemo => 'عرض تجريبي';

  @override
  String get wfRequestQuotation => 'عرض سعر';

  @override
  String get wfRequestTrial => 'تجربة';

  @override
  String get wfReqPending => 'قيد المعالجة';

  @override
  String get wfReqScheduled => 'مجدولة';

  @override
  String get wfReqHandled => 'تمت معالجتها';

  @override
  String get wfMarkHandled => 'تحديد كمعالجة';

  @override
  String get wfRequestUpdated => 'تم تحديث الطلب.';

  @override
  String get wfTrainingSubtitle => 'حصص التكوين وسلاسل المرافقة للعملاء.';

  @override
  String get wfNewTraining => 'تكوين جديد';

  @override
  String get wfNewAccompaniment => 'مرافقة جديدة';

  @override
  String get wfNoSessions => 'لا توجد حصص';

  @override
  String get wfNoSessionsHint => 'جدول حصة تكوين أو سلسلة مرافقة.';

  @override
  String get wfShowPast => 'إظهار الماضي';

  @override
  String get wfPartOfSeries => 'سلسلة مرافقة';

  @override
  String get wfCancelThisSession => 'إلغاء هذه الحصة';

  @override
  String get wfCancelRemainingSeries => 'إلغاء بقية السلسلة';

  @override
  String get wfCancelSessionTitle => 'إلغاء هذه الحصة؟';

  @override
  String get wfCancelSessionBody =>
      'تُلغى هذه الحصة المستقبلية فقط؛ باقي السلسلة لا يتغير.';

  @override
  String get wfCancelSeriesTitle => 'إلغاء بقية السلسلة؟';

  @override
  String get wfCancelSeriesBody =>
      'تُلغى هذه الحصة وما بعدها. الحصص المنجزة لا تتأثر.';

  @override
  String get wfCancelSeries => 'إلغاء المتبقي';

  @override
  String get wfSessionCancelled => 'تم إلغاء الحصة.';

  @override
  String wfSeriesCancelled(Object count) {
    return 'تم إلغاء $count حصة.';
  }

  @override
  String get wfSessionScheduled => 'تمت جدولة الحصة.';

  @override
  String wfSeriesScheduled(Object count) {
    return 'تمت جدولة السلسلة: $count حصص.';
  }

  @override
  String get wfMoreActions => 'إجراءات أخرى';

  @override
  String get wfSessionType => 'نوع الحصة';

  @override
  String get wfNoTypesConfigured =>
      'لا يوجد نوع موعد نشط لهذه المجموعة. اضبطه من الإعدادات.';

  @override
  String get wfSelectType => 'اختر نوعًا.';

  @override
  String get wfSelectProduct => 'اختر منتجًا.';

  @override
  String get wfNoProduct => 'بدون منتج';

  @override
  String get wfOccurrences => 'عدد الحصص';

  @override
  String get wfOccurrencesHint => 'القيمة الافتراضية من الإعدادات.';

  @override
  String get wfIntervalDays => 'الفاصل (أيام)';

  @override
  String get wfIntervalHint => 'عدد الأيام بين حصتين.';

  @override
  String wfPlannedSessions(Object count) {
    return '$count حصص مخططة';
  }

  @override
  String get wfPickResource => 'اختر مرجع تكوين';

  @override
  String get wfResourceLink => 'رابط المرجع (اختياري)';

  @override
  String get wfPrepareWhatsApp => 'تجهيز رسالة واتساب';

  @override
  String get wfPrepareWhatsAppHint => 'يجهز النص؛ ترسله بنفسك من واتساب.';

  @override
  String get wfOpenWhatsApp => 'فتح واتساب';

  @override
  String get wfWhatsAppHint =>
      'يفتح رسالة جاهزة. الإرسال يتم داخل واتساب ولا يؤكده النظام.';

  @override
  String get wfWhatsappInvalidLink => 'رابط واتساب غير معروف: لم يتم فتحه.';

  @override
  String get wfCustomersSubtitle => 'العملاء المحتملون الذين تحولوا إلى عملاء.';

  @override
  String get wfCustomerSearchHint => 'ابحث عن عميل…';

  @override
  String get wfNoCustomers => 'لا يوجد عملاء';

  @override
  String get wfNoCustomersHint => 'حوّل عميلًا محتملًا من ملفه.';

  @override
  String get wfCustomerSince => 'عميل منذ';

  @override
  String wfCustomerSinceDate(Object date) {
    return 'عميل منذ $date';
  }

  @override
  String get wfCustomerBadge => 'عميل';

  @override
  String wfCustomersCount(Object count) {
    return '$count عملاء';
  }

  @override
  String get wfConvertTitle => 'تحويل إلى عميل';

  @override
  String get wfConvertAction => 'تحويل إلى عميل';

  @override
  String wfConvertIntro(Object name) {
    return 'سيصبح «$name» عميلًا. يتم الاحتفاظ بالملف والسجل والأنشطة والمراحل.';
  }

  @override
  String get wfPurchasedProducts => 'المنتجات المشتراة';

  @override
  String get wfConversionNote => 'ملاحظة التحويل';

  @override
  String get wfConvertedBy => 'تاريخ ومنفّذ التحويل';

  @override
  String wfConverted(Object name) {
    return 'أصبح «$name» عميلًا.';
  }

  @override
  String get wfAlreadyCustomer =>
      'هذا العميل المحتمل أصبح عميلًا بالفعل. حدّث الملف.';

  @override
  String get wfOpenCustomerProfile => 'فتح ملف العميل';

  @override
  String get wfCustomerProducts => 'منتجات العميل';

  @override
  String get wfNoCustomerProducts => 'لا توجد منتجات مرتبطة';

  @override
  String wfPurchasedOn(Object date) {
    return 'اشتري في $date';
  }

  @override
  String get wfPortalAccounts => 'حسابات فضاء العميل';

  @override
  String get wfPortalAccountsHint =>
      'هويات الموقع، منفصلة عن صلاحيات الموظفين.';

  @override
  String get wfNoPortalAccount => 'لا يوجد حساب مرتبط بالفضاء';

  @override
  String wfLastLogin(Object date) {
    return 'آخر دخول: $date';
  }

  @override
  String get wfTrials => 'فترات التجربة';

  @override
  String get wfNoTrials => 'لا توجد تجارب';

  @override
  String get wfNewTrial => 'تجربة جديدة';

  @override
  String get wfTrialUrl => 'رابط الوصول للتجربة';

  @override
  String get wfTrialUrlHint => 'لا يراه العميل إلا أثناء التجربة الفعالة.';

  @override
  String get wfTrialStarts => 'بداية التجربة';

  @override
  String get wfTrialEnds => 'نهاية التجربة';

  @override
  String get wfTrialDays => 'مدة التجربة الافتراضية (أيام)';

  @override
  String get wfTrialActive => 'فعّال';

  @override
  String get wfTrialScheduled => 'مبرمج';

  @override
  String get wfTrialRevoked => 'ملغى الوصول';

  @override
  String get wfTrialActivated => 'تم تفعيل التجربة.';

  @override
  String get wfTrialOverlap => 'توجد تجربة لهذا المنتج في نفس الفترة.';

  @override
  String get wfRevoke => 'سحب الوصول';

  @override
  String get wfRevokeTrialTitle => 'سحب الوصول إلى التجربة؟';

  @override
  String wfRevokeTrialBody(Object product) {
    return 'لن يرى العميل رابط تجربة «$product» بعد الآن.';
  }

  @override
  String get wfTrialRevokedDone => 'تم سحب الوصول.';

  @override
  String get wfAppointments => 'المواعيد';

  @override
  String get wfAppointmentsHint => 'مجدولة أو منجزة (النتيجة تصبح نشاطًا).';

  @override
  String get wfNoAppointments => 'لا توجد مواعيد';

  @override
  String get wfScheduleTraining => 'جدولة تكوين';

  @override
  String get wfAfterSalesSubtitle =>
      'طلبات العملاء والتدخلات التي ينشرها الفريق.';

  @override
  String get wfNewIntervention => 'تدخل جديد';

  @override
  String wfInterventionCreated(Object reference) {
    return 'تم إنشاء التدخل $reference.';
  }

  @override
  String get wfInterventionType => 'نوع التدخل';

  @override
  String get wfPriority => 'الأولوية';

  @override
  String get wfNoPriority => 'بدون أولوية';

  @override
  String get wfSource => 'المصدر';

  @override
  String get wfSourceCustomer => 'العميل';

  @override
  String get wfSourceEmployee => 'الموظف';

  @override
  String get wfSourceBoth => 'العميل والموظف';

  @override
  String get wfOpenItems => 'مفتوحة';

  @override
  String get wfClosedItems => 'مغلقة';

  @override
  String get wfNoInterventions => 'لا توجد تدخلات';

  @override
  String get wfNoInterventionsHint => 'تظهر هنا طلبات العملاء وتدخلاتك.';

  @override
  String get wfAffectedCustomers => 'العملاء المعنيون';

  @override
  String get wfAddCustomer => 'إضافة عميل';

  @override
  String get wfScheduledAt => 'مجدولة في';

  @override
  String get wfTitleRequired => 'العنوان مطلوب.';

  @override
  String get wfDescriptionRequired => 'الوصف مطلوب.';

  @override
  String get wfClosedAt => 'أغلقت في';

  @override
  String get wfStatusWorkflow => 'الحالة';

  @override
  String get wfStatusWorkflowHint =>
      'تُعرض الحالات المسموح بها من الحالة الحالية فقط.';

  @override
  String get wfCurrentStatus => 'الحالة الحالية';

  @override
  String get wfCustomerSees => 'ما يراه العميل';

  @override
  String get wfNoTransitions => 'لا يوجد انتقال مسموح من هذه الحالة.';

  @override
  String get wfTransitionNotAllowed => 'تغيير الحالة هذا غير مسموح.';

  @override
  String wfChangeStatusTo(Object status) {
    return 'تغيير إلى «$status»';
  }

  @override
  String wfCustomerSeesStatus(Object label) {
    return 'سيرى العميل: «$label».';
  }

  @override
  String get wfStatusExplanation => 'شرح للعميل (اختياري)';

  @override
  String get wfStatusChanged => 'تم تحديث الحالة.';

  @override
  String get wfTriage => 'الفرز والتخطيط';

  @override
  String get wfReleaseNotes => 'ملاحظات الإصدار';

  @override
  String get wfReleaseNotesHint => 'انشر الإصلاح أو التحديث للعملاء المعنيين.';

  @override
  String get wfPublish => 'نشر';

  @override
  String get wfPublished => 'تم النشر للعملاء المعنيين.';

  @override
  String get wfPublishTitle => 'النشر للعملاء';

  @override
  String wfPublishTo(Object names) {
    return 'سيظهر لـ: $names';
  }

  @override
  String get wfPublishNoCustomers =>
      'لا يوجد عملاء معنيون: أضفهم عند الإنشاء ليتم النشر.';

  @override
  String wfPublishedOn(Object date) {
    return 'نُشر في $date';
  }

  @override
  String get wfNotPublished => 'لم يُنشر بعد: لا يراه العملاء.';

  @override
  String get wfResolutionRequired => 'نص النشر مطلوب.';

  @override
  String get wfUnpublish => 'إلغاء النشر';

  @override
  String get wfUnpublishTitle => 'إلغاء النشر؟';

  @override
  String get wfUnpublishBody => 'لن يرى العملاء هذه الملاحظات بعد الآن.';

  @override
  String get wfUnpublished => 'تم إلغاء النشر.';

  @override
  String get wfConversation => 'المحادثة';

  @override
  String get wfNoMessages => 'لا توجد رسائل';

  @override
  String get wfInternalNote => 'ملاحظة داخلية';

  @override
  String get wfCustomerReply => 'رد على العميل';

  @override
  String get wfInternalNoteHint => 'للفريق فقط: لا يراها العميل أبدًا.';

  @override
  String get wfCustomerReplyWarning => 'ستظهر هذه الرسالة للعميل في فضائه.';

  @override
  String get wfConfirmCustomerReplyTitle => 'الإرسال إلى العميل؟';

  @override
  String get wfConfirmCustomerReplyBody =>
      'سيظهر الرد للعميل. لا تذكر أي نقاش داخلي.';

  @override
  String get wfSendReply => 'إرسال الرد';

  @override
  String get wfAddNote => 'إضافة الملاحظة';

  @override
  String get wfReplySaved => 'تم حفظ الرد للعميل.';

  @override
  String get wfNoteSaved => 'تم حفظ الملاحظة الداخلية.';

  @override
  String get wfMessageRequired => 'الرسالة فارغة.';

  @override
  String get wfEmployeesSubtitle =>
      'المحطات المتصلة بالنظام والعمل المسند. لجميع الموظفين نفس الصلاحيات.';

  @override
  String get wfNoEmployees => 'لا يوجد موظفون معروفون';

  @override
  String get wfNoEmployeesHint => 'يظهر الموظفون عند اتصال تطبيقهم بالخادم.';

  @override
  String get wfSelectEmployee => 'اختر موظفًا';

  @override
  String get wfIdle => 'خامل';

  @override
  String wfAssignedAppointments(Object name) {
    return 'المواعيد القادمة لـ $name';
  }

  @override
  String wfAssignedInterventions(Object name) {
    return 'التدخلات المفتوحة لـ $name';
  }

  @override
  String get wfNothingAssigned => 'لا شيء مسند';

  @override
  String get wfSettingsSubtitle =>
      'الأوقات والأنواع والحالات والأولويات والنماذج. كل شيء محفوظ في النظام.';

  @override
  String get wfSettingsSaved => 'تم حفظ الإعدادات.';

  @override
  String get wfCfgScheduling => 'الأوقات والحجز';

  @override
  String get wfCfgSchedulingHint =>
      'أيام وساعات العمل ومدة المواعيد وانتهاء الحجز وتكرار المرافقة والتجارب.';

  @override
  String get wfCfgAppointmentTypes => 'أنواع المواعيد';

  @override
  String get wfCfgAppointmentTypesHint =>
      'عرض، اجتماع، تكوين، مرافقة: المدة الافتراضية ولون التقويم.';

  @override
  String get wfCfgHolidays => 'أيام العطل';

  @override
  String get wfCfgHolidaysHint => 'لا تُعرض مواعيد في هذه الأيام.';

  @override
  String get wfCfgInterventionTypes => 'أنواع التدخل';

  @override
  String get wfCfgInterventionTypesHint =>
      'خلل، سؤال، ملاحظة، إصلاح، إصدار… ومن يحق له إنشاؤها.';

  @override
  String get wfCfgInterventionStatuses => 'حالات التدخل';

  @override
  String get wfCfgInterventionStatusesHint =>
      'التسمية الداخلية والتسمية التي يراها العميل.';

  @override
  String get wfCfgTransitions => 'انتقالات الحالة';

  @override
  String get wfCfgTransitionsHint =>
      'أي حالة يمكن أن تتبع أي حالة، وهل يمكن للعميل إجراء التغيير.';

  @override
  String get wfCfgPriorities => 'الأولويات';

  @override
  String get wfCfgPrioritiesHint =>
      'اللون ومهلة الرد المستهدفة؛ الترتيب يحدد الفرز.';

  @override
  String get wfCfgTemplates => 'نماذج الرسائل';

  @override
  String get wfCfgTemplatesHint =>
      'نصوص واتساب المجهزة للتكوين (لا ترسل تلقائيًا).';

  @override
  String get wfCfgProductResources => 'مراجع المنتجات';

  @override
  String get wfCfgProductResourcesHint =>
      'روابط التكوين والتوثيق مع إمكانية الظهور للعميل.';

  @override
  String get wfProductResources => 'مراجع وروابط المنتج';

  @override
  String wfProductResourcesTitle(Object name) {
    return 'المراجع: $name';
  }

  @override
  String get wfNoResources => 'لا توجد مراجع لهذا المنتج';

  @override
  String get wfNoConfigRows => 'لا توجد عناصر';

  @override
  String get wfNoConfigRowsHint => 'أضف أول عنصر. يمكن تعطيله لكن لا يُحذف.';

  @override
  String get wfDeactivateTitle => 'تعطيل هذا العنصر؟';

  @override
  String get wfDeactivateBody =>
      'لن يُعرض بعد الآن، لكن السجل المرتبط به يُحفظ.';

  @override
  String get wfDeactivated => 'تم تعطيل العنصر.';

  @override
  String get wfReactivated => 'تمت إعادة تفعيل العنصر.';

  @override
  String get wfDurationMinutes => 'المدة (د)';

  @override
  String get wfCustomerBookable => 'قابل للحجز من العميل';

  @override
  String get wfCustomerLabel => 'تسمية العميل';

  @override
  String get wfCustomerLabelHint => 'ما يراه العميل لهذه الحالة.';

  @override
  String get wfIsInitial => 'حالة ابتدائية';

  @override
  String get wfIsClosed => 'تغلق التدخل';

  @override
  String get wfAwaitsCustomer => 'بانتظار العميل';

  @override
  String get wfIsDelivered => 'تم تسليمه للعميل';

  @override
  String get wfFromStatus => 'من الحالة';

  @override
  String get wfToStatus => 'إلى الحالة';

  @override
  String get wfCustomerAllowed => 'يمكن للعميل تنفيذه';

  @override
  String get wfResponseTarget => 'مهلة الرد (ساعة)';

  @override
  String get wfResponseTargetHint => 'اتركه فارغًا لعدم وجود مهلة.';

  @override
  String get wfTemplate => 'النموذج';

  @override
  String get wfTemplateTrainingFirst => 'أول تكوين';

  @override
  String get wfTemplateTrainingReview => 'متابعة التكوين';

  @override
  String get wfTemplateBody => 'نص الرسالة';

  @override
  String get wfTemplatePlaceholders =>
      'المتغيرات المتاحة (اكتبها بين أقواس معقوفة): contact, product, date, start, end, resource_url';

  @override
  String get wfKindVideo => 'فيديو';

  @override
  String get wfKindLink => 'رابط';

  @override
  String get wfCustomerVisible => 'يظهر للعميل';

  @override
  String get wfTrainingMaterial => 'مادة تكوين';

  @override
  String get wfWorkingDays => 'أيام العمل';

  @override
  String get wfPickWorkingDay => 'اختر يومًا واحدًا على الأقل.';

  @override
  String get wfWorkStart => 'بداية اليوم';

  @override
  String get wfWorkEnd => 'نهاية اليوم';

  @override
  String get wfTimeInvalid => 'الصيغة المطلوبة HH:mm.';

  @override
  String get wfSlotMinutes => 'مدة الموعد (د)';

  @override
  String get wfHoldExpiryMinutes => 'انتهاء الحجز (د)';

  @override
  String get wfHoldExpiryHint => 'بعدها يتحرر الموعد تلقائيًا.';

  @override
  String get wfBookingHorizon => 'أفق الحجز (أيام)';

  @override
  String get wfMinNotice => 'أقل مهلة (ساعات)';

  @override
  String get wfDemoCapacity => 'عروض متزامنة';

  @override
  String get wfDemoCapacityHint => 'عدد العروض المتزامنة.';

  @override
  String get wfAccompanimentOccurrences => 'حصص المرافقة (افتراضي)';

  @override
  String get wfAccompanimentInterval => 'فاصل المرافقة (أيام، افتراضي)';

  @override
  String get wfWhatsappCountryCode => 'رمز دولة واتساب';

  @override
  String get wfWhatsappCountryCodeHint =>
      'أرقام فقط مثل 213. يُستعمل لإكمال الأرقام التي تبدأ بـ 0.';

  @override
  String get wfCountryCodeInvalid => 'من 1 إلى 4 أرقام.';

  @override
  String get ivSupport => 'الدعم';

  @override
  String get ivSystem => 'النظام';

  @override
  String ivEventStatusFull(Object actor, Object from, Object time, Object to) {
    return 'غيّر $actor الحالة من $from إلى $to في $time';
  }

  @override
  String ivEventStatusTo(Object actor, Object time, Object to) {
    return 'غيّر $actor الحالة إلى $to في $time';
  }

  @override
  String ivEventReopened(Object actor, Object time) {
    return 'أعاد $actor فتح التدخل في $time';
  }

  @override
  String get ivAttachFiles => 'إرفاق ملفات';

  @override
  String ivAttachLimit(Object max) {
    return '$max ملفات كحد أقصى في الرسالة.';
  }

  @override
  String get ivRemoveFile => 'إزالة هذا الملف';

  @override
  String get ivDownload => 'تنزيل';

  @override
  String get ivPreview => 'معاينة';

  @override
  String get ivViewPdf => 'فتح ملف PDF';

  @override
  String ivFileSaved(Object path) {
    return 'تم حفظ الملف: $path';
  }

  @override
  String get ivImageError => 'تعذر عرض الصورة.';

  @override
  String get ivClosedBanner => 'تم إغلاق هذا التدخل. الردود الجديدة معطلة.';

  @override
  String get ivReopen => 'إعادة فتح التدخل';

  @override
  String get ivReopenBody => 'ستُفعَّل الردود من جديد لك وللعميل.';

  @override
  String get ivReopenNote => 'ملاحظة (اختياري)';

  @override
  String get ivReopened => 'تمت إعادة فتح التدخل.';

  @override
  String get prDemoLink => 'رابط العرض التجريبي';

  @override
  String get prDemoLinkHint => 'رابط ثابت محدد في المنتج.';

  @override
  String get prNoDemoLink => 'لا يملك هذا المنتج رابط عرض تجريبي.';

  @override
  String get prNoDemoProducts => 'لا يوجد منتج بعرض تجريبي لهذا العميل.';

  @override
  String get prNoLinkedProducts => 'لا توجد منتجات مرتبطة بهذا العميل.';

  @override
  String get prFilteredByCustomer => 'تُعرض المنتجات المرتبطة بهذا العميل فقط.';

  @override
  String get prCustomersFilteredByProduct =>
      'تُعرض العملاء المرتبطون بهذا المنتج فقط.';

  @override
  String prPackReplaced(Object name) {
    return 'تم إلغاء تحديد «$name»: منتج واحد فقط لكل حزمة.';
  }

  @override
  String get prPackHint => 'منتج واحد لكل حزمة.';

  @override
  String get navReleases => 'إصدارات المنتجات';

  @override
  String get rlSubtitle => 'إصدارات المنتجات المنشورة وملفات التثبيت والجمهور.';

  @override
  String get rlNew => 'إصدار جديد';

  @override
  String get rlEdit => 'تعديل الإصدار';

  @override
  String get rlVersion => 'رقم الإصدار';

  @override
  String get rlVersionRequired => 'رقم الإصدار مطلوب.';

  @override
  String get rlDate => 'تاريخ الإصدار';

  @override
  String get rlChangelog => 'ملاحظات الإصدار';

  @override
  String get rlAudience => 'الجمهور';

  @override
  String get rlAudienceAll => 'جميع العملاء';

  @override
  String get rlAudienceOwned => 'العملاء الذين يملكون المنتج';

  @override
  String get rlAudienceSpecific => 'عملاء محددون';

  @override
  String get rlCustomers => 'العملاء المحددون';

  @override
  String get rlCustomersRequired => 'اختر عميلاً واحداً على الأقل.';

  @override
  String get rlInstaller => 'ملف التثبيت';

  @override
  String get rlInstallerHint => '.exe أو .zip أو .rar';

  @override
  String get rlPickInstaller => 'اختيار ملف';

  @override
  String get rlRemoveInstaller => 'إزالة ملف التثبيت';

  @override
  String get rlExternalUrl => 'رابط تنزيل خارجي';

  @override
  String get rlPublished => 'منشور';

  @override
  String get rlDraft => 'مسودة';

  @override
  String get rlNoReleases => 'لا توجد إصدارات';

  @override
  String get rlNoReleasesHint => 'أنشئ أول إصدار لمنتج.';

  @override
  String get rlDeleteTitle => 'حذف هذا الإصدار؟';

  @override
  String get rlDeleteBody => 'لن يراه العملاء بعد الآن.';

  @override
  String get rlSaved => 'تم حفظ الإصدار.';

  @override
  String get rlDeleted => 'تم حذف الإصدار.';

  @override
  String get rlUploading => 'جارٍ رفع الملف…';

  @override
  String get rlAllProducts => 'كل المنتجات';

  @override
  String get helpTooltip => 'مساعدة';

  @override
  String get helpExample => 'مثال';

  @override
  String get helpFields => 'الحقول';

  @override
  String get helpUnavailable => 'المساعدة غير متوفرة لهذا القسم.';

  @override
  String get wfFixedTypesNote =>
      'الأنواع الأربعة (عرض تجريبي، اجتماع، تدريب، مرافقة) ثابتة. يمكنك فقط تعديل المدة واللون والحجز عبر الإنترنت.';

  @override
  String get navBilling => 'الفوترة';

  @override
  String get blTitle => 'الاشتراكات والفوترة';

  @override
  String get blSubtitle =>
      'الصيانة والدعم لكل زبون، ودفعات نقدية بانتظار التأكيد.';

  @override
  String get blStatusAll => 'كل الحالات';

  @override
  String get blStatusActive => 'نشط';

  @override
  String get blStatusExpiringSoon => 'ينتهي قريباً';

  @override
  String get blStatusExpired => 'منتهي';

  @override
  String get blStatusNone => 'بدون اشتراك';

  @override
  String get blFilterStatus => 'الحالة';

  @override
  String get blSortBy => 'ترتيب حسب';

  @override
  String get blSortName => 'اسم الزبون';

  @override
  String get blSortExpiry => 'تاريخ الانتهاء';

  @override
  String get blSortConverted => 'تاريخ التحول إلى زبون';

  @override
  String get blSortDirection => 'عكس الترتيب';

  @override
  String get blPendingOnly => 'تجديدات بانتظار التأكيد';

  @override
  String get blSearchHint => 'ابحث عن زبون...';

  @override
  String get blColCustomer => 'الزبون';

  @override
  String get blColExpiry => 'الانتهاء';

  @override
  String get blColDaysLeft => 'الأيام المتبقية';

  @override
  String get blColPending => 'بانتظار التأكيد';

  @override
  String get blNoCustomers => 'لا يوجد زبائن';

  @override
  String get blNoCustomersHint => 'لا يوجد زبون يطابق عوامل التصفية.';

  @override
  String get blDetailTitle => 'فوترة الزبون';

  @override
  String get blBack => 'العودة إلى الاشتراكات';

  @override
  String get blLicense => 'الترخيص';

  @override
  String get blLicenseLifetime => 'ترخيص دائم مدى الحياة (لا ينتهي)';

  @override
  String get blLicenseSince => 'منذ';

  @override
  String get blMaintenance => 'الصيانة والدعم';

  @override
  String get blMaintenanceStarts => 'البداية';

  @override
  String get blMaintenanceExpires => 'الانتهاء';

  @override
  String get blPricePerYear => 'السعر للسنة';

  @override
  String get blCurrency => 'دج';

  @override
  String get blDaysUnit => 'يوم';

  @override
  String get blSetMaintenance => 'تحديد الفترة';

  @override
  String get blSetMaintenanceTitle => 'فترة الصيانة';

  @override
  String get blSaved => 'تم الحفظ.';

  @override
  String get blRenewals => 'طلبات التجديد';

  @override
  String get blNoRenewals => 'لا توجد طلبات تجديد.';

  @override
  String get blRenewalReference => 'مرجع الفاتورة الأولية';

  @override
  String get blRenewalYears => 'السنوات';

  @override
  String get blRenewalAmount => 'المبلغ';

  @override
  String get blRenewalPending => 'بانتظار الدفع';

  @override
  String get blRenewalConfirmed => 'مؤكد';

  @override
  String get blRequestedOn => 'تاريخ الطلب';

  @override
  String get blConfirmedOn => 'تاريخ التأكيد';

  @override
  String get blMarkPaid => 'تأكيد الدفع';

  @override
  String get blMarkPaidTitle => 'تأكيد الدفع نقداً';

  @override
  String get blMarkPaidHint =>
      'أكّد استلام المبلغ نقداً. ستُمدَّد فترة صيانة الزبون تلقائياً.';

  @override
  String get blPaidAt => 'تاريخ الدفع';

  @override
  String get blMarkedPaid => 'تم تأكيد الدفع: تم تمديد الصيانة.';

  @override
  String get blInvoices => 'الفواتير والسندات';

  @override
  String get blNoInvoices => 'لا توجد فواتير.';

  @override
  String get blColInvoice => 'المرجع';

  @override
  String get blColType => 'النوع';

  @override
  String get blColAmount => 'المبلغ (دج)';

  @override
  String get blColIssued => 'تاريخ الإصدار';

  @override
  String get blColPaid => 'تاريخ الدفع';

  @override
  String get blInvoiceTypeLicense => 'ترخيص';

  @override
  String get blInvoiceTypeRenewal => 'تجديد صيانة';

  @override
  String get blInvoicePaid => 'مدفوعة نقداً';

  @override
  String get blInvoicePending => 'بانتظار التحصيل';

  @override
  String get blInvoiceDetails => 'تفاصيل الفاتورة';

  @override
  String get blReceipt => 'السند الممسوح';

  @override
  String get blReceiptNone => 'لا يوجد سند مرفق.';

  @override
  String get blUploadReceipt => 'إرفاق سند (PDF أو صورة)';

  @override
  String get blReplaceReceipt => 'استبدال السند';

  @override
  String get blRemoveReceipt => 'حذف السند';

  @override
  String get blViewReceipt => 'تنزيل السند';

  @override
  String get blReceiptUploaded => 'تم حفظ السند.';

  @override
  String get blReceiptRemoved => 'تم حذف السند.';

  @override
  String get blNewInvoice => 'فاتورة جديدة';

  @override
  String get blInvoiceType => 'نوع الفاتورة';

  @override
  String get blInvoiceAmount => 'المبلغ (دج)';

  @override
  String get blInvoiceAlreadyPaid => 'مدفوعة نقداً مسبقاً';

  @override
  String get blInvoiceCreated => 'تم إنشاء الفاتورة.';

  @override
  String get blAmountInvalid => 'أدخل مبلغاً صحيحاً.';

  @override
  String get blPeriodInvalid => 'يجب أن تكون النهاية بعد البداية.';

  @override
  String get blRenewalPendingQuote => 'بانتظار التسعير';

  @override
  String get blRenewalQuoted => 'تم التسعير، بانتظار الدفع';

  @override
  String get blRenewalRejected => 'مرفوض';

  @override
  String get blQuotePrice => 'تسعير';

  @override
  String get blQuoteTitle => 'تسعير طلب التجديد';

  @override
  String get blQuoteHint =>
      'أدخل المبلغ الإجمالي الذي سيدفعه الزبون نقداً. سيتم إصدار فاتورة أولية.';

  @override
  String get blQuoteAmount => 'المبلغ الإجمالي (دج)';

  @override
  String get blQuoteIssue => 'إصدار الفاتورة الأولية';

  @override
  String get blQuoted => 'تم إصدار الفاتورة الأولية.';

  @override
  String get blWorkstations => 'أجهزة';

  @override
  String get blDossiers => 'ملفات';

  @override
  String get blNotesLabel => 'ملاحظات';

  @override
  String get ivHotfixLabel => 'نسخة خاصة (Hotfix)';

  @override
  String get ivHotfixHint => 'سيرى الزبون هذا الملف كنسخة خاصة (Hotfix).';

  @override
  String get productImage => 'صورة المنتج';

  @override
  String get productUploadImage => 'رفع صورة المنتج';

  @override
  String get productUploadingImage => 'جاري رفع الصورة...';

  @override
  String get productRemoveImage => 'حذف الصورة';

  @override
  String get productTabsBasic => 'المعلومات الأساسية';

  @override
  String get productTabsWeb => 'بيانات الموقع والكتالوج';

  @override
  String get productTabsDemo => 'النسخة التجريبية';

  @override
  String get productImageUploaded => 'تم رفع صورة المنتج بنجاح.';

  @override
  String get productImageTooLarge => 'حجم الصورة يتجاوز 5 ميغابايت.';

  @override
  String get productImageUrl => 'أو الصق رابط صورة';

  @override
  String get productImageUrlInvalid => 'رابط الصورة غير صالح (http/https).';

  @override
  String get productImageHint =>
      'PNG أو JPG أو WEBP أو SVG — 5 ميغابايت كحد أقصى.';

  @override
  String get productImageSvgPreview =>
      'معاينة SVG غير متوفرة، لكن الملف محفوظ.';

  @override
  String get productSlug => 'الرابط المختصر (Slug)';

  @override
  String get productSlugHint => 'يُولَّد تلقائيًا من الاسم إذا ترك فارغًا.';

  @override
  String get productSlugInvalid => 'أحرف لاتينية صغيرة وأرقام وشرطات فقط.';

  @override
  String get productSortOrder => 'ترتيب العرض';

  @override
  String get productSortOrderInvalid => 'أدخل رقمًا بين 0 و 100000.';

  @override
  String get productSummaryLabel => 'ملخص قصير';

  @override
  String get productWebDescriptionLabel => 'الوصف الكامل';

  @override
  String get productFeatures => 'المميزات';

  @override
  String get productFeatureHint => 'أضف ميزة ثم اضغط إضافة';

  @override
  String get productAddFeature => 'إضافة ميزة';

  @override
  String get customerViewProspectHistory => 'سجل مرحلة المهتم';

  @override
  String get customerTabLicenses => 'التراخيص والبرمجيات';

  @override
  String get customerTabBilling => 'الاشتراكات والفوترة';

  @override
  String get customerTabSupport => 'الدعم الفني والتدخلات';

  @override
  String get customerTabAppointments => 'المواعيد والتدريب';

  @override
  String get customerTabPortal => 'حسابات البوابة';

  @override
  String get customerTabProspectArchive => 'أرشيف وسجل المهتم';

  @override
  String get filterActiveLeads => 'المهتمين الحاليين';

  @override
  String get filterConvertedLeads => 'المحولين لزبائن';

  @override
  String get filterAllLeads => 'الكل';

  @override
  String get prospectStageTimeline => 'مسار مراحل البيع السابقة';

  @override
  String get prospectInitialData => 'البيانات الأولية للمهتم';

  @override
  String get customerSoftelClient => 'عميل Softel';

  @override
  String customerMaintenanceActiveUntil(String date) {
    return 'صيانة نشطة حتى $date';
  }

  @override
  String get customerMaintenanceExpired => 'صيانة منتهية';

  @override
  String get customerMaintenanceNone => 'لا توجد صيانة';

  @override
  String get customerSubscriptionLifetime => 'ترخيص دائم';

  @override
  String get customerSubscriptionMaintenance => 'صيانة ودعم فني';

  @override
  String customerSubscriptionPeriod(String start, String end) {
    return 'من $start إلى $end';
  }

  @override
  String get customerNoSubscriptions => 'لا توجد اشتراكات';

  @override
  String get customerOpenBilling => 'فتح الفوترة';

  @override
  String get customerNoInterventions => 'لا توجد تدخلات';

  @override
  String get customerNoStageHistory => 'لا يوجد سجل مراحل';

  @override
  String get customerNoProspectActivities => 'لا توجد أنشطة مسجلة قبل التحويل';

  @override
  String get customerProspectActivities => 'أنشطة مرحلة المهتم';

  @override
  String get customerInitialInquiryDate => 'تاريخ أول استفسار';

  @override
  String get customerProspectNotes => 'ملاحظات المبيعات';

  @override
  String get prospectTabOverview => 'النظرة العامة والاهتمامات';

  @override
  String get prospectTabPipeline => 'مسار البيع والمراحل';

  @override
  String get prospectTabFollowUps => 'المتابعات والمهام';

  @override
  String get prospectTabActivities => 'سجل الأنشطة والملاحظات';

  @override
  String get prospectTabDemos => 'النسخ التجريبية والمواعيد';

  @override
  String get copyDemoLink => 'نسخ رابط النسخة التجريبية';

  @override
  String get demoLinkCopied => 'تم نسخ الرابط';

  @override
  String get customerFilterAll => 'الكل';

  @override
  String get customerFilterMaintenance => 'الصيانة';

  @override
  String get customerFilterPortal => 'البوابة';

  @override
  String get customerMaintenanceActivePlan => 'خطة نشطة';

  @override
  String get customerMaintenanceExpiringSoon => 'تنتهي خلال أقل من 60 يومًا';

  @override
  String get customerMaintenanceExpiredNone => 'منتهية / بدون خطة';

  @override
  String get customerPortalHas => 'لديه حساب بوابة';

  @override
  String get customerPortalNone => 'بدون حساب';

  @override
  String get customerQuickCall => 'اتصال';

  @override
  String get trialFieldPeriod => 'الفترة';

  @override
  String get trialFieldCreatedBy => 'أنشئ بواسطة';

  @override
  String get trialFieldLink => 'رابط النسخة التجريبية';

  @override
  String get openDemoLink => 'فتح رابط النسخة التجريبية';

  @override
  String get phoneCopied => 'تم نسخ الرقم';

  @override
  String get phoneTapToCopy => 'انقر لنسخ الرقم';

  @override
  String get searchKeyboardHint => '↑ ↓ للتنقل · ↵ للفتح · Esc للإغلاق';

  @override
  String get actionOpen => 'فتح';

  @override
  String get calNewAppointment => 'موعد جديد';

  @override
  String get calQuickAll => 'الكل';

  @override
  String get calQuickDemos => 'تجارب برمجية';

  @override
  String get calQuickTrainings => 'تدريب ومرافقة';

  @override
  String get calQuickSupport => 'تدخلات الدعم';

  @override
  String get calQuickFollowUps => 'متابعات';

  @override
  String get empWorkstationName => 'اسم الحاسوب / المكتب';

  @override
  String get empEditWorkstation => 'تعديل بيانات الحاسوب';

  @override
  String get empRole => 'القسم والدور';

  @override
  String get empRoleSales => 'المبيعات والتجاري';

  @override
  String get empRoleSupport => 'الدعم الفني والتدخلات';

  @override
  String get empRoleManagement => 'الإدارة والإشراف';

  @override
  String get empRoleTraining => 'المرافقة والتدريب';

  @override
  String get empPresenceAvailable => 'متاح للعمل';

  @override
  String get empPresenceBusy => 'في مكالمة أو اجتماع';

  @override
  String get empPresenceAway => 'مهمة خارجية';

  @override
  String get empPresenceBreak => 'استراحة';

  @override
  String get empActionsToday => 'إنجازات اليوم';

  @override
  String get empOnlineNow => 'المتصلون الآن';

  @override
  String get empSalesActive => 'فريق المبيعات';

  @override
  String get empSupportActive => 'فريق الدعم';

  @override
  String get empTeamActionsToday => 'إجمالي عمليات الفريق اليوم';

  @override
  String get empSaveFailed => 'تعذّر الحفظ. حاول مرة أخرى.';

  @override
  String empFollowUpsCount(int count) {
    return '$count متابعة';
  }

  @override
  String empTicketsCount(int count) {
    return '$count تذكرة دعم';
  }

  @override
  String empAppointmentsCount(int count) {
    return '$count موعد';
  }

  @override
  String get navAnalytics => 'التحليلات والتقارير';

  @override
  String get analyticsSubtitle => 'مؤشرات الأداء، مسار الصفقات، ونشاط الفريق';

  @override
  String get analyticsRangeMonth => 'هذا الشهر';

  @override
  String get analyticsRangeQuarter => 'الربع الحالي';

  @override
  String get analyticsRangeYear => 'هذه السنة';

  @override
  String get analyticsRangeAll => 'الكل';

  @override
  String get analyticsTabSales => 'المبيعات والصفقات';

  @override
  String get analyticsTabRevenue => 'الاشتراكات والتراخيص';

  @override
  String get analyticsTabSupport => 'الدعم وجودة الخدمة';

  @override
  String get analyticsTabTeam => 'إنتاجية الفريق';

  @override
  String get analyticsFunnel => 'قمع تحويل المبيعات';

  @override
  String get analyticsFunnelWon => 'الصفقات الرابحة';

  @override
  String get analyticsLossReasons => 'أسباب خسارة الصفقات';

  @override
  String get analyticsNoReason => 'بدون سبب محدد';

  @override
  String get analyticsSources => 'قنوات استقطاب المهتمين';

  @override
  String get analyticsTopCities => 'أهم المدن';

  @override
  String get analyticsUnknown => 'غير محدد';

  @override
  String get analyticsAvgCycle => 'متوسط دورة البيع';

  @override
  String get analyticsUnitDays => 'يوم';

  @override
  String get analyticsUnitHours => 'ساعة';

  @override
  String get analyticsNoData => 'لا توجد بيانات لهذه الفترة';

  @override
  String get analyticsTotalCustomers => 'العملاء';

  @override
  String get analyticsActiveMaintenance => 'صيانة سارية';

  @override
  String get analyticsExpiredMaintenance => 'صيانة منتهية';

  @override
  String get analyticsAvgPcs => 'منتجات لكل عميل';

  @override
  String get analyticsRetention => 'معدل تجديد الصيانة السنوية';

  @override
  String get analyticsRetentionShort => 'التجديد';

  @override
  String get analyticsProductPopularity => 'المنتجات الأكثر مبيعًا';

  @override
  String get analyticsExpiringTitle => 'صيانة تنتهي خلال 60 يومًا';

  @override
  String get analyticsExpiringNone => 'لا توجد صيانة تنتهي قريبًا.';

  @override
  String get analyticsExpiringAction => 'فتح الفوترة';

  @override
  String get analyticsTotalTickets => 'التذاكر';

  @override
  String get analyticsResolvedTickets => 'تذاكر محلولة';

  @override
  String get analyticsResolutionRate => 'معدل الحل';

  @override
  String get analyticsResolutionSpeed => 'متوسط سرعة حل التذاكر';

  @override
  String get analyticsTicketsByCategory => 'التذاكر حسب الفئة';

  @override
  String get analyticsDemoConversion => 'معدل تحويل الديمو إلى شراء';

  @override
  String get analyticsDemoConverted => 'تحولوا إلى عملاء';

  @override
  String get analyticsDemoNotConverted => 'بدون شراء';

  @override
  String get analyticsLeaderboard => 'ترتيب الفريق';

  @override
  String get analyticsColEmployee => 'الموظف';

  @override
  String get analyticsColActivities => 'الأنشطة';

  @override
  String get analyticsColInterventions => 'التدخلات';

  @override
  String get analyticsColDeals => 'صفقات مغلقة';

  @override
  String analyticsExpiringCount(int count) {
    return '$count صيانة تحتاج إلى تجديد قريبًا';
  }
}
