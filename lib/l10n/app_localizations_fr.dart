// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navProspects => 'Prospects';

  @override
  String get navPipeline => 'Pipeline';

  @override
  String get navActivities => 'Activités';

  @override
  String get navFollowUps => 'Relances';

  @override
  String get navProducts => 'Produits';

  @override
  String get navSalesStages => 'Étapes de vente';

  @override
  String get navLossReasons => 'Motifs de perte';

  @override
  String get navServerDisplay => 'Serveur & affichage';

  @override
  String get navSettingsSection => 'PARAMÈTRES';

  @override
  String get themeLight => 'Thème clair';

  @override
  String get themeDark => 'Thème sombre';

  @override
  String get globalSearchHint =>
      'Rechercher un prospect (nom, téléphone, e-mail…) puis Entrée';

  @override
  String get connOnline => 'Connecté';

  @override
  String get connOffline => 'Hors ligne';

  @override
  String get connChecking => 'Vérification…';

  @override
  String get connUnknown => 'Inconnu';

  @override
  String connServer(Object url) {
    return 'Serveur : $url';
  }

  @override
  String connLastCheck(Object time) {
    return '\nDernière vérification : $time';
  }

  @override
  String get connClickToCheck => '\nCliquer pour vérifier maintenant.';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSaving => 'Enregistrement…';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionDeactivate => 'Désactiver';

  @override
  String get actionReactivate => 'Réactiver';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionSchedule => 'Planifier';

  @override
  String get actionSeeAll => 'Tout voir';

  @override
  String get actionMoveUp => 'Monter';

  @override
  String get actionMoveDown => 'Descendre';

  @override
  String get actionOpenRecord => 'Ouvrir la fiche';

  @override
  String get loading => 'Chargement…';

  @override
  String get loadingRecord => 'Chargement de la fiche…';

  @override
  String get loadingStages => 'Chargement des étapes…';

  @override
  String get errorOccurred => 'Une erreur est survenue';

  @override
  String get serverUnreachable => 'Serveur injoignable';

  @override
  String get serverSettings => 'Paramètres serveur';

  @override
  String get errorUnknown => 'Erreur inconnue.';

  @override
  String get noItems => 'Aucun élément';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get searchHint => 'Rechercher…';

  @override
  String get filterAll => 'Tous';

  @override
  String get clearPeriod => 'Effacer la période';

  @override
  String get period => 'Période';

  @override
  String get perPage => 'Par page';

  @override
  String get pageFirst => 'Première page';

  @override
  String get pagePrevious => 'Page précédente';

  @override
  String get pageNext => 'Page suivante';

  @override
  String get pageLast => 'Dernière page';

  @override
  String pageOf(Object page, Object pages) {
    return 'Page $page / $pages';
  }

  @override
  String rangeOfTotal(Object from, Object to, Object total) {
    return '$from–$to sur $total';
  }

  @override
  String showMoreCount(Object count) {
    return 'Afficher plus ($count)';
  }

  @override
  String get color => 'Couleur';

  @override
  String get colDate => 'Date';

  @override
  String get colStatus => 'Statut';

  @override
  String get colActions => 'Actions';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldDescriptionRequired => 'Description *';

  @override
  String get fieldOutcome => 'Résultat';

  @override
  String get fieldDateTimeRequired => 'Date et heure *';

  @override
  String get fieldNameRequired => 'Nom *';

  @override
  String get fieldLabelRequired => 'Libellé *';

  @override
  String get fieldTypeRequired => 'Type *';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldAddress => 'Adresse';

  @override
  String get fieldCity => 'Ville';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldContact => 'Contact';

  @override
  String get colContactDetails => 'Coordonnées';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusActiveFem => 'Active';

  @override
  String get statusInactive => 'Inactif';

  @override
  String get statusInactiveFem => 'Inactive';

  @override
  String get optionOther => 'Autre';

  @override
  String get validThisField => 'Ce champ';

  @override
  String validRequired(Object field) {
    return '$field est obligatoire.';
  }

  @override
  String validMaxLength(Object max) {
    return '$max caractères maximum.';
  }

  @override
  String get validEmailInvalid => 'Adresse e-mail invalide.';

  @override
  String get validPhoneChars =>
      'Le numéro ne peut contenir que des chiffres, espaces, +, -, . ou ().';

  @override
  String get validPhoneLength =>
      'Le numéro doit contenir entre 6 et 20 chiffres.';

  @override
  String get validColorInvalid => 'Couleur invalide (format #RRGGBB).';

  @override
  String get validServerRequired => 'L\'adresse du serveur est obligatoire.';

  @override
  String get validServerInvalid =>
      'Adresse invalide. Exemple : http://192.168.1.100:8000/api/v1';

  @override
  String get validServerScheme =>
      'L\'adresse doit commencer par http:// ou https://';

  @override
  String get validFieldDescription => 'La description';

  @override
  String get validFieldName => 'Le nom';

  @override
  String get validFieldLabel => 'Le libellé';

  @override
  String get validFieldCompany => 'Le nom de la société / du client';

  @override
  String get validFixFields => 'Veuillez corriger les champs signalés.';

  @override
  String get validSelectProspect => 'Sélectionnez un prospect.';

  @override
  String get validSelectStage => 'Sélectionnez une étape.';

  @override
  String get validDateRequired => 'La date est obligatoire.';

  @override
  String get validFollowUpFuture =>
      'La date de relance doit être dans le futur.';

  @override
  String get validDateNotFuture => 'La date ne peut pas être dans le futur.';

  @override
  String get validNextFollowUpFuture =>
      'La prochaine relance doit être dans le futur.';

  @override
  String get validNextFollowUpAfterActivity =>
      'La prochaine relance doit être postérieure à l\'activité.';

  @override
  String get validActivityNotFuture =>
      'Une activité ne peut pas être dans le futur : planifiez plutôt une relance.';

  @override
  String get validInitialStageRequired => 'L\'étape initiale est obligatoire.';

  @override
  String get validStageDisabled => 'Cette étape est désactivée.';

  @override
  String get validAlreadyInStage => 'Le prospect est déjà à cette étape.';

  @override
  String get validLossReasonRequiredForLost =>
      'Le motif de perte est obligatoire pour une étape « perdu ».';

  @override
  String get validLossReasonRequired => 'Le motif de perte est obligatoire.';

  @override
  String get validReasonNeedsDetails => 'Ce motif nécessite une précision.';

  @override
  String get validDetailsRequired => 'Précision obligatoire pour ce motif.';

  @override
  String get typeAtLeastTwo => 'Tapez au moins 2 caractères…';

  @override
  String errTimeout(Object server) {
    return 'Le serveur ($server) ne répond pas dans le délai imparti. Vérifiez le réseau puis réessayez.';
  }

  @override
  String errConnection(Object server) {
    return 'Impossible de joindre le serveur ($server). Vérifiez que l\'ordinateur central est allumé, que vous êtes sur le réseau de l\'entreprise et que l\'adresse du serveur est correcte.';
  }

  @override
  String errConnectionShort(Object server) {
    return 'Impossible de joindre le serveur ($server). Vérifiez le réseau et l\'adresse du serveur.';
  }

  @override
  String errCertificate(Object server) {
    return 'Certificat du serveur refusé ($server).';
  }

  @override
  String get errCancelled => 'Requête annulée.';

  @override
  String errReceiveTimeout(Object server) {
    return 'La réponse du serveur ($server) n\'a pas pu être lue à temps.';
  }

  @override
  String errCommunication(Object details) {
    return 'Erreur de communication avec le serveur : $details';
  }

  @override
  String get errBadRequest => 'Requête invalide.';

  @override
  String get errNotFound => 'Élément introuvable sur le serveur.';

  @override
  String get errNotSupported => 'Opération non prise en charge par le serveur.';

  @override
  String get errConflict =>
      'Opération refusée : conflit avec les données existantes.';

  @override
  String get errValidation => 'Certaines données sont invalides.';

  @override
  String errServer(Object status) {
    return 'Erreur interne du serveur ($status). Réessayez ou contactez l\'administrateur.';
  }

  @override
  String errUnexpectedStatus(Object status) {
    return 'Réponse inattendue du serveur ($status).';
  }

  @override
  String errUnexpectedResponse(Object details) {
    return 'Réponse du serveur inattendue : $details';
  }

  @override
  String errUnexpected(Object details) {
    return 'Erreur inattendue : $details';
  }

  @override
  String get errExpectedObject =>
      'Réponse du serveur inattendue : un objet JSON était attendu.';

  @override
  String get errExpectedList =>
      'Réponse du serveur inattendue : une liste JSON était attendue.';

  @override
  String get errExpectedPaged =>
      'Réponse du serveur inattendue : une liste paginée était attendue.';

  @override
  String get errMissingProspect =>
      'Réponse du serveur inattendue : le prospect mis à jour est absent.';

  @override
  String get errBusy => 'Opération déjà en cours.';

  @override
  String relToday(Object time) {
    return 'aujourd\'hui $time';
  }

  @override
  String relTomorrow(Object time) {
    return 'demain $time';
  }

  @override
  String relYesterday(Object time) {
    return 'hier $time';
  }

  @override
  String relInDays(Object days) {
    return 'dans $days j';
  }

  @override
  String relDaysAgo(Object days) {
    return 'il y a $days j';
  }

  @override
  String get dashSubtitle => 'Vue d\'ensemble de l\'activité commerciale';

  @override
  String dashUpdatedAt(Object time) {
    return 'Mis à jour à $time';
  }

  @override
  String dashStale(Object error) {
    return 'Chiffres peut-être obsolètes : $error';
  }

  @override
  String get stageTypeOpen => 'En cours';

  @override
  String get dashWon => 'Gagnés';

  @override
  String get dashLost => 'Perdus';

  @override
  String dashWinRate(Object rate) {
    return 'Taux de réussite : $rate %';
  }

  @override
  String get dashFollowUpsToday => 'Relances aujourd\'hui';

  @override
  String get dashFollowUpsOverdue => 'Relances en retard';

  @override
  String get dashFollowUpsUpcoming => 'Relances à venir';

  @override
  String dashFollowUpsUpcomingDays(Object days) {
    return 'Relances à venir ($days j)';
  }

  @override
  String get dashProspectsByStage => 'Prospects par étape';

  @override
  String get dashClickStage => 'Cliquez sur une étape pour voir ses prospects';

  @override
  String get noStages => 'Aucune étape';

  @override
  String get dashOutcomes => 'Issue des opportunités';

  @override
  String get dashRecentActivities => 'Activités récentes';

  @override
  String get noRecentActivities => 'Aucune activité récente';

  @override
  String get dashWhyLose => 'Pourquoi perdons-nous des ventes ?';

  @override
  String get dashLostByReason => 'Prospects perdus par motif';

  @override
  String get noLostProspects => 'Aucun prospect perdu';

  @override
  String get prospectsSubtitle => 'Gestion des prospects et opportunités';

  @override
  String get newProspect => 'Nouveau prospect';

  @override
  String get editProspect => 'Modifier le prospect';

  @override
  String get createProspect => 'Créer le prospect';

  @override
  String get addProspect => 'Ajouter un prospect';

  @override
  String get noProspectMatchesFilters =>
      'Aucun prospect ne correspond aux filtres';

  @override
  String get noProspectsYet => 'Aucun prospect pour le moment';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get prospectSearchHint => 'Nom, société, téléphone, e-mail…';

  @override
  String get fieldStage => 'Étape';

  @override
  String stageInactiveSuffix(Object name) {
    return '$name (inactive)';
  }

  @override
  String get allStages => 'Toutes les étapes';

  @override
  String get fieldProduct => 'Produit';

  @override
  String get allProducts => 'Tous les produits';

  @override
  String get fieldLossReason => 'Motif de perte';

  @override
  String get allReasons => 'Tous les motifs';

  @override
  String get filterCreatedDate => 'Date de création';

  @override
  String filtersUnavailable(Object error) {
    return 'Listes de filtres indisponibles : $error\nCliquer pour réessayer.';
  }

  @override
  String prospectCreated(Object name) {
    return 'Prospect « $name » créé.';
  }

  @override
  String get prospectUpdated => 'Prospect mis à jour.';

  @override
  String prospectMovedTo(Object name, Object stage) {
    return '« $name » est passé à l\'étape « $stage ».';
  }

  @override
  String get colCompanyContact => 'Société / contact';

  @override
  String get colLastActivity => 'Dernière activité';

  @override
  String get colNextFollowUp => 'Prochaine relance';

  @override
  String get colCreatedOn => 'Créé le';

  @override
  String get changeStage => 'Changer d\'étape';

  @override
  String get scheduleFollowUp => 'Planifier une relance';

  @override
  String get addActivity => 'Ajouter une activité';

  @override
  String get sectionIdentity => 'Identité';

  @override
  String get fieldCompanyRequired => 'Société / client *';

  @override
  String get fieldCompany => 'Société / client';

  @override
  String get fieldContactPerson => 'Personne à contacter';

  @override
  String get sectionSalesFollowUp => 'Suivi commercial';

  @override
  String get currentStage => 'Étape actuelle';

  @override
  String get currentStageLabel => 'Étape actuelle :  ';

  @override
  String get useChangeStageHint =>
      'Utilisez « Changer d\'étape » pour la modifier (historique conservé).';

  @override
  String stagesUnavailable(Object error) {
    return 'Étapes indisponibles : $error';
  }

  @override
  String get initialStageRequired => 'Étape initiale *';

  @override
  String get markAsLost => 'Marquer comme perdu';

  @override
  String get confirmChange => 'Confirmer le changement';

  @override
  String get newStageRequired => 'Nouvelle étape *';

  @override
  String get stageMarksWon => 'Cette étape marque une vente gagnée.';

  @override
  String get lossReasonRequiredLabel => 'Motif de perte *';

  @override
  String get noActiveLossReason =>
      'Aucun motif actif : ajoutez-en dans « Motifs de perte ».';

  @override
  String reasonDetailsRequiredSuffix(Object label) {
    return '$label  (précision requise)';
  }

  @override
  String get detailsRequiredLabel => 'Précision *';

  @override
  String get details => 'Précision';

  @override
  String get interestedProducts => 'Produits intéressés';

  @override
  String get invalidProspectId => 'Identifiant de prospect invalide.';

  @override
  String dataMaybeStale(Object error) {
    return 'Données peut-être obsolètes : $error';
  }

  @override
  String stageChanged(Object stage) {
    return 'Étape changée : « $stage ».';
  }

  @override
  String createdOnDate(Object date) {
    return 'Créé le $date';
  }

  @override
  String get sectionInformation => 'Informations';

  @override
  String get updatedLabel => 'Mis à jour';

  @override
  String get productsUpdated => 'Produits mis à jour.';

  @override
  String get noProductAssociated => 'Aucun produit associé.';

  @override
  String get sectionCommercialStage => 'Étape commerciale';

  @override
  String get opportunityLost => 'Opportunité perdue';

  @override
  String get reason => 'Motif';

  @override
  String get saleWon => 'Vente gagnée';

  @override
  String get stageHistory => 'Historique des étapes';

  @override
  String get noStageChanges => 'Aucun changement d\'étape enregistré.';

  @override
  String get creationArrow => 'Création →';

  @override
  String pendingCount(Object count) {
    return '$count en attente';
  }

  @override
  String get noFollowUpScheduled => 'Aucune relance planifiée.';

  @override
  String closedFollowUps(Object count) {
    return 'Relances terminées ou annulées ($count)';
  }

  @override
  String get activityHistory => 'Historique des activités';

  @override
  String get activityWord => 'activité';

  @override
  String get noActivitiesForProspect =>
      'Aucune activité enregistrée pour ce prospect.';

  @override
  String get showOlderActivities => 'Afficher les activités plus anciennes';

  @override
  String get activitiesSubtitle => 'Appels, rendez-vous, messages et notes';

  @override
  String get newActivity => 'Nouvelle activité';

  @override
  String get activitySearchHint => 'Description, résultat, prospect…';

  @override
  String get allTypes => 'Tous les types';

  @override
  String get noActivityMatchesFilters =>
      'Aucune activité ne correspond aux filtres';

  @override
  String get noActivities => 'Aucune activité enregistrée';

  @override
  String get colProspect => 'Prospect';

  @override
  String prospectNumber(Object id) {
    return 'Prospect #$id';
  }

  @override
  String outcomeLine(Object outcome) {
    return 'Résultat : $outcome';
  }

  @override
  String get activityTypeLabel => 'Type d\'activité';

  @override
  String get activityDescriptionHint => 'Ce qui a été dit / fait…';

  @override
  String get activityOutcomeHint =>
      'Ex. : intéressé, hésite sur le prix, demande une démo…';

  @override
  String get nextStepsSection => 'Suite à donner';

  @override
  String get nextFollowUpOptional => 'Prochaine relance (optionnel)';

  @override
  String get alsoScheduleFollowUp => 'Planifier aussi une relance à cette date';

  @override
  String get willAppearInFollowUps => 'Elle apparaîtra dans « Relances ».';

  @override
  String get followUpSubject => 'Objet de la relance';

  @override
  String get leaveEmptyAuto => 'Laisser vide pour un texte automatique';

  @override
  String get activitySaved => 'Activité enregistrée.';

  @override
  String get activitySavedAndFollowUp =>
      'Activité enregistrée et relance planifiée.';

  @override
  String get activitySavedFollowUpFailed =>
      'L\'activité est enregistrée, mais la relance n\'a PAS pu être planifiée :';

  @override
  String get activityTypeCall => 'Appel';

  @override
  String get activityTypeAppointment => 'Rendez-vous';

  @override
  String get activityTypeMessage => 'Message';

  @override
  String get activityTypeNote => 'Note';

  @override
  String followUpAfterActivity(Object type, Object date) {
    return 'Relance suite à : $type du $date';
  }

  @override
  String get followUpsSubtitle => 'Suivi des rappels et rendez-vous à venir';

  @override
  String get followUpSearchHint => 'Prospect, description…';

  @override
  String get noFollowUpsToday => 'Aucune relance prévue aujourd\'hui';

  @override
  String get noFollowUpsOverdue => 'Aucune relance en retard';

  @override
  String get noFollowUpsUpcoming => 'Aucune relance à venir';

  @override
  String get noFollowUpsDone => 'Aucune relance effectuée';

  @override
  String get noFollowUpsCancelled => 'Aucune relance annulée';

  @override
  String get colDueDate => 'Échéance';

  @override
  String get markAsDone => 'Marquer comme effectuée';

  @override
  String get cancelFollowUp => 'Annuler la relance';

  @override
  String get followUpStatusPending => 'En attente';

  @override
  String get followUpStatusCompleted => 'Effectuée';

  @override
  String get followUpStatusCancelled => 'Annulée';

  @override
  String get followUpViewToday => 'Aujourd\'hui';

  @override
  String get followUpViewOverdue => 'En retard';

  @override
  String get followUpViewUpcoming => 'À venir';

  @override
  String get followUpViewCompleted => 'Effectuées';

  @override
  String get followUpViewCancelled => 'Annulées';

  @override
  String get followUpScheduled => 'Relance planifiée.';

  @override
  String get followUpUpdated => 'Relance modifiée.';

  @override
  String get followUpCompleted => 'Relance marquée comme effectuée.';

  @override
  String followUpCompletedActivityFailed(Object error) {
    return 'Relance marquée comme effectuée, mais l\'activité n\'a pas pu être enregistrée ($error). Le résultat est conservé dans la note de la relance ; ajoutez l\'activité depuis la fiche du prospect.';
  }

  @override
  String get followUpCancelled => 'Relance annulée.';

  @override
  String get editFollowUp => 'Modifier la relance';

  @override
  String get quickTomorrow => 'Demain';

  @override
  String get quickIn3Days => 'Dans 3 jours';

  @override
  String get quickIn1Week => 'Dans 1 semaine';

  @override
  String get quickIn2Weeks => 'Dans 2 semaines';

  @override
  String get followUpDescriptionHint =>
      'Ex. : rappeler pour la validation du devis';

  @override
  String get completeFollowUpTitle => 'Marquer la relance comme effectuée';

  @override
  String get finishFollowUp => 'Terminer la relance';

  @override
  String dueOn(Object date) {
    return 'Prévue le $date';
  }

  @override
  String get recordOutcomeAsActivity =>
      'Enregistrer le résultat comme activité';

  @override
  String get recommendedKeepsHistory =>
      'Recommandé : garde l\'historique de l\'échange.';

  @override
  String get completeOutcomeHint =>
      'Ex. : accord de principe, souhaite réfléchir…';

  @override
  String companyDueOn(Object company, Object date) {
    return '$company — prévue le $date';
  }

  @override
  String get reasonOptional => 'Raison (optionnel)';

  @override
  String get followUpOverdueTip => 'Relance en retard';

  @override
  String get pipelineTitle => 'Pipeline des ventes';

  @override
  String get pipelineSubtitle => 'Prospects regroupés par étape';

  @override
  String get pipelineFilterHint => 'Filtrer toutes les étapes…';

  @override
  String get noStagesConfigured => 'Aucune étape de vente configurée';

  @override
  String get configureStages => 'Configurer les étapes';

  @override
  String prospectMovedToStage(Object name, Object stage) {
    return '« $name » déplacé vers « $stage ».';
  }

  @override
  String get dropCardHere => 'Déposez une carte ici';

  @override
  String get stageDeactivated => 'Étape désactivée';

  @override
  String get moveTo => 'Déplacer vers…';

  @override
  String moveToStage(Object stage) {
    return 'Déplacer vers « $stage »';
  }

  @override
  String productAdded(Object name) {
    return 'Produit « $name » ajouté.';
  }

  @override
  String get productUpdated => 'Produit mis à jour.';

  @override
  String get productReactivated => 'Produit réactivé.';

  @override
  String get productDeactivated => 'Produit désactivé.';

  @override
  String deactivateQuestion(Object name) {
    return 'Désactiver « $name » ?';
  }

  @override
  String get deactivateProductBody =>
      'Le produit ne pourra plus être associé à de nouveaux prospects. Les associations existantes et l\'historique sont conservés.';

  @override
  String get productsSubtitle => 'Logiciels et services proposés aux prospects';

  @override
  String get newProduct => 'Nouveau produit';

  @override
  String get productSearchHint => 'Rechercher un produit…';

  @override
  String get showInactiveProducts => 'Afficher les produits inactifs';

  @override
  String get noProducts => 'Aucun produit';

  @override
  String get noProductMatches => 'Aucun produit ne correspond';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get productActive => 'Produit actif';

  @override
  String get productActiveHint =>
      'Seuls les produits actifs peuvent être associés aux prospects.';

  @override
  String selectedCount(Object count) {
    return '$count sélectionné(s)';
  }

  @override
  String get noActiveProducts =>
      'Aucun produit actif. Ajoutez-en dans « Produits ».';

  @override
  String productInactiveSuffix(Object name) {
    return '$name (inactif)';
  }

  @override
  String stageCreated(Object name) {
    return 'Étape « $name » créée.';
  }

  @override
  String get stageUpdated => 'Étape mise à jour.';

  @override
  String get stageReactivated => 'Étape réactivée.';

  @override
  String get stageDeactivatedMsg => 'Étape désactivée.';

  @override
  String get stageDeleted => 'Étape supprimée.';

  @override
  String deleteQuestion(Object name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteStageBody =>
      'Cette étape n\'a jamais été utilisée. Elle sera définitivement supprimée.';

  @override
  String get orderNotSaved => 'Le nouvel ordre n\'a pas été enregistré :';

  @override
  String get stagesSubtitle =>
      'Définissez le pipeline : ordre, couleur et type (en cours / gagné / perdu). Les étapes utilisées ne peuvent pas être supprimées, seulement désactivées.';

  @override
  String get newStage => 'Nouvelle étape';

  @override
  String get savingNewOrder => 'Enregistrement du nouvel ordre…';

  @override
  String get createStagesHint =>
      'Créez au moins une étape « en cours », une « gagné » et une « perdu ».';

  @override
  String get createStage => 'Créer une étape';

  @override
  String prospectsCountShort(Object count) {
    return '$count prospect(s)';
  }

  @override
  String get stageUsedNoDelete =>
      'Utilisée par des prospects ou l\'historique : suppression impossible.';

  @override
  String get deleteImpossibleUsed => 'Suppression impossible (étape utilisée)';

  @override
  String get editStage => 'Modifier l\'étape';

  @override
  String get stageTypeLocked =>
      'Étape déjà utilisée : son type ne peut plus changer (protection de l\'historique).';

  @override
  String get lostRequiresReasonHint =>
      '« Perdu » exige un motif de perte lors du changement d\'étape.';

  @override
  String get stageActive => 'Étape active';

  @override
  String get stageUsedDeactivateInstead =>
      'Cette étape est utilisée par des prospects ou leur historique : désactivez-la au lieu de la supprimer.';

  @override
  String get stageTypeWon => 'Gagné';

  @override
  String get stageTypeLost => 'Perdu';

  @override
  String get reasonAdded => 'Motif ajouté.';

  @override
  String get reasonUpdated => 'Motif mis à jour.';

  @override
  String get reasonReactivated => 'Motif réactivé.';

  @override
  String get reasonDeactivated => 'Motif désactivé.';

  @override
  String get deactivateReasonBody =>
      'Ce motif ne sera plus proposé. Les prospects déjà perdus avec ce motif le conservent.';

  @override
  String get lossReasonsSubtitle =>
      'Raisons proposées lorsqu\'un prospect passe à une étape « perdu ». Elles alimentent l\'analyse des ventes perdues.';

  @override
  String get newReason => 'Nouveau motif';

  @override
  String get lossReasonsReadOnly =>
      'Le serveur ne permet pas de gérer les motifs de perte depuis l\'application : liste en lecture seule.';

  @override
  String get noLossReasons => 'Aucun motif de perte';

  @override
  String get noActiveReasonWarning =>
      'Sans motif actif, aucun prospect ne peut passer à une étape « perdu ».';

  @override
  String get detailsRequired => 'Précision requise';

  @override
  String get editReason => 'Modifier le motif';

  @override
  String get newLossReason => 'Nouveau motif de perte';

  @override
  String get reasonLabelHint => 'Ex. : Trop cher';

  @override
  String get detailsMandatory => 'Précision obligatoire';

  @override
  String get detailsMandatoryHint =>
      'Ex. : « Concurrent choisi » → préciser lequel.';

  @override
  String get reasonActive => 'Motif actif';

  @override
  String get settingsSavedOnline =>
      'Paramètres enregistrés. Serveur joignable.';

  @override
  String get settingsSavedOffline =>
      'Paramètres enregistrés sur cet ordinateur, mais le serveur ne répond pas pour le moment.';

  @override
  String get settingsSubtitle => 'Paramètres propres à cet ordinateur';

  @override
  String get firstLaunchHint =>
      'Première utilisation : indiquez l\'adresse de l\'ordinateur central (serveur Laravel) sur le réseau de l\'entreprise, testez la connexion puis enregistrez.';

  @override
  String get settingsServerTitle => 'Serveur de l\'application';

  @override
  String get settingsServerSubtitle =>
      'API Laravel hébergée sur l\'ordinateur central (réseau local)';

  @override
  String get fieldApiAddress => 'Adresse de l\'API *';

  @override
  String get apiAddressHelp =>
      'Format : http://ADRESSE_IP:PORT/api/v1 — n\'utilisez pas « localhost » sur les postes des employés.';

  @override
  String get fieldTimeout => 'Délai d\'attente maximal';

  @override
  String secondsShort(Object seconds) {
    return '$seconds s';
  }

  @override
  String get testing => 'Test en cours…';

  @override
  String get testConnection => 'Tester la connexion';

  @override
  String connectionSuccess(Object url) {
    return 'Connexion réussie à $url';
  }

  @override
  String get settingsDisplay => 'Affichage';

  @override
  String get themeLightShort => 'Clair';

  @override
  String get themeDarkShort => 'Sombre';

  @override
  String get themeSystemShort => 'Système';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get aboutApplication => 'Application';

  @override
  String aboutClient(Object app) {
    return '$app — client Windows';
  }

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutData => 'Données';

  @override
  String get aboutDataBody =>
      'Toutes les données sont stockées sur le serveur central. Seuls l\'adresse du serveur et le thème sont enregistrés sur ce poste.';

  @override
  String get changeProspect => 'Changer de prospect';

  @override
  String get prospectRequiredLabel => 'Prospect *';

  @override
  String get errNotJson =>
      'Le serveur a répondu, mais pas en JSON. Vérifiez que l\'adresse se termine par /api/v1.';

  @override
  String countProspects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prospects',
      one: '1 prospect',
      zero: 'Aucun prospect',
    );
    return '$_temp0';
  }

  @override
  String countActivities(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activités',
      one: '1 activité',
      zero: 'Aucune activité',
    );
    return '$_temp0';
  }

  @override
  String activitiesCountSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activités',
      one: '$count activité',
    );
    return '$_temp0 — appels, rendez-vous, messages et notes';
  }

  @override
  String pipelineCountSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prospects',
      one: '$count prospect',
    );
    return '$_temp0 · glissez une carte vers une autre étape pour la déplacer';
  }

  @override
  String get donutProspects => 'prospects';

  @override
  String reasonLine(Object note) {
    return 'Raison : $note';
  }

  @override
  String lossReasonLine(Object reason) {
    return 'Motif : $reason';
  }

  @override
  String get deactivateStageIntro =>
      'L\'étape ne pourra plus être choisie pour de nouveaux changements.';

  @override
  String deactivateStageProspects(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prospects y sont actuellement et y resteront.',
      one: '1 prospect y est actuellement et y restera.',
    );
    return '$_temp0';
  }

  @override
  String get deactivateStageOutro => 'L\'historique est conservé.';

  @override
  String get sectionBusinessProfile => 'Profil commercial';

  @override
  String get fieldBusinessActivity => 'Activité de l\'entreprise';

  @override
  String get businessActivityHint => 'Choisir ou saisir une activité';

  @override
  String get fieldSource => 'Source du prospect';

  @override
  String get fieldSourceOther => 'Précisez la source';

  @override
  String get fieldPreviousSoftware => 'Logiciel utilisé auparavant';

  @override
  String get previousSoftwareHint => 'Choisir ou saisir un logiciel';

  @override
  String get notSpecified => 'Non renseigné';

  @override
  String get allSources => 'Toutes les sources';

  @override
  String get baWholesale => 'Commerce de gros';

  @override
  String get baRetail => 'Commerce de détail';

  @override
  String get baManufacturing => 'Industrie / production';

  @override
  String get baConstruction => 'BTP / construction';

  @override
  String get baServices => 'Services';

  @override
  String get srcFacebook => 'Facebook';

  @override
  String get srcInstagram => 'Instagram';

  @override
  String get srcFriendReferral => 'Ami / recommandation personnelle';

  @override
  String get srcCustomerReferral => 'Recommandation d\'un client existant';

  @override
  String get srcWebsite => 'Site web';

  @override
  String get srcPhoneCall => 'Appel téléphonique';

  @override
  String get swSage => 'Sage';

  @override
  String get swPcCompta => 'PC Compta';

  @override
  String get swExcel => 'Excel';

  @override
  String get swOtherSoftware => 'Autre logiciel de gestion';

  @override
  String get swNone => 'Aucun logiciel';

  @override
  String get searchProspectTitle => 'Rechercher un prospect';

  @override
  String get searchProspectHint => 'Nom, société, téléphone ou n° de prospect…';

  @override
  String get searchProspectIdle =>
      'Saisissez un nom, une société, un numéro de téléphone ou un n° de prospect.';

  @override
  String get searchProspectEmpty => 'Aucun prospect trouvé';

  @override
  String searchProspectMore(Object total) {
    return 'Affinez la recherche pour voir les autres résultats ($total au total).';
  }

  @override
  String get searchAllStagesNote =>
      'La recherche porte sur toutes les étapes (gagnés et perdus inclus).';

  @override
  String prospectIdShort(Object id) {
    return 'N° $id';
  }

  @override
  String get prospectOptionalLabel => 'Prospect (optionnel)';

  @override
  String get pickProspect => 'Choisir un prospect';

  @override
  String get activityTitleRequired => 'Titre / résumé *';

  @override
  String get activityTitleHint => 'Ex. : appel du client au sujet du devis';

  @override
  String get activityDiscussionLabel => 'Discussion, réponse du client, notes';

  @override
  String get colTitle => 'Titre';

  @override
  String get linkStatusLinked => 'Lié';

  @override
  String get linkStatusUnlinked => 'Non lié';

  @override
  String get linkToProspect => 'Lier à un prospect';

  @override
  String get changeLinkedProspect => 'Changer le prospect lié';

  @override
  String get linkedProspectLabel => 'Prospect lié';

  @override
  String get noProspectLinked => 'Aucun prospect lié';

  @override
  String get openProspect => 'Ouvrir le prospect';

  @override
  String get activityDetails => 'Détails de l\'activité';

  @override
  String activityLinkedTo(Object name) {
    return 'Activité liée à « $name ».';
  }

  @override
  String get relinkTitle => 'Changer le prospect lié ?';

  @override
  String relinkBody(Object from, Object to) {
    return 'Cette activité est liée à « $from ». La déplacer vers « $to » ? Son contenu et sa date ne changent pas.';
  }

  @override
  String get relinkConfirm => 'Déplacer';

  @override
  String get originLabel => 'Origine';

  @override
  String get originDirect => 'Saisie directe';

  @override
  String get originFollowUp => 'Issue d\'une relance';

  @override
  String get activityFromFollowUpLocked =>
      'Cette activité provient d\'une relance : elle reste liée à son prospect.';

  @override
  String get filterLinkAll => 'Toutes (liées ou non)';

  @override
  String get filterLinkOnlyLinked => 'Liées à un prospect';

  @override
  String get filterLinkOnlyUnlinked => 'Non liées';

  @override
  String get colLink => 'Prospect lié';

  @override
  String get colLinkfllowup => 'Relance liée';

  @override
  String get activityOccurredAt => 'Date et heure';

  @override
  String get createdOnLabel => 'Créée le';

  @override
  String get linkedOnLabel => 'Liée le';

  @override
  String get typeLabelRequired => 'Type d\'activité *';

  @override
  String get followUpTypeLabel => 'Type de relance';

  @override
  String get followUpTypeRequired => 'Choisissez le type de relance.';

  @override
  String get followUpTypeMissing => 'Type non défini';

  @override
  String followUpCompletedKeepsType(Object type) {
    return 'Le type de l\'activité sera celui de la relance : $type.';
  }

  @override
  String get activityTypeForLegacy =>
      'Cette relance n\'a pas de type : choisissez celui de l\'activité.';

  @override
  String get followUpCompletedWithActivity =>
      'Relance terminée et activité enregistrée.';

  @override
  String get colType => 'Type';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageHint =>
      'Langue de l\'interface. Le changement est immédiat.';

  @override
  String get languageMenuTooltip => 'Changer la langue';

  @override
  String get themeToggleToDark => 'Passer au thème sombre';

  @override
  String get themeToggleToLight => 'Passer au thème clair';

  @override
  String get settingsAboutBody =>
      'Seuls l\'adresse du serveur, la langue et le thème sont enregistrés sur ce poste.';

  @override
  String get validFieldTitle => 'Le titre';

  @override
  String validMinLength(Object min) {
    return '$min caractères minimum.';
  }

  @override
  String get navAfterSales => 'Après-vente';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navCustomers => 'Clients';

  @override
  String get navEmployees => 'Employés';

  @override
  String get navGroupCrm => 'CRM';

  @override
  String get navGroupCustomers => 'Clients et produits';

  @override
  String get navGroupService => 'Service';

  @override
  String get navGroupTeam => 'Équipe';

  @override
  String get navRequests => 'Demandes et réservations';

  @override
  String get navTraining => 'Formation et accompagnement';

  @override
  String get navWorkflowSettings => 'Rendez-vous et après-vente';

  @override
  String get wfYes => 'Oui';

  @override
  String get wfNo => 'Non';

  @override
  String get wfSaved => 'Enregistré.';

  @override
  String get wfDate => 'Date';

  @override
  String get wfWhen => 'Quand';

  @override
  String get wfToday => 'Aujourd\'hui';

  @override
  String get wfPrevious => 'Précédent';

  @override
  String get wfNext => 'Suivant';

  @override
  String get wfTitle => 'Titre';

  @override
  String get wfUpdated => 'Mis à jour';

  @override
  String get wfReceived => 'Reçue le';

  @override
  String get wfReference => 'Référence';

  @override
  String get wfEmployee => 'Employé';

  @override
  String get wfAssignedTo => 'Assigné à';

  @override
  String get wfUnassigned => 'Non assigné';

  @override
  String get wfTrainer => 'Formateur';

  @override
  String get wfCode => 'Code';

  @override
  String get wfCodeInvalid =>
      'Minuscules, chiffres et _ ; commence par une lettre.';

  @override
  String get wfFieldRequired => 'Champ obligatoire.';

  @override
  String get wfNumberInvalid => 'Nombre entier positif attendu.';

  @override
  String wfTooLong(Object max) {
    return '$max caractères maximum.';
  }

  @override
  String wfRangeError(Object min, Object max) {
    return 'Entre $min et $max.';
  }

  @override
  String get wfUrl => 'Lien (URL)';

  @override
  String get wfUrlInvalid => 'Lien http(s) invalide.';

  @override
  String get wfUrlRequired => 'Le lien est obligatoire.';

  @override
  String get wfInvalidId => 'Identifiant invalide.';

  @override
  String get wfStartInPast => 'L\'heure de début est déjà passée.';

  @override
  String get wfEndAfterStart => 'La fin doit être après le début.';

  @override
  String get wfStarts => 'Début';

  @override
  String get wfEnds => 'Fin';

  @override
  String get wfStartTime => 'Heure de début';

  @override
  String get wfEndTime => 'Heure de fin';

  @override
  String get wfLanguage => 'Langue';

  @override
  String get wfSortOrder => 'Ordre d\'affichage';

  @override
  String get wfSortOrderHint => 'Le plus petit nombre = le plus urgent.';

  @override
  String get wfStatusHeld => 'En attente';

  @override
  String get wfStatusProposed => 'Proposé';

  @override
  String get wfStatusConfirmed => 'Confirmé';

  @override
  String get wfStatusRejected => 'Refusé';

  @override
  String get wfStatusCancelled => 'Annulé';

  @override
  String get wfStatusExpired => 'Expiré';

  @override
  String get wfStatusCompleted => 'Réalisé';

  @override
  String get wfStatusNoShow => 'Absent';

  @override
  String get wfKindAppointment => 'Rendez-vous';

  @override
  String get wfKindFollowUp => 'Relance';

  @override
  String get wfKindIntervention => 'Intervention';

  @override
  String get wfKindActivity => 'Activités réalisées';

  @override
  String get wfGroupDemo => 'Démo';

  @override
  String get wfGroupMeeting => 'Réunion';

  @override
  String get wfGroupTraining => 'Formation';

  @override
  String get wfGroup => 'Groupe';

  @override
  String get wfGroupAccompaniment => 'Accompagnement';

  @override
  String get wfConflictHoliday => 'Jour férié';

  @override
  String get wfConflictEmployee => 'Employé déjà occupé';

  @override
  String get wfConflictCustomer => 'Client déjà occupé';

  @override
  String get wfConflictsTitle => 'Planning refusé : conflits détectés';

  @override
  String wfConflictLine(Object occurrence, Object date, Object reason) {
    return 'Séance $occurrence ($date) : $reason';
  }

  @override
  String get wfConflictNothingSaved =>
      'Conflit de planning : rien n\'a été enregistré. Corrigez les séances listées.';

  @override
  String wfConflictExplain(Object reasons) {
    return 'Conflit : $reasons';
  }

  @override
  String get wfHoldExpired =>
      'La réservation a expiré et le créneau a été libéré. Actualisez la liste.';

  @override
  String get wfHoldExpiredChip => 'Réservation expirée';

  @override
  String get wfHoldExpires => 'Expiration de la réservation';

  @override
  String wfExpiresIn(Object time) {
    return 'expire dans $time';
  }

  @override
  String get wfCalendarSubtitle =>
      'Rendez-vous, relances et interventions planifiés ; les activités réalisées apparaissent en grisé.';

  @override
  String get wfViewMonth => 'Mois';

  @override
  String get wfViewWeek => 'Semaine';

  @override
  String get wfViewDay => 'Jour';

  @override
  String get wfLegendScheduled => 'Planifié';

  @override
  String get wfLegendCompleted => 'Réalisé';

  @override
  String get wfFilterCustomer => 'Client';

  @override
  String get wfClearFilters => 'Effacer les filtres';

  @override
  String wfMoreItems(Object count) {
    return '+$count autres';
  }

  @override
  String get wfNothingScheduled => 'Rien de planifié ce jour';

  @override
  String get wfNothingScheduledHint =>
      'Les rendez-vous confirmés, relances et interventions apparaissent ici.';

  @override
  String wfActivitiesNotLoaded(Object message) {
    return 'Les activités réalisées n\'ont pas pu être chargées : $message';
  }

  @override
  String get wfConfirmHoldTitle => 'Confirmer le rendez-vous';

  @override
  String get wfRejectTitle => 'Refuser la demande';

  @override
  String get wfCancelAppointmentTitle => 'Annuler le rendez-vous';

  @override
  String get wfProposeTitle => 'Proposer un autre horaire';

  @override
  String get wfRescheduleTitle => 'Déplacer la séance';

  @override
  String get wfRecordOutcomeTitle => 'Enregistrer le résultat';

  @override
  String get wfReject => 'Refuser';

  @override
  String get wfCancelAppointment => 'Annuler le rendez-vous';

  @override
  String get wfCancelProposal => 'Retirer la proposition';

  @override
  String get wfProposeOther => 'Proposer un autre horaire';

  @override
  String get wfSendProposal => 'Envoyer la proposition';

  @override
  String get wfReschedule => 'Déplacer';

  @override
  String get wfRecordOutcome => 'Enregistrer le résultat';

  @override
  String get wfMarkNoShow => 'Marquer absent';

  @override
  String get wfMeetingLink => 'Lien de la réunion';

  @override
  String get wfMeetingLinkHint => 'Visible par le client une fois confirmé.';

  @override
  String get wfNewTime => 'Nouvel horaire';

  @override
  String get wfReasonVisible => 'Motif (visible par le client)';

  @override
  String get wfMessageVisible => 'Message (visible par le client)';

  @override
  String get wfCustomerVisibleHint =>
      'Ce texte est visible par le client dans son espace.';

  @override
  String get wfOutcome => 'Résultat';

  @override
  String get wfOutcomeHint =>
      'Une activité est créée dans le CRM avec ce résultat.';

  @override
  String get wfOutcomeRequired => 'Le résultat est obligatoire.';

  @override
  String get wfActivityRecorded => 'Activité enregistrée';

  @override
  String get wfCustomerMessage => 'Message au client';

  @override
  String get wfInternalNotes => 'Notes internes';

  @override
  String get wfOpenProspectRecord => 'Ouvrir la fiche';

  @override
  String get wfNewProspect => 'Nouveau prospect';

  @override
  String get wfWaitingForCustomer => 'En attente de la réponse du client.';

  @override
  String get wfRequestsSubtitle =>
      'Créneaux réservés par les visiteurs et demandes reçues du site web.';

  @override
  String wfHoldsTab(Object count) {
    return 'Réservations ($count)';
  }

  @override
  String get wfWebsiteRequestsTab => 'Demandes du site';

  @override
  String get wfNoHolds => 'Aucune réservation en attente';

  @override
  String get wfNoHoldsHint =>
      'Les créneaux demandés depuis le site apparaissent ici jusqu\'à votre décision.';

  @override
  String get wfNoRequests => 'Aucune demande';

  @override
  String get wfRequestDemo => 'Démo';

  @override
  String get wfRequestQuotation => 'Devis';

  @override
  String get wfRequestTrial => 'Essai';

  @override
  String get wfReqPending => 'À traiter';

  @override
  String get wfReqScheduled => 'Planifiée';

  @override
  String get wfReqHandled => 'Traitée';

  @override
  String get wfMarkHandled => 'Marquer comme traitée';

  @override
  String get wfRequestUpdated => 'Demande mise à jour.';

  @override
  String get wfTrainingSubtitle =>
      'Séances de formation et séries d\'accompagnement des clients.';

  @override
  String get wfNewTraining => 'Nouvelle formation';

  @override
  String get wfNewAccompaniment => 'Nouvel accompagnement';

  @override
  String get wfNoSessions => 'Aucune séance';

  @override
  String get wfNoSessionsHint =>
      'Planifiez une formation ou une série d\'accompagnement.';

  @override
  String get wfShowPast => 'Inclure le passé';

  @override
  String get wfPartOfSeries => 'Série d\'accompagnement';

  @override
  String get wfCancelThisSession => 'Annuler cette séance';

  @override
  String get wfCancelRemainingSeries => 'Annuler le reste de la série';

  @override
  String get wfCancelSessionTitle => 'Annuler cette séance ?';

  @override
  String get wfCancelSessionBody =>
      'Seule cette séance future est annulée ; le reste de la série reste inchangé.';

  @override
  String get wfCancelSeriesTitle => 'Annuler le reste de la série ?';

  @override
  String get wfCancelSeriesBody =>
      'Cette séance et les suivantes sont annulées. Les séances déjà réalisées ne sont pas touchées.';

  @override
  String get wfCancelSeries => 'Annuler la suite';

  @override
  String get wfSessionCancelled => 'Séance annulée.';

  @override
  String wfSeriesCancelled(Object count) {
    return '$count séance(s) annulée(s).';
  }

  @override
  String get wfSessionScheduled => 'Séance planifiée.';

  @override
  String wfSeriesScheduled(Object count) {
    return 'Série planifiée : $count séances.';
  }

  @override
  String get wfMoreActions => 'Autres actions';

  @override
  String get wfSessionType => 'Type de séance';

  @override
  String get wfNoTypesConfigured =>
      'Aucun type de rendez-vous actif pour ce groupe. Configurez-le dans les paramètres.';

  @override
  String get wfSelectType => 'Choisissez un type.';

  @override
  String get wfSelectProduct => 'Choisissez un produit.';

  @override
  String get wfNoProduct => 'Aucun produit';

  @override
  String get wfOccurrences => 'Nombre de séances';

  @override
  String get wfOccurrencesHint => 'Valeur par défaut des paramètres.';

  @override
  String get wfIntervalDays => 'Intervalle (jours)';

  @override
  String get wfIntervalHint => 'Jours entre deux séances.';

  @override
  String wfPlannedSessions(Object count) {
    return '$count séances prévues';
  }

  @override
  String get wfPickResource => 'Choisir un support de formation';

  @override
  String get wfResourceLink => 'Lien du support (optionnel)';

  @override
  String get wfPrepareWhatsApp => 'Préparer un message WhatsApp';

  @override
  String get wfPrepareWhatsAppHint =>
      'Prépare le texte ; vous l\'envoyez vous-même depuis WhatsApp.';

  @override
  String get wfOpenWhatsApp => 'Ouvrir WhatsApp';

  @override
  String get wfWhatsAppHint =>
      'Ouvre un message pré-rempli. L\'envoi se fait dans WhatsApp, non confirmé par le CRM.';

  @override
  String get wfWhatsappInvalidLink =>
      'Lien WhatsApp non reconnu : il n\'a pas été ouvert.';

  @override
  String get wfCustomersSubtitle => 'Prospects convertis en clients.';

  @override
  String get wfCustomerSearchHint => 'Rechercher un client…';

  @override
  String get wfNoCustomers => 'Aucun client';

  @override
  String get wfNoCustomersHint => 'Convertissez un prospect depuis sa fiche.';

  @override
  String get wfCustomerSince => 'Client depuis';

  @override
  String wfCustomerSinceDate(Object date) {
    return 'Client depuis le $date';
  }

  @override
  String get wfCustomerBadge => 'Client';

  @override
  String wfCustomersCount(Object count) {
    return '$count clients';
  }

  @override
  String get wfConvertTitle => 'Convertir en client';

  @override
  String get wfConvertAction => 'Convertir en client';

  @override
  String wfConvertIntro(Object name) {
    return '« $name » devient client. La fiche, l\'historique, les activités et les étapes sont conservés.';
  }

  @override
  String get wfPurchasedProducts => 'Produits achetés';

  @override
  String get wfConversionNote => 'Note de conversion';

  @override
  String get wfConvertedBy => 'Converti le / par';

  @override
  String wfConverted(Object name) {
    return '« $name » est maintenant client.';
  }

  @override
  String get wfAlreadyCustomer =>
      'Ce prospect est déjà client. Actualisez la fiche.';

  @override
  String get wfOpenCustomerProfile => 'Voir le profil client';

  @override
  String get wfCustomerProducts => 'Produits du client';

  @override
  String get wfNoCustomerProducts => 'Aucun produit lié';

  @override
  String wfPurchasedOn(Object date) {
    return 'Acheté le $date';
  }

  @override
  String get wfPortalAccounts => 'Comptes du portail client';

  @override
  String get wfPortalAccountsHint =>
      'Identités du site web, distinctes des accès employés.';

  @override
  String get wfNoPortalAccount => 'Aucun compte portail lié';

  @override
  String wfLastLogin(Object date) {
    return 'Dernière connexion : $date';
  }

  @override
  String get wfTrials => 'Accès d\'essai';

  @override
  String get wfNoTrials => 'Aucun essai';

  @override
  String get wfNewTrial => 'Nouvel essai';

  @override
  String get wfTrialUrl => 'Lien d\'accès à l\'essai';

  @override
  String get wfTrialUrlHint =>
      'Le client ne le voit que pendant l\'essai actif.';

  @override
  String get wfTrialStarts => 'Début de l\'essai';

  @override
  String get wfTrialEnds => 'Fin de l\'essai';

  @override
  String get wfTrialDays => 'Durée d\'essai par défaut (jours)';

  @override
  String get wfTrialActive => 'Actif';

  @override
  String get wfTrialScheduled => 'Programmé';

  @override
  String get wfTrialRevoked => 'Révoqué';

  @override
  String get wfTrialActivated => 'Essai activé.';

  @override
  String get wfTrialOverlap =>
      'Un essai existe déjà pour ce produit sur cette période.';

  @override
  String get wfRevoke => 'Révoquer';

  @override
  String get wfRevokeTrialTitle => 'Révoquer l\'accès à l\'essai ?';

  @override
  String wfRevokeTrialBody(Object product) {
    return 'Le client ne verra plus le lien de l\'essai « $product ».';
  }

  @override
  String get wfTrialRevokedDone => 'Accès révoqué.';

  @override
  String get wfAppointments => 'Rendez-vous';

  @override
  String get wfAppointmentsHint =>
      'Planifiés ou réalisés (le résultat devient une activité).';

  @override
  String get wfNoAppointments => 'Aucun rendez-vous';

  @override
  String get wfScheduleTraining => 'Planifier une formation';

  @override
  String get wfAfterSalesSubtitle =>
      'Demandes des clients et interventions publiées par l\'équipe.';

  @override
  String get wfNewIntervention => 'Nouvelle intervention';

  @override
  String wfInterventionCreated(Object reference) {
    return 'Intervention $reference créée.';
  }

  @override
  String get wfInterventionType => 'Type d\'intervention';

  @override
  String get wfPriority => 'Priorité';

  @override
  String get wfNoPriority => 'Sans priorité';

  @override
  String get wfSource => 'Origine';

  @override
  String get wfSourceCustomer => 'Client';

  @override
  String get wfSourceEmployee => 'Employé';

  @override
  String get wfSourceBoth => 'Client et employé';

  @override
  String get wfOpenItems => 'Ouvertes';

  @override
  String get wfClosedItems => 'Clôturées';

  @override
  String get wfNoInterventions => 'Aucune intervention';

  @override
  String get wfNoInterventionsHint =>
      'Les demandes des clients et vos interventions apparaissent ici.';

  @override
  String get wfAffectedCustomers => 'Clients concernés';

  @override
  String get wfAddCustomer => 'Ajouter un client';

  @override
  String get wfScheduledAt => 'Planifiée le';

  @override
  String get wfTitleRequired => 'Le titre est obligatoire.';

  @override
  String get wfDescriptionRequired => 'La description est obligatoire.';

  @override
  String get wfClosedAt => 'Clôturée le';

  @override
  String get wfStatusWorkflow => 'Statut';

  @override
  String get wfStatusWorkflowHint =>
      'Seuls les statuts autorisés depuis le statut actuel sont proposés.';

  @override
  String get wfCurrentStatus => 'Statut actuel';

  @override
  String get wfCustomerSees => 'Vu par le client';

  @override
  String get wfNoTransitions => 'Aucune transition autorisée depuis ce statut.';

  @override
  String get wfTransitionNotAllowed =>
      'Ce changement de statut n\'est pas autorisé.';

  @override
  String wfChangeStatusTo(Object status) {
    return 'Passer à « $status »';
  }

  @override
  String wfCustomerSeesStatus(Object label) {
    return 'Le client verra : « $label ».';
  }

  @override
  String get wfStatusExplanation => 'Explication pour le client (optionnelle)';

  @override
  String get wfStatusChanged => 'Statut mis à jour.';

  @override
  String get wfTriage => 'Tri et planification';

  @override
  String get wfReleaseNotes => 'Notes de version';

  @override
  String get wfReleaseNotesHint =>
      'Publiez la correction ou la mise à jour aux clients concernés.';

  @override
  String get wfPublish => 'Publier';

  @override
  String get wfPublished => 'Publié aux clients concernés.';

  @override
  String get wfPublishTitle => 'Publier aux clients';

  @override
  String wfPublishTo(Object names) {
    return 'Sera visible par : $names';
  }

  @override
  String get wfPublishNoCustomers =>
      'Aucun client concerné : ajoutez-en à la création pour pouvoir publier.';

  @override
  String wfPublishedOn(Object date) {
    return 'Publié le $date';
  }

  @override
  String get wfNotPublished =>
      'Pas encore publié : les clients ne le voient pas.';

  @override
  String get wfResolutionRequired => 'Le texte publié est obligatoire.';

  @override
  String get wfUnpublish => 'Dépublier';

  @override
  String get wfUnpublishTitle => 'Dépublier ?';

  @override
  String get wfUnpublishBody => 'Les clients ne verront plus ces notes.';

  @override
  String get wfUnpublished => 'Dépublié.';

  @override
  String get wfConversation => 'Échanges';

  @override
  String get wfNoMessages => 'Aucun message';

  @override
  String get wfInternalNote => 'Note interne';

  @override
  String get wfCustomerReply => 'Réponse au client';

  @override
  String get wfInternalNoteHint =>
      'Réservée à l\'équipe : le client ne la verra jamais.';

  @override
  String get wfCustomerReplyWarning =>
      'Ce message sera visible par le client dans son espace.';

  @override
  String get wfConfirmCustomerReplyTitle => 'Envoyer au client ?';

  @override
  String get wfConfirmCustomerReplyBody =>
      'La réponse sera visible par le client. Ne mentionnez aucune discussion interne.';

  @override
  String get wfSendReply => 'Envoyer la réponse';

  @override
  String get wfAddNote => 'Ajouter la note';

  @override
  String get wfReplySaved => 'Réponse enregistrée pour le client.';

  @override
  String get wfNoteSaved => 'Note interne enregistrée.';

  @override
  String get wfMessageRequired => 'Le message est vide.';

  @override
  String get wfEmployeesSubtitle =>
      'Postes connectés au CRM et travail assigné. Tous les employés ont le même accès.';

  @override
  String get wfNoEmployees => 'Aucun employé connu';

  @override
  String get wfNoEmployeesHint =>
      'Les employés apparaissent quand leur application se connecte au serveur.';

  @override
  String get wfSelectEmployee => 'Sélectionnez un employé';

  @override
  String get wfIdle => 'Inactif';

  @override
  String wfAssignedAppointments(Object name) {
    return 'Rendez-vous à venir de $name';
  }

  @override
  String wfAssignedInterventions(Object name) {
    return 'Interventions ouvertes de $name';
  }

  @override
  String get wfNothingAssigned => 'Rien d\'assigné';

  @override
  String get wfSettingsSubtitle =>
      'Horaires, types, statuts, priorités et modèles. Tout est stocké dans le CRM.';

  @override
  String get wfSettingsSaved => 'Paramètres enregistrés.';

  @override
  String get wfCfgScheduling => 'Horaires et réservations';

  @override
  String get wfCfgSchedulingHint =>
      'Jours et heures de travail, durée des créneaux, expiration des réservations, récurrence de l\'accompagnement et essais.';

  @override
  String get wfCfgAppointmentTypes => 'Types de rendez-vous';

  @override
  String get wfCfgAppointmentTypesHint =>
      'Démo, réunion, formation, accompagnement : durée par défaut et couleur du calendrier.';

  @override
  String get wfCfgHolidays => 'Jours fériés';

  @override
  String get wfCfgHolidaysHint => 'Aucun créneau n\'est proposé ces jours-là.';

  @override
  String get wfCfgInterventionTypes => 'Types d\'intervention';

  @override
  String get wfCfgInterventionTypesHint =>
      'Bug, question, remarque, correctif, version… et qui peut les créer.';

  @override
  String get wfCfgInterventionStatuses => 'Statuts d\'intervention';

  @override
  String get wfCfgInterventionStatusesHint =>
      'Libellé interne et libellé vu par le client.';

  @override
  String get wfCfgTransitions => 'Transitions de statut';

  @override
  String get wfCfgTransitionsHint =>
      'Quels statuts peuvent suivre quels statuts, et si le client peut déclencher le changement.';

  @override
  String get wfCfgPriorities => 'Priorités';

  @override
  String get wfCfgPrioritiesHint =>
      'Couleur et délai de réponse cible ; l\'ordre sert au tri.';

  @override
  String get wfCfgTemplates => 'Modèles de message';

  @override
  String get wfCfgTemplatesHint =>
      'Textes WhatsApp préparés pour les formations (jamais envoyés automatiquement).';

  @override
  String get wfCfgProductResources => 'Supports produit';

  @override
  String get wfCfgProductResourcesHint =>
      'Liens de formation et de documentation, avec visibilité client.';

  @override
  String get wfProductResources => 'Supports et liens du produit';

  @override
  String wfProductResourcesTitle(Object name) {
    return 'Supports : $name';
  }

  @override
  String get wfNoResources => 'Aucun support pour ce produit';

  @override
  String get wfNoConfigRows => 'Aucune entrée';

  @override
  String get wfNoConfigRowsHint =>
      'Ajoutez la première entrée. Elle pourra être désactivée, jamais supprimée.';

  @override
  String get wfDeactivateTitle => 'Désactiver cette entrée ?';

  @override
  String get wfDeactivateBody =>
      'Elle n\'est plus proposée, mais l\'historique qui la référence est conservé.';

  @override
  String get wfDeactivated => 'Entrée désactivée.';

  @override
  String get wfReactivated => 'Entrée réactivée.';

  @override
  String get wfDurationMinutes => 'Durée (min)';

  @override
  String get wfCustomerBookable => 'Réservable par le client';

  @override
  String get wfCustomerLabel => 'Libellé client';

  @override
  String get wfCustomerLabelHint => 'Ce que le client voit pour ce statut.';

  @override
  String get wfIsInitial => 'Statut initial';

  @override
  String get wfIsClosed => 'Clôture l\'intervention';

  @override
  String get wfAwaitsCustomer => 'Attend le client';

  @override
  String get wfIsDelivered => 'Livré au client';

  @override
  String get wfFromStatus => 'Depuis le statut';

  @override
  String get wfToStatus => 'Vers le statut';

  @override
  String get wfCustomerAllowed => 'Déclenchable par le client';

  @override
  String get wfResponseTarget => 'Délai de réponse (h)';

  @override
  String get wfResponseTargetHint => 'Laisser vide pour aucun délai.';

  @override
  String get wfTemplate => 'Modèle';

  @override
  String get wfTemplateTrainingFirst => 'Première formation';

  @override
  String get wfTemplateTrainingReview => 'Suivi de formation';

  @override
  String get wfTemplateBody => 'Texte du message';

  @override
  String get wfTemplatePlaceholders =>
      'Variables disponibles (à écrire entre accolades) : contact, product, date, start, end, resource_url';

  @override
  String get wfKindVideo => 'Vidéo';

  @override
  String get wfKindLink => 'Lien';

  @override
  String get wfCustomerVisible => 'Visible par le client';

  @override
  String get wfTrainingMaterial => 'Support de formation';

  @override
  String get wfWorkingDays => 'Jours ouvrés';

  @override
  String get wfPickWorkingDay => 'Choisissez au moins un jour.';

  @override
  String get wfWorkStart => 'Début de journée';

  @override
  String get wfWorkEnd => 'Fin de journée';

  @override
  String get wfTimeInvalid => 'Format HH:mm attendu.';

  @override
  String get wfSlotMinutes => 'Durée d\'un créneau (min)';

  @override
  String get wfHoldExpiryMinutes => 'Expiration d\'une réservation (min)';

  @override
  String get wfHoldExpiryHint =>
      'Au-delà, le créneau est libéré automatiquement.';

  @override
  String get wfBookingHorizon => 'Réservation jusqu\'à (jours)';

  @override
  String get wfMinNotice => 'Préavis minimum (heures)';

  @override
  String get wfDemoCapacity => 'Démos en parallèle';

  @override
  String get wfDemoCapacityHint => 'Nombre de démos simultanées.';

  @override
  String get wfAccompanimentOccurrences => 'Séances d\'accompagnement (défaut)';

  @override
  String get wfAccompanimentInterval =>
      'Intervalle d\'accompagnement (jours, défaut)';

  @override
  String get wfWhatsappCountryCode => 'Indicatif pays WhatsApp';

  @override
  String get wfWhatsappCountryCodeHint =>
      'Chiffres seulement, ex. 213. Sert à compléter les numéros commençant par 0.';

  @override
  String get wfCountryCodeInvalid => '1 à 4 chiffres.';

  @override
  String get ivSupport => 'Support';

  @override
  String get ivSystem => 'Système';

  @override
  String ivEventStatusFull(Object actor, Object from, Object time, Object to) {
    return 'Statut modifié de $from à $to par $actor à $time';
  }

  @override
  String ivEventStatusTo(Object actor, Object time, Object to) {
    return 'Statut modifié en $to par $actor à $time';
  }

  @override
  String ivEventReopened(Object actor, Object time) {
    return 'Intervention rouverte par $actor à $time';
  }

  @override
  String get ivAttachFiles => 'Joindre des fichiers';

  @override
  String ivAttachLimit(Object max) {
    return '$max fichiers maximum par message.';
  }

  @override
  String get ivRemoveFile => 'Retirer ce fichier';

  @override
  String get ivDownload => 'Télécharger';

  @override
  String get ivPreview => 'Aperçu';

  @override
  String get ivViewPdf => 'Ouvrir le PDF';

  @override
  String ivFileSaved(Object path) {
    return 'Fichier enregistré : $path';
  }

  @override
  String get ivImageError => 'Impossible d\'afficher l\'image.';

  @override
  String get ivClosedBanner =>
      'Cette intervention est clôturée. Les nouvelles réponses sont désactivées.';

  @override
  String get ivReopen => 'Rouvrir l\'intervention';

  @override
  String get ivReopenBody =>
      'Les réponses seront de nouveau possibles pour vous et pour le client.';

  @override
  String get ivReopenNote => 'Note (facultative)';

  @override
  String get ivReopened => 'Intervention rouverte.';

  @override
  String get prDemoLink => 'Lien de la démo';

  @override
  String get prDemoLinkHint => 'Lien fixe défini sur le produit.';

  @override
  String get prNoDemoLink => 'Ce produit n\'a pas de lien de démo.';

  @override
  String get prNoDemoProducts => 'Aucun produit avec démo pour ce client.';

  @override
  String get prNoLinkedProducts => 'Aucun produit associé à ce client.';

  @override
  String get prFilteredByCustomer =>
      'Produits associés à ce client uniquement.';

  @override
  String get prCustomersFilteredByProduct =>
      'Clients liés à ce produit uniquement.';

  @override
  String prPackReplaced(Object name) {
    return '« $name » a été désélectionné : un seul produit par pack.';
  }

  @override
  String get prPackHint => 'Un seul produit par pack.';

  @override
  String get navReleases => 'Mises à jour produits';

  @override
  String get rlSubtitle =>
      'Versions publiées de vos produits, fichiers d\'installation et audience.';

  @override
  String get rlNew => 'Nouvelle version';

  @override
  String get rlEdit => 'Modifier la version';

  @override
  String get rlVersion => 'Numéro de version';

  @override
  String get rlVersionRequired => 'Numéro de version obligatoire.';

  @override
  String get rlDate => 'Date de sortie';

  @override
  String get rlChangelog => 'Notes de version';

  @override
  String get rlAudience => 'Audience';

  @override
  String get rlAudienceAll => 'Tous les clients';

  @override
  String get rlAudienceOwned => 'Clients propriétaires du produit';

  @override
  String get rlAudienceSpecific => 'Clients précis';

  @override
  String get rlCustomers => 'Clients concernés';

  @override
  String get rlCustomersRequired => 'Choisissez au moins un client.';

  @override
  String get rlInstaller => 'Fichier d\'installation';

  @override
  String get rlInstallerHint => '.exe, .zip ou .rar';

  @override
  String get rlPickInstaller => 'Choisir un fichier';

  @override
  String get rlRemoveInstaller => 'Retirer l\'installateur';

  @override
  String get rlExternalUrl => 'Lien de téléchargement externe';

  @override
  String get rlPublished => 'Publiée';

  @override
  String get rlDraft => 'Brouillon';

  @override
  String get rlNoReleases => 'Aucune version';

  @override
  String get rlNoReleasesHint => 'Créez la première version d\'un produit.';

  @override
  String get rlDeleteTitle => 'Supprimer cette version ?';

  @override
  String get rlDeleteBody => 'Les clients ne la verront plus.';

  @override
  String get rlSaved => 'Version enregistrée.';

  @override
  String get rlDeleted => 'Version supprimée.';

  @override
  String get rlUploading => 'Envoi du fichier…';

  @override
  String get rlAllProducts => 'Tous les produits';

  @override
  String get helpTooltip => 'Aide';

  @override
  String get helpExample => 'Exemple';

  @override
  String get helpFields => 'Champs';

  @override
  String get helpUnavailable => 'Aide indisponible pour cette section.';

  @override
  String get wfFixedTypesNote =>
      'Les 4 types (Démo, Réunion, Formation, Accompagnement) sont fixes. Vous pouvez seulement ajuster la durée, la couleur et la réservation en ligne.';
}
