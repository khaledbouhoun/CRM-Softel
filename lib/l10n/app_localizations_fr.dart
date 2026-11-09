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
  String countProspects(int count) {
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
  String countActivities(int count) {
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
  String activitiesCountSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activités',
      one: '$count activité',
    );
    return '$_temp0 — appels, rendez-vous, messages et notes';
  }

  @override
  String pipelineCountSubtitle(int count) {
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
  String deactivateStageProspects(int count) {
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
}
