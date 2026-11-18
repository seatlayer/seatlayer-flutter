// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftFr(int count) => '$count libres';

String _moreCountFr(int count) => '+$count de plus';

String _addMinutesFr(int minutes) => '+$minutes min';

String _fromPriceFr(String money) => 'Dès $money';

String _sightlineFr(String metres) => '≈ $metres m de la scène';

String _secureMoreAndCheckoutFr(int count) =>
    'Sécuriser $count de plus et payer';

String _accessFreeCountFr(int count) => '$count libres';

String _seatJustTakenByAnotherFr(String label) =>
    'La place $label vient d’être prise par un autre acheteur.';

String _peekSecuredFr(int count, String total) =>
    '✓ $count réservées · $total. Vous ne serez pas encore débité';

String _venueMapFr(String venue) => 'Plan de salle de $venue';

String _accessibleStepFr(int index, int total) => '$index sur $total';

String _chooseMinMaxGuestsFr(int min, int max) =>
    'Choisissez entre $min et $max invités.';

String _chooseMoreFr(int count) => 'Choisissez-en encore $count';

String _seatsHeldForNeedMoreTimeFr(String time) =>
    'Vos places sont réservées pendant $time. Besoin de plus de temps ?';

String _accessNeedWithCountFr(String need, int count) => '$need · $count';

String _ticketCountFr(int count) => switch (pickerPluralCategory('fr', count)) {
  PickerPluralCategory.one => '$count billet',
  PickerPluralCategory.many => '$count billets',
  _ => '$count billets',
};

String _findBestSeatsFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => 'Trouver $count meilleure place',
      PickerPluralCategory.many => 'Trouver $count meilleures places',
      _ => 'Trouver $count meilleures places',
    };

String _reselectSeatsFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => 'La sélectionner à nouveau',
      PickerPluralCategory.many => 'Les sélectionner à nouveau',
      _ => 'Les sélectionner à nouveau',
    };

String _seatsFreeFr(int count) => switch (pickerPluralCategory('fr', count)) {
  PickerPluralCategory.one => '$count place',
  PickerPluralCategory.many => '$count places',
  _ => '$count places',
};

String _seatsLeftInSectionFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count siège restant',
      PickerPluralCategory.many => '$count sièges restants',
      _ => '$count sièges restants',
    };

String _holdLapsedStillFreeFr(int count) => switch (pickerPluralCategory(
  'fr',
  count,
)) {
  PickerPluralCategory.one =>
    'Votre réservation a expiré pendant votre absence. Cette place est toujours libre.',
  PickerPluralCategory.many =>
    'Votre réservation a expiré pendant votre absence. Ces places sont toujours libres.',
  _ =>
    'Votre réservation a expiré pendant votre absence. Ces places sont toujours libres.',
};

String _holdLapsedSomeTakenFr(int count) => switch (pickerPluralCategory(
  'fr',
  count,
)) {
  PickerPluralCategory.one =>
    'Votre réservation a expiré pendant votre absence et $count de ces places a été prise. Les autres sont toujours libres.',
  PickerPluralCategory.many =>
    'Votre réservation a expiré pendant votre absence et $count de ces places ont été prises. Les autres sont toujours libres.',
  _ =>
    'Votre réservation a expiré pendant votre absence et $count de ces places ont été prises. Les autres sont toujours libres.',
};

String _holdLapsedAllTakenFr(int count) => switch (pickerPluralCategory(
  'fr',
  count,
)) {
  PickerPluralCategory.one =>
    'Votre réservation a expiré pendant votre absence et cette place a été prise.',
  PickerPluralCategory.many =>
    'Votre réservation a expiré pendant votre absence et ces places ont été prises.',
  _ =>
    'Votre réservation a expiré pendant votre absence et ces places ont été prises.',
};

String _accessibleSectionsFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count section',
      PickerPluralCategory.many => '$count de sections',
      _ => '$count sections',
    };

String _placesAvailableFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count place disponible actuellement',
      PickerPluralCategory.many => '$count de places disponibles actuellement',
      _ => '$count places disponibles actuellement',
    };

String _removeTicketsFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => 'Retirer $count billet',
      PickerPluralCategory.many => 'Retirer $count de billets',
      _ => 'Retirer $count billets',
    };

String _holdMinutesLeftFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count minute restante',
      PickerPluralCategory.many => '$count de minutes restantes',
      _ => '$count minutes restantes',
    };

