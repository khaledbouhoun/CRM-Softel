// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProspects => 'Prospects';

  @override
  String get navPipeline => 'Pipeline';

  @override
  String get navActivities => 'Activities';

  @override
  String get navFollowUps => 'Follow-ups';

  @override
  String get navProducts => 'Products';

  @override
  String get navSalesStages => 'Sales stages';

  @override
  String get navLossReasons => 'Loss reasons';

  @override
  String get navServerDisplay => 'Server & display';

  @override
  String get navSettingsSection => 'SETTINGS';

  @override
  String get themeLight => 'Light theme';

  @override
  String get themeDark => 'Dark theme';

  @override
  String get globalSearchHint =>
      'Search a prospect (name, company, phone…) then press Enter';

  @override
  String get connOnline => 'Connected';

  @override
  String get connOffline => 'Offline';

  @override
  String get connChecking => 'Checking…';

  @override
  String get connUnknown => 'Unknown';

  @override
  String connServer(Object url) {
    return 'Server: $url';
  }

  @override
  String connLastCheck(Object time) {
    return '\nLast check: $time';
  }

  @override
  String get connClickToCheck => '\nClick to check now.';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSaving => 'Saving…';

  @override
  String get actionClose => 'Close';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDeactivate => 'Deactivate';

  @override
  String get actionReactivate => 'Reactivate';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionBack => 'Back';

  @override
  String get actionSchedule => 'Schedule';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionMoveUp => 'Move up';

  @override
  String get actionMoveDown => 'Move down';

  @override
  String get actionOpenRecord => 'Open record';

  @override
  String get loading => 'Loading…';

  @override
  String get loadingRecord => 'Loading record…';

  @override
  String get loadingStages => 'Loading stages…';

  @override
  String get errorOccurred => 'Something went wrong';

  @override
  String get serverUnreachable => 'Server unreachable';

  @override
  String get serverSettings => 'Server settings';

  @override
  String get errorUnknown => 'Unknown error.';

  @override
  String get noItems => 'No items';

  @override
  String get noResults => 'No results';

  @override
  String get searchHint => 'Search…';

  @override
  String get filterAll => 'All';

  @override
  String get clearPeriod => 'Clear period';

  @override
  String get period => 'Period';

  @override
  String get perPage => 'Per page';

  @override
  String get pageFirst => 'First page';

  @override
  String get pagePrevious => 'Previous page';

  @override
  String get pageNext => 'Next page';

  @override
  String get pageLast => 'Last page';

  @override
  String pageOf(Object page, Object pages) {
    return 'Page $page / $pages';
  }

  @override
  String rangeOfTotal(Object from, Object to, Object total) {
    return '$from–$to of $total';
  }

  @override
  String showMoreCount(Object count) {
    return 'Show more ($count)';
  }

  @override
  String get color => 'Color';

  @override
  String get colDate => 'Date';

  @override
  String get colStatus => 'Status';

  @override
  String get colActions => 'Actions';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldDescriptionRequired => 'Description *';

  @override
  String get fieldOutcome => 'Outcome';

  @override
  String get fieldDateTimeRequired => 'Date and time *';

  @override
  String get fieldNameRequired => 'Name *';

  @override
  String get fieldLabelRequired => 'Label *';

  @override
  String get fieldTypeRequired => 'Type *';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldContact => 'Contact';

  @override
  String get colContactDetails => 'Contact details';

  @override
  String get statusActive => 'Active';

  @override
  String get statusActiveFem => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusInactiveFem => 'Inactive';

  @override
  String get optionOther => 'Other';

  @override
  String get validThisField => 'This field';

  @override
  String validRequired(Object field) {
    return '$field is required.';
  }

  @override
  String validMaxLength(Object max) {
    return '$max characters maximum.';
  }

  @override
  String get validEmailInvalid => 'Invalid e-mail address.';

  @override
  String get validPhoneChars =>
      'The number may only contain digits, spaces, +, -, . or ().';

  @override
  String get validPhoneLength =>
      'The number must contain between 6 and 20 digits.';

  @override
  String get validColorInvalid => 'Invalid color (format #RRGGBB).';

  @override
  String get validServerRequired => 'The server address is required.';

  @override
  String get validServerInvalid =>
      'Invalid address. Example: http://192.168.1.100:8000/api/v1';

  @override
  String get validServerScheme =>
      'The address must start with http:// or https://';

  @override
  String get validFieldDescription => 'The description';

  @override
  String get validFieldName => 'The name';

  @override
  String get validFieldLabel => 'The label';

  @override
  String get validFieldCompany => 'The company / customer name';

  @override
  String get validFixFields => 'Please correct the highlighted fields.';

  @override
  String get validSelectProspect => 'Select a prospect.';

  @override
  String get validSelectStage => 'Select a stage.';

  @override
  String get validDateRequired => 'The date is required.';

  @override
  String get validFollowUpFuture => 'The follow-up date must be in the future.';

  @override
  String get validDateNotFuture => 'The date cannot be in the future.';

  @override
  String get validNextFollowUpFuture =>
      'The next follow-up must be in the future.';

  @override
  String get validNextFollowUpAfterActivity =>
      'The next follow-up must be after the activity.';

  @override
  String get validActivityNotFuture =>
      'An activity cannot be in the future: schedule a follow-up instead.';

  @override
  String get validInitialStageRequired => 'The initial stage is required.';

  @override
  String get validStageDisabled => 'This stage is deactivated.';

  @override
  String get validAlreadyInStage => 'The prospect is already in this stage.';

  @override
  String get validLossReasonRequiredForLost =>
      'A loss reason is required for a \"lost\" stage.';

  @override
  String get validLossReasonRequired => 'The loss reason is required.';

  @override
  String get validReasonNeedsDetails => 'This reason requires details.';

  @override
  String get validDetailsRequired => 'Details are required for this reason.';

  @override
  String get typeAtLeastTwo => 'Type at least 2 characters…';

  @override
  String errTimeout(Object server) {
    return 'The server ($server) did not answer in time. Check the network and try again.';
  }

  @override
  String errConnection(Object server) {
    return 'Cannot reach the server ($server). Check that the central computer is on, that you are on the company network and that the server address is correct.';
  }

  @override
  String errConnectionShort(Object server) {
    return 'Cannot reach the server ($server). Check the network and the server address.';
  }

  @override
  String errCertificate(Object server) {
    return 'Server certificate rejected ($server).';
  }

  @override
  String get errCancelled => 'Request cancelled.';

  @override
  String errReceiveTimeout(Object server) {
    return 'The server response ($server) could not be read in time.';
  }

  @override
  String errCommunication(Object details) {
    return 'Communication error with the server: $details';
  }

  @override
  String get errBadRequest => 'Invalid request.';

  @override
  String get errNotFound => 'Item not found on the server.';

  @override
  String get errNotSupported => 'Operation not supported by the server.';

  @override
  String get errConflict => 'Operation refused: conflict with existing data.';

  @override
  String get errValidation => 'Some data is invalid.';

  @override
  String errServer(Object status) {
    return 'Internal server error ($status). Try again or contact the administrator.';
  }

  @override
  String errUnexpectedStatus(Object status) {
    return 'Unexpected server response ($status).';
  }

  @override
  String errUnexpectedResponse(Object details) {
    return 'Unexpected server response: $details';
  }

  @override
  String errUnexpected(Object details) {
    return 'Unexpected error: $details';
  }

  @override
  String get errExpectedObject =>
      'Unexpected server response: a JSON object was expected.';

  @override
  String get errExpectedList =>
      'Unexpected server response: a JSON list was expected.';

  @override
  String get errExpectedPaged =>
      'Unexpected server response: a paginated list was expected.';

  @override
  String get errMissingProspect =>
      'Unexpected server response: the updated prospect is missing.';

  @override
  String get errBusy => 'Operation already in progress.';

  @override
  String relToday(Object time) {
    return 'today $time';
  }

  @override
  String relTomorrow(Object time) {
    return 'tomorrow $time';
  }

  @override
  String relYesterday(Object time) {
    return 'yesterday $time';
  }

  @override
  String relInDays(Object days) {
    return 'in $days d';
  }

  @override
  String relDaysAgo(Object days) {
    return '$days d ago';
  }

  @override
  String get dashSubtitle => 'Overview of sales activity';

  @override
  String dashUpdatedAt(Object time) {
    return 'Updated at $time';
  }

  @override
  String dashStale(Object error) {
    return 'Figures may be outdated: $error';
  }

  @override
  String get stageTypeOpen => 'In progress';

  @override
  String get dashWon => 'Won';

  @override
  String get dashLost => 'Lost';

  @override
  String dashWinRate(Object rate) {
    return 'Win rate: $rate %';
  }

  @override
  String get dashFollowUpsToday => 'Follow-ups today';

  @override
  String get dashFollowUpsOverdue => 'Overdue follow-ups';

  @override
  String get dashFollowUpsUpcoming => 'Upcoming follow-ups';

  @override
  String dashFollowUpsUpcomingDays(Object days) {
    return 'Upcoming follow-ups ($days d)';
  }

  @override
  String get dashProspectsByStage => 'Prospects by stage';

  @override
  String get dashClickStage => 'Click a stage to see its prospects';

  @override
  String get noStages => 'No stages';

  @override
  String get dashOutcomes => 'Opportunity outcomes';

  @override
  String get dashRecentActivities => 'Recent activities';

  @override
  String get noRecentActivities => 'No recent activity';

  @override
  String get dashWhyLose => 'Why do we lose sales?';

  @override
  String get dashLostByReason => 'Lost prospects by reason';

  @override
  String get noLostProspects => 'No lost prospect';

  @override
  String get prospectsSubtitle => 'Manage prospects and opportunities';

  @override
  String get newProspect => 'New prospect';

  @override
  String get editProspect => 'Edit prospect';

  @override
  String get createProspect => 'Create prospect';

  @override
  String get addProspect => 'Add a prospect';

  @override
  String get noProspectMatchesFilters => 'No prospect matches the filters';

  @override
  String get noProspectsYet => 'No prospects yet';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get prospectSearchHint => 'Name, company, phone, ID…';

  @override
  String get fieldStage => 'Stage';

  @override
  String stageInactiveSuffix(Object name) {
    return '$name (inactive)';
  }

  @override
  String get allStages => 'All stages';

  @override
  String get fieldProduct => 'Product';

  @override
  String get allProducts => 'All products';

  @override
  String get fieldLossReason => 'Loss reason';

  @override
  String get allReasons => 'All reasons';

  @override
  String get filterCreatedDate => 'Creation date';

  @override
  String filtersUnavailable(Object error) {
    return 'Filter lists unavailable: $error\nClick to retry.';
  }

  @override
  String prospectCreated(Object name) {
    return 'Prospect \"$name\" created.';
  }

  @override
  String get prospectUpdated => 'Prospect updated.';

  @override
  String prospectMovedTo(Object name, Object stage) {
    return '\"$name\" moved to stage \"$stage\".';
  }

  @override
  String get colCompanyContact => 'Company / contact';

  @override
  String get colLastActivity => 'Last activity';

  @override
  String get colNextFollowUp => 'Next follow-up';

  @override
  String get colCreatedOn => 'Created on';

  @override
  String get changeStage => 'Change stage';

  @override
  String get scheduleFollowUp => 'Schedule a follow-up';

  @override
  String get addActivity => 'Add an activity';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get fieldCompanyRequired => 'Company / customer *';

  @override
  String get fieldCompany => 'Company / customer';

  @override
  String get fieldContactPerson => 'Contact person';

  @override
  String get sectionSalesFollowUp => 'Sales follow-up';

  @override
  String get currentStage => 'Current stage';

  @override
  String get currentStageLabel => 'Current stage:  ';

  @override
  String get useChangeStageHint =>
      'Use \"Change stage\" to modify it (history is kept).';

  @override
  String stagesUnavailable(Object error) {
    return 'Stages unavailable: $error';
  }

  @override
  String get initialStageRequired => 'Initial stage *';

  @override
  String get markAsLost => 'Mark as lost';

  @override
  String get confirmChange => 'Confirm change';

  @override
  String get newStageRequired => 'New stage *';

  @override
  String get stageMarksWon => 'This stage marks a won sale.';

  @override
  String get lossReasonRequiredLabel => 'Loss reason *';

  @override
  String get noActiveLossReason =>
      'No active reason: add some in \"Loss reasons\".';

  @override
  String reasonDetailsRequiredSuffix(Object label) {
    return '$label  (details required)';
  }

  @override
  String get detailsRequiredLabel => 'Details *';

  @override
  String get details => 'Details';

  @override
  String get interestedProducts => 'Interested products';

  @override
  String get invalidProspectId => 'Invalid prospect identifier.';

  @override
  String dataMaybeStale(Object error) {
    return 'Data may be outdated: $error';
  }

  @override
  String stageChanged(Object stage) {
    return 'Stage changed: \"$stage\".';
  }

  @override
  String createdOnDate(Object date) {
    return 'Created on $date';
  }

  @override
  String get sectionInformation => 'Information';

  @override
  String get updatedLabel => 'Updated';

  @override
  String get productsUpdated => 'Products updated.';

  @override
  String get noProductAssociated => 'No product associated.';

  @override
  String get sectionCommercialStage => 'Sales stage';

  @override
  String get opportunityLost => 'Lost opportunity';

  @override
  String get reason => 'Reason';

  @override
  String get saleWon => 'Sale won';

  @override
  String get stageHistory => 'Stage history';

  @override
  String get noStageChanges => 'No stage change recorded.';

  @override
  String get creationArrow => 'Creation →';

  @override
  String pendingCount(Object count) {
    return '$count pending';
  }

  @override
  String get noFollowUpScheduled => 'No follow-up scheduled.';

  @override
  String closedFollowUps(Object count) {
    return 'Completed or cancelled follow-ups ($count)';
  }

  @override
  String get activityHistory => 'Activity history';

  @override
  String get activityWord => 'activity';

  @override
  String get noActivitiesForProspect =>
      'No activity recorded for this prospect.';

  @override
  String get showOlderActivities => 'Show older activities';

  @override
  String get activitiesSubtitle => 'Calls, appointments, messages and notes';

  @override
  String get newActivity => 'New activity';

  @override
  String get activitySearchHint => 'Title, description, outcome…';

  @override
  String get allTypes => 'All types';

  @override
  String get noActivityMatchesFilters => 'No activity matches the filters';

  @override
  String get noActivities => 'No activity recorded';

  @override
  String get colProspect => 'Prospect';

  @override
  String prospectNumber(Object id) {
    return 'Prospect #$id';
  }

  @override
  String outcomeLine(Object outcome) {
    return 'Outcome: $outcome';
  }

  @override
  String get activityTypeLabel => 'Activity type';

  @override
  String get activityDescriptionHint => 'What was said / done…';

  @override
  String get activityOutcomeHint =>
      'E.g. interested, hesitates on price, asks for a demo…';

  @override
  String get nextStepsSection => 'Next steps';

  @override
  String get nextFollowUpOptional => 'Next follow-up (optional)';

  @override
  String get alsoScheduleFollowUp => 'Also schedule a follow-up on this date';

  @override
  String get willAppearInFollowUps => 'It will appear in \"Follow-ups\".';

  @override
  String get followUpSubject => 'Follow-up subject';

  @override
  String get leaveEmptyAuto => 'Leave empty for an automatic text';

  @override
  String get activitySaved => 'Activity saved.';

  @override
  String get activitySavedAndFollowUp =>
      'Activity saved and follow-up scheduled.';

  @override
  String get activitySavedFollowUpFailed =>
      'The activity is saved, but the follow-up could NOT be scheduled:';

  @override
  String get activityTypeCall => 'Phone call';

  @override
  String get activityTypeAppointment => 'Appointment';

  @override
  String get activityTypeMessage => 'Message';

  @override
  String get activityTypeNote => 'Note';

  @override
  String followUpAfterActivity(Object type, Object date) {
    return 'Follow-up after: $type of $date';
  }

  @override
  String get followUpsSubtitle => 'Track reminders and upcoming appointments';

  @override
  String get followUpSearchHint => 'Prospect, description…';

  @override
  String get noFollowUpsToday => 'No follow-up planned today';

  @override
  String get noFollowUpsOverdue => 'No overdue follow-up';

  @override
  String get noFollowUpsUpcoming => 'No upcoming follow-up';

  @override
  String get noFollowUpsDone => 'No completed follow-up';

  @override
  String get noFollowUpsCancelled => 'No cancelled follow-up';

  @override
  String get colDueDate => 'Due date';

  @override
  String get markAsDone => 'Mark as done';

  @override
  String get cancelFollowUp => 'Cancel follow-up';

  @override
  String get followUpStatusPending => 'Pending';

  @override
  String get followUpStatusCompleted => 'Completed';

  @override
  String get followUpStatusCancelled => 'Cancelled';

  @override
  String get followUpViewToday => 'Today';

  @override
  String get followUpViewOverdue => 'Overdue';

  @override
  String get followUpViewUpcoming => 'Upcoming';

  @override
  String get followUpViewCompleted => 'Completed';

  @override
  String get followUpViewCancelled => 'Cancelled';

  @override
  String get followUpScheduled => 'Follow-up scheduled.';

  @override
  String get followUpUpdated => 'Follow-up updated.';

  @override
  String get followUpCompleted => 'Follow-up marked as done.';

  @override
  String followUpCompletedActivityFailed(Object error) {
    return 'Follow-up marked as done, but the activity could not be saved ($error). The outcome is kept in the follow-up note; add the activity from the prospect page.';
  }

  @override
  String get followUpCancelled => 'Follow-up cancelled.';

  @override
  String get editFollowUp => 'Edit follow-up';

  @override
  String get quickTomorrow => 'Tomorrow';

  @override
  String get quickIn3Days => 'In 3 days';

  @override
  String get quickIn1Week => 'In 1 week';

  @override
  String get quickIn2Weeks => 'In 2 weeks';

  @override
  String get followUpDescriptionHint =>
      'E.g. call back to confirm the quotation';

  @override
  String get completeFollowUpTitle => 'Mark follow-up as done';

  @override
  String get finishFollowUp => 'Complete follow-up';

  @override
  String dueOn(Object date) {
    return 'Due on $date';
  }

  @override
  String get recordOutcomeAsActivity => 'Record the outcome as an activity';

  @override
  String get recommendedKeepsHistory =>
      'Recommended: keeps the history of the exchange.';

  @override
  String get completeOutcomeHint =>
      'E.g. agreement in principle, wants to think about it…';

  @override
  String companyDueOn(Object company, Object date) {
    return '$company — due on $date';
  }

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get followUpOverdueTip => 'Overdue follow-up';

  @override
  String get pipelineTitle => 'Sales pipeline';

  @override
  String get pipelineSubtitle => 'Prospects grouped by stage';

  @override
  String get pipelineFilterHint => 'Filter all stages…';

  @override
  String get noStagesConfigured => 'No sales stage configured';

  @override
  String get configureStages => 'Configure stages';

  @override
  String prospectMovedToStage(Object name, Object stage) {
    return '\"$name\" moved to \"$stage\".';
  }

  @override
  String get dropCardHere => 'Drop a card here';

  @override
  String get stageDeactivated => 'Stage deactivated';

  @override
  String get moveTo => 'Move to…';

  @override
  String moveToStage(Object stage) {
    return 'Move to \"$stage\"';
  }

  @override
  String productAdded(Object name) {
    return 'Product \"$name\" added.';
  }

  @override
  String get productUpdated => 'Product updated.';

  @override
  String get productReactivated => 'Product reactivated.';

  @override
  String get productDeactivated => 'Product deactivated.';

  @override
  String deactivateQuestion(Object name) {
    return 'Deactivate \"$name\"?';
  }

  @override
  String get deactivateProductBody =>
      'The product can no longer be linked to new prospects. Existing links and history are kept.';

  @override
  String get productsSubtitle => 'Software and services offered to prospects';

  @override
  String get newProduct => 'New product';

  @override
  String get productSearchHint => 'Search a product…';

  @override
  String get showInactiveProducts => 'Show inactive products';

  @override
  String get noProducts => 'No product';

  @override
  String get noProductMatches => 'No product matches';

  @override
  String get addProduct => 'Add a product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productActive => 'Active product';

  @override
  String get productActiveHint =>
      'Only active products can be linked to prospects.';

  @override
  String get productPack => 'Pack (tier suite)';

  @override
  String get productNoPack => 'Standalone product (no pack)';

  @override
  String get productNewPack => 'New pack';

  @override
  String get productPackName => 'Pack name';

  @override
  String get productPackCode => 'Pack code';

  @override
  String get productDemoUrl => 'Demo version URL';

  @override
  String get productDemoUrlHint =>
      'Fixed demo link for this product (e.g. https://...)';

  @override
  String get productUploadDemo => 'Upload demo installer to server';

  @override
  String get productDemoUploaded =>
      'Demo installer uploaded successfully and URL updated.';

  @override
  String get productUploadingDemo => 'Uploading demo file to server…';

  @override
  String get productActiveOnWeb => 'Show on website & portal';

  @override
  String get productActiveOnWebHint =>
      'Makes this product visible and selectable by online clients.';

  @override
  String get productPacksTitle => 'Manage packs';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get noActiveProducts => 'No active product. Add some in \"Products\".';

  @override
  String productInactiveSuffix(Object name) {
    return '$name (inactive)';
  }

  @override
  String stageCreated(Object name) {
    return 'Stage \"$name\" created.';
  }

  @override
  String get stageUpdated => 'Stage updated.';

  @override
  String get stageReactivated => 'Stage reactivated.';

  @override
  String get stageDeactivatedMsg => 'Stage deactivated.';

  @override
  String get stageDeleted => 'Stage deleted.';

  @override
  String deleteQuestion(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteStageBody =>
      'This stage was never used. It will be permanently deleted.';

  @override
  String get orderNotSaved => 'The new order was not saved:';

  @override
  String get stagesSubtitle =>
      'Define the pipeline: order, color and type (in progress / won / lost). Used stages cannot be deleted, only deactivated.';

  @override
  String get newStage => 'New stage';

  @override
  String get savingNewOrder => 'Saving the new order…';

  @override
  String get createStagesHint =>
      'Create at least one \"in progress\", one \"won\" and one \"lost\" stage.';

  @override
  String get createStage => 'Create a stage';

  @override
  String prospectsCountShort(Object count) {
    return '$count prospect(s)';
  }

  @override
  String get stageUsedNoDelete =>
      'Used by prospects or history: cannot be deleted.';

  @override
  String get deleteImpossibleUsed => 'Cannot delete (stage in use)';

  @override
  String get editStage => 'Edit stage';

  @override
  String get stageTypeLocked =>
      'Stage already in use: its type can no longer change (history protection).';

  @override
  String get lostRequiresReasonHint =>
      '\"Lost\" requires a loss reason when changing stage.';

  @override
  String get stageActive => 'Active stage';

  @override
  String get stageUsedDeactivateInstead =>
      'This stage is used by prospects or their history: deactivate it instead of deleting it.';

  @override
  String get stageTypeWon => 'Won';

  @override
  String get stageTypeLost => 'Lost';

  @override
  String get reasonAdded => 'Reason added.';

  @override
  String get reasonUpdated => 'Reason updated.';

  @override
  String get reasonReactivated => 'Reason reactivated.';

  @override
  String get reasonDeactivated => 'Reason deactivated.';

  @override
  String get deactivateReasonBody =>
      'This reason will no longer be offered. Prospects already lost with it keep it.';

  @override
  String get lossReasonsSubtitle =>
      'Reasons offered when a prospect moves to a \"lost\" stage. They feed the lost-sales analysis.';

  @override
  String get newReason => 'New reason';

  @override
  String get lossReasonsReadOnly =>
      'The server does not allow managing loss reasons from the app: read-only list.';

  @override
  String get noLossReasons => 'No loss reason';

  @override
  String get noActiveReasonWarning =>
      'Without an active reason, no prospect can move to a \"lost\" stage.';

  @override
  String get detailsRequired => 'Details required';

  @override
  String get editReason => 'Edit reason';

  @override
  String get newLossReason => 'New loss reason';

  @override
  String get reasonLabelHint => 'E.g. Too expensive';

  @override
  String get detailsMandatory => 'Details mandatory';

  @override
  String get detailsMandatoryHint =>
      'E.g. \"Competitor chosen\" → say which one.';

  @override
  String get reasonActive => 'Active reason';

  @override
  String get settingsSavedOnline => 'Settings saved. Server reachable.';

  @override
  String get settingsSavedOffline =>
      'Settings saved on this computer, but the server is not answering at the moment.';

  @override
  String get settingsSubtitle => 'Settings specific to this computer';

  @override
  String get firstLaunchHint =>
      'First use: enter the address of the central computer (Laravel server) on the company network, test the connection, then save.';

  @override
  String get settingsServerTitle => 'Application server';

  @override
  String get settingsServerSubtitle =>
      'Laravel API hosted on the central computer (local network)';

  @override
  String get fieldApiAddress => 'API address *';

  @override
  String get apiAddressHelp =>
      'Format: http://IP_ADDRESS:PORT/api/v1 — do not use \"localhost\" on employee computers.';

  @override
  String get fieldTimeout => 'Maximum timeout';

  @override
  String secondsShort(Object seconds) {
    return '$seconds s';
  }

  @override
  String get testing => 'Testing…';

  @override
  String get testConnection => 'Test connection';

  @override
  String connectionSuccess(Object url) {
    return 'Connection to $url succeeded';
  }

  @override
  String get settingsDisplay => 'Display';

  @override
  String get themeLightShort => 'Light';

  @override
  String get themeDarkShort => 'Dark';

  @override
  String get themeSystemShort => 'System';

  @override
  String get settingsAbout => 'About';

  @override
  String get aboutApplication => 'Application';

  @override
  String aboutClient(Object app) {
    return '$app — Windows client';
  }

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutData => 'Data';

  @override
  String get aboutDataBody =>
      'All data is stored on the central server. Only the server address, language and theme are saved on this computer.';

  @override
  String get changeProspect => 'Change prospect';

  @override
  String get prospectRequiredLabel => 'Prospect *';

  @override
  String get errNotJson =>
      'The server answered, but not in JSON. Check that the address ends with /api/v1.';

  @override
  String countProspects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prospects',
      one: '1 prospect',
      zero: 'No prospects',
    );
    return '$_temp0';
  }

  @override
  String countActivities(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
      zero: 'No activities',
    );
    return '$_temp0';
  }

  @override
  String activitiesCountSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '$count activity',
    );
    return '$_temp0 — calls, appointments, messages and notes';
  }

  @override
  String pipelineCountSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prospects',
      one: '$count prospect',
    );
    return '$_temp0 · drag a card to another stage to move it';
  }

  @override
  String get donutProspects => 'prospects';

  @override
  String reasonLine(Object note) {
    return 'Reason: $note';
  }

  @override
  String lossReasonLine(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get deactivateStageIntro =>
      'The stage can no longer be chosen for new changes.';

  @override
  String deactivateStageProspects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prospects are currently in it and will stay there.',
      one: '1 prospect is currently in it and will stay there.',
    );
    return '$_temp0';
  }

  @override
  String get deactivateStageOutro => 'The history is kept.';

  @override
  String get sectionBusinessProfile => 'Business profile';

  @override
  String get fieldBusinessActivity => 'Business activity';

  @override
  String get businessActivityHint => 'Pick or type an activity';

  @override
  String get fieldSource => 'Prospect source';

  @override
  String get fieldSourceOther => 'Specify the source';

  @override
  String get fieldPreviousSoftware => 'Previous software';

  @override
  String get previousSoftwareHint => 'Pick or type a software';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get allSources => 'All sources';

  @override
  String get baWholesale => 'Wholesale trade';

  @override
  String get baRetail => 'Retail';

  @override
  String get baManufacturing => 'Manufacturing';

  @override
  String get baConstruction => 'Construction';

  @override
  String get baServices => 'Services';

  @override
  String get srcFacebook => 'Facebook';

  @override
  String get srcInstagram => 'Instagram';

  @override
  String get srcFriendReferral => 'Friend / personal referral';

  @override
  String get srcCustomerReferral => 'Existing customer referral';

  @override
  String get srcWebsite => 'Website';

  @override
  String get srcPhoneCall => 'Phone call';

  @override
  String get swSage => 'Sage';

  @override
  String get swPcCompta => 'PC Compta';

  @override
  String get swExcel => 'Excel';

  @override
  String get swOtherSoftware => 'Another management software';

  @override
  String get swNone => 'No previous software';

  @override
  String get searchProspectTitle => 'Search a prospect';

  @override
  String get searchProspectHint => 'Name, company, phone or prospect ID…';

  @override
  String get searchProspectIdle =>
      'Type a name, company, phone number or prospect ID.';

  @override
  String get searchProspectEmpty => 'No prospect found';

  @override
  String searchProspectMore(Object total) {
    return 'Refine the search to see the other results ($total in total).';
  }

  @override
  String get searchAllStagesNote =>
      'The search covers all stages (won and lost included).';

  @override
  String prospectIdShort(Object id) {
    return 'ID $id';
  }

  @override
  String get prospectOptionalLabel => 'Prospect (optional)';

  @override
  String get pickProspect => 'Choose a prospect';

  @override
  String get activityTitleRequired => 'Title / summary *';

  @override
  String get activityTitleHint => 'E.g. customer called about the quotation';

  @override
  String get activityDiscussionLabel => 'Discussion, customer response, notes';

  @override
  String get colTitle => 'Title';

  @override
  String get linkStatusLinked => 'Linked';

  @override
  String get linkStatusUnlinked => 'Unlinked';

  @override
  String get linkToProspect => 'Link to prospect';

  @override
  String get changeLinkedProspect => 'Change linked prospect';

  @override
  String get linkedProspectLabel => 'Linked prospect';

  @override
  String get noProspectLinked => 'No linked prospect';

  @override
  String get openProspect => 'Open prospect';

  @override
  String get activityDetails => 'Activity details';

  @override
  String activityLinkedTo(Object name) {
    return 'Activity linked to \"$name\".';
  }

  @override
  String get relinkTitle => 'Change the linked prospect?';

  @override
  String relinkBody(Object from, Object to) {
    return 'This activity is linked to \"$from\". Move it to \"$to\"? Its content and date do not change.';
  }

  @override
  String get relinkConfirm => 'Move';

  @override
  String get originLabel => 'Origin';

  @override
  String get originDirect => 'Entered directly';

  @override
  String get originFollowUp => 'Converted from a follow-up';

  @override
  String get activityFromFollowUpLocked =>
      'This activity comes from a follow-up: it stays with its prospect.';

  @override
  String get filterLinkAll => 'All (linked or not)';

  @override
  String get filterLinkOnlyLinked => 'Linked to a prospect';

  @override
  String get filterLinkOnlyUnlinked => 'Unlinked';

  @override
  String get colLink => 'Linked prospect';

  @override
  String get colLinkfllowup => 'Linked follow-up';

  @override
  String get activityOccurredAt => 'Date and time';

  @override
  String get createdOnLabel => 'Created on';

  @override
  String get linkedOnLabel => 'Linked on';

  @override
  String get typeLabelRequired => 'Activity type *';

  @override
  String get followUpTypeLabel => 'Follow-up type';

  @override
  String get followUpTypeRequired => 'Choose the follow-up type.';

  @override
  String get followUpTypeMissing => 'Type not set';

  @override
  String followUpCompletedKeepsType(Object type) {
    return 'The activity type will be the follow-up\'s: $type.';
  }

  @override
  String get activityTypeForLegacy =>
      'This follow-up has no type: choose the activity type.';

  @override
  String get followUpCompletedWithActivity =>
      'Follow-up completed and activity recorded.';

  @override
  String get colType => 'Type';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageHint =>
      'Interface language. The change is immediate.';

  @override
  String get languageMenuTooltip => 'Change language';

  @override
  String get themeToggleToDark => 'Switch to dark theme';

  @override
  String get themeToggleToLight => 'Switch to light theme';

  @override
  String get settingsAboutBody =>
      'Only the server address, language and theme are saved on this computer.';

  @override
  String get validFieldTitle => 'The title';

  @override
  String validMinLength(Object min) {
    return '$min characters minimum.';
  }

  @override
  String get navAfterSales => 'After-sales';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navEmployees => 'Employees';

  @override
  String get navGroupCrm => 'CRM';

  @override
  String get navGroupCustomers => 'Customers and products';

  @override
  String get navGroupService => 'Service';

  @override
  String get navGroupTeam => 'Team';

  @override
  String get navWorkspaceAgenda => 'Agenda & Overview';

  @override
  String get navWorkspaceSales => 'Sales & Clients';

  @override
  String get navWorkspaceSupport => 'Support & Operations';

  @override
  String get navWorkspaceBilling => 'Billing & Releases';

  @override
  String get navToggleSidebar => 'Collapse / expand menu';

  @override
  String get settingsGroupGeneral => 'General & Server';

  @override
  String get settingsGroupSales => 'Business & Sales Pipeline';

  @override
  String get settingsGroupSchedule => 'Schedule & Working Hours';

  @override
  String get settingsGroupCatalog => 'Catalog & Product Resources';

  @override
  String get settingsGroupAfterSales => 'After-Sales & Interventions';

  @override
  String get hoursOpen => 'Open';

  @override
  String get hoursClosed => 'Closed';

  @override
  String get hoursDailySpan => 'Daily opening span';

  @override
  String get hoursPickTime => 'Pick a time';

  @override
  String get hoursSlotsPerDay => 'slots per day';

  @override
  String get unitMinutes => 'min';

  @override
  String get unitHours => 'h';

  @override
  String get unitDays => 'days';

  @override
  String get hoursBookingHorizonHint =>
      'How many days ahead a customer may book.';

  @override
  String get hoursMinNoticeHint =>
      'Minimum time between booking and appointment, so the team can prepare.';

  @override
  String get hoursHoldHint =>
      'A requested slot stays reserved this long before it is released.';

  @override
  String get navRequests => 'Requests and holds';

  @override
  String get navTraining => 'Training and accompaniment';

  @override
  String get navWorkflowSettings => 'Scheduling and after-sales';

  @override
  String get wfYes => 'Yes';

  @override
  String get wfNo => 'No';

  @override
  String get wfSaved => 'Saved.';

  @override
  String get wfDate => 'Date';

  @override
  String get wfWhen => 'When';

  @override
  String get wfToday => 'Today';

  @override
  String get wfPrevious => 'Previous';

  @override
  String get wfNext => 'Next';

  @override
  String get wfTitle => 'Title';

  @override
  String get wfUpdated => 'Updated';

  @override
  String get wfReceived => 'Received';

  @override
  String get wfReference => 'Reference';

  @override
  String get wfEmployee => 'Employee';

  @override
  String get wfAssignedTo => 'Assigned to';

  @override
  String get wfUnassigned => 'Unassigned';

  @override
  String get wfTrainer => 'Trainer';

  @override
  String get wfCode => 'Code';

  @override
  String get wfCodeInvalid =>
      'Lowercase letters, digits and _ ; must start with a letter.';

  @override
  String get wfFieldRequired => 'This field is required.';

  @override
  String get wfNumberInvalid => 'A positive whole number is expected.';

  @override
  String wfTooLong(Object max) {
    return '$max characters maximum.';
  }

  @override
  String wfRangeError(Object min, Object max) {
    return 'Between $min and $max.';
  }

  @override
  String get wfUrl => 'Link (URL)';

  @override
  String get wfUrlInvalid => 'Invalid http(s) link.';

  @override
  String get wfUrlRequired => 'The link is required.';

  @override
  String get wfInvalidId => 'Invalid identifier.';

  @override
  String get wfStartInPast => 'The start time is already in the past.';

  @override
  String get wfEndAfterStart => 'The end must be after the start.';

  @override
  String get wfStarts => 'Starts';

  @override
  String get wfEnds => 'Ends';

  @override
  String get wfStartTime => 'Start time';

  @override
  String get wfEndTime => 'End time';

  @override
  String get wfLanguage => 'Language';

  @override
  String get wfSortOrder => 'Display order';

  @override
  String get wfSortOrderHint => 'Smallest number = most urgent.';

  @override
  String get wfStatusHeld => 'Held';

  @override
  String get wfStatusProposed => 'Proposed';

  @override
  String get wfStatusConfirmed => 'Confirmed';

  @override
  String get wfStatusRejected => 'Rejected';

  @override
  String get wfStatusCancelled => 'Cancelled';

  @override
  String get wfStatusExpired => 'Expired';

  @override
  String get wfStatusCompleted => 'Completed';

  @override
  String get wfStatusNoShow => 'No-show';

  @override
  String get wfKindAppointment => 'Appointment';

  @override
  String get wfKindFollowUp => 'Follow-up';

  @override
  String get wfKindIntervention => 'Intervention';

  @override
  String get wfKindActivity => 'Completed activities';

  @override
  String get wfGroupDemo => 'Demo';

  @override
  String get wfGroupMeeting => 'Meeting';

  @override
  String get wfGroupTraining => 'Training';

  @override
  String get wfGroup => 'Group';

  @override
  String get wfGroupAccompaniment => 'Accompaniment';

  @override
  String get wfConflictHoliday => 'Holiday';

  @override
  String get wfConflictEmployee => 'Employee already busy';

  @override
  String get wfConflictCustomer => 'Customer already busy';

  @override
  String get wfConflictsTitle => 'Schedule refused: conflicts found';

  @override
  String wfConflictLine(Object occurrence, Object date, Object reason) {
    return 'Session $occurrence ($date): $reason';
  }

  @override
  String get wfConflictNothingSaved =>
      'Schedule conflict: nothing was saved. Fix the listed sessions.';

  @override
  String wfConflictExplain(Object reasons) {
    return 'Conflict: $reasons';
  }

  @override
  String get wfHoldExpired =>
      'The hold has expired and the slot was released. Refresh the list.';

  @override
  String get wfHoldExpiredChip => 'Hold expired';

  @override
  String get wfHoldExpires => 'Hold expires';

  @override
  String wfExpiresIn(Object time) {
    return 'expires in $time';
  }

  @override
  String get wfCalendarSubtitle =>
      'Scheduled appointments, follow-ups and interventions; completed activities appear muted.';

  @override
  String get wfViewMonth => 'Month';

  @override
  String get wfViewWeek => 'Week';

  @override
  String get wfViewDay => 'Day';

  @override
  String get wfLegendScheduled => 'Scheduled';

  @override
  String get wfLegendCompleted => 'Completed';

  @override
  String get wfFilterCustomer => 'Customer';

  @override
  String get wfClearFilters => 'Clear filters';

  @override
  String wfMoreItems(Object count) {
    return '+$count more';
  }

  @override
  String get wfNothingScheduled => 'Nothing scheduled on this day';

  @override
  String get wfNothingScheduledHint =>
      'Confirmed appointments, follow-ups and interventions appear here.';

  @override
  String wfActivitiesNotLoaded(Object message) {
    return 'Completed activities could not be loaded: $message';
  }

  @override
  String get wfConfirmHoldTitle => 'Confirm the appointment';

  @override
  String get wfRejectTitle => 'Reject the request';

  @override
  String get wfCancelAppointmentTitle => 'Cancel the appointment';

  @override
  String get wfProposeTitle => 'Propose another time';

  @override
  String get wfRescheduleTitle => 'Move the session';

  @override
  String get wfRecordOutcomeTitle => 'Record the outcome';

  @override
  String get wfReject => 'Reject';

  @override
  String get wfCancelAppointment => 'Cancel appointment';

  @override
  String get wfCancelProposal => 'Withdraw proposal';

  @override
  String get wfProposeOther => 'Propose another time';

  @override
  String get wfSendProposal => 'Send proposal';

  @override
  String get wfReschedule => 'Reschedule';

  @override
  String get wfRecordOutcome => 'Record outcome';

  @override
  String get wfMarkNoShow => 'Mark as no-show';

  @override
  String get wfMeetingLink => 'Meeting link';

  @override
  String get wfMeetingLinkHint => 'Shown to the customer once confirmed.';

  @override
  String get wfNewTime => 'New time';

  @override
  String get wfReasonVisible => 'Reason (visible to the customer)';

  @override
  String get wfMessageVisible => 'Message (visible to the customer)';

  @override
  String get wfCustomerVisibleHint =>
      'The customer sees this text in their portal.';

  @override
  String get wfOutcome => 'Outcome';

  @override
  String get wfOutcomeHint =>
      'An activity is created in the CRM with this outcome.';

  @override
  String get wfOutcomeRequired => 'The outcome is required.';

  @override
  String get wfActivityRecorded => 'Activity recorded';

  @override
  String get wfCustomerMessage => 'Message to the customer';

  @override
  String get wfInternalNotes => 'Internal notes';

  @override
  String get wfOpenProspectRecord => 'Open record';

  @override
  String get wfNewProspect => 'New prospect';

  @override
  String get wfWaitingForCustomer => 'Waiting for the customer\'s answer.';

  @override
  String get wfRequestsSubtitle =>
      'Slots held for visitors and requests received from the website.';

  @override
  String wfHoldsTab(Object count) {
    return 'Holds ($count)';
  }

  @override
  String get wfWebsiteRequestsTab => 'Website requests';

  @override
  String get wfNoHolds => 'No pending holds';

  @override
  String get wfNoHoldsHint =>
      'Slots requested from the website appear here until you decide.';

  @override
  String get wfNoRequests => 'No requests';

  @override
  String get wfRequestDemo => 'Demo';

  @override
  String get wfRequestQuotation => 'Quotation';

  @override
  String get wfRequestTrial => 'Trial';

  @override
  String get wfReqPending => 'Pending';

  @override
  String get wfReqScheduled => 'Scheduled';

  @override
  String get wfReqHandled => 'Handled';

  @override
  String get wfMarkHandled => 'Mark as handled';

  @override
  String get wfRequestUpdated => 'Request updated.';

  @override
  String get wfTrainingSubtitle =>
      'Customer training sessions and accompaniment series.';

  @override
  String get wfNewTraining => 'New training';

  @override
  String get wfNewAccompaniment => 'New accompaniment';

  @override
  String get wfNoSessions => 'No sessions';

  @override
  String get wfNoSessionsHint =>
      'Schedule a training session or an accompaniment series.';

  @override
  String get wfShowPast => 'Include past';

  @override
  String get wfPartOfSeries => 'Accompaniment series';

  @override
  String get wfCancelThisSession => 'Cancel this session';

  @override
  String get wfCancelRemainingSeries => 'Cancel the rest of the series';

  @override
  String get wfCancelSessionTitle => 'Cancel this session?';

  @override
  String get wfCancelSessionBody =>
      'Only this future session is cancelled; the rest of the series is unchanged.';

  @override
  String get wfCancelSeriesTitle => 'Cancel the rest of the series?';

  @override
  String get wfCancelSeriesBody =>
      'This session and the following ones are cancelled. Completed sessions are not touched.';

  @override
  String get wfCancelSeries => 'Cancel remaining';

  @override
  String get wfSessionCancelled => 'Session cancelled.';

  @override
  String wfSeriesCancelled(Object count) {
    return '$count session(s) cancelled.';
  }

  @override
  String get wfSessionScheduled => 'Session scheduled.';

  @override
  String wfSeriesScheduled(Object count) {
    return 'Series scheduled: $count sessions.';
  }

  @override
  String get wfMoreActions => 'More actions';

  @override
  String get wfSessionType => 'Session type';

  @override
  String get wfNoTypesConfigured =>
      'No active appointment type for this group. Configure one in the settings.';

  @override
  String get wfSelectType => 'Select a type.';

  @override
  String get wfSelectProduct => 'Select a product.';

  @override
  String get wfNoProduct => 'No product';

  @override
  String get wfOccurrences => 'Number of sessions';

  @override
  String get wfOccurrencesHint => 'Default from the settings.';

  @override
  String get wfIntervalDays => 'Interval (days)';

  @override
  String get wfIntervalHint => 'Days between two sessions.';

  @override
  String wfPlannedSessions(Object count) {
    return '$count planned sessions';
  }

  @override
  String get wfPickResource => 'Pick a training resource';

  @override
  String get wfResourceLink => 'Resource link (optional)';

  @override
  String get wfPrepareWhatsApp => 'Prepare a WhatsApp message';

  @override
  String get wfPrepareWhatsAppHint =>
      'Prepares the text; you send it yourself from WhatsApp.';

  @override
  String get wfOpenWhatsApp => 'Open WhatsApp';

  @override
  String get wfWhatsAppHint =>
      'Opens a prefilled message. Sending happens in WhatsApp and is not confirmed by the CRM.';

  @override
  String get wfWhatsappInvalidLink =>
      'Unrecognised WhatsApp link: it was not opened.';

  @override
  String get wfCustomersSubtitle => 'Prospects converted into customers.';

  @override
  String get wfCustomerSearchHint => 'Search customers…';

  @override
  String get wfNoCustomers => 'No customers yet';

  @override
  String get wfNoCustomersHint => 'Convert a prospect from its record.';

  @override
  String get wfCustomerSince => 'Customer since';

  @override
  String wfCustomerSinceDate(Object date) {
    return 'Customer since $date';
  }

  @override
  String get wfCustomerBadge => 'Customer';

  @override
  String wfCustomersCount(Object count) {
    return '$count customers';
  }

  @override
  String get wfConvertTitle => 'Convert to customer';

  @override
  String get wfConvertAction => 'Convert to customer';

  @override
  String wfConvertIntro(Object name) {
    return '\"$name\" becomes a customer. The record, history, activities and stages are kept.';
  }

  @override
  String get wfPurchasedProducts => 'Purchased products';

  @override
  String get wfConversionNote => 'Conversion note';

  @override
  String get wfConvertedBy => 'Converted on / by';

  @override
  String wfConverted(Object name) {
    return '\"$name\" is now a customer.';
  }

  @override
  String get wfAlreadyCustomer =>
      'This prospect is already a customer. Refresh the record.';

  @override
  String get wfOpenCustomerProfile => 'Open customer profile';

  @override
  String get wfCustomerProducts => 'Customer products';

  @override
  String get wfNoCustomerProducts => 'No linked product';

  @override
  String wfPurchasedOn(Object date) {
    return 'Purchased on $date';
  }

  @override
  String get wfPortalAccounts => 'Customer portal accounts';

  @override
  String get wfPortalAccountsHint =>
      'Website identities, separate from employee access.';

  @override
  String get wfNoPortalAccount => 'No portal account linked';

  @override
  String wfLastLogin(Object date) {
    return 'Last sign-in: $date';
  }

  @override
  String get wfTrials => 'Trial access';

  @override
  String get wfNoTrials => 'No trials';

  @override
  String get wfNewTrial => 'New trial';

  @override
  String get wfTrialUrl => 'Trial access link';

  @override
  String get wfTrialUrlHint =>
      'The customer only sees it while the trial is active.';

  @override
  String get wfTrialStarts => 'Trial start';

  @override
  String get wfTrialEnds => 'Trial end';

  @override
  String get wfTrialDays => 'Default trial length (days)';

  @override
  String get wfTrialActive => 'Active';

  @override
  String get wfTrialScheduled => 'Scheduled';

  @override
  String get wfTrialRevoked => 'Revoked';

  @override
  String get wfTrialActivated => 'Trial activated.';

  @override
  String get wfTrialOverlap =>
      'A trial already exists for this product in that period.';

  @override
  String get wfRevoke => 'Revoke';

  @override
  String get wfRevokeTrialTitle => 'Revoke trial access?';

  @override
  String wfRevokeTrialBody(Object product) {
    return 'The customer will no longer see the trial link for \"$product\".';
  }

  @override
  String get wfTrialRevokedDone => 'Access revoked.';

  @override
  String get wfAppointments => 'Appointments';

  @override
  String get wfAppointmentsHint =>
      'Scheduled or completed (the outcome becomes an activity).';

  @override
  String get wfNoAppointments => 'No appointments';

  @override
  String get wfScheduleTraining => 'Schedule training';

  @override
  String get wfAfterSalesSubtitle =>
      'Customer requests and interventions published by the team.';

  @override
  String get wfNewIntervention => 'New intervention';

  @override
  String wfInterventionCreated(Object reference) {
    return 'Intervention $reference created.';
  }

  @override
  String get wfInterventionType => 'Intervention type';

  @override
  String get wfPriority => 'Priority';

  @override
  String get wfNoPriority => 'No priority';

  @override
  String get wfSource => 'Source';

  @override
  String get wfSourceCustomer => 'Customer';

  @override
  String get wfSourceEmployee => 'Employee';

  @override
  String get wfSourceBoth => 'Customer and employee';

  @override
  String get wfOpenItems => 'Open';

  @override
  String get wfClosedItems => 'Closed';

  @override
  String get wfNoInterventions => 'No interventions';

  @override
  String get wfNoInterventionsHint =>
      'Customer requests and your interventions appear here.';

  @override
  String get wfAffectedCustomers => 'Affected customers';

  @override
  String get wfAddCustomer => 'Add a customer';

  @override
  String get wfScheduledAt => 'Scheduled for';

  @override
  String get wfTitleRequired => 'The title is required.';

  @override
  String get wfDescriptionRequired => 'The description is required.';

  @override
  String get wfClosedAt => 'Closed on';

  @override
  String get wfStatusWorkflow => 'Status';

  @override
  String get wfStatusWorkflowHint =>
      'Only statuses allowed from the current one are offered.';

  @override
  String get wfCurrentStatus => 'Current status';

  @override
  String get wfCustomerSees => 'Customer sees';

  @override
  String get wfNoTransitions => 'No transition is allowed from this status.';

  @override
  String get wfTransitionNotAllowed => 'This status change is not allowed.';

  @override
  String wfChangeStatusTo(Object status) {
    return 'Change to \"$status\"';
  }

  @override
  String wfCustomerSeesStatus(Object label) {
    return 'The customer will see: \"$label\".';
  }

  @override
  String get wfStatusExplanation => 'Explanation for the customer (optional)';

  @override
  String get wfStatusChanged => 'Status updated.';

  @override
  String get wfTriage => 'Triage and planning';

  @override
  String get wfReleaseNotes => 'Release notes';

  @override
  String get wfReleaseNotesHint =>
      'Publish the fix or update to the affected customers.';

  @override
  String get wfPublish => 'Publish';

  @override
  String get wfPublished => 'Published to the affected customers.';

  @override
  String get wfPublishTitle => 'Publish to customers';

  @override
  String wfPublishTo(Object names) {
    return 'Will be visible to: $names';
  }

  @override
  String get wfPublishNoCustomers =>
      'No affected customer: add some when creating to publish.';

  @override
  String wfPublishedOn(Object date) {
    return 'Published on $date';
  }

  @override
  String get wfNotPublished => 'Not published yet: customers cannot see it.';

  @override
  String get wfResolutionRequired => 'The published text is required.';

  @override
  String get wfUnpublish => 'Unpublish';

  @override
  String get wfUnpublishTitle => 'Unpublish?';

  @override
  String get wfUnpublishBody => 'Customers will no longer see these notes.';

  @override
  String get wfUnpublished => 'Unpublished.';

  @override
  String get wfConversation => 'Conversation';

  @override
  String get wfNoMessages => 'No messages';

  @override
  String get wfInternalNote => 'Internal note';

  @override
  String get wfCustomerReply => 'Customer reply';

  @override
  String get wfInternalNoteHint => 'Team only: the customer never sees it.';

  @override
  String get wfCustomerReplyWarning =>
      'This message will be visible to the customer in their portal.';

  @override
  String get wfConfirmCustomerReplyTitle => 'Send to the customer?';

  @override
  String get wfConfirmCustomerReplyBody =>
      'The reply will be visible to the customer. Do not mention internal discussion.';

  @override
  String get wfSendReply => 'Send reply';

  @override
  String get wfAddNote => 'Add note';

  @override
  String get wfReplySaved => 'Reply saved for the customer.';

  @override
  String get wfNoteSaved => 'Internal note saved.';

  @override
  String get wfMessageRequired => 'The message is empty.';

  @override
  String get wfEmployeesSubtitle =>
      'Workstations connected to the CRM and assigned work. All employees have the same access.';

  @override
  String get wfNoEmployees => 'No known employees';

  @override
  String get wfNoEmployeesHint =>
      'Employees appear once their app connects to the server.';

  @override
  String get wfSelectEmployee => 'Select an employee';

  @override
  String get wfIdle => 'Idle';

  @override
  String wfAssignedAppointments(Object name) {
    return 'Upcoming appointments of $name';
  }

  @override
  String wfAssignedInterventions(Object name) {
    return 'Open interventions of $name';
  }

  @override
  String get wfNothingAssigned => 'Nothing assigned';

  @override
  String get wfSettingsSubtitle =>
      'Hours, types, statuses, priorities and templates. Everything is stored in the CRM.';

  @override
  String get wfSettingsSaved => 'Settings saved.';

  @override
  String get wfCfgScheduling => 'Hours and booking';

  @override
  String get wfCfgSchedulingHint =>
      'Working days and hours, slot length, hold expiry, accompaniment recurrence and trials.';

  @override
  String get wfCfgAppointmentTypes => 'Appointment types';

  @override
  String get wfCfgAppointmentTypesHint =>
      'Demo, meeting, training, accompaniment: default length and calendar color.';

  @override
  String get wfCfgHolidays => 'Holidays';

  @override
  String get wfCfgHolidaysHint => 'No slot is offered on these days.';

  @override
  String get wfCfgInterventionTypes => 'Intervention types';

  @override
  String get wfCfgInterventionTypesHint =>
      'Bug, question, remark, fix, release… and who may create them.';

  @override
  String get wfCfgInterventionStatuses => 'Intervention statuses';

  @override
  String get wfCfgInterventionStatusesHint =>
      'Internal label and the label the customer sees.';

  @override
  String get wfCfgTransitions => 'Status transitions';

  @override
  String get wfCfgTransitionsHint =>
      'Which statuses may follow which, and whether the customer may trigger the change.';

  @override
  String get wfCfgPriorities => 'Priorities';

  @override
  String get wfCfgPrioritiesHint =>
      'Color and target response time; the order drives sorting.';

  @override
  String get wfCfgTemplates => 'Message templates';

  @override
  String get wfCfgTemplatesHint =>
      'WhatsApp texts prepared for training sessions (never sent automatically).';

  @override
  String get wfCfgProductResources => 'Product resources';

  @override
  String get wfCfgProductResourcesHint =>
      'Training and documentation links, with customer visibility.';

  @override
  String get wfProductResources => 'Product resources and links';

  @override
  String wfProductResourcesTitle(Object name) {
    return 'Resources: $name';
  }

  @override
  String get wfNoResources => 'No resource for this product';

  @override
  String get wfNoConfigRows => 'No entries';

  @override
  String get wfNoConfigRowsHint =>
      'Add the first entry. It can be deactivated, never deleted.';

  @override
  String get wfDeactivateTitle => 'Deactivate this entry?';

  @override
  String get wfDeactivateBody =>
      'It is no longer offered, but history that references it is kept.';

  @override
  String get wfDeactivated => 'Entry deactivated.';

  @override
  String get wfReactivated => 'Entry reactivated.';

  @override
  String get wfDurationMinutes => 'Length (min)';

  @override
  String get wfCustomerBookable => 'Customer bookable';

  @override
  String get wfCustomerLabel => 'Customer label';

  @override
  String get wfCustomerLabelHint => 'What the customer sees for this status.';

  @override
  String get wfIsInitial => 'Initial status';

  @override
  String get wfIsClosed => 'Closes the intervention';

  @override
  String get wfAwaitsCustomer => 'Awaits the customer';

  @override
  String get wfIsDelivered => 'Delivered to the customer';

  @override
  String get wfFromStatus => 'From status';

  @override
  String get wfToStatus => 'To status';

  @override
  String get wfCustomerAllowed => 'Customer may trigger';

  @override
  String get wfResponseTarget => 'Response target (h)';

  @override
  String get wfResponseTargetHint => 'Leave empty for no target.';

  @override
  String get wfTemplate => 'Template';

  @override
  String get wfTemplateTrainingFirst => 'First training';

  @override
  String get wfTemplateTrainingReview => 'Training follow-up';

  @override
  String get wfTemplateBody => 'Message text';

  @override
  String get wfTemplatePlaceholders =>
      'Available variables (write them between curly braces): contact, product, date, start, end, resource_url';

  @override
  String get wfKindVideo => 'Video';

  @override
  String get wfKindLink => 'Link';

  @override
  String get wfCustomerVisible => 'Customer visible';

  @override
  String get wfTrainingMaterial => 'Training material';

  @override
  String get wfWorkingDays => 'Working days';

  @override
  String get wfPickWorkingDay => 'Pick at least one day.';

  @override
  String get wfWorkStart => 'Day start';

  @override
  String get wfWorkEnd => 'Day end';

  @override
  String get wfTimeInvalid => 'Expected format HH:mm.';

  @override
  String get wfSlotMinutes => 'Slot length (min)';

  @override
  String get wfHoldExpiryMinutes => 'Hold expiry (min)';

  @override
  String get wfHoldExpiryHint =>
      'After that the slot is released automatically.';

  @override
  String get wfBookingHorizon => 'Booking horizon (days)';

  @override
  String get wfMinNotice => 'Minimum notice (hours)';

  @override
  String get wfDemoCapacity => 'Parallel demos';

  @override
  String get wfDemoCapacityHint => 'Number of simultaneous demos.';

  @override
  String get wfAccompanimentOccurrences => 'Accompaniment sessions (default)';

  @override
  String get wfAccompanimentInterval =>
      'Accompaniment interval (days, default)';

  @override
  String get wfWhatsappCountryCode => 'WhatsApp country code';

  @override
  String get wfWhatsappCountryCodeHint =>
      'Digits only, e.g. 213. Used to complete numbers starting with 0.';

  @override
  String get wfCountryCodeInvalid => '1 to 4 digits.';

  @override
  String get ivSupport => 'Support';

  @override
  String get ivSystem => 'System';

  @override
  String ivEventStatusFull(Object actor, Object from, Object time, Object to) {
    return 'Status changed from $from to $to by $actor at $time';
  }

  @override
  String ivEventStatusTo(Object actor, Object time, Object to) {
    return 'Status changed to $to by $actor at $time';
  }

  @override
  String ivEventReopened(Object actor, Object time) {
    return 'Intervention reopened by $actor at $time';
  }

  @override
  String get ivAttachFiles => 'Attach files';

  @override
  String ivAttachLimit(Object max) {
    return 'At most $max files per message.';
  }

  @override
  String get ivRemoveFile => 'Remove this file';

  @override
  String get ivDownload => 'Download';

  @override
  String get ivPreview => 'Preview';

  @override
  String get ivViewPdf => 'Open PDF';

  @override
  String ivFileSaved(Object path) {
    return 'File saved: $path';
  }

  @override
  String get ivImageError => 'Could not display the image.';

  @override
  String get ivClosedBanner =>
      'This intervention is closed. New replies are disabled.';

  @override
  String get ivReopen => 'Reopen intervention';

  @override
  String get ivReopenBody =>
      'Replies will be enabled again for you and the customer.';

  @override
  String get ivReopenNote => 'Note (optional)';

  @override
  String get ivReopened => 'Intervention reopened.';

  @override
  String get prDemoLink => 'Demo link';

  @override
  String get prDemoLinkHint => 'Fixed link set on the product.';

  @override
  String get prNoDemoLink => 'This product has no demo link.';

  @override
  String get prNoDemoProducts => 'No demo-enabled product for this customer.';

  @override
  String get prNoLinkedProducts => 'No product linked to this customer.';

  @override
  String get prFilteredByCustomer =>
      'Showing only the products linked to this customer.';

  @override
  String get prCustomersFilteredByProduct =>
      'Showing only customers linked to this product.';

  @override
  String prPackReplaced(Object name) {
    return '“$name” was unchecked: only one product per pack.';
  }

  @override
  String get prPackHint => 'One product per pack.';

  @override
  String get navReleases => 'Product releases';

  @override
  String get rlSubtitle =>
      'Published product versions, installers and audience.';

  @override
  String get rlNew => 'New release';

  @override
  String get rlEdit => 'Edit release';

  @override
  String get rlVersion => 'Version number';

  @override
  String get rlVersionRequired => 'Version number is required.';

  @override
  String get rlDate => 'Release date';

  @override
  String get rlChangelog => 'Changelog';

  @override
  String get rlAudience => 'Audience';

  @override
  String get rlAudienceAll => 'All customers';

  @override
  String get rlAudienceOwned => 'Customers who own the product';

  @override
  String get rlAudienceSpecific => 'Specific customers';

  @override
  String get rlCustomers => 'Selected customers';

  @override
  String get rlCustomersRequired => 'Choose at least one customer.';

  @override
  String get rlInstaller => 'Installer file';

  @override
  String get rlInstallerHint => '.exe, .zip or .rar';

  @override
  String get rlPickInstaller => 'Choose a file';

  @override
  String get rlRemoveInstaller => 'Remove installer';

  @override
  String get rlExternalUrl => 'External download link';

  @override
  String get rlPublished => 'Published';

  @override
  String get rlDraft => 'Draft';

  @override
  String get rlNoReleases => 'No releases yet';

  @override
  String get rlNoReleasesHint => 'Create the first release of a product.';

  @override
  String get rlDeleteTitle => 'Delete this release?';

  @override
  String get rlDeleteBody => 'Customers will no longer see it.';

  @override
  String get rlSaved => 'Release saved.';

  @override
  String get rlDeleted => 'Release deleted.';

  @override
  String get rlUploading => 'Uploading file…';

  @override
  String get rlAllProducts => 'All products';

  @override
  String get helpTooltip => 'Help';

  @override
  String get helpExample => 'Example';

  @override
  String get helpFields => 'Fields';

  @override
  String get helpUnavailable => 'Help is not available for this section.';

  @override
  String get wfFixedTypesNote =>
      'The 4 types (Demo, Meeting, Training, Accompaniment) are fixed. You can only adjust duration, color and online booking.';

  @override
  String get navBilling => 'Billing';

  @override
  String get blTitle => 'Subscriptions & billing';

  @override
  String get blSubtitle =>
      'Maintenance & support of every customer, cash payments to confirm.';

  @override
  String get blStatusAll => 'All statuses';

  @override
  String get blStatusActive => 'Active';

  @override
  String get blStatusExpiringSoon => 'Expiring soon';

  @override
  String get blStatusExpired => 'Expired';

  @override
  String get blStatusNone => 'No plan';

  @override
  String get blFilterStatus => 'Status';

  @override
  String get blSortBy => 'Sort by';

  @override
  String get blSortName => 'Customer name';

  @override
  String get blSortExpiry => 'Expiry date';

  @override
  String get blSortConverted => 'Customer since';

  @override
  String get blSortDirection => 'Reverse order';

  @override
  String get blPendingOnly => 'Pending renewals';

  @override
  String get blSearchHint => 'Search customers...';

  @override
  String get blColCustomer => 'Customer';

  @override
  String get blColExpiry => 'Expires';

  @override
  String get blColDaysLeft => 'Days left';

  @override
  String get blColPending => 'Pending';

  @override
  String get blNoCustomers => 'No customers';

  @override
  String get blNoCustomersHint => 'No customer matches the filters.';

  @override
  String get blDetailTitle => 'Customer billing';

  @override
  String get blBack => 'Back to subscriptions';

  @override
  String get blLicense => 'License';

  @override
  String get blLicenseLifetime => 'Lifetime license (never expires)';

  @override
  String get blLicenseSince => 'Since';

  @override
  String get blMaintenance => 'Maintenance & support';

  @override
  String get blMaintenanceStarts => 'Starts';

  @override
  String get blMaintenanceExpires => 'Expires';

  @override
  String get blPricePerYear => 'Price per year';

  @override
  String get blCurrency => 'DZD';

  @override
  String get blDaysUnit => 'days';

  @override
  String get blSetMaintenance => 'Set period';

  @override
  String get blSetMaintenanceTitle => 'Maintenance period';

  @override
  String get blSaved => 'Saved.';

  @override
  String get blRenewals => 'Renewal requests';

  @override
  String get blNoRenewals => 'No renewal requests.';

  @override
  String get blRenewalReference => 'Proforma reference';

  @override
  String get blRenewalYears => 'Years';

  @override
  String get blRenewalAmount => 'Amount';

  @override
  String get blRenewalPending => 'Awaiting payment';

  @override
  String get blRenewalConfirmed => 'Confirmed';

  @override
  String get blRequestedOn => 'Requested on';

  @override
  String get blConfirmedOn => 'Confirmed on';

  @override
  String get blMarkPaid => 'Mark as paid';

  @override
  String get blMarkPaidTitle => 'Confirm cash payment';

  @override
  String get blMarkPaidHint =>
      'Confirm the cash was received. The customer\'s maintenance period is extended automatically.';

  @override
  String get blPaidAt => 'Payment date';

  @override
  String get blMarkedPaid => 'Payment confirmed: maintenance extended.';

  @override
  String get blInvoices => 'Invoices & receipts';

  @override
  String get blNoInvoices => 'No invoices.';

  @override
  String get blColInvoice => 'Reference';

  @override
  String get blColType => 'Type';

  @override
  String get blColAmount => 'Amount (DZD)';

  @override
  String get blColIssued => 'Issued';

  @override
  String get blColPaid => 'Paid on';

  @override
  String get blInvoiceTypeLicense => 'License';

  @override
  String get blInvoiceTypeRenewal => 'Maintenance renewal';

  @override
  String get blInvoicePaid => 'Paid in cash';

  @override
  String get blInvoicePending => 'Awaiting cash';

  @override
  String get blInvoiceDetails => 'Invoice details';

  @override
  String get blReceipt => 'Scanned receipt';

  @override
  String get blReceiptNone => 'No receipt attached.';

  @override
  String get blUploadReceipt => 'Attach a receipt (PDF or image)';

  @override
  String get blReplaceReceipt => 'Replace receipt';

  @override
  String get blRemoveReceipt => 'Remove receipt';

  @override
  String get blViewReceipt => 'Download receipt';

  @override
  String get blReceiptUploaded => 'Receipt saved.';

  @override
  String get blReceiptRemoved => 'Receipt removed.';

  @override
  String get blNewInvoice => 'New invoice';

  @override
  String get blInvoiceType => 'Invoice type';

  @override
  String get blInvoiceAmount => 'Amount (DZD)';

  @override
  String get blInvoiceAlreadyPaid => 'Already paid in cash';

  @override
  String get blInvoiceCreated => 'Invoice created.';

  @override
  String get blAmountInvalid => 'Enter a valid amount.';

  @override
  String get blPeriodInvalid => 'The end must be after the start.';

  @override
  String get blRenewalPendingQuote => 'Awaiting quote';

  @override
  String get blRenewalQuoted => 'Quoted, awaiting cash';

  @override
  String get blRenewalRejected => 'Rejected';

  @override
  String get blQuotePrice => 'Quote price';

  @override
  String get blQuoteTitle => 'Quote renewal price';

  @override
  String get blQuoteHint =>
      'Enter the total amount the customer will pay in cash. A proforma is issued.';

  @override
  String get blQuoteAmount => 'Total amount (DZD)';

  @override
  String get blQuoteIssue => 'Issue proforma';

  @override
  String get blQuoted => 'Proforma issued.';

  @override
  String get blWorkstations => 'workstations';

  @override
  String get blDossiers => 'databases';

  @override
  String get blNotesLabel => 'Notes';

  @override
  String get ivHotfixLabel => 'Hotfix / Patch';

  @override
  String get ivHotfixHint =>
      'The customer will see this file as a private hotfix patch.';

  @override
  String get productImage => 'Product image';

  @override
  String get productUploadImage => 'Upload image';

  @override
  String get productUploadingImage => 'Uploading image...';

  @override
  String get productRemoveImage => 'Remove image';

  @override
  String get productTabsBasic => 'Basic info';

  @override
  String get productTabsWeb => 'Catalog & web';

  @override
  String get productTabsDemo => 'Demo version';

  @override
  String get productImageUploaded => 'Product image uploaded successfully.';

  @override
  String get productImageTooLarge => 'The image exceeds 5 MB.';

  @override
  String get productImageUrl => 'Or paste an image URL';

  @override
  String get productImageUrlInvalid => 'Invalid image URL (http/https).';

  @override
  String get productImageHint => 'PNG, JPG, WEBP or SVG — 5 MB max.';

  @override
  String get productImageSvgPreview =>
      'SVG preview unavailable, the file is saved.';

  @override
  String get productSlug => 'Slug (short URL)';

  @override
  String get productSlugHint => 'Generated from the name when left empty.';

  @override
  String get productSlugInvalid =>
      'Lowercase letters, digits and hyphens only.';

  @override
  String get productSortOrder => 'Sort order';

  @override
  String get productSortOrderInvalid => 'Enter a number between 0 and 100000.';

  @override
  String get productSummaryLabel => 'Short summary';

  @override
  String get productWebDescriptionLabel => 'Full description';

  @override
  String get productFeatures => 'Features';

  @override
  String get productFeatureHint => 'Type a feature and press add';

  @override
  String get productAddFeature => 'Add feature';
}
