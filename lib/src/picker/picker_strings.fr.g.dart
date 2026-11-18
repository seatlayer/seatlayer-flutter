// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

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

String _ticketCountFr(int count) =>
    count == 1 ? '$count billet' : '$count billets';

String _findBestSeatsFr(int count) => count == 1
    ? 'Trouver $count meilleure place'
    : 'Trouver $count meilleures places';

String _reselectSeatsFr(int count) =>
    count == 1 ? 'La sélectionner à nouveau' : 'Les sélectionner à nouveau';

String _seatsFreeFr(int count) => count == 1 ? '$count place' : '$count places';

String _seatsLeftInSectionFr(int count) =>
    count == 1 ? '$count siège restant' : '$count sièges restants';

String _holdLapsedStillFreeFr(int count) => count == 1
    ? 'Votre réservation a expiré pendant votre absence. Cette place est toujours libre.'
    : 'Votre réservation a expiré pendant votre absence. Ces places sont toujours libres.';

String _holdLapsedSomeTakenFr(int count) => count == 1
    ? 'Votre réservation a expiré pendant votre absence et $count de ces places a été prise. Les autres sont toujours libres.'
    : 'Votre réservation a expiré pendant votre absence et $count de ces places ont été prises. Les autres sont toujours libres.';

String _holdLapsedAllTakenFr(int count) => count == 1
    ? 'Votre réservation a expiré pendant votre absence et cette place a été prise.'
    : 'Votre réservation a expiré pendant votre absence et ces places ont été prises.';

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
  testMode: 'MODE TEST',
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
  ticketCount: _ticketCountFr,
  findBestSeats: _findBestSeatsFr,
  reselectSeats: _reselectSeatsFr,
  seatsFree: _seatsFreeFr,
  seatsLeftInSection: _seatsLeftInSectionFr,
  holdLapsedStillFree: _holdLapsedStillFreeFr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenFr,
  holdLapsedAllTaken: _holdLapsedAllTakenFr,
  continueWithTotal: _continueWithTotalFr,
);