String _holdSecondsLeftFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count seconde restante',
      PickerPluralCategory.many => '$count de secondes restantes',
      _ => '$count secondes restantes',
    };

String _holdLapsedBodyFr(int count) => switch (pickerPluralCategory(
  'fr',
  count,
)) {
  PickerPluralCategory.one => 'Elles ont été réservées pendant $count minute.',
  PickerPluralCategory.many =>
    'Elles ont été réservées pendant $count de minutes.',
  _ => 'Elles ont été réservées pendant $count minutes.',
};

String _seatsNotRecoveredFr(int count) => switch (pickerPluralCategory(
  'fr',
  count,
)) {
  PickerPluralCategory.one => '$count place n’a pas pu être récupérée',
  PickerPluralCategory.many => '$count de places n’ont pas pu être récupérées',
  _ => '$count places n’ont pas pu être récupérées',
};

String _activeFiltersFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count filtre',
      PickerPluralCategory.many => '$count de filtres',
      _ => '$count filtres',
    };

String _accessibilityFiltersActiveFr(int count) =>
    switch (pickerPluralCategory('fr', count)) {
      PickerPluralCategory.one => '$count filtre d’accessibilité actif',
      PickerPluralCategory.many => '$count de filtres d’accessibilité actifs',
      _ => '$count filtres d’accessibilité actifs',
    };

String _onlyLeftFr(int count) => switch (pickerPluralCategory('fr', count)) {
  PickerPluralCategory.one => '$count siège restant',
  PickerPluralCategory.many => '$count sièges restants',
  _ => '$count sièges restants',
};

String _continueWithTotalFr(String money) => 'Continuer \u00b7 $money';

