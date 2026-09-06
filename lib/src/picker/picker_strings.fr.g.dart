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

String _ticketCountFr(int count) =>
    count == 1 ? '$count billet' : '$count billets';

String _findBestSeatsFr(int count) => count == 1
    ? 'Trouver $count meilleure place'
    : 'Trouver $count meilleures places';

String _reselectSeatsFr(int count) =>
    count == 1 ? 'La sélectionner à nouveau' : 'Les sélectionner à nouveau';

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
  hideLimitedView: 'Masquer les places à visibilité réduite',
  colorblindSafe: 'Couleurs adaptées au daltonisme',
  notAvailable: 'Non disponible',
  restrictedView: 'Visibilité réduite',
  obstructedView: 'Vue obstruée',
  premiumSeat: 'Place premium',
  continueWord: 'Continuer',
  accessNeeds: <String, String>{
    'wheelchair': 'Emplacement fauteuil roulant',
    'companion': 'Place d’accompagnant',
    'semi-ambulatory': 'Mobilité réduite',
    'designated-aisle': 'Place côté allée pour transfert',
    'step-free': 'Place accessible de plain-pied',
    'hearing': 'Aide à l’écoute',
    'cart': 'Sous-titrage en direct (CART)',
    'sign-language': 'Vue sur la langue des signes',
    'low-vision': 'Places pour personnes aveugles ou malvoyantes',
    'sensory-friendly': 'Places calmes et sensoriellement adaptées',
    'plus-size': 'Siège grande taille',
    'lift-armrest': 'Accoudoir relevable',
  },
  seatsLeft: _seatsLeftFr,
  moreCount: _moreCountFr,
  addMinutes: _addMinutesFr,
  fromPrice: _fromPriceFr,
  sightline: _sightlineFr,
  ticketCount: _ticketCountFr,
  findBestSeats: _findBestSeatsFr,
  reselectSeats: _reselectSeatsFr,
  continueWithTotal: _continueWithTotalFr,
);
