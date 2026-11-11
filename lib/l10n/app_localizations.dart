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
  String countProspects(int count);

  /// No description provided for @countActivities.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune activité} one{1 activité} other{{count} activités}}'**
  String countActivities(int count);

  /// No description provided for @activitiesCountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} activité} other{{count} activités}} — appels, rendez-vous, messages et notes'**
  String activitiesCountSubtitle(int count);

  /// No description provided for @pipelineCountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} prospect} other{{count} prospects}} · glissez une carte vers une autre étape pour la déplacer'**
  String pipelineCountSubtitle(int count);

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
  String deactivateStageProspects(int count);

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