/// The `fr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsFr = SeatLayerPickerStrings(
  close: 'Fermer',
  overview: 'Lieu',
  backToVenue: 'Retour au lieu',
  cancel: 'Annuler',
  select: 'Sélectionner',
  removeSeat: 'Retirer place',
  viewFromHere: 'Vue depuis ici',
  openVenue360: 'Ouvrir la vue 360° du lieu',
  recentre: 'Recentrer sur la scène',
  viewFromYourSeat: 'vue depuis votre place',
  emptyTrayHint:
      'Touchez une place sur le plan, ou laissez-nous choisir les meilleures disponibles pour vous.',
  anyTicketType: 'Tout type de billet',
  anyVenueZone: 'Toute zone du lieu',
  bestSeats: 'Meilleures places',
  showLess: 'Afficher moins',
  undo: 'Annuler',
  holdAndCheckout: 'Réserver les places et payer',
  poweredBy: 'Propulsé par SeatLayer',
  testMode: 'Mode test',
  accessibility: 'Options d’accessibilité et de couleur',
  accessibilityTitle: 'Options d’accessibilité et de couleur',
  fitVenue: 'Afficher tout le lieu',
  fitWholeVenue: 'Afficher tout le lieu',
  loading: 'Chargement du plan de salle…',
  errorMessage: 'Le plan de salle n’a pas pu se charger',
  retry: 'Réessayer',
  accessRefresh: 'Actualiser',
  noSeatsSelected: 'Aucune place sélectionnée',
  findBestSeatsCta: 'Trouver les meilleures places',
  organizerNote: 'Note de l’organisateur',
  accessiblePhysicalSeat: 'Siège physique accessible',
  emptyWheelchairSpace: 'Emplacement vide pour fauteuil roulant',
  findSeatsTogether: 'Trouver des places côte à côte',
  aboutBestSeats: 'À propos des places côte à côte',
  closestGroupChosenInstantly:
      'Groupe disponible le plus proche, choisi instantanément.',
  hideLimitedView: 'Masquer les places à visibilité réduite',
  colorblindSafe: 'Couleurs adaptées au daltonisme',
  notAvailable: 'Non disponible',
  viewGroupTitle: 'VUE',
  restrictedView: 'Visibilité réduite',
  obstructedView: 'Vue obstruée',
  premiumSeat: 'Place premium',
  continueWord: 'Continuer',
  allFloors: 'Tous les étages',
  previousSection: 'Section précédente',
  nextSection: 'Section suivante',
  addSeat: 'Ajouter place',
  added: 'Ajouté',
  sectionWord: 'Section',
  rowWord: 'Rangée',
  seatWord: 'Place',
  seeItIn3D: 'Voir en 3D',
  viewFromThisSeat: 'Vue depuis cette place',
  allPrices: 'Tous les prix',
  ticketPrices: 'Prix des billets',
  yourSeats: 'Vos places',
  ticketType: 'Type de billet',
  tierCompanionGuidance: 'Nécessite la place fauteuil roulant adjacente',
  findingBestSeats: 'Recherche des meilleures places…',
  findSeats: 'Trouver places',
  expandCart: 'Ouvrir le panneau des billets',
  collapseCart: 'Réduire le panneau des billets',
  continueToCheckout: 'Continuer vers le paiement',
  secureMore: 'Sécuriser plus',
  selectSeats: 'Sélectionner des places',
  pickYourSeats: 'Choisissez vos places',
  salesClosedPill: 'Les ventes sont closes',
  salesClosedCta: 'Ventes closes',
  confirmOrCancelSeat: 'Confirmer ou annuler cette place',
  securingSeats: 'Réservation de vos places…',
  openingCheckout: 'Ouverture du paiement sécurisé…',
  testModeExplained:
      'Les réservations ici ne sont pas réelles et aucune carte n\'est débitée',
  displayOptions: 'Options d\'affichage',
  companionSeatsNote:
      'Les places d’accompagnant voisines restent sélectionnables',
  zoomIn: 'Zoomer',
  zoomOut: 'Dézoomer',
  rotateVenue: 'Faites glisser pour faire pivoter le lieu',
  moveVenue: 'Faites glisser pour déplacer le lieu',
  mapView: 'Plan',
  flat2dMap: 'Plan 2D à plat',
  interactive3dVenueView: 'Vue 3D interactive du lieu',
  venueView: 'Vue du lieu',
  holdLapsedTitle: 'Vos places ont été libérées',
  salesClosed: 'Les ventes sont closes',
  salesClosedCopy: 'La vente de billets pour cet événement est terminée.',
  salesClosedToast: 'Les ventes sont closes pour cet événement.',
  soldOutEyebrow: 'Cet événement',
  soldOutTitle: 'Complet',
  soldOutCopy:
      'Aucune place réservée n’est actuellement disponible pour cet événement.',
  holdExpired:
      'Votre réservation a expiré. Les sièges ont été libérés. Sélectionnez à nouveau.',
  addingEllipsis: 'Ajout en cours…',
  moreTimeAdded:
      'Du temps supplémentaire a été ajouté. Vos places restent réservées.',
  couldNotAddMoreTime:
      'Impossible d’ajouter du temps. Veuillez passer au paiement maintenant.',
  seatsJustTaken:
      'Une ou plusieurs places viennent d’être prises. Veuillez choisir à nouveau.',
  allSetTitle: 'Tout est prêt',
  confirmedAndOnWay: 'confirmés. Une confirmation arrive.',
  backToMap: 'Retour au plan',
  mapDidNotLoad: 'Le plan de salle n’a pas pu se charger',
  checkConnection: 'Vérifiez votre connexion et réessayez.',
  accessPausedTitle: 'Ces places sont actuellement en attente',
  accessPausedCopy:
      'L’organisateur a mis cette sélection en pause. Réessayez dans quelques minutes.',
  accessRevokedTitle: 'Ce lien d’accès n’est plus actif',
  accessRevokedCopy:
      'Demandez à la personne qui vous a envoyé ce lien de vous en fournir un nouveau pour continuer à réserver ces places.',
  accessUnverifiedTitle: 'Nous n’avons pas pu vérifier votre accès',
  accessUnverifiedCopy:
      'Vous pouvez toujours réserver tout ce qui est indiqué comme disponible. Contactez la personne qui vous a envoyé ce lien pour accéder au reste.',
  generalAdmission: 'Entrée générale',
  numberOfGuests: 'Nombre d’invités',
  chooseGuestsCopy:
      'Choisissez combien d’invités seront assis ensemble. Cette table est réservée exclusivement à votre groupe.',
  fewerGuests: 'Moins d’invités',
  moreGuests: 'Plus d’invités',
  selectTable: 'Sélectionner la table',
  updateTable: 'Mettre à jour la table',
  removeWord: 'Retirer',
  floorWord: 'Étage',
  totalWord: 'Total',
  adjustSelection: 'Ajustez la sélection des sièges',
  chooseSeats: 'Choisissez vos places',
  chooseTickets: 'Choisissez vos billets',
  placeWord: 'PLACE',
  ticketWord: 'Billet',
  passport: 'Fiche de la place',
  venue3D: '3D',
  venueZone: 'Zone du lieu',
  venueMapHint:
      'Les places se choisissent avec les commandes autour du plan : la barre des prix au-dessus, les commandes des sections en dessous et le panneau des billets en bas.',
  previousSeat: 'Place précédente',
  nextSeat: 'Place suivante',
  orbitMode: 'Faire pivoter le lieu',
  panMode: 'Déplacer le lieu',
  openInteractive3dVenue: 'Ouvrir le lieu en 3D interactive',
  showSeatsFor: 'AFFICHER LES PLACES POUR',
  accessJumpFirstSection: 'Accéder à la première section',
  accessJumpNextSection: 'Accéder à la section suivante',
  fewerTickets: 'Moins de billets',
  moreTickets: 'Plus de billets',
  addTickets: 'Ajouter des billets',
  noSelectableSeats:
      'Aucune place sélectionnable n’est disponible pour le moment.',
  confirmYourTickets: 'Confirmez vos billets',
  seatsSecuredOpeningCheckout: 'Places réservées. Ouverture du paiement…',
  holdInCheckoutTitle: 'Vos places sont déjà en cours de paiement',
  holdInCheckoutBody:
      'Terminez le paiement pour les garder. Pour choisir d’autres places, libérez d’abord celles-ci — elles sont remises en vente.',
  releaseAndChangeSeats: 'Libérer et changer de places',
  holdAlreadyHeldTitle: 'Vos places sont déjà réservées',
  holdAlreadyHeldBody: 'Continuez vers le paiement pour les garder.',
  accessExpiredTitle: 'Votre session de sélection a expiré',
  accessExpiredCopy:
      'Rechargez le plan de salle pour continuer. Les places déjà dans votre panier restent réservées jusqu’à la fin du minuteur.',
  dismissError: 'Fermer le message d’erreur',
  testModeLong: 'Mode test · rien n’est réservé',
  seatRemoved: 'Billet retiré',
  reloadSeatMap: 'Recharger le plan de salle',
  accessNeeds: <String, String>{
    'wheelchair': 'Emplacement fauteuil roulant',
    'companion': 'Place d’accompagnant',
    'semi-ambulatory': 'Mobilité réduite',
    'designated-aisle': 'Allée / transfert',
    'step-free': 'De plain-pied',
    'hearing': 'Aide à l’écoute',
    'cart': 'Sous-titrage en direct',
    'sign-language': 'Langue des signes',
    'low-vision': 'Malvoyants',
    'sensory-friendly': 'Sensoriellement adaptée',
    'plus-size': 'Grande taille',
    'lift-armrest': 'Accoudoir relevable',
  },
  seatsLeft: _seatsLeftFr,
  moreCount: _moreCountFr,
  addMinutes: _addMinutesFr,
  fromPrice: _fromPriceFr,
  sightline: _sightlineFr,
  secureMoreAndCheckout: _secureMoreAndCheckoutFr,
  accessFreeCount: _accessFreeCountFr,
  seatJustTakenByAnother: _seatJustTakenByAnotherFr,
  peekSecured: _peekSecuredFr,
  venueMap: _venueMapFr,
  accessibleStep: _accessibleStepFr,
  chooseMinMaxGuests: _chooseMinMaxGuestsFr,
  chooseMore: _chooseMoreFr,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeFr,
  accessNeedWithCount: _accessNeedWithCountFr,
  ticketCount: _ticketCountFr,
  findBestSeats: _findBestSeatsFr,
  reselectSeats: _reselectSeatsFr,
  seatsFree: _seatsFreeFr,
  seatsLeftInSection: _seatsLeftInSectionFr,
  holdLapsedStillFree: _holdLapsedStillFreeFr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenFr,
  holdLapsedAllTaken: _holdLapsedAllTakenFr,
  accessibleSections: _accessibleSectionsFr,
  placesAvailable: _placesAvailableFr,
  removeTickets: _removeTicketsFr,
  holdMinutesLeft: _holdMinutesLeftFr,
  holdSecondsLeft: _holdSecondsLeftFr,
  holdLapsedBody: _holdLapsedBodyFr,
  seatsNotRecovered: _seatsNotRecoveredFr,
  activeFilters: _activeFiltersFr,
  accessibilityFiltersActive: _accessibilityFiltersActiveFr,
  onlyLeft: _onlyLeftFr,
  continueWithTotal: _continueWithTotalFr,
);
