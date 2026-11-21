import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get navDashboard;

  /// No description provided for @navProspects.
  ///
  /// In fr, this message translates to:
  /// **'Prospects'**
  String get navProspects;

  /// No description provided for @navPipeline.
  ///
  /// In fr, this message translates to:
  /// **'Pipeline'**
  String get navPipeline;

  /// No description provided for @navActivities.
  ///
  /// In fr, this message translates to:
  /// **'Activités'**
  String get navActivities;

  /// No description provided for @navFollowUps.
  ///
  /// In fr, this message translates to:
  /// **'Relances'**
  String get navFollowUps;

  /// No description provided for @navProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get navProducts;

  /// No description provided for @navSalesStages.
  ///
  /// In fr, this message translates to:
  /// **'Étapes de vente'**
  String get navSalesStages;

  /// No description provided for @navLossReasons.
  ///
  /// In fr, this message translates to:
  /// **'Motifs de perte'**
  String get navLossReasons;

  /// No description provided for @navServerDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Serveur & affichage'**
  String get navServerDisplay;

  /// No description provided for @navSettingsSection.
  ///
  /// In fr, this message translates to:
  /// **'PARAMÈTRES'**
  String get navSettingsSection;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Thème clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get themeDark;

  /// No description provided for @globalSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un prospect (nom, téléphone, e-mail…) puis Entrée'**
  String get globalSearchHint;

  /// No description provided for @connOnline.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get connOnline;

  /// No description provided for @connOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get connOffline;

  /// No description provided for @connChecking.
  ///
  /// In fr, this message translates to:
  /// **'Vérification…'**
  String get connChecking;

  /// No description provided for @connUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get connUnknown;

  /// No description provided for @connServer.
  ///
  /// In fr, this message translates to:
  /// **'Serveur : {url}'**
  String connServer(Object url);

  /// No description provided for @connLastCheck.
  ///
  /// In fr, this message translates to:
  /// **'\nDernière vérification : {time}'**
  String connLastCheck(Object time);

  /// No description provided for @connClickToCheck.
  ///
  /// In fr, this message translates to:
  /// **'\nCliquer pour vérifier maintenant.'**
  String get connClickToCheck;

  /// No description provided for @actionRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get actionRefresh;

  /// No description provided for @actionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get actionAdd;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get actionConfirm;

  /// No description provided for @actionSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// No description provided for @actionSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get actionSaving;

  /// No description provided for @actionClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get actionClose;

  /// No description provided for @actionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// No description provided for @actionDeactivate.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get actionDeactivate;

  /// No description provided for @actionReactivate.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver'**
  String get actionReactivate;

  /// No description provided for @actionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionRetry;

  /// No description provided for @actionReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get actionReset;

  /// No description provided for @actionClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get actionClear;

  /// No description provided for @actionBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get actionBack;

  /// No description provided for @actionSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Planifier'**
  String get actionSchedule;

  /// No description provided for @actionSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get actionSeeAll;

  /// No description provided for @actionMoveUp.
  ///
  /// In fr, this message translates to:
  /// **'Monter'**
  String get actionMoveUp;

  /// No description provided for @actionMoveDown.
  ///
  /// In fr, this message translates to:
  /// **'Descendre'**
  String get actionMoveDown;

  /// No description provided for @actionOpenRecord.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la fiche'**
  String get actionOpenRecord;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @loadingRecord.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de la fiche…'**
  String get loadingRecord;

  /// No description provided for @loadingStages.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des étapes…'**
  String get loadingStages;

  /// No description provided for @errorOccurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorOccurred;

  /// No description provided for @serverUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable'**
  String get serverUnreachable;

  /// No description provided for @serverSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres serveur'**
  String get serverSettings;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue.'**
  String get errorUnknown;

  /// No description provided for @noItems.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élément'**
  String get noItems;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResults;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher…'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @clearPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la période'**
  String get clearPeriod;

  /// No description provided for @period.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get period;

  /// No description provided for @perPage.
  ///
  /// In fr, this message translates to:
  /// **'Par page'**
  String get perPage;

  /// No description provided for @pageFirst.
  ///
  /// In fr, this message translates to:
  /// **'Première page'**
  String get pageFirst;

  /// No description provided for @pagePrevious.
  ///
  /// In fr, this message translates to:
  /// **'Page précédente'**
  String get pagePrevious;

  /// No description provided for @pageNext.
  ///
  /// In fr, this message translates to:
  /// **'Page suivante'**
  String get pageNext;

  /// No description provided for @pageLast.
  ///
  /// In fr, this message translates to:
  /// **'Dernière page'**
  String get pageLast;

  /// No description provided for @pageOf.
  ///
  /// In fr, this message translates to:
  /// **'Page {page} / {pages}'**
  String pageOf(Object page, Object pages);

  /// No description provided for @rangeOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'{from}–{to} sur {total}'**
  String rangeOfTotal(Object from, Object to, Object total);

  /// No description provided for @showMoreCount.
  ///
  /// In fr, this message translates to:
  /// **'Afficher plus ({count})'**
  String showMoreCount(Object count);

  /// No description provided for @color.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get color;

  /// No description provided for @colDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get colStatus;

  /// No description provided for @colActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get colActions;

  /// No description provided for @fieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldDescriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Description *'**
  String get fieldDescriptionRequired;

  /// No description provided for @fieldOutcome.
  ///
  /// In fr, this message translates to:
  /// **'Résultat'**
  String get fieldOutcome;

  /// No description provided for @fieldDateTimeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Date et heure *'**
  String get fieldDateTimeRequired;

  /// No description provided for @fieldNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom *'**
  String get fieldNameRequired;

  /// No description provided for @fieldLabelRequired.
  ///
  /// In fr, this message translates to:
  /// **'Libellé *'**
  String get fieldLabelRequired;

  /// No description provided for @fieldTypeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Type *'**
  String get fieldTypeRequired;

  /// No description provided for @fieldType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get fieldAddress;

  /// No description provided for @fieldCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get fieldCity;

  /// No description provided for @fieldPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get fieldEmail;

  /// No description provided for @fieldContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get fieldContact;

  /// No description provided for @colContactDetails.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get colContactDetails;

  /// No description provided for @statusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statusActive;

  /// No description provided for @statusActiveFem.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get statusActiveFem;

  /// No description provided for @statusInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get statusInactive;

  /// No description provided for @statusInactiveFem.
  ///
  /// In fr, this message translates to:
  /// **'Inactive'**
  String get statusInactiveFem;

  /// No description provided for @optionOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get optionOther;

  /// No description provided for @validThisField.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ'**
  String get validThisField;

  /// No description provided for @validRequired.
  ///
  /// In fr, this message translates to:
  /// **'{field} est obligatoire.'**
  String validRequired(Object field);

  /// No description provided for @validMaxLength.
  ///
  /// In fr, this message translates to:
  /// **'{max} caractères maximum.'**
  String validMaxLength(Object max);

  /// No description provided for @validEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get validEmailInvalid;

  /// No description provided for @validPhoneChars.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro ne peut contenir que des chiffres, espaces, +, -, . ou ().'**
  String get validPhoneChars;

  /// No description provided for @validPhoneLength.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro doit contenir entre 6 et 20 chiffres.'**
  String get validPhoneLength;

  /// No description provided for @validColorInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Couleur invalide (format #RRGGBB).'**
  String get validColorInvalid;

  /// No description provided for @validServerRequired.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse du serveur est obligatoire.'**
  String get validServerRequired;

  /// No description provided for @validServerInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse invalide. Exemple : http://192.168.1.100:8000/api/v1'**
  String get validServerInvalid;

  /// No description provided for @validServerScheme.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse doit commencer par http:// ou https://'**
  String get validServerScheme;

  /// No description provided for @validFieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'La description'**
  String get validFieldDescription;

  /// No description provided for @validFieldName.
  ///
  /// In fr, this message translates to:
  /// **'Le nom'**
  String get validFieldName;

  /// No description provided for @validFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Le libellé'**
  String get validFieldLabel;

  /// No description provided for @validFieldCompany.
  ///
  /// In fr, this message translates to:
  /// **'Le nom de la société / du client'**
  String get validFieldCompany;

  /// No description provided for @validFixFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez corriger les champs signalés.'**
  String get validFixFields;

  /// No description provided for @validSelectProspect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un prospect.'**
  String get validSelectProspect;

  /// No description provided for @validSelectStage.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une étape.'**
  String get validSelectStage;

  /// No description provided for @validDateRequired.
  ///
  /// In fr, this message translates to:
  /// **'La date est obligatoire.'**
  String get validDateRequired;

  /// No description provided for @validFollowUpFuture.
  ///
  /// In fr, this message translates to:
  /// **'La date de relance doit être dans le futur.'**
  String get validFollowUpFuture;

  /// No description provided for @validDateNotFuture.
  ///
  /// In fr, this message translates to:
  /// **'La date ne peut pas être dans le futur.'**
  String get validDateNotFuture;

  /// No description provided for @validNextFollowUpFuture.
  ///
  /// In fr, this message translates to:
  /// **'La prochaine relance doit être dans le futur.'**
  String get validNextFollowUpFuture;

  /// No description provided for @validNextFollowUpAfterActivity.
  ///
  /// In fr, this message translates to:
  /// **'La prochaine relance doit être postérieure à l\'activité.'**
  String get validNextFollowUpAfterActivity;

  /// No description provided for @validActivityNotFuture.
  ///
  /// In fr, this message translates to:
  /// **'Une activité ne peut pas être dans le futur : planifiez plutôt une relance.'**
  String get validActivityNotFuture;

  /// No description provided for @validInitialStageRequired.
  ///
  /// In fr, this message translates to:
  /// **'L\'étape initiale est obligatoire.'**
  String get validInitialStageRequired;

  /// No description provided for @validStageDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Cette étape est désactivée.'**
  String get validStageDisabled;

  /// No description provided for @validAlreadyInStage.
  ///
  /// In fr, this message translates to:
  /// **'Le prospect est déjà à cette étape.'**
  String get validAlreadyInStage;

  /// No description provided for @validLossReasonRequiredForLost.
  ///
  /// In fr, this message translates to:
  /// **'Le motif de perte est obligatoire pour une étape « perdu ».'**
  String get validLossReasonRequiredForLost;

  /// No description provided for @validLossReasonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le motif de perte est obligatoire.'**
  String get validLossReasonRequired;

  /// No description provided for @validReasonNeedsDetails.
  ///
  /// In fr, this message translates to:
  /// **'Ce motif nécessite une précision.'**
  String get validReasonNeedsDetails;

  /// No description provided for @validDetailsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Précision obligatoire pour ce motif.'**
  String get validDetailsRequired;

  /// No description provided for @typeAtLeastTwo.
  ///
  /// In fr, this message translates to:
  /// **'Tapez au moins 2 caractères…'**
  String get typeAtLeastTwo;

  /// No description provided for @errTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur ({server}) ne répond pas dans le délai imparti. Vérifiez le réseau puis réessayez.'**
  String errTimeout(Object server);

  /// No description provided for @errConnection.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur ({server}). Vérifiez que l\'ordinateur central est allumé, que vous êtes sur le réseau de l\'entreprise et que l\'adresse du serveur est correcte.'**
  String errConnection(Object server);

  /// No description provided for @errConnectionShort.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur ({server}). Vérifiez le réseau et l\'adresse du serveur.'**
  String errConnectionShort(Object server);

  /// No description provided for @errCertificate.
  ///
  /// In fr, this message translates to:
  /// **'Certificat du serveur refusé ({server}).'**
  String errCertificate(Object server);

  /// No description provided for @errCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Requête annulée.'**
  String get errCancelled;

  /// No description provided for @errReceiveTimeout.
  ///
  /// In fr, this message translates to:
  /// **'La réponse du serveur ({server}) n\'a pas pu être lue à temps.'**
  String errReceiveTimeout(Object server);

  /// No description provided for @errCommunication.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de communication avec le serveur : {details}'**
  String errCommunication(Object details);

  /// No description provided for @errBadRequest.
  ///
  /// In fr, this message translates to:
  /// **'Requête invalide.'**
  String get errBadRequest;

  /// No description provided for @errNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Élément introuvable sur le serveur.'**
  String get errNotFound;

  /// No description provided for @errNotSupported.
  ///
  /// In fr, this message translates to:
  /// **'Opération non prise en charge par le serveur.'**
  String get errNotSupported;

  /// No description provided for @errConflict.
  ///
  /// In fr, this message translates to:
  /// **'Opération refusée : conflit avec les données existantes.'**
  String get errConflict;

  /// No description provided for @errValidation.
  ///
  /// In fr, this message translates to:
  /// **'Certaines données sont invalides.'**
  String get errValidation;

  /// No description provided for @errServer.
  ///
  /// In fr, this message translates to:
  /// **'Erreur interne du serveur ({status}). Réessayez ou contactez l\'administrateur.'**
  String errServer(Object status);

  /// No description provided for @errUnexpectedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Réponse inattendue du serveur ({status}).'**
  String errUnexpectedStatus(Object status);

  /// No description provided for @errUnexpectedResponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du serveur inattendue : {details}'**
  String errUnexpectedResponse(Object details);

  /// No description provided for @errUnexpected.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inattendue : {details}'**
  String errUnexpected(Object details);

  /// No description provided for @errExpectedObject.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du serveur inattendue : un objet JSON était attendu.'**
  String get errExpectedObject;

  /// No description provided for @errExpectedList.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du serveur inattendue : une liste JSON était attendue.'**
  String get errExpectedList;

  /// No description provided for @errExpectedPaged.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du serveur inattendue : une liste paginée était attendue.'**
  String get errExpectedPaged;

  /// No description provided for @errMissingProspect.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du serveur inattendue : le prospect mis à jour est absent.'**
  String get errMissingProspect;

  /// No description provided for @errBusy.
  ///
  /// In fr, this message translates to:
  /// **'Opération déjà en cours.'**
  String get errBusy;

  /// No description provided for @relToday.
  ///
  /// In fr, this message translates to:
  /// **'aujourd\'hui {time}'**
  String relToday(Object time);

  /// No description provided for @relTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'demain {time}'**
  String relTomorrow(Object time);

  /// No description provided for @relYesterday.
  ///
  /// In fr, this message translates to:
  /// **'hier {time}'**
  String relYesterday(Object time);

  /// No description provided for @relInDays.
  ///
  /// In fr, this message translates to:
  /// **'dans {days} j'**
  String relInDays(Object days);

  /// No description provided for @relDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {days} j'**
  String relDaysAgo(Object days);

  /// No description provided for @dashSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble de l\'activité commerciale'**
  String get dashSubtitle;

  /// No description provided for @dashUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour à {time}'**
  String dashUpdatedAt(Object time);

  /// No description provided for @dashStale.
  ///
  /// In fr, this message translates to:
  /// **'Chiffres peut-être obsolètes : {error}'**
  String dashStale(Object error);

  /// No description provided for @stageTypeOpen.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get stageTypeOpen;

  /// No description provided for @dashWon.
  ///
  /// In fr, this message translates to:
  /// **'Gagnés'**
  String get dashWon;

  /// No description provided for @dashLost.
  ///
  /// In fr, this message translates to:
  /// **'Perdus'**
  String get dashLost;

  /// No description provided for @dashWinRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de réussite : {rate} %'**
  String dashWinRate(Object rate);

  /// No description provided for @dashFollowUpsToday.
  ///
  /// In fr, this message translates to:
  /// **'Relances aujourd\'hui'**
  String get dashFollowUpsToday;

  /// No description provided for @dashFollowUpsOverdue.
  ///
  /// In fr, this message translates to:
  /// **'Relances en retard'**
  String get dashFollowUpsOverdue;

  /// No description provided for @dashFollowUpsUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Relances à venir'**
  String get dashFollowUpsUpcoming;

  /// No description provided for @dashFollowUpsUpcomingDays.
  ///
  /// In fr, this message translates to:
  /// **'Relances à venir ({days} j)'**
  String dashFollowUpsUpcomingDays(Object days);

  /// No description provided for @dashProspectsByStage.
  ///
  /// In fr, this message translates to:
  /// **'Prospects par étape'**
  String get dashProspectsByStage;

  /// No description provided for @dashClickStage.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez sur une étape pour voir ses prospects'**
  String get dashClickStage;

  /// No description provided for @noStages.
  ///
  /// In fr, this message translates to:
  /// **'Aucune étape'**
  String get noStages;

  /// No description provided for @dashOutcomes.
  ///
  /// In fr, this message translates to:
  /// **'Issue des opportunités'**
  String get dashOutcomes;

  /// No description provided for @dashRecentActivities.
  ///
  /// In fr, this message translates to:
  /// **'Activités récentes'**
  String get dashRecentActivities;

  /// No description provided for @noRecentActivities.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité récente'**
  String get noRecentActivities;

  /// No description provided for @dashWhyLose.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi perdons-nous des ventes ?'**
  String get dashWhyLose;

  /// No description provided for @dashLostByReason.
  ///
  /// In fr, this message translates to:
  /// **'Prospects perdus par motif'**
  String get dashLostByReason;

  /// No description provided for @noLostProspects.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prospect perdu'**
  String get noLostProspects;

  /// No description provided for @prospectsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des prospects et opportunités'**
  String get prospectsSubtitle;

  /// No description provided for @newProspect.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau prospect'**
  String get newProspect;

  /// No description provided for @editProspect.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le prospect'**
  String get editProspect;

  /// No description provided for @createProspect.
  ///
  /// In fr, this message translates to:
  /// **'Créer le prospect'**
  String get createProspect;

  /// No description provided for @addProspect.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un prospect'**
  String get addProspect;

  /// No description provided for @noProspectMatchesFilters.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prospect ne correspond aux filtres'**
  String get noProspectMatchesFilters;

  /// No description provided for @noProspectsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prospect pour le moment'**
  String get noProspectsYet;

  /// No description provided for @clearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get clearFilters;

  /// No description provided for @prospectSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom, société, téléphone, e-mail…'**
  String get prospectSearchHint;

  /// No description provided for @fieldStage.
  ///
  /// In fr, this message translates to:
  /// **'Étape'**
  String get fieldStage;

  /// No description provided for @stageInactiveSuffix.
  ///
  /// In fr, this message translates to:
  /// **'{name} (inactive)'**
  String stageInactiveSuffix(Object name);

  /// No description provided for @allStages.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les étapes'**
  String get allStages;

  /// No description provided for @fieldProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get fieldProduct;

  /// No description provided for @allProducts.
  ///
  /// In fr, this message translates to:
  /// **'Tous les produits'**
  String get allProducts;

  /// No description provided for @fieldLossReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de perte'**
  String get fieldLossReason;

  /// No description provided for @allReasons.
  ///
  /// In fr, this message translates to:
  /// **'Tous les motifs'**
  String get allReasons;

  /// No description provided for @filterCreatedDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de création'**
  String get filterCreatedDate;

  /// No description provided for @filtersUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Listes de filtres indisponibles : {error}\nCliquer pour réessayer.'**
  String filtersUnavailable(Object error);

  /// No description provided for @prospectCreated.
  ///
  /// In fr, this message translates to:
  /// **'Prospect « {name} » créé.'**
  String prospectCreated(Object name);

  /// No description provided for @prospectUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Prospect mis à jour.'**
  String get prospectUpdated;

  /// No description provided for @prospectMovedTo.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » est passé à l\'étape « {stage} ».'**
  String prospectMovedTo(Object name, Object stage);

  /// No description provided for @colCompanyContact.
  ///
  /// In fr, this message translates to:
  /// **'Société / contact'**
  String get colCompanyContact;

  /// No description provided for @colLastActivity.
  ///
  /// In fr, this message translates to:
  /// **'Dernière activité'**
  String get colLastActivity;

  /// No description provided for @colNextFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine relance'**
  String get colNextFollowUp;

  /// No description provided for @colCreatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get colCreatedOn;

  /// No description provided for @changeStage.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'étape'**
  String get changeStage;

  /// No description provided for @scheduleFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Planifier une relance'**
  String get scheduleFollowUp;

  /// No description provided for @addActivity.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une activité'**
  String get addActivity;

  /// No description provided for @sectionIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get sectionIdentity;

  /// No description provided for @fieldCompanyRequired.
  ///
  /// In fr, this message translates to:
  /// **'Société / client *'**
  String get fieldCompanyRequired;

  /// No description provided for @fieldCompany.
  ///
  /// In fr, this message translates to:
  /// **'Société / client'**
  String get fieldCompany;

  /// No description provided for @fieldContactPerson.
  ///
  /// In fr, this message translates to:
  /// **'Personne à contacter'**
  String get fieldContactPerson;

  /// No description provided for @sectionSalesFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Suivi commercial'**
  String get sectionSalesFollowUp;

  /// No description provided for @currentStage.
  ///
  /// In fr, this message translates to:
  /// **'Étape actuelle'**
  String get currentStage;

  /// No description provided for @currentStageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Étape actuelle :  '**
  String get currentStageLabel;

  /// No description provided for @useChangeStageHint.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez « Changer d\'étape » pour la modifier (historique conservé).'**
  String get useChangeStageHint;

  /// No description provided for @stagesUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Étapes indisponibles : {error}'**
  String stagesUnavailable(Object error);

  /// No description provided for @initialStageRequired.
  ///
  /// In fr, this message translates to:
  /// **'Étape initiale *'**
  String get initialStageRequired;

  /// No description provided for @markAsLost.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme perdu'**
  String get markAsLost;

  /// No description provided for @confirmChange.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le changement'**
  String get confirmChange;

  /// No description provided for @newStageRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle étape *'**
  String get newStageRequired;

  /// No description provided for @stageMarksWon.
  ///
  /// In fr, this message translates to:
  /// **'Cette étape marque une vente gagnée.'**
  String get stageMarksWon;

  /// No description provided for @lossReasonRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Motif de perte *'**
  String get lossReasonRequiredLabel;

  /// No description provided for @noActiveLossReason.
  ///
  /// In fr, this message translates to:
  /// **'Aucun motif actif : ajoutez-en dans « Motifs de perte ».'**
  String get noActiveLossReason;

  /// No description provided for @reasonDetailsRequiredSuffix.
  ///
  /// In fr, this message translates to:
  /// **'{label}  (précision requise)'**
  String reasonDetailsRequiredSuffix(Object label);

  /// No description provided for @detailsRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Précision *'**
  String get detailsRequiredLabel;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Précision'**
  String get details;

  /// No description provided for @interestedProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits intéressés'**
  String get interestedProducts;

  /// No description provided for @invalidProspectId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant de prospect invalide.'**
  String get invalidProspectId;

  /// No description provided for @dataMaybeStale.
  ///
  /// In fr, this message translates to:
  /// **'Données peut-être obsolètes : {error}'**
  String dataMaybeStale(Object error);

  /// No description provided for @stageChanged.
  ///
  /// In fr, this message translates to:
  /// **'Étape changée : « {stage} ».'**
  String stageChanged(Object stage);

  /// No description provided for @createdOnDate.
  ///
  /// In fr, this message translates to:
  /// **'Créé le {date}'**
  String createdOnDate(Object date);

  /// No description provided for @sectionInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get sectionInformation;

  /// No description provided for @updatedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour'**
  String get updatedLabel;

  /// No description provided for @productsUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Produits mis à jour.'**
  String get productsUpdated;

  /// No description provided for @noProductAssociated.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit associé.'**
  String get noProductAssociated;

  /// No description provided for @sectionCommercialStage.
  ///
  /// In fr, this message translates to:
  /// **'Étape commerciale'**
  String get sectionCommercialStage;

  /// No description provided for @opportunityLost.
  ///
  /// In fr, this message translates to:
  /// **'Opportunité perdue'**
  String get opportunityLost;

  /// No description provided for @reason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get reason;

  /// No description provided for @saleWon.
  ///
  /// In fr, this message translates to:
  /// **'Vente gagnée'**
  String get saleWon;

  /// No description provided for @stageHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des étapes'**
  String get stageHistory;

  /// No description provided for @noStageChanges.
  ///
  /// In fr, this message translates to:
  /// **'Aucun changement d\'étape enregistré.'**
  String get noStageChanges;

  /// No description provided for @creationArrow.
  ///
  /// In fr, this message translates to:
  /// **'Création →'**
  String get creationArrow;

  /// No description provided for @pendingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} en attente'**
  String pendingCount(Object count);

  /// No description provided for @noFollowUpScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune relance planifiée.'**
  String get noFollowUpScheduled;

  /// No description provided for @closedFollowUps.
  ///
  /// In fr, this message translates to:
  /// **'Relances terminées ou annulées ({count})'**
  String closedFollowUps(Object count);

  /// No description provided for @activityHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des activités'**
  String get activityHistory;

  /// No description provided for @activityWord.
  ///
  /// In fr, this message translates to:
  /// **'activité'**
  String get activityWord;

  /// No description provided for @noActivitiesForProspect.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité enregistrée pour ce prospect.'**
  String get noActivitiesForProspect;

  /// No description provided for @showOlderActivities.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les activités plus anciennes'**
  String get showOlderActivities;

  /// No description provided for @activitiesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Appels, rendez-vous, messages et notes'**
  String get activitiesSubtitle;

  /// No description provided for @newActivity.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle activité'**
  String get newActivity;

  /// No description provided for @activitySearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Description, résultat, prospect…'**
  String get activitySearchHint;

  /// No description provided for @allTypes.
  ///
  /// In fr, this message translates to:
  /// **'Tous les types'**
  String get allTypes;

  /// No description provided for @noActivityMatchesFilters.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité ne correspond aux filtres'**
  String get noActivityMatchesFilters;

  /// No description provided for @noActivities.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité enregistrée'**
  String get noActivities;

  /// No description provided for @colProspect.
  ///
  /// In fr, this message translates to:
  /// **'Prospect'**
  String get colProspect;

  /// No description provided for @prospectNumber.
  ///
  /// In fr, this message translates to:
  /// **'Prospect #{id}'**
  String prospectNumber(Object id);

  /// No description provided for @outcomeLine.
  ///
  /// In fr, this message translates to:
  /// **'Résultat : {outcome}'**
  String outcomeLine(Object outcome);

  /// No description provided for @activityTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'activité'**
  String get activityTypeLabel;

  /// No description provided for @activityDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui a été dit / fait…'**
  String get activityDescriptionHint;

  /// No description provided for @activityOutcomeHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : intéressé, hésite sur le prix, demande une démo…'**
  String get activityOutcomeHint;

  /// No description provided for @nextStepsSection.
  ///
  /// In fr, this message translates to:
  /// **'Suite à donner'**
  String get nextStepsSection;

  /// No description provided for @nextFollowUpOptional.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine relance (optionnel)'**
  String get nextFollowUpOptional;

  /// No description provided for @alsoScheduleFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Planifier aussi une relance à cette date'**
  String get alsoScheduleFollowUp;

  /// No description provided for @willAppearInFollowUps.
  ///
  /// In fr, this message translates to:
  /// **'Elle apparaîtra dans « Relances ».'**
  String get willAppearInFollowUps;

  /// No description provided for @followUpSubject.
  ///
  /// In fr, this message translates to:
  /// **'Objet de la relance'**
  String get followUpSubject;

  /// No description provided for @leaveEmptyAuto.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide pour un texte automatique'**
  String get leaveEmptyAuto;

  /// No description provided for @activitySaved.
  ///
  /// In fr, this message translates to:
  /// **'Activité enregistrée.'**
  String get activitySaved;

  /// No description provided for @activitySavedAndFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Activité enregistrée et relance planifiée.'**
  String get activitySavedAndFollowUp;

  /// No description provided for @activitySavedFollowUpFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'activité est enregistrée, mais la relance n\'a PAS pu être planifiée :'**
  String get activitySavedFollowUpFailed;

  /// No description provided for @activityTypeCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel'**
  String get activityTypeCall;

  /// No description provided for @activityTypeAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get activityTypeAppointment;

  /// No description provided for @activityTypeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get activityTypeMessage;

  /// No description provided for @activityTypeNote.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get activityTypeNote;

  /// No description provided for @followUpAfterActivity.
  ///
  /// In fr, this message translates to:
  /// **'Relance suite à : {type} du {date}'**
  String followUpAfterActivity(Object type, Object date);

  /// No description provided for @followUpsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi des rappels et rendez-vous à venir'**
  String get followUpsSubtitle;

  /// No description provided for @followUpSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Prospect, description…'**
  String get followUpSearchHint;

  /// No description provided for @noFollowUpsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucune relance prévue aujourd\'hui'**
  String get noFollowUpsToday;

  /// No description provided for @noFollowUpsOverdue.
  ///
  /// In fr, this message translates to:
  /// **'Aucune relance en retard'**
  String get noFollowUpsOverdue;

  /// No description provided for @noFollowUpsUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucune relance à venir'**
  String get noFollowUpsUpcoming;

  /// No description provided for @noFollowUpsDone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune relance effectuée'**
  String get noFollowUpsDone;

  /// No description provided for @noFollowUpsCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Aucune relance annulée'**
  String get noFollowUpsCancelled;

  /// No description provided for @colDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get colDueDate;

  /// No description provided for @markAsDone.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme effectuée'**
  String get markAsDone;

  /// No description provided for @cancelFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la relance'**
  String get cancelFollowUp;

  /// No description provided for @followUpStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get followUpStatusPending;

  /// No description provided for @followUpStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Effectuée'**
  String get followUpStatusCompleted;

  /// No description provided for @followUpStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get followUpStatusCancelled;

  /// No description provided for @followUpViewToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get followUpViewToday;

  /// No description provided for @followUpViewOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get followUpViewOverdue;

  /// No description provided for @followUpViewUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get followUpViewUpcoming;

  /// No description provided for @followUpViewCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Effectuées'**
  String get followUpViewCompleted;

  /// No description provided for @followUpViewCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulées'**
  String get followUpViewCancelled;

  /// No description provided for @followUpScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Relance planifiée.'**
  String get followUpScheduled;

  /// No description provided for @followUpUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Relance modifiée.'**
  String get followUpUpdated;

  /// No description provided for @followUpCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Relance marquée comme effectuée.'**
  String get followUpCompleted;

  /// No description provided for @followUpCompletedActivityFailed.
  ///
  /// In fr, this message translates to:
  /// **'Relance marquée comme effectuée, mais l\'activité n\'a pas pu être enregistrée ({error}). Le résultat est conservé dans la note de la relance ; ajoutez l\'activité depuis la fiche du prospect.'**
  String followUpCompletedActivityFailed(Object error);

  /// No description provided for @followUpCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Relance annulée.'**
  String get followUpCancelled;

  /// No description provided for @editFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la relance'**
  String get editFollowUp;

  /// No description provided for @quickTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get quickTomorrow;

  /// No description provided for @quickIn3Days.
  ///
  /// In fr, this message translates to:
  /// **'Dans 3 jours'**
  String get quickIn3Days;

  /// No description provided for @quickIn1Week.
  ///
  /// In fr, this message translates to:
  /// **'Dans 1 semaine'**
  String get quickIn1Week;

  /// No description provided for @quickIn2Weeks.
  ///
  /// In fr, this message translates to:
  /// **'Dans 2 semaines'**
  String get quickIn2Weeks;

  /// No description provided for @followUpDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : rappeler pour la validation du devis'**
  String get followUpDescriptionHint;

  /// No description provided for @completeFollowUpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Marquer la relance comme effectuée'**
  String get completeFollowUpTitle;

  /// No description provided for @finishFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la relance'**
  String get finishFollowUp;

  /// No description provided for @dueOn.
  ///
  /// In fr, this message translates to:
  /// **'Prévue le {date}'**
  String dueOn(Object date);

  /// No description provided for @recordOutcomeAsActivity.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le résultat comme activité'**
  String get recordOutcomeAsActivity;

  /// No description provided for @recommendedKeepsHistory.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé : garde l\'historique de l\'échange.'**
  String get recommendedKeepsHistory;

  /// No description provided for @completeOutcomeHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : accord de principe, souhaite réfléchir…'**
  String get completeOutcomeHint;

  /// No description provided for @companyDueOn.
  ///
  /// In fr, this message translates to:
  /// **'{company} — prévue le {date}'**
  String companyDueOn(Object company, Object date);

  /// No description provided for @reasonOptional.
  ///
  /// In fr, this message translates to:
  /// **'Raison (optionnel)'**
  String get reasonOptional;

  /// No description provided for @followUpOverdueTip.
  ///
  /// In fr, this message translates to:
  /// **'Relance en retard'**
  String get followUpOverdueTip;

  /// No description provided for @pipelineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pipeline des ventes'**
  String get pipelineTitle;

  /// No description provided for @pipelineSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prospects regroupés par étape'**
  String get pipelineSubtitle;

  /// No description provided for @pipelineFilterHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer toutes les étapes…'**
  String get pipelineFilterHint;

  /// No description provided for @noStagesConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Aucune étape de vente configurée'**
  String get noStagesConfigured;

  /// No description provided for @configureStages.
  ///
  /// In fr, this message translates to:
  /// **'Configurer les étapes'**
  String get configureStages;

  /// No description provided for @prospectMovedToStage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » déplacé vers « {stage} ».'**
  String prospectMovedToStage(Object name, Object stage);

  /// No description provided for @dropCardHere.
  ///
  /// In fr, this message translates to:
  /// **'Déposez une carte ici'**
  String get dropCardHere;

  /// No description provided for @stageDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Étape désactivée'**
  String get stageDeactivated;

  /// No description provided for @moveTo.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer vers…'**
  String get moveTo;

  /// No description provided for @moveToStage.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer vers « {stage} »'**
  String moveToStage(Object stage);

  /// No description provided for @productAdded.
  ///
  /// In fr, this message translates to:
  /// **'Produit « {name} » ajouté.'**
  String productAdded(Object name);

  /// No description provided for @productUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Produit mis à jour.'**
  String get productUpdated;

  /// No description provided for @productReactivated.
  ///
  /// In fr, this message translates to:
  /// **'Produit réactivé.'**
  String get productReactivated;

  /// No description provided for @productDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Produit désactivé.'**
  String get productDeactivated;

  /// No description provided for @deactivateQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver « {name} » ?'**
  String deactivateQuestion(Object name);

  /// No description provided for @deactivateProductBody.
  ///
  /// In fr, this message translates to:
  /// **'Le produit ne pourra plus être associé à de nouveaux prospects. Les associations existantes et l\'historique sont conservés.'**
  String get deactivateProductBody;

  /// No description provided for @productsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Logiciels et services proposés aux prospects'**
  String get productsSubtitle;

  /// No description provided for @newProduct.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get newProduct;

  /// No description provided for @productSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit…'**
  String get productSearchHint;

  /// No description provided for @showInactiveProducts.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les produits inactifs'**
  String get showInactiveProducts;

  /// No description provided for @noProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit'**
  String get noProducts;

  /// No description provided for @noProductMatches.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit ne correspond'**
  String get noProductMatches;

  /// No description provided for @addProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get editProduct;

  /// No description provided for @productActive.
  ///
  /// In fr, this message translates to:
  /// **'Produit actif'**
  String get productActive;

  /// No description provided for @productActiveHint.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les produits actifs peuvent être associés aux prospects.'**
  String get productActiveHint;

  /// No description provided for @productPack.
  ///
  /// In fr, this message translates to:
  /// **'Pack (suite de variantes)'**
  String get productPack;

  /// No description provided for @productNoPack.
  ///
  /// In fr, this message translates to:
  /// **'Produit indépendant (aucun pack)'**
  String get productNoPack;

  /// No description provided for @productNewPack.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau pack'**
  String get productNewPack;

  /// No description provided for @productPackName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du pack'**
  String get productPackName;

  /// No description provided for @productPackCode.
  ///
  /// In fr, this message translates to:
  /// **'Code du pack'**
  String get productPackCode;

  /// No description provided for @productDemoUrl.
  ///
  /// In fr, this message translates to:
  /// **'Lien version démo'**
  String get productDemoUrl;

  /// No description provided for @productDemoUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'Lien fixe de démo pour ce produit (ex: https://...)'**
  String get productDemoUrlHint;

  /// No description provided for @productUploadDemo.
  ///
  /// In fr, this message translates to:
  /// **'Téléverser le fichier démo sur le serveur'**
  String get productUploadDemo;

  /// No description provided for @productDemoUploaded.
  ///
  /// In fr, this message translates to:
  /// **'Fichier démo téléversé avec succès et lien mis à jour.'**
  String get productDemoUploaded;

  /// No description provided for @productUploadingDemo.
  ///
  /// In fr, this message translates to:
  /// **'Téléversement du fichier démo vers le serveur…'**
  String get productUploadingDemo;

  /// No description provided for @productActiveOnWeb.
  ///
  /// In fr, this message translates to:
  /// **'Afficher sur le site web & portail'**
  String get productActiveOnWeb;

  /// No description provided for @productActiveOnWebHint.
  ///
  /// In fr, this message translates to:
  /// **'Rend ce produit visible et sélectionnable par les clients en ligne.'**
  String get productActiveOnWebHint;

  /// No description provided for @productPacksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des packs'**
  String get productPacksTitle;

  /// No description provided for @selectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sélectionné(s)'**
  String selectedCount(Object count);

  /// No description provided for @noActiveProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit actif. Ajoutez-en dans « Produits ».'**
  String get noActiveProducts;

  /// No description provided for @productInactiveSuffix.
  ///
  /// In fr, this message translates to:
  /// **'{name} (inactif)'**
  String productInactiveSuffix(Object name);

  /// No description provided for @stageCreated.
  ///
  /// In fr, this message translates to:
  /// **'Étape « {name} » créée.'**
  String stageCreated(Object name);

  /// No description provided for @stageUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Étape mise à jour.'**
  String get stageUpdated;

  /// No description provided for @stageReactivated.
  ///
  /// In fr, this message translates to:
  /// **'Étape réactivée.'**
  String get stageReactivated;

  /// No description provided for @stageDeactivatedMsg.
  ///
  /// In fr, this message translates to:
  /// **'Étape désactivée.'**
  String get stageDeactivatedMsg;

  /// No description provided for @stageDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Étape supprimée.'**
  String get stageDeleted;

  /// No description provided for @deleteQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ?'**
  String deleteQuestion(Object name);

  /// No description provided for @deleteStageBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette étape n\'a jamais été utilisée. Elle sera définitivement supprimée.'**
  String get deleteStageBody;

  /// No description provided for @orderNotSaved.
  ///
  /// In fr, this message translates to:
  /// **'Le nouvel ordre n\'a pas été enregistré :'**
  String get orderNotSaved;

  /// No description provided for @stagesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Définissez le pipeline : ordre, couleur et type (en cours / gagné / perdu). Les étapes utilisées ne peuvent pas être supprimées, seulement désactivées.'**
  String get stagesSubtitle;

  /// No description provided for @newStage.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle étape'**
  String get newStage;

  /// No description provided for @savingNewOrder.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement du nouvel ordre…'**
  String get savingNewOrder;

  /// No description provided for @createStagesHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez au moins une étape « en cours », une « gagné » et une « perdu ».'**
  String get createStagesHint;

  /// No description provided for @createStage.
  ///
  /// In fr, this message translates to:
  /// **'Créer une étape'**
  String get createStage;

  /// No description provided for @prospectsCountShort.
  ///
  /// In fr, this message translates to:
  /// **'{count} prospect(s)'**
  String prospectsCountShort(Object count);

  /// No description provided for @stageUsedNoDelete.
  ///
  /// In fr, this message translates to:
  /// **'Utilisée par des prospects ou l\'historique : suppression impossible.'**
  String get stageUsedNoDelete;

  /// No description provided for @deleteImpossibleUsed.
  ///
  /// In fr, this message translates to:
  /// **'Suppression impossible (étape utilisée)'**
  String get deleteImpossibleUsed;

  /// No description provided for @editStage.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'étape'**
  String get editStage;

  /// No description provided for @stageTypeLocked.
  ///
  /// In fr, this message translates to:
  /// **'Étape déjà utilisée : son type ne peut plus changer (protection de l\'historique).'**
  String get stageTypeLocked;

  /// No description provided for @lostRequiresReasonHint.
  ///
  /// In fr, this message translates to:
  /// **'« Perdu » exige un motif de perte lors du changement d\'étape.'**
  String get lostRequiresReasonHint;

  /// No description provided for @stageActive.
  ///
  /// In fr, this message translates to:
  /// **'Étape active'**
  String get stageActive;

  /// No description provided for @stageUsedDeactivateInstead.
  ///
  /// In fr, this message translates to:
  /// **'Cette étape est utilisée par des prospects ou leur historique : désactivez-la au lieu de la supprimer.'**
  String get stageUsedDeactivateInstead;

  /// No description provided for @stageTypeWon.
  ///
  /// In fr, this message translates to:
  /// **'Gagné'**
  String get stageTypeWon;

  /// No description provided for @stageTypeLost.
  ///
  /// In fr, this message translates to:
  /// **'Perdu'**
  String get stageTypeLost;

  /// No description provided for @reasonAdded.
  ///
  /// In fr, this message translates to:
  /// **'Motif ajouté.'**
  String get reasonAdded;

  /// No description provided for @reasonUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Motif mis à jour.'**
  String get reasonUpdated;

  /// No description provided for @reasonReactivated.
  ///
  /// In fr, this message translates to:
  /// **'Motif réactivé.'**
  String get reasonReactivated;

  /// No description provided for @reasonDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Motif désactivé.'**
  String get reasonDeactivated;

  /// No description provided for @deactivateReasonBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce motif ne sera plus proposé. Les prospects déjà perdus avec ce motif le conservent.'**
  String get deactivateReasonBody;

  /// No description provided for @lossReasonsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Raisons proposées lorsqu\'un prospect passe à une étape « perdu ». Elles alimentent l\'analyse des ventes perdues.'**
  String get lossReasonsSubtitle;

  /// No description provided for @newReason.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau motif'**
  String get newReason;

  /// No description provided for @lossReasonsReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur ne permet pas de gérer les motifs de perte depuis l\'application : liste en lecture seule.'**
  String get lossReasonsReadOnly;

  /// No description provided for @noLossReasons.
  ///
  /// In fr, this message translates to:
  /// **'Aucun motif de perte'**
  String get noLossReasons;

  /// No description provided for @noActiveReasonWarning.
  ///
  /// In fr, this message translates to:
  /// **'Sans motif actif, aucun prospect ne peut passer à une étape « perdu ».'**
  String get noActiveReasonWarning;

  /// No description provided for @detailsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Précision requise'**
  String get detailsRequired;

  /// No description provided for @editReason.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le motif'**
  String get editReason;

  /// No description provided for @newLossReason.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau motif de perte'**
  String get newLossReason;

  /// No description provided for @reasonLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Trop cher'**
  String get reasonLabelHint;

  /// No description provided for @detailsMandatory.
  ///
  /// In fr, this message translates to:
  /// **'Précision obligatoire'**
  String get detailsMandatory;

  /// No description provided for @detailsMandatoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : « Concurrent choisi » → préciser lequel.'**
  String get detailsMandatoryHint;

  /// No description provided for @reasonActive.
  ///
  /// In fr, this message translates to:
  /// **'Motif actif'**
  String get reasonActive;

  /// No description provided for @settingsSavedOnline.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés. Serveur joignable.'**
  String get settingsSavedOnline;

  /// No description provided for @settingsSavedOffline.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés sur cet ordinateur, mais le serveur ne répond pas pour le moment.'**
  String get settingsSavedOffline;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres propres à cet ordinateur'**
  String get settingsSubtitle;

  /// No description provided for @firstLaunchHint.
  ///
  /// In fr, this message translates to:
  /// **'Première utilisation : indiquez l\'adresse de l\'ordinateur central (serveur Laravel) sur le réseau de l\'entreprise, testez la connexion puis enregistrez.'**
  String get firstLaunchHint;

  /// No description provided for @settingsServerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Serveur de l\'application'**
  String get settingsServerTitle;

  /// No description provided for @settingsServerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'API Laravel hébergée sur l\'ordinateur central (réseau local)'**
  String get settingsServerSubtitle;

  /// No description provided for @fieldApiAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de l\'API *'**
  String get fieldApiAddress;

  /// No description provided for @apiAddressHelp.
  ///
  /// In fr, this message translates to:
  /// **'Format : http://ADRESSE_IP:PORT/api/v1 — n\'utilisez pas « localhost » sur les postes des employés.'**
  String get apiAddressHelp;

  /// No description provided for @fieldTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Délai d\'attente maximal'**
  String get fieldTimeout;

  /// No description provided for @secondsShort.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(Object seconds);

  /// No description provided for @testing.
  ///
  /// In fr, this message translates to:
  /// **'Test en cours…'**
  String get testing;

  /// No description provided for @testConnection.
  ///
  /// In fr, this message translates to:
  /// **'Tester la connexion'**
  String get testConnection;

  /// No description provided for @connectionSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie à {url}'**
  String connectionSuccess(Object url);

  /// No description provided for @settingsDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get settingsDisplay;

  /// No description provided for @themeLightShort.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLightShort;

  /// No description provided for @themeDarkShort.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDarkShort;

  /// No description provided for @themeSystemShort.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystemShort;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @aboutApplication.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get aboutApplication;

  /// No description provided for @aboutClient.
  ///
  /// In fr, this message translates to:
  /// **'{app} — client Windows'**
  String aboutClient(Object app);

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get aboutData;

  /// No description provided for @aboutDataBody.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les données sont stockées sur le serveur central. Seuls l\'adresse du serveur et le thème sont enregistrés sur ce poste.'**
  String get aboutDataBody;

  /// No description provided for @changeProspect.
  ///
  /// In fr, this message translates to:
  /// **'Changer de prospect'**
  String get changeProspect;

  /// No description provided for @prospectRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prospect *'**
  String get prospectRequiredLabel;

  /// No description provided for @errNotJson.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a répondu, mais pas en JSON. Vérifiez que l\'adresse se termine par /api/v1.'**
  String get errNotJson;

  /// No description provided for @countProspects.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun prospect} one{1 prospect} other{{count} prospects}}'**
  String countProspects(num count);

  /// No description provided for @countActivities.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune activité} one{1 activité} other{{count} activités}}'**
  String countActivities(num count);

  /// No description provided for @activitiesCountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} activité} other{{count} activités}} — appels, rendez-vous, messages et notes'**
  String activitiesCountSubtitle(num count);

  /// No description provided for @pipelineCountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} prospect} other{{count} prospects}} · glissez une carte vers une autre étape pour la déplacer'**
  String pipelineCountSubtitle(num count);

  /// No description provided for @donutProspects.
  ///
  /// In fr, this message translates to:
  /// **'prospects'**
  String get donutProspects;

  /// No description provided for @reasonLine.
  ///
  /// In fr, this message translates to:
  /// **'Raison : {note}'**
  String reasonLine(Object note);

  /// No description provided for @lossReasonLine.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String lossReasonLine(Object reason);

  /// No description provided for @deactivateStageIntro.
  ///
  /// In fr, this message translates to:
  /// **'L\'étape ne pourra plus être choisie pour de nouveaux changements.'**
  String get deactivateStageIntro;

  /// No description provided for @deactivateStageProspects.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 prospect y est actuellement et y restera.} other{{count} prospects y sont actuellement et y resteront.}}'**
  String deactivateStageProspects(num count);

  /// No description provided for @deactivateStageOutro.
  ///
  /// In fr, this message translates to:
  /// **'L\'historique est conservé.'**
  String get deactivateStageOutro;

  /// No description provided for @sectionBusinessProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil commercial'**
  String get sectionBusinessProfile;

  /// No description provided for @fieldBusinessActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité de l\'entreprise'**
  String get fieldBusinessActivity;

  /// No description provided for @businessActivityHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisir ou saisir une activité'**
  String get businessActivityHint;

  /// No description provided for @fieldSource.
  ///
  /// In fr, this message translates to:
  /// **'Source du prospect'**
  String get fieldSource;

  /// No description provided for @fieldSourceOther.
  ///
  /// In fr, this message translates to:
  /// **'Précisez la source'**
  String get fieldSourceOther;

  /// No description provided for @fieldPreviousSoftware.
  ///
  /// In fr, this message translates to:
  /// **'Logiciel utilisé auparavant'**
  String get fieldPreviousSoftware;

  /// No description provided for @previousSoftwareHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisir ou saisir un logiciel'**
  String get previousSoftwareHint;

  /// No description provided for @notSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get notSpecified;

  /// No description provided for @allSources.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les sources'**
  String get allSources;

  /// No description provided for @baWholesale.
  ///
  /// In fr, this message translates to:
  /// **'Commerce de gros'**
  String get baWholesale;

  /// No description provided for @baRetail.
  ///
  /// In fr, this message translates to:
  /// **'Commerce de détail'**
  String get baRetail;

  /// No description provided for @baManufacturing.
  ///
  /// In fr, this message translates to:
  /// **'Industrie / production'**
  String get baManufacturing;

  /// No description provided for @baConstruction.
  ///
  /// In fr, this message translates to:
  /// **'BTP / construction'**
  String get baConstruction;

  /// No description provided for @baServices.
  ///
  /// In fr, this message translates to:
  /// **'Services'**
  String get baServices;

  /// No description provided for @srcFacebook.
  ///
  /// In fr, this message translates to:
  /// **'Facebook'**
  String get srcFacebook;

  /// No description provided for @srcInstagram.
  ///
  /// In fr, this message translates to:
  /// **'Instagram'**
  String get srcInstagram;

  /// No description provided for @srcFriendReferral.
  ///
  /// In fr, this message translates to:
  /// **'Ami / recommandation personnelle'**
  String get srcFriendReferral;

  /// No description provided for @srcCustomerReferral.
  ///
  /// In fr, this message translates to:
  /// **'Recommandation d\'un client existant'**
  String get srcCustomerReferral;

  /// No description provided for @srcWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get srcWebsite;

  /// No description provided for @srcPhoneCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel téléphonique'**
  String get srcPhoneCall;

  /// No description provided for @swSage.
  ///
  /// In fr, this message translates to:
  /// **'Sage'**
  String get swSage;

  /// No description provided for @swPcCompta.
  ///
  /// In fr, this message translates to:
  /// **'PC Compta'**
  String get swPcCompta;

  /// No description provided for @swExcel.
  ///
  /// In fr, this message translates to:
  /// **'Excel'**
  String get swExcel;

  /// No description provided for @swOtherSoftware.
  ///
  /// In fr, this message translates to:
  /// **'Autre logiciel de gestion'**
  String get swOtherSoftware;

  /// No description provided for @swNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun logiciel'**
  String get swNone;

  /// No description provided for @searchProspectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un prospect'**
  String get searchProspectTitle;

  /// No description provided for @searchProspectHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom, société, téléphone ou n° de prospect…'**
  String get searchProspectHint;

  /// No description provided for @searchProspectIdle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un nom, une société, un numéro de téléphone ou un n° de prospect.'**
  String get searchProspectIdle;

  /// No description provided for @searchProspectEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prospect trouvé'**
  String get searchProspectEmpty;

  /// No description provided for @searchProspectMore.
  ///
  /// In fr, this message translates to:
  /// **'Affinez la recherche pour voir les autres résultats ({total} au total).'**
  String searchProspectMore(Object total);

  /// No description provided for @searchAllStagesNote.
  ///
  /// In fr, this message translates to:
  /// **'La recherche porte sur toutes les étapes (gagnés et perdus inclus).'**
  String get searchAllStagesNote;

  /// No description provided for @prospectIdShort.
  ///
  /// In fr, this message translates to:
  /// **'N° {id}'**
  String prospectIdShort(Object id);

  /// No description provided for @prospectOptionalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prospect (optionnel)'**
  String get prospectOptionalLabel;

  /// No description provided for @pickProspect.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un prospect'**
  String get pickProspect;

  /// No description provided for @activityTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Titre / résumé *'**
  String get activityTitleRequired;

  /// No description provided for @activityTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : appel du client au sujet du devis'**
  String get activityTitleHint;

  /// No description provided for @activityDiscussionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Discussion, réponse du client, notes'**
  String get activityDiscussionLabel;

  /// No description provided for @colTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get colTitle;

  /// No description provided for @linkStatusLinked.
  ///
  /// In fr, this message translates to:
  /// **'Lié'**
  String get linkStatusLinked;

  /// No description provided for @linkStatusUnlinked.
  ///
  /// In fr, this message translates to:
  /// **'Non lié'**
  String get linkStatusUnlinked;

  /// No description provided for @linkToProspect.
  ///
  /// In fr, this message translates to:
  /// **'Lier à un prospect'**
  String get linkToProspect;

  /// No description provided for @changeLinkedProspect.
  ///
  /// In fr, this message translates to:
  /// **'Changer le prospect lié'**
  String get changeLinkedProspect;

  /// No description provided for @linkedProspectLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prospect lié'**
  String get linkedProspectLabel;

  /// No description provided for @noProspectLinked.
  ///
  /// In fr, this message translates to:
  /// **'Aucun prospect lié'**
  String get noProspectLinked;

  /// No description provided for @openProspect.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le prospect'**
  String get openProspect;

  /// No description provided for @activityDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails de l\'activité'**
  String get activityDetails;

  /// No description provided for @activityLinkedTo.
  ///
  /// In fr, this message translates to:
  /// **'Activité liée à « {name} ».'**
  String activityLinkedTo(Object name);

  /// No description provided for @relinkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le prospect lié ?'**
  String get relinkTitle;

  /// No description provided for @relinkBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette activité est liée à « {from} ». La déplacer vers « {to} » ? Son contenu et sa date ne changent pas.'**
  String relinkBody(Object from, Object to);

  /// No description provided for @relinkConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer'**
  String get relinkConfirm;

  /// No description provided for @originLabel.
  ///
  /// In fr, this message translates to:
  /// **'Origine'**
  String get originLabel;

  /// No description provided for @originDirect.
  ///
  /// In fr, this message translates to:
  /// **'Saisie directe'**
  String get originDirect;

  /// No description provided for @originFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Issue d\'une relance'**
  String get originFollowUp;

  /// No description provided for @activityFromFollowUpLocked.
  ///
  /// In fr, this message translates to:
  /// **'Cette activité provient d\'une relance : elle reste liée à son prospect.'**
  String get activityFromFollowUpLocked;

  /// No description provided for @filterLinkAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes (liées ou non)'**
  String get filterLinkAll;

  /// No description provided for @filterLinkOnlyLinked.
  ///
  /// In fr, this message translates to:
  /// **'Liées à un prospect'**
  String get filterLinkOnlyLinked;

  /// No description provided for @filterLinkOnlyUnlinked.
  ///
  /// In fr, this message translates to:
  /// **'Non liées'**
  String get filterLinkOnlyUnlinked;

  /// No description provided for @colLink.
  ///
  /// In fr, this message translates to:
  /// **'Prospect lié'**
  String get colLink;

  /// No description provided for @colLinkfllowup.
  ///
  /// In fr, this message translates to:
  /// **'Relance liée'**
  String get colLinkfllowup;

  /// No description provided for @activityOccurredAt.
  ///
  /// In fr, this message translates to:
  /// **'Date et heure'**
  String get activityOccurredAt;

  /// No description provided for @createdOnLabel.
  ///
  /// In fr, this message translates to:
  /// **'Créée le'**
  String get createdOnLabel;

  /// No description provided for @linkedOnLabel.
  ///
  /// In fr, this message translates to:
  /// **'Liée le'**
  String get linkedOnLabel;

  /// No description provided for @typeLabelRequired.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'activité *'**
  String get typeLabelRequired;

  /// No description provided for @followUpTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type de relance'**
  String get followUpTypeLabel;

  /// No description provided for @followUpTypeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le type de relance.'**
  String get followUpTypeRequired;

  /// No description provided for @followUpTypeMissing.
  ///
  /// In fr, this message translates to:
  /// **'Type non défini'**
  String get followUpTypeMissing;

  /// No description provided for @followUpCompletedKeepsType.
  ///
  /// In fr, this message translates to:
  /// **'Le type de l\'activité sera celui de la relance : {type}.'**
  String followUpCompletedKeepsType(Object type);

  /// No description provided for @activityTypeForLegacy.
  ///
  /// In fr, this message translates to:
  /// **'Cette relance n\'a pas de type : choisissez celui de l\'activité.'**
  String get activityTypeForLegacy;

  /// No description provided for @followUpCompletedWithActivity.
  ///
  /// In fr, this message translates to:
  /// **'Relance terminée et activité enregistrée.'**
  String get followUpCompletedWithActivity;

  /// No description provided for @colType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'interface. Le changement est immédiat.'**
  String get settingsLanguageHint;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Changer la langue'**
  String get languageMenuTooltip;

  /// No description provided for @themeToggleToDark.
  ///
  /// In fr, this message translates to:
  /// **'Passer au thème sombre'**
  String get themeToggleToDark;

  /// No description provided for @themeToggleToLight.
  ///
  /// In fr, this message translates to:
  /// **'Passer au thème clair'**
  String get themeToggleToLight;

  /// No description provided for @settingsAboutBody.
  ///
  /// In fr, this message translates to:
  /// **'Seuls l\'adresse du serveur, la langue et le thème sont enregistrés sur ce poste.'**
  String get settingsAboutBody;

  /// No description provided for @validFieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le titre'**
  String get validFieldTitle;

  /// No description provided for @validMinLength.
  ///
  /// In fr, this message translates to:
  /// **'{min} caractères minimum.'**
  String validMinLength(Object min);

  /// No description provided for @navAfterSales.
  ///
  /// In fr, this message translates to:
  /// **'Après-vente'**
  String get navAfterSales;

  /// No description provided for @navCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get navCalendar;

  /// No description provided for @navCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get navCustomers;

  /// No description provided for @navEmployees.
  ///
  /// In fr, this message translates to:
  /// **'Employés'**
  String get navEmployees;

  /// No description provided for @navGroupCrm.
  ///
  /// In fr, this message translates to:
  /// **'CRM'**
  String get navGroupCrm;

  /// No description provided for @navGroupCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients et produits'**
  String get navGroupCustomers;

  /// No description provided for @navGroupService.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get navGroupService;

  /// No description provided for @navGroupTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get navGroupTeam;

  /// No description provided for @navRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes et réservations'**
  String get navRequests;

  /// No description provided for @navTraining.
  ///
  /// In fr, this message translates to:
  /// **'Formation et accompagnement'**
  String get navTraining;

  /// No description provided for @navWorkflowSettings.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous et après-vente'**
  String get navWorkflowSettings;

  /// No description provided for @wfYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get wfYes;

  /// No description provided for @wfNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get wfNo;

  /// No description provided for @wfSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré.'**
  String get wfSaved;

  /// No description provided for @wfDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get wfDate;

  /// No description provided for @wfWhen.
  ///
  /// In fr, this message translates to:
  /// **'Quand'**
  String get wfWhen;

  /// No description provided for @wfToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get wfToday;

  /// No description provided for @wfPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get wfPrevious;

  /// No description provided for @wfNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get wfNext;

  /// No description provided for @wfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get wfTitle;

  /// No description provided for @wfUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour'**
  String get wfUpdated;

  /// No description provided for @wfReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçue le'**
  String get wfReceived;

  /// No description provided for @wfReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get wfReference;

  /// No description provided for @wfEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Employé'**
  String get wfEmployee;

  /// No description provided for @wfAssignedTo.
  ///
  /// In fr, this message translates to:
  /// **'Assigné à'**
  String get wfAssignedTo;

  /// No description provided for @wfUnassigned.
  ///
  /// In fr, this message translates to:
  /// **'Non assigné'**
  String get wfUnassigned;

  /// No description provided for @wfTrainer.
  ///
  /// In fr, this message translates to:
  /// **'Formateur'**
  String get wfTrainer;

  /// No description provided for @wfCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get wfCode;

  /// No description provided for @wfCodeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Minuscules, chiffres et _ ; commence par une lettre.'**
  String get wfCodeInvalid;

  /// No description provided for @wfFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire.'**
  String get wfFieldRequired;

  /// No description provided for @wfNumberInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Nombre entier positif attendu.'**
  String get wfNumberInvalid;

  /// No description provided for @wfTooLong.
  ///
  /// In fr, this message translates to:
  /// **'{max} caractères maximum.'**
  String wfTooLong(Object max);

  /// No description provided for @wfRangeError.
  ///
  /// In fr, this message translates to:
  /// **'Entre {min} et {max}.'**
  String wfRangeError(Object min, Object max);

  /// No description provided for @wfUrl.
  ///
  /// In fr, this message translates to:
  /// **'Lien (URL)'**
  String get wfUrl;

  /// No description provided for @wfUrlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Lien http(s) invalide.'**
  String get wfUrlInvalid;

  /// No description provided for @wfUrlRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le lien est obligatoire.'**
  String get wfUrlRequired;

  /// No description provided for @wfInvalidId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant invalide.'**
  String get wfInvalidId;

  /// No description provided for @wfStartInPast.
  ///
  /// In fr, this message translates to:
  /// **'L\'heure de début est déjà passée.'**
  String get wfStartInPast;

  /// No description provided for @wfEndAfterStart.
  ///
  /// In fr, this message translates to:
  /// **'La fin doit être après le début.'**
  String get wfEndAfterStart;

  /// No description provided for @wfStarts.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get wfStarts;

  /// No description provided for @wfEnds.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get wfEnds;

  /// No description provided for @wfStartTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de début'**
  String get wfStartTime;

  /// No description provided for @wfEndTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de fin'**
  String get wfEndTime;

  /// No description provided for @wfLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get wfLanguage;

  /// No description provided for @wfSortOrder.
  ///
  /// In fr, this message translates to:
  /// **'Ordre d\'affichage'**
  String get wfSortOrder;

  /// No description provided for @wfSortOrderHint.
  ///
  /// In fr, this message translates to:
  /// **'Le plus petit nombre = le plus urgent.'**
  String get wfSortOrderHint;

  /// No description provided for @wfStatusHeld.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get wfStatusHeld;

  /// No description provided for @wfStatusProposed.
  ///
  /// In fr, this message translates to:
  /// **'Proposé'**
  String get wfStatusProposed;

  /// No description provided for @wfStatusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get wfStatusConfirmed;

  /// No description provided for @wfStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get wfStatusRejected;

  /// No description provided for @wfStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get wfStatusCancelled;

  /// No description provided for @wfStatusExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get wfStatusExpired;

  /// No description provided for @wfStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Réalisé'**
  String get wfStatusCompleted;

  /// No description provided for @wfStatusNoShow.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get wfStatusNoShow;

  /// No description provided for @wfKindAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get wfKindAppointment;

  /// No description provided for @wfKindFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Relance'**
  String get wfKindFollowUp;

  /// No description provided for @wfKindIntervention.
  ///
  /// In fr, this message translates to:
  /// **'Intervention'**
  String get wfKindIntervention;

  /// No description provided for @wfKindActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activités réalisées'**
  String get wfKindActivity;

  /// No description provided for @wfGroupDemo.
  ///
  /// In fr, this message translates to:
  /// **'Démo'**
  String get wfGroupDemo;

  /// No description provided for @wfGroupMeeting.
  ///
  /// In fr, this message translates to:
  /// **'Réunion'**
  String get wfGroupMeeting;

  /// No description provided for @wfGroupTraining.
  ///
  /// In fr, this message translates to:
  /// **'Formation'**
  String get wfGroupTraining;

  /// No description provided for @wfGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get wfGroup;

  /// No description provided for @wfGroupAccompaniment.
  ///
  /// In fr, this message translates to:
  /// **'Accompagnement'**
  String get wfGroupAccompaniment;

  /// No description provided for @wfConflictHoliday.
  ///
  /// In fr, this message translates to:
  /// **'Jour férié'**
  String get wfConflictHoliday;

  /// No description provided for @wfConflictEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Employé déjà occupé'**
  String get wfConflictEmployee;

  /// No description provided for @wfConflictCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Client déjà occupé'**
  String get wfConflictCustomer;

  /// No description provided for @wfConflictsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning refusé : conflits détectés'**
  String get wfConflictsTitle;

  /// No description provided for @wfConflictLine.
  ///
  /// In fr, this message translates to:
  /// **'Séance {occurrence} ({date}) : {reason}'**
  String wfConflictLine(Object occurrence, Object date, Object reason);

  /// No description provided for @wfConflictNothingSaved.
  ///
  /// In fr, this message translates to:
  /// **'Conflit de planning : rien n\'a été enregistré. Corrigez les séances listées.'**
  String get wfConflictNothingSaved;

  /// No description provided for @wfConflictExplain.
  ///
  /// In fr, this message translates to:
  /// **'Conflit : {reasons}'**
  String wfConflictExplain(Object reasons);

  /// No description provided for @wfHoldExpired.
  ///
  /// In fr, this message translates to:
  /// **'La réservation a expiré et le créneau a été libéré. Actualisez la liste.'**
  String get wfHoldExpired;

  /// No description provided for @wfHoldExpiredChip.
  ///
  /// In fr, this message translates to:
  /// **'Réservation expirée'**
  String get wfHoldExpiredChip;

  /// No description provided for @wfHoldExpires.
  ///
  /// In fr, this message translates to:
  /// **'Expiration de la réservation'**
  String get wfHoldExpires;

  /// No description provided for @wfExpiresIn.
  ///
  /// In fr, this message translates to:
  /// **'expire dans {time}'**
  String wfExpiresIn(Object time);

  /// No description provided for @wfCalendarSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous, relances et interventions planifiés ; les activités réalisées apparaissent en grisé.'**
  String get wfCalendarSubtitle;

  /// No description provided for @wfViewMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get wfViewMonth;

  /// No description provided for @wfViewWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get wfViewWeek;

  /// No description provided for @wfViewDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get wfViewDay;

  /// No description provided for @wfLegendScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Planifié'**
  String get wfLegendScheduled;

  /// No description provided for @wfLegendCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Réalisé'**
  String get wfLegendCompleted;

  /// No description provided for @wfFilterCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get wfFilterCustomer;

  /// No description provided for @wfClearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get wfClearFilters;

  /// No description provided for @wfMoreItems.
  ///
  /// In fr, this message translates to:
  /// **'+{count} autres'**
  String wfMoreItems(Object count);

  /// No description provided for @wfNothingScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Rien de planifié ce jour'**
  String get wfNothingScheduled;

  /// No description provided for @wfNothingScheduledHint.
  ///
  /// In fr, this message translates to:
  /// **'Les rendez-vous confirmés, relances et interventions apparaissent ici.'**
  String get wfNothingScheduledHint;

  /// No description provided for @wfActivitiesNotLoaded.
  ///
  /// In fr, this message translates to:
  /// **'Les activités réalisées n\'ont pas pu être chargées : {message}'**
  String wfActivitiesNotLoaded(Object message);

  /// No description provided for @wfConfirmHoldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le rendez-vous'**
  String get wfConfirmHoldTitle;

  /// No description provided for @wfRejectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la demande'**
  String get wfRejectTitle;

  /// No description provided for @wfCancelAppointmentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le rendez-vous'**
  String get wfCancelAppointmentTitle;

  /// No description provided for @wfProposeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Proposer un autre horaire'**
  String get wfProposeTitle;

  /// No description provided for @wfRescheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer la séance'**
  String get wfRescheduleTitle;

  /// No description provided for @wfRecordOutcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le résultat'**
  String get wfRecordOutcomeTitle;

  /// No description provided for @wfReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get wfReject;

  /// No description provided for @wfCancelAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le rendez-vous'**
  String get wfCancelAppointment;

  /// No description provided for @wfCancelProposal.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la proposition'**
  String get wfCancelProposal;

  /// No description provided for @wfProposeOther.
  ///
  /// In fr, this message translates to:
  /// **'Proposer un autre horaire'**
  String get wfProposeOther;

  /// No description provided for @wfSendProposal.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la proposition'**
  String get wfSendProposal;

  /// No description provided for @wfReschedule.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer'**
  String get wfReschedule;

  /// No description provided for @wfRecordOutcome.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le résultat'**
  String get wfRecordOutcome;

  /// No description provided for @wfMarkNoShow.
  ///
  /// In fr, this message translates to:
  /// **'Marquer absent'**
  String get wfMarkNoShow;

  /// No description provided for @wfMeetingLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien de la réunion'**
  String get wfMeetingLink;

  /// No description provided for @wfMeetingLinkHint.
  ///
  /// In fr, this message translates to:
  /// **'Visible par le client une fois confirmé.'**
  String get wfMeetingLinkHint;

  /// No description provided for @wfNewTime.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel horaire'**
  String get wfNewTime;

  /// No description provided for @wfReasonVisible.
  ///
  /// In fr, this message translates to:
  /// **'Motif (visible par le client)'**
  String get wfReasonVisible;

  /// No description provided for @wfMessageVisible.
  ///
  /// In fr, this message translates to:
  /// **'Message (visible par le client)'**
  String get wfMessageVisible;

  /// No description provided for @wfCustomerVisibleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce texte est visible par le client dans son espace.'**
  String get wfCustomerVisibleHint;

  /// No description provided for @wfOutcome.
  ///
  /// In fr, this message translates to:
  /// **'Résultat'**
  String get wfOutcome;

  /// No description provided for @wfOutcomeHint.
  ///
  /// In fr, this message translates to:
  /// **'Une activité est créée dans le CRM avec ce résultat.'**
  String get wfOutcomeHint;

  /// No description provided for @wfOutcomeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le résultat est obligatoire.'**
  String get wfOutcomeRequired;

  /// No description provided for @wfActivityRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Activité enregistrée'**
  String get wfActivityRecorded;

  /// No description provided for @wfCustomerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message au client'**
  String get wfCustomerMessage;

  /// No description provided for @wfInternalNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes internes'**
  String get wfInternalNotes;

  /// No description provided for @wfOpenProspectRecord.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la fiche'**
  String get wfOpenProspectRecord;

  /// No description provided for @wfNewProspect.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau prospect'**
  String get wfNewProspect;

  /// No description provided for @wfWaitingForCustomer.
  ///
  /// In fr, this message translates to:
  /// **'En attente de la réponse du client.'**
  String get wfWaitingForCustomer;

  /// No description provided for @wfRequestsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux réservés par les visiteurs et demandes reçues du site web.'**
  String get wfRequestsSubtitle;

  /// No description provided for @wfHoldsTab.
  ///
  /// In fr, this message translates to:
  /// **'Réservations ({count})'**
  String wfHoldsTab(Object count);

  /// No description provided for @wfWebsiteRequestsTab.
  ///
  /// In fr, this message translates to:
  /// **'Demandes du site'**
  String get wfWebsiteRequestsTab;

  /// No description provided for @wfNoHolds.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation en attente'**
  String get wfNoHolds;

  /// No description provided for @wfNoHoldsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les créneaux demandés depuis le site apparaissent ici jusqu\'à votre décision.'**
  String get wfNoHoldsHint;

  /// No description provided for @wfNoRequests.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande'**
  String get wfNoRequests;

  /// No description provided for @wfRequestDemo.
  ///
  /// In fr, this message translates to:
  /// **'Démo'**
  String get wfRequestDemo;

  /// No description provided for @wfRequestQuotation.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get wfRequestQuotation;

  /// No description provided for @wfRequestTrial.
  ///
  /// In fr, this message translates to:
  /// **'Essai'**
  String get wfRequestTrial;

  /// No description provided for @wfReqPending.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get wfReqPending;

  /// No description provided for @wfReqScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Planifiée'**
  String get wfReqScheduled;

  /// No description provided for @wfReqHandled.
  ///
  /// In fr, this message translates to:
  /// **'Traitée'**
  String get wfReqHandled;

  /// No description provided for @wfMarkHandled.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme traitée'**
  String get wfMarkHandled;

  /// No description provided for @wfRequestUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Demande mise à jour.'**
  String get wfRequestUpdated;

  /// No description provided for @wfTrainingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Séances de formation et séries d\'accompagnement des clients.'**
  String get wfTrainingSubtitle;

  /// No description provided for @wfNewTraining.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle formation'**
  String get wfNewTraining;

  /// No description provided for @wfNewAccompaniment.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel accompagnement'**
  String get wfNewAccompaniment;

  /// No description provided for @wfNoSessions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance'**
  String get wfNoSessions;

  /// No description provided for @wfNoSessionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Planifiez une formation ou une série d\'accompagnement.'**
  String get wfNoSessionsHint;

  /// No description provided for @wfShowPast.
  ///
  /// In fr, this message translates to:
  /// **'Inclure le passé'**
  String get wfShowPast;

  /// No description provided for @wfPartOfSeries.
  ///
  /// In fr, this message translates to:
  /// **'Série d\'accompagnement'**
  String get wfPartOfSeries;

  /// No description provided for @wfCancelThisSession.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette séance'**
  String get wfCancelThisSession;

  /// No description provided for @wfCancelRemainingSeries.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le reste de la série'**
  String get wfCancelRemainingSeries;

  /// No description provided for @wfCancelSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette séance ?'**
  String get wfCancelSessionTitle;

  /// No description provided for @wfCancelSessionBody.
  ///
  /// In fr, this message translates to:
  /// **'Seule cette séance future est annulée ; le reste de la série reste inchangé.'**
  String get wfCancelSessionBody;

  /// No description provided for @wfCancelSeriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le reste de la série ?'**
  String get wfCancelSeriesTitle;

  /// No description provided for @wfCancelSeriesBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette séance et les suivantes sont annulées. Les séances déjà réalisées ne sont pas touchées.'**
  String get wfCancelSeriesBody;

  /// No description provided for @wfCancelSeries.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la suite'**
  String get wfCancelSeries;

  /// No description provided for @wfSessionCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Séance annulée.'**
  String get wfSessionCancelled;

  /// No description provided for @wfSeriesCancelled.
  ///
  /// In fr, this message translates to:
  /// **'{count} séance(s) annulée(s).'**
  String wfSeriesCancelled(Object count);

  /// No description provided for @wfSessionScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Séance planifiée.'**
  String get wfSessionScheduled;

  /// No description provided for @wfSeriesScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Série planifiée : {count} séances.'**
  String wfSeriesScheduled(Object count);

  /// No description provided for @wfMoreActions.
  ///
  /// In fr, this message translates to:
  /// **'Autres actions'**
  String get wfMoreActions;

  /// No description provided for @wfSessionType.
  ///
  /// In fr, this message translates to:
  /// **'Type de séance'**
  String get wfSessionType;

  /// No description provided for @wfNoTypesConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Aucun type de rendez-vous actif pour ce groupe. Configurez-le dans les paramètres.'**
  String get wfNoTypesConfigured;

  /// No description provided for @wfSelectType.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un type.'**
  String get wfSelectType;

  /// No description provided for @wfSelectProduct.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un produit.'**
  String get wfSelectProduct;

  /// No description provided for @wfNoProduct.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit'**
  String get wfNoProduct;

  /// No description provided for @wfOccurrences.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de séances'**
  String get wfOccurrences;

  /// No description provided for @wfOccurrencesHint.
  ///
  /// In fr, this message translates to:
  /// **'Valeur par défaut des paramètres.'**
  String get wfOccurrencesHint;

  /// No description provided for @wfIntervalDays.
  ///
  /// In fr, this message translates to:
  /// **'Intervalle (jours)'**
  String get wfIntervalDays;

  /// No description provided for @wfIntervalHint.
  ///
  /// In fr, this message translates to:
  /// **'Jours entre deux séances.'**
  String get wfIntervalHint;

  /// No description provided for @wfPlannedSessions.
  ///
  /// In fr, this message translates to:
  /// **'{count} séances prévues'**
  String wfPlannedSessions(Object count);

  /// No description provided for @wfPickResource.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un support de formation'**
  String get wfPickResource;

  /// No description provided for @wfResourceLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien du support (optionnel)'**
  String get wfResourceLink;

  /// No description provided for @wfPrepareWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Préparer un message WhatsApp'**
  String get wfPrepareWhatsApp;

  /// No description provided for @wfPrepareWhatsAppHint.
  ///
  /// In fr, this message translates to:
  /// **'Prépare le texte ; vous l\'envoyez vous-même depuis WhatsApp.'**
  String get wfPrepareWhatsAppHint;

  /// No description provided for @wfOpenWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir WhatsApp'**
  String get wfOpenWhatsApp;

  /// No description provided for @wfWhatsAppHint.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre un message pré-rempli. L\'envoi se fait dans WhatsApp, non confirmé par le CRM.'**
  String get wfWhatsAppHint;

  /// No description provided for @wfWhatsappInvalidLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien WhatsApp non reconnu : il n\'a pas été ouvert.'**
  String get wfWhatsappInvalidLink;

  /// No description provided for @wfCustomersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prospects convertis en clients.'**
  String get wfCustomersSubtitle;

  /// No description provided for @wfCustomerSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un client…'**
  String get wfCustomerSearchHint;

  /// No description provided for @wfNoCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client'**
  String get wfNoCustomers;

  /// No description provided for @wfNoCustomersHint.
  ///
  /// In fr, this message translates to:
  /// **'Convertissez un prospect depuis sa fiche.'**
  String get wfNoCustomersHint;

  /// No description provided for @wfCustomerSince.
  ///
  /// In fr, this message translates to:
  /// **'Client depuis'**
  String get wfCustomerSince;

  /// No description provided for @wfCustomerSinceDate.
  ///
  /// In fr, this message translates to:
  /// **'Client depuis le {date}'**
  String wfCustomerSinceDate(Object date);

  /// No description provided for @wfCustomerBadge.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get wfCustomerBadge;

  /// No description provided for @wfCustomersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} clients'**
  String wfCustomersCount(Object count);

  /// No description provided for @wfConvertTitle.
  ///
  /// In fr, this message translates to:
  /// **'Convertir en client'**
  String get wfConvertTitle;

  /// No description provided for @wfConvertAction.
  ///
  /// In fr, this message translates to:
  /// **'Convertir en client'**
  String get wfConvertAction;

  /// No description provided for @wfConvertIntro.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » devient client. La fiche, l\'historique, les activités et les étapes sont conservés.'**
  String wfConvertIntro(Object name);

  /// No description provided for @wfPurchasedProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits achetés'**
  String get wfPurchasedProducts;

  /// No description provided for @wfConversionNote.
  ///
  /// In fr, this message translates to:
  /// **'Note de conversion'**
  String get wfConversionNote;

  /// No description provided for @wfConvertedBy.
  ///
  /// In fr, this message translates to:
  /// **'Converti le / par'**
  String get wfConvertedBy;

  /// No description provided for @wfConverted.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » est maintenant client.'**
  String wfConverted(Object name);

  /// No description provided for @wfAlreadyCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Ce prospect est déjà client. Actualisez la fiche.'**
  String get wfAlreadyCustomer;

  /// No description provided for @wfOpenCustomerProfile.
  ///
  /// In fr, this message translates to:
  /// **'Voir le profil client'**
  String get wfOpenCustomerProfile;

  /// No description provided for @wfCustomerProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits du client'**
  String get wfCustomerProducts;

  /// No description provided for @wfNoCustomerProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit lié'**
  String get wfNoCustomerProducts;

  /// No description provided for @wfPurchasedOn.
  ///
  /// In fr, this message translates to:
  /// **'Acheté le {date}'**
  String wfPurchasedOn(Object date);

  /// No description provided for @wfPortalAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Comptes du portail client'**
  String get wfPortalAccounts;

  /// No description provided for @wfPortalAccountsHint.
  ///
  /// In fr, this message translates to:
  /// **'Identités du site web, distinctes des accès employés.'**
  String get wfPortalAccountsHint;

  /// No description provided for @wfNoPortalAccount.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte portail lié'**
  String get wfNoPortalAccount;

  /// No description provided for @wfLastLogin.
  ///
  /// In fr, this message translates to:
  /// **'Dernière connexion : {date}'**
  String wfLastLogin(Object date);

  /// No description provided for @wfTrials.
  ///
  /// In fr, this message translates to:
  /// **'Accès d\'essai'**
  String get wfTrials;

  /// No description provided for @wfNoTrials.
  ///
  /// In fr, this message translates to:
  /// **'Aucun essai'**
  String get wfNoTrials;

  /// No description provided for @wfNewTrial.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel essai'**
  String get wfNewTrial;

  /// No description provided for @wfTrialUrl.
  ///
  /// In fr, this message translates to:
  /// **'Lien d\'accès à l\'essai'**
  String get wfTrialUrl;

  /// No description provided for @wfTrialUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'Le client ne le voit que pendant l\'essai actif.'**
  String get wfTrialUrlHint;

  /// No description provided for @wfTrialStarts.
  ///
  /// In fr, this message translates to:
  /// **'Début de l\'essai'**
  String get wfTrialStarts;

  /// No description provided for @wfTrialEnds.
  ///
  /// In fr, this message translates to:
  /// **'Fin de l\'essai'**
  String get wfTrialEnds;

  /// No description provided for @wfTrialDays.
  ///
  /// In fr, this message translates to:
  /// **'Durée d\'essai par défaut (jours)'**
  String get wfTrialDays;

  /// No description provided for @wfTrialActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get wfTrialActive;

  /// No description provided for @wfTrialScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Programmé'**
  String get wfTrialScheduled;

  /// No description provided for @wfTrialRevoked.
  ///
  /// In fr, this message translates to:
  /// **'Révoqué'**
  String get wfTrialRevoked;

  /// No description provided for @wfTrialActivated.
  ///
  /// In fr, this message translates to:
  /// **'Essai activé.'**
  String get wfTrialActivated;

  /// No description provided for @wfTrialOverlap.
  ///
  /// In fr, this message translates to:
  /// **'Un essai existe déjà pour ce produit sur cette période.'**
  String get wfTrialOverlap;

  /// No description provided for @wfRevoke.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer'**
  String get wfRevoke;

  /// No description provided for @wfRevokeTrialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer l\'accès à l\'essai ?'**
  String get wfRevokeTrialTitle;

  /// No description provided for @wfRevokeTrialBody.
  ///
  /// In fr, this message translates to:
  /// **'Le client ne verra plus le lien de l\'essai « {product} ».'**
  String wfRevokeTrialBody(Object product);

  /// No description provided for @wfTrialRevokedDone.
  ///
  /// In fr, this message translates to:
  /// **'Accès révoqué.'**
  String get wfTrialRevokedDone;

  /// No description provided for @wfAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get wfAppointments;

  /// No description provided for @wfAppointmentsHint.
  ///
  /// In fr, this message translates to:
  /// **'Planifiés ou réalisés (le résultat devient une activité).'**
  String get wfAppointmentsHint;

  /// No description provided for @wfNoAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous'**
  String get wfNoAppointments;

  /// No description provided for @wfScheduleTraining.
  ///
  /// In fr, this message translates to:
  /// **'Planifier une formation'**
  String get wfScheduleTraining;

  /// No description provided for @wfAfterSalesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandes des clients et interventions publiées par l\'équipe.'**
  String get wfAfterSalesSubtitle;

  /// No description provided for @wfNewIntervention.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle intervention'**
  String get wfNewIntervention;

  /// No description provided for @wfInterventionCreated.
  ///
  /// In fr, this message translates to:
  /// **'Intervention {reference} créée.'**
  String wfInterventionCreated(Object reference);

  /// No description provided for @wfInterventionType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'intervention'**
  String get wfInterventionType;

  /// No description provided for @wfPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get wfPriority;

  /// No description provided for @wfNoPriority.
  ///
  /// In fr, this message translates to:
  /// **'Sans priorité'**
  String get wfNoPriority;

  /// No description provided for @wfSource.
  ///
  /// In fr, this message translates to:
  /// **'Origine'**
  String get wfSource;

  /// No description provided for @wfSourceCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get wfSourceCustomer;

  /// No description provided for @wfSourceEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Employé'**
  String get wfSourceEmployee;

  /// No description provided for @wfSourceBoth.
  ///
  /// In fr, this message translates to:
  /// **'Client et employé'**
  String get wfSourceBoth;

  /// No description provided for @wfOpenItems.
  ///
  /// In fr, this message translates to:
  /// **'Ouvertes'**
  String get wfOpenItems;

  /// No description provided for @wfClosedItems.
  ///
  /// In fr, this message translates to:
  /// **'Clôturées'**
  String get wfClosedItems;

  /// No description provided for @wfNoInterventions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune intervention'**
  String get wfNoInterventions;

  /// No description provided for @wfNoInterventionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les demandes des clients et vos interventions apparaissent ici.'**
  String get wfNoInterventionsHint;

  /// No description provided for @wfAffectedCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients concernés'**
  String get wfAffectedCustomers;

  /// No description provided for @wfAddCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un client'**
  String get wfAddCustomer;

  /// No description provided for @wfScheduledAt.
  ///
  /// In fr, this message translates to:
  /// **'Planifiée le'**
  String get wfScheduledAt;

  /// No description provided for @wfTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le titre est obligatoire.'**
  String get wfTitleRequired;

  /// No description provided for @wfDescriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'La description est obligatoire.'**
  String get wfDescriptionRequired;

  /// No description provided for @wfClosedAt.
  ///
  /// In fr, this message translates to:
  /// **'Clôturée le'**
  String get wfClosedAt;

  /// No description provided for @wfStatusWorkflow.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get wfStatusWorkflow;

  /// No description provided for @wfStatusWorkflowHint.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les statuts autorisés depuis le statut actuel sont proposés.'**
  String get wfStatusWorkflowHint;

  /// No description provided for @wfCurrentStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut actuel'**
  String get wfCurrentStatus;

  /// No description provided for @wfCustomerSees.
  ///
  /// In fr, this message translates to:
  /// **'Vu par le client'**
  String get wfCustomerSees;

  /// No description provided for @wfNoTransitions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transition autorisée depuis ce statut.'**
  String get wfNoTransitions;

  /// No description provided for @wfTransitionNotAllowed.
  ///
  /// In fr, this message translates to:
  /// **'Ce changement de statut n\'est pas autorisé.'**
  String get wfTransitionNotAllowed;

  /// No description provided for @wfChangeStatusTo.
  ///
  /// In fr, this message translates to:
  /// **'Passer à « {status} »'**
  String wfChangeStatusTo(Object status);

  /// No description provided for @wfCustomerSeesStatus.
  ///
  /// In fr, this message translates to:
  /// **'Le client verra : « {label} ».'**
  String wfCustomerSeesStatus(Object label);

  /// No description provided for @wfStatusExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Explication pour le client (optionnelle)'**
  String get wfStatusExplanation;

  /// No description provided for @wfStatusChanged.
  ///
  /// In fr, this message translates to:
  /// **'Statut mis à jour.'**
  String get wfStatusChanged;

  /// No description provided for @wfTriage.
  ///
  /// In fr, this message translates to:
  /// **'Tri et planification'**
  String get wfTriage;

  /// No description provided for @wfReleaseNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de version'**
  String get wfReleaseNotes;

  /// No description provided for @wfReleaseNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Publiez la correction ou la mise à jour aux clients concernés.'**
  String get wfReleaseNotesHint;

  /// No description provided for @wfPublish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get wfPublish;

  /// No description provided for @wfPublished.
  ///
  /// In fr, this message translates to:
  /// **'Publié aux clients concernés.'**
  String get wfPublished;

  /// No description provided for @wfPublishTitle.
  ///
  /// In fr, this message translates to:
  /// **'Publier aux clients'**
  String get wfPublishTitle;

  /// No description provided for @wfPublishTo.
  ///
  /// In fr, this message translates to:
  /// **'Sera visible par : {names}'**
  String wfPublishTo(Object names);

  /// No description provided for @wfPublishNoCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client concerné : ajoutez-en à la création pour pouvoir publier.'**
  String get wfPublishNoCustomers;

  /// No description provided for @wfPublishedOn.
  ///
  /// In fr, this message translates to:
  /// **'Publié le {date}'**
  String wfPublishedOn(Object date);

  /// No description provided for @wfNotPublished.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore publié : les clients ne le voient pas.'**
  String get wfNotPublished;

  /// No description provided for @wfResolutionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le texte publié est obligatoire.'**
  String get wfResolutionRequired;

  /// No description provided for @wfUnpublish.
  ///
  /// In fr, this message translates to:
  /// **'Dépublier'**
  String get wfUnpublish;

  /// No description provided for @wfUnpublishTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dépublier ?'**
  String get wfUnpublishTitle;

  /// No description provided for @wfUnpublishBody.
  ///
  /// In fr, this message translates to:
  /// **'Les clients ne verront plus ces notes.'**
  String get wfUnpublishBody;

  /// No description provided for @wfUnpublished.
  ///
  /// In fr, this message translates to:
  /// **'Dépublié.'**
  String get wfUnpublished;

  /// No description provided for @wfConversation.
  ///
  /// In fr, this message translates to:
  /// **'Échanges'**
  String get wfConversation;

  /// No description provided for @wfNoMessages.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message'**
  String get wfNoMessages;

  /// No description provided for @wfInternalNote.
  ///
  /// In fr, this message translates to:
  /// **'Note interne'**
  String get wfInternalNote;

  /// No description provided for @wfCustomerReply.
  ///
  /// In fr, this message translates to:
  /// **'Réponse au client'**
  String get wfCustomerReply;

  /// No description provided for @wfInternalNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Réservée à l\'équipe : le client ne la verra jamais.'**
  String get wfInternalNoteHint;

  /// No description provided for @wfCustomerReplyWarning.
  ///
  /// In fr, this message translates to:
  /// **'Ce message sera visible par le client dans son espace.'**
  String get wfCustomerReplyWarning;

  /// No description provided for @wfConfirmCustomerReplyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer au client ?'**
  String get wfConfirmCustomerReplyTitle;

  /// No description provided for @wfConfirmCustomerReplyBody.
  ///
  /// In fr, this message translates to:
  /// **'La réponse sera visible par le client. Ne mentionnez aucune discussion interne.'**
  String get wfConfirmCustomerReplyBody;

  /// No description provided for @wfSendReply.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la réponse'**
  String get wfSendReply;

  /// No description provided for @wfAddNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la note'**
  String get wfAddNote;

  /// No description provided for @wfReplySaved.
  ///
  /// In fr, this message translates to:
  /// **'Réponse enregistrée pour le client.'**
  String get wfReplySaved;

  /// No description provided for @wfNoteSaved.
  ///
  /// In fr, this message translates to:
  /// **'Note interne enregistrée.'**
  String get wfNoteSaved;

  /// No description provided for @wfMessageRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le message est vide.'**
  String get wfMessageRequired;

  /// No description provided for @wfEmployeesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Postes connectés au CRM et travail assigné. Tous les employés ont le même accès.'**
  String get wfEmployeesSubtitle;

  /// No description provided for @wfNoEmployees.
  ///
  /// In fr, this message translates to:
  /// **'Aucun employé connu'**
  String get wfNoEmployees;

  /// No description provided for @wfNoEmployeesHint.
  ///
  /// In fr, this message translates to:
  /// **'Les employés apparaissent quand leur application se connecte au serveur.'**
  String get wfNoEmployeesHint;

  /// No description provided for @wfSelectEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un employé'**
  String get wfSelectEmployee;

  /// No description provided for @wfIdle.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get wfIdle;

  /// No description provided for @wfAssignedAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous à venir de {name}'**
  String wfAssignedAppointments(Object name);

  /// No description provided for @wfAssignedInterventions.
  ///
  /// In fr, this message translates to:
  /// **'Interventions ouvertes de {name}'**
  String wfAssignedInterventions(Object name);

  /// No description provided for @wfNothingAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Rien d\'assigné'**
  String get wfNothingAssigned;

  /// No description provided for @wfSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Horaires, types, statuts, priorités et modèles. Tout est stocké dans le CRM.'**
  String get wfSettingsSubtitle;

  /// No description provided for @wfSettingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés.'**
  String get wfSettingsSaved;

  /// No description provided for @wfCfgScheduling.
  ///
  /// In fr, this message translates to:
  /// **'Horaires et réservations'**
  String get wfCfgScheduling;

  /// No description provided for @wfCfgSchedulingHint.
  ///
  /// In fr, this message translates to:
  /// **'Jours et heures de travail, durée des créneaux, expiration des réservations, récurrence de l\'accompagnement et essais.'**
  String get wfCfgSchedulingHint;

  /// No description provided for @wfCfgAppointmentTypes.
  ///
  /// In fr, this message translates to:
  /// **'Types de rendez-vous'**
  String get wfCfgAppointmentTypes;

  /// No description provided for @wfCfgAppointmentTypesHint.
  ///
  /// In fr, this message translates to:
  /// **'Démo, réunion, formation, accompagnement : durée par défaut et couleur du calendrier.'**
  String get wfCfgAppointmentTypesHint;

  /// No description provided for @wfCfgHolidays.
  ///
  /// In fr, this message translates to:
  /// **'Jours fériés'**
  String get wfCfgHolidays;

  /// No description provided for @wfCfgHolidaysHint.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau n\'est proposé ces jours-là.'**
  String get wfCfgHolidaysHint;

  /// No description provided for @wfCfgInterventionTypes.
  ///
  /// In fr, this message translates to:
  /// **'Types d\'intervention'**
  String get wfCfgInterventionTypes;

  /// No description provided for @wfCfgInterventionTypesHint.
  ///
  /// In fr, this message translates to:
  /// **'Bug, question, remarque, correctif, version… et qui peut les créer.'**
  String get wfCfgInterventionTypesHint;

  /// No description provided for @wfCfgInterventionStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Statuts d\'intervention'**
  String get wfCfgInterventionStatuses;

  /// No description provided for @wfCfgInterventionStatusesHint.
  ///
  /// In fr, this message translates to:
  /// **'Libellé interne et libellé vu par le client.'**
  String get wfCfgInterventionStatusesHint;

  /// No description provided for @wfCfgTransitions.
  ///
  /// In fr, this message translates to:
  /// **'Transitions de statut'**
  String get wfCfgTransitions;

  /// No description provided for @wfCfgTransitionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Quels statuts peuvent suivre quels statuts, et si le client peut déclencher le changement.'**
  String get wfCfgTransitionsHint;

  /// No description provided for @wfCfgPriorities.
  ///
  /// In fr, this message translates to:
  /// **'Priorités'**
  String get wfCfgPriorities;

  /// No description provided for @wfCfgPrioritiesHint.
  ///
  /// In fr, this message translates to:
  /// **'Couleur et délai de réponse cible ; l\'ordre sert au tri.'**
  String get wfCfgPrioritiesHint;

  /// No description provided for @wfCfgTemplates.
  ///
  /// In fr, this message translates to:
  /// **'Modèles de message'**
  String get wfCfgTemplates;

  /// No description provided for @wfCfgTemplatesHint.
  ///
  /// In fr, this message translates to:
  /// **'Textes WhatsApp préparés pour les formations (jamais envoyés automatiquement).'**
  String get wfCfgTemplatesHint;

  /// No description provided for @wfCfgProductResources.
  ///
  /// In fr, this message translates to:
  /// **'Supports produit'**
  String get wfCfgProductResources;

  /// No description provided for @wfCfgProductResourcesHint.
  ///
  /// In fr, this message translates to:
  /// **'Liens de formation et de documentation, avec visibilité client.'**
  String get wfCfgProductResourcesHint;

  /// No description provided for @wfProductResources.
  ///
  /// In fr, this message translates to:
  /// **'Supports et liens du produit'**
  String get wfProductResources;

  /// No description provided for @wfProductResourcesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supports : {name}'**
  String wfProductResourcesTitle(Object name);

  /// No description provided for @wfNoResources.
  ///
  /// In fr, this message translates to:
  /// **'Aucun support pour ce produit'**
  String get wfNoResources;

  /// No description provided for @wfNoConfigRows.
  ///
  /// In fr, this message translates to:
  /// **'Aucune entrée'**
  String get wfNoConfigRows;

  /// No description provided for @wfNoConfigRowsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez la première entrée. Elle pourra être désactivée, jamais supprimée.'**
  String get wfNoConfigRowsHint;

  /// No description provided for @wfDeactivateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver cette entrée ?'**
  String get wfDeactivateTitle;

  /// No description provided for @wfDeactivateBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle n\'est plus proposée, mais l\'historique qui la référence est conservé.'**
  String get wfDeactivateBody;

  /// No description provided for @wfDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Entrée désactivée.'**
  String get wfDeactivated;

  /// No description provided for @wfReactivated.
  ///
  /// In fr, this message translates to:
  /// **'Entrée réactivée.'**
  String get wfReactivated;

  /// No description provided for @wfDurationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Durée (min)'**
  String get wfDurationMinutes;

  /// No description provided for @wfCustomerBookable.
  ///
  /// In fr, this message translates to:
  /// **'Réservable par le client'**
  String get wfCustomerBookable;

  /// No description provided for @wfCustomerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé client'**
  String get wfCustomerLabel;

  /// No description provided for @wfCustomerLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce que le client voit pour ce statut.'**
  String get wfCustomerLabelHint;

  /// No description provided for @wfIsInitial.
  ///
  /// In fr, this message translates to:
  /// **'Statut initial'**
  String get wfIsInitial;

  /// No description provided for @wfIsClosed.
  ///
  /// In fr, this message translates to:
  /// **'Clôture l\'intervention'**
  String get wfIsClosed;

  /// No description provided for @wfAwaitsCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Attend le client'**
  String get wfAwaitsCustomer;

  /// No description provided for @wfIsDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livré au client'**
  String get wfIsDelivered;

  /// No description provided for @wfFromStatus.
  ///
  /// In fr, this message translates to:
  /// **'Depuis le statut'**
  String get wfFromStatus;

  /// No description provided for @wfToStatus.
  ///
  /// In fr, this message translates to:
  /// **'Vers le statut'**
  String get wfToStatus;

  /// No description provided for @wfCustomerAllowed.
  ///
  /// In fr, this message translates to:
  /// **'Déclenchable par le client'**
  String get wfCustomerAllowed;

  /// No description provided for @wfResponseTarget.
  ///
  /// In fr, this message translates to:
  /// **'Délai de réponse (h)'**
  String get wfResponseTarget;

  /// No description provided for @wfResponseTargetHint.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide pour aucun délai.'**
  String get wfResponseTargetHint;

  /// No description provided for @wfTemplate.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get wfTemplate;

  /// No description provided for @wfTemplateTrainingFirst.
  ///
  /// In fr, this message translates to:
  /// **'Première formation'**
  String get wfTemplateTrainingFirst;

  /// No description provided for @wfTemplateTrainingReview.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de formation'**
  String get wfTemplateTrainingReview;

  /// No description provided for @wfTemplateBody.
  ///
  /// In fr, this message translates to:
  /// **'Texte du message'**
  String get wfTemplateBody;

  /// No description provided for @wfTemplatePlaceholders.
  ///
  /// In fr, this message translates to:
  /// **'Variables disponibles (à écrire entre accolades) : contact, product, date, start, end, resource_url'**
  String get wfTemplatePlaceholders;

  /// No description provided for @wfKindVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get wfKindVideo;

  /// No description provided for @wfKindLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien'**
  String get wfKindLink;

  /// No description provided for @wfCustomerVisible.
  ///
  /// In fr, this message translates to:
  /// **'Visible par le client'**
  String get wfCustomerVisible;

  /// No description provided for @wfTrainingMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Support de formation'**
  String get wfTrainingMaterial;

  /// No description provided for @wfWorkingDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours ouvrés'**
  String get wfWorkingDays;

  /// No description provided for @wfPickWorkingDay.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un jour.'**
  String get wfPickWorkingDay;

  /// No description provided for @wfWorkStart.
  ///
  /// In fr, this message translates to:
  /// **'Début de journée'**
  String get wfWorkStart;

  /// No description provided for @wfWorkEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin de journée'**
  String get wfWorkEnd;

  /// No description provided for @wfTimeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Format HH:mm attendu.'**
  String get wfTimeInvalid;

  /// No description provided for @wfSlotMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Durée d\'un créneau (min)'**
  String get wfSlotMinutes;

  /// No description provided for @wfHoldExpiryMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Expiration d\'une réservation (min)'**
  String get wfHoldExpiryMinutes;

  /// No description provided for @wfHoldExpiryHint.
  ///
  /// In fr, this message translates to:
  /// **'Au-delà, le créneau est libéré automatiquement.'**
  String get wfHoldExpiryHint;

  /// No description provided for @wfBookingHorizon.
  ///
  /// In fr, this message translates to:
  /// **'Réservation jusqu\'à (jours)'**
  String get wfBookingHorizon;

  /// No description provided for @wfMinNotice.
  ///
  /// In fr, this message translates to:
  /// **'Préavis minimum (heures)'**
  String get wfMinNotice;

  /// No description provided for @wfDemoCapacity.
  ///
  /// In fr, this message translates to:
  /// **'Démos en parallèle'**
  String get wfDemoCapacity;

  /// No description provided for @wfDemoCapacityHint.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de démos simultanées.'**
  String get wfDemoCapacityHint;

  /// No description provided for @wfAccompanimentOccurrences.
  ///
  /// In fr, this message translates to:
  /// **'Séances d\'accompagnement (défaut)'**
  String get wfAccompanimentOccurrences;

  /// No description provided for @wfAccompanimentInterval.
  ///
  /// In fr, this message translates to:
  /// **'Intervalle d\'accompagnement (jours, défaut)'**
  String get wfAccompanimentInterval;

  /// No description provided for @wfWhatsappCountryCode.
  ///
  /// In fr, this message translates to:
  /// **'Indicatif pays WhatsApp'**
  String get wfWhatsappCountryCode;

  /// No description provided for @wfWhatsappCountryCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Chiffres seulement, ex. 213. Sert à compléter les numéros commençant par 0.'**
  String get wfWhatsappCountryCodeHint;

  /// No description provided for @wfCountryCodeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'1 à 4 chiffres.'**
  String get wfCountryCodeInvalid;

  /// No description provided for @ivSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get ivSupport;

  /// No description provided for @ivSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get ivSystem;

  /// No description provided for @ivEventStatusFull.
  ///
  /// In fr, this message translates to:
  /// **'Statut modifié de {from} à {to} par {actor} à {time}'**
  String ivEventStatusFull(Object actor, Object from, Object time, Object to);

  /// No description provided for @ivEventStatusTo.
  ///
  /// In fr, this message translates to:
  /// **'Statut modifié en {to} par {actor} à {time}'**
  String ivEventStatusTo(Object actor, Object time, Object to);

  /// No description provided for @ivEventReopened.
  ///
  /// In fr, this message translates to:
  /// **'Intervention rouverte par {actor} à {time}'**
  String ivEventReopened(Object actor, Object time);

  /// No description provided for @ivAttachFiles.
  ///
  /// In fr, this message translates to:
  /// **'Joindre des fichiers'**
  String get ivAttachFiles;

  /// No description provided for @ivAttachLimit.
  ///
  /// In fr, this message translates to:
  /// **'{max} fichiers maximum par message.'**
  String ivAttachLimit(Object max);

  /// No description provided for @ivRemoveFile.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce fichier'**
  String get ivRemoveFile;

  /// No description provided for @ivDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get ivDownload;

  /// No description provided for @ivPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get ivPreview;

  /// No description provided for @ivViewPdf.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le PDF'**
  String get ivViewPdf;

  /// No description provided for @ivFileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré : {path}'**
  String ivFileSaved(Object path);

  /// No description provided for @ivImageError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'afficher l\'image.'**
  String get ivImageError;

  /// No description provided for @ivClosedBanner.
  ///
  /// In fr, this message translates to:
  /// **'Cette intervention est clôturée. Les nouvelles réponses sont désactivées.'**
  String get ivClosedBanner;

  /// No description provided for @ivReopen.
  ///
  /// In fr, this message translates to:
  /// **'Rouvrir l\'intervention'**
  String get ivReopen;

  /// No description provided for @ivReopenBody.
  ///
  /// In fr, this message translates to:
  /// **'Les réponses seront de nouveau possibles pour vous et pour le client.'**
  String get ivReopenBody;

  /// No description provided for @ivReopenNote.
  ///
  /// In fr, this message translates to:
  /// **'Note (facultative)'**
  String get ivReopenNote;

  /// No description provided for @ivReopened.
  ///
  /// In fr, this message translates to:
  /// **'Intervention rouverte.'**
  String get ivReopened;

  /// No description provided for @prDemoLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien de la démo'**
  String get prDemoLink;

  /// No description provided for @prDemoLinkHint.
  ///
  /// In fr, this message translates to:
  /// **'Lien fixe défini sur le produit.'**
  String get prDemoLinkHint;

  /// No description provided for @prNoDemoLink.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit n\'a pas de lien de démo.'**
  String get prNoDemoLink;

  /// No description provided for @prNoDemoProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit avec démo pour ce client.'**
  String get prNoDemoProducts;

  /// No description provided for @prNoLinkedProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit associé à ce client.'**
  String get prNoLinkedProducts;

  /// No description provided for @prFilteredByCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Produits associés à ce client uniquement.'**
  String get prFilteredByCustomer;

  /// No description provided for @prCustomersFilteredByProduct.
  ///
  /// In fr, this message translates to:
  /// **'Clients liés à ce produit uniquement.'**
  String get prCustomersFilteredByProduct;

  /// No description provided for @prPackReplaced.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » a été désélectionné : un seul produit par pack.'**
  String prPackReplaced(Object name);

  /// No description provided for @prPackHint.
  ///
  /// In fr, this message translates to:
  /// **'Un seul produit par pack.'**
  String get prPackHint;

  /// No description provided for @navReleases.
  ///
  /// In fr, this message translates to:
  /// **'Mises à jour produits'**
  String get navReleases;

  /// No description provided for @rlSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Versions publiées de vos produits, fichiers d\'installation et audience.'**
  String get rlSubtitle;

  /// No description provided for @rlNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle version'**
  String get rlNew;

  /// No description provided for @rlEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la version'**
  String get rlEdit;

  /// No description provided for @rlVersion.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de version'**
  String get rlVersion;

  /// No description provided for @rlVersionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de version obligatoire.'**
  String get rlVersionRequired;

  /// No description provided for @rlDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de sortie'**
  String get rlDate;

  /// No description provided for @rlChangelog.
  ///
  /// In fr, this message translates to:
  /// **'Notes de version'**
  String get rlChangelog;

  /// No description provided for @rlAudience.
  ///
  /// In fr, this message translates to:
  /// **'Audience'**
  String get rlAudience;

  /// No description provided for @rlAudienceAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous les clients'**
  String get rlAudienceAll;

  /// No description provided for @rlAudienceOwned.
  ///
  /// In fr, this message translates to:
  /// **'Clients propriétaires du produit'**
  String get rlAudienceOwned;

  /// No description provided for @rlAudienceSpecific.
  ///
  /// In fr, this message translates to:
  /// **'Clients précis'**
  String get rlAudienceSpecific;

  /// No description provided for @rlCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients concernés'**
  String get rlCustomers;

  /// No description provided for @rlCustomersRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un client.'**
  String get rlCustomersRequired;

  /// No description provided for @rlInstaller.
  ///
  /// In fr, this message translates to:
  /// **'Fichier d\'installation'**
  String get rlInstaller;

  /// No description provided for @rlInstallerHint.
  ///
  /// In fr, this message translates to:
  /// **'.exe, .zip ou .rar'**
  String get rlInstallerHint;

  /// No description provided for @rlPickInstaller.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier'**
  String get rlPickInstaller;

  /// No description provided for @rlRemoveInstaller.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l\'installateur'**
  String get rlRemoveInstaller;

  /// No description provided for @rlExternalUrl.
  ///
  /// In fr, this message translates to:
  /// **'Lien de téléchargement externe'**
  String get rlExternalUrl;

  /// No description provided for @rlPublished.
  ///
  /// In fr, this message translates to:
  /// **'Publiée'**
  String get rlPublished;

  /// No description provided for @rlDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get rlDraft;

  /// No description provided for @rlNoReleases.
  ///
  /// In fr, this message translates to:
  /// **'Aucune version'**
  String get rlNoReleases;

  /// No description provided for @rlNoReleasesHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez la première version d\'un produit.'**
  String get rlNoReleasesHint;

  /// No description provided for @rlDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette version ?'**
  String get rlDeleteTitle;

  /// No description provided for @rlDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Les clients ne la verront plus.'**
  String get rlDeleteBody;

  /// No description provided for @rlSaved.
  ///
  /// In fr, this message translates to:
  /// **'Version enregistrée.'**
  String get rlSaved;

  /// No description provided for @rlDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Version supprimée.'**
  String get rlDeleted;

  /// No description provided for @rlUploading.
  ///
  /// In fr, this message translates to:
  /// **'Envoi du fichier…'**
  String get rlUploading;

  /// No description provided for @rlAllProducts.
  ///
  /// In fr, this message translates to:
  /// **'Tous les produits'**
  String get rlAllProducts;

  /// No description provided for @helpTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get helpTooltip;

  /// No description provided for @helpExample.
  ///
  /// In fr, this message translates to:
  /// **'Exemple'**
  String get helpExample;

  /// No description provided for @helpFields.
  ///
  /// In fr, this message translates to:
  /// **'Champs'**
  String get helpFields;

  /// No description provided for @helpUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Aide indisponible pour cette section.'**
  String get helpUnavailable;

  /// No description provided for @wfFixedTypesNote.
  ///
  /// In fr, this message translates to:
  /// **'Les 4 types (Démo, Réunion, Formation, Accompagnement) sont fixes. Vous pouvez seulement ajuster la durée, la couleur et la réservation en ligne.'**
  String get wfFixedTypesNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
