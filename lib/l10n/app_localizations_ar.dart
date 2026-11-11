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
  String countProspects(int count) {
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
  String countActivities(int count) {
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
  String activitiesCountSubtitle(int count) {
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
  String pipelineCountSubtitle(int count) {
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
  String deactivateStageProspects(int count) {
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
}
