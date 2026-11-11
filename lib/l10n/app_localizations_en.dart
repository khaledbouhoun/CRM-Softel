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
  String countProspects(int count) {
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
  String countActivities(int count) {
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
  String activitiesCountSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '$count activity',
    );
    return '$_temp0 — calls, appointments, messages and notes';
  }

  @override
  String pipelineCountSubtitle(int count) {
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
  String deactivateStageProspects(int count) {
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
}
