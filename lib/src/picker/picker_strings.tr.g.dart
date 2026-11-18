// GENERATED — do not edit.
//
// Source: design/locale_strings.json (tr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftTr(int count) => '$count kaldı';

String _moreCountTr(int count) => '+$count daha';

String _addMinutesTr(int minutes) => '+$minutes dk';

String _fromPriceTr(String money) => '$money den itibaren';

String _sightlineTr(String metres) => 'Sahneye ≈ $metres m';

String _secureMoreAndCheckoutTr(int count) => '$count tane daha al ve öde';

String _accessFreeCountTr(int count) => '$count boş';

String _seatJustTakenByAnotherTr(String label) =>
    '$label koltuğunu az önce başka bir alıcı aldı.';

String _peekSecuredTr(int count, String total) =>
    '✓ $count güvenceye alındı · $total. Henüz ücret alınmayacak';

String _ticketCountTr(int count) =>
    count == 1 ? '$count bilet' : '$count bilet';

String _findBestSeatsTr(int count) =>
    count == 1 ? '$count en iyi koltuğu bul' : '$count en iyi koltuğu bul';

String _reselectSeatsTr(int count) =>
    count == 1 ? 'Onu tekrar seç' : 'Onları tekrar seç';

String _seatsFreeTr(int count) =>
    count == 1 ? '$count koltuk' : '$count koltuk';

String _seatsLeftInSectionTr(int count) =>
    count == 1 ? '$count koltuk kaldı' : '$count koltuk kaldı';

String _holdLapsedStillFreeTr(int count) => count == 1
    ? 'Siz yokken rezervasyonunuz sona erdi. O koltuk hâlâ boş.'
    : 'Siz yokken rezervasyonunuz sona erdi. O koltuklar hâlâ boş.';

String _holdLapsedSomeTakenTr(int count) => count == 1
    ? 'Siz yokken rezervasyonunuz sona erdi ve o koltuklardan $count tanesi alındı. Geri kalanlar hâlâ boş.'
    : 'Siz yokken rezervasyonunuz sona erdi ve o koltuklardan $count tanesi alındı. Geri kalanlar hâlâ boş.';

String _holdLapsedAllTakenTr(int count) => count == 1
    ? 'Siz yokken rezervasyonunuz sona erdi ve o koltuk alındı.'
    : 'Siz yokken rezervasyonunuz sona erdi ve o koltuklar alındı.';

String _continueWithTotalTr(String money) => 'Devam \u00b7 $money';

/// The `tr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsTr = SeatLayerPickerStrings(
  close: 'Kapat',
  overview: 'Mekân',
  backToVenue: 'Mekana dön',
  cancel: 'İptal',
  select: 'Seç',
  removeSeat: 'Koltuğu kaldır',
  viewFromHere: 'Buradan manzara',
  openVenue360: 'Mekanı 360° aç',
  recentre: 'Sahneyi yeniden ortala',
  viewFromYourSeat: 'koltuğunuzdan görünüm',
  emptyTrayHint:
      'Plandan bir koltuğa dokunun ya da en iyi müsait koltukları sizin için biz seçelim.',
  anyTicketType: 'Herhangi bir bilet türü',
  anyVenueZone: 'Herhangi bir mekan bölgesi',
  bestSeats: 'En iyi koltuklar',
  showLess: 'Daha az göster',
  undo: 'Geri al',
  holdAndCheckout: 'Koltukları tut ve öde',
  poweredBy: 'SeatLayer tarafından sağlanır',
  testMode: 'TEST MODU',
  accessibility: 'Erişilebilirlik ve renk seçenekleri',
  accessibilityTitle: 'Erişilebilirlik ve renk seçenekleri',
  fitVenue: 'Tüm mekânı göster',
  fitWholeVenue: 'Tüm mekânı göster',
  loading: 'Koltuk planı yükleniyor…',
  errorMessage: 'Koltuk planı yüklenemedi',
  retry: 'Tekrar dene',
  accessRefresh: 'Yenile',
  noSeatsSelected: 'Koltuk seçilmedi',
  findBestSeatsCta: 'En iyi koltukları bul',
  organizerNote: 'Organizatör notu',
  accessiblePhysicalSeat: 'Erişilebilir fiziksel koltuk',
  emptyWheelchairSpace: 'Boş tekerlekli sandalye yeri',
  findSeatsTogether: 'Yan yana koltuk bul',
  aboutBestSeats: 'Yan yana koltuk bulma hakkında',
  closestGroupChosenInstantly: 'En yakın müsait grup, anında seçildi.',
  hideLimitedView: 'Kısıtlı manzaralı koltukları gizle',
  colorblindSafe: 'Renk körlüğüne uygun renkler',
  notAvailable: 'Müsait değil',
  restrictedView: 'Kısıtlı manzara',
  obstructedView: 'Engelli manzara',
  premiumSeat: 'Premium koltuk',
  continueWord: 'Devam',
  allFloors: 'Tüm katlar',
  previousSection: 'Önceki blok',
  nextSection: 'Sonraki blok',
  addSeat: 'Koltuk ekle',
  added: 'Eklendi',
  sectionWord: 'Blok',
  rowWord: 'Sıra',
  seatWord: 'Koltuk',
  seeItIn3D: '3B olarak gör',
  viewFromThisSeat: 'Bu koltuktan manzara',
  allPrices: 'Tüm fiyatlar',
  ticketType: 'Bilet türü',
  tierCompanionGuidance: 'Bitişikteki tekerlekli sandalye yerini gerektirir',
  findingBestSeats: 'En iyi koltuklar aranıyor…',
  findSeats: 'Koltuk bul',
  expandCart: 'Bilet panelini aç',
  collapseCart: 'Bilet panelini daralt',
  continueToCheckout: 'Ödemeye devam et',
  secureMore: 'Daha fazla al',
  selectSeats: 'Koltukları seç',
  pickYourSeats: 'Koltuklarınızı seçin',
  salesClosedPill: 'Satışlar kapalı',
  salesClosedCta: 'Satışlar kapalı',
  confirmOrCancelSeat: 'Bu koltuğu onaylayın veya iptal edin',
  securingSeats: 'Koltuklarınız güvenceye alınıyor…',
  openingCheckout: 'Güvenli ödeme açılıyor…',
  testModeExplained:
      'Buradaki rezervasyonlar gerçek değildir ve herhangi bir karttan ücret alınmayacak',
  displayOptions: 'Görünüm seçenekleri',
  companionSeatsNote: 'Yanlarındaki refakatçi yerleri seçilebilir kalır',
  zoomIn: 'Yakınlaştır',
  zoomOut: 'Uzaklaştır',
  rotateVenue: 'Mekânı döndürmek için sürükleyin',
  moveVenue: 'Mekânı taşımak için sürükleyin',
  mapView: 'Plan',
  flat2dMap: 'Düz 2B plan',
  interactive3dVenueView: 'Etkileşimli 3B mekan görünümü',
  venueView: 'Mekan görünümü',
  holdLapsedTitle: 'Koltuklarınız serbest bırakıldı',
  salesClosed: 'Satışlar kapalı',
  salesClosedCopy: 'Bu etkinliğin bilet satışı sona erdi.',
  salesClosedToast: 'Bu etkinlik için satışlar kapalı.',
  soldOutEyebrow: 'Bu etkinlik',
  soldOutTitle: 'Tükendi',
  soldOutCopy: 'Bu etkinlik için şu anda müsait numaralı koltuk yok.',
  holdExpired:
      'Rezervasyonunuzun süresi doldu. Koltuklar serbest bırakıldı. Tekrar seçin.',
  addingEllipsis: 'Ekleniyor…',
  moreTimeAdded: 'Ek süre verildi. Koltuklarınız hâlâ rezerve.',
  couldNotAddMoreTime: 'Ek süre verilemedi. Lütfen şimdi ödemeye geçin.',
  seatsJustTaken:
      'Bir veya daha fazla koltuk az önce alındı. Lütfen tekrar seçin.',
  allSetTitle: 'Her şey hazır',
  confirmedAndOnWay: 'onaylandı. Onay e-postası yolda.',
  backToMap: 'Plana dön',
  mapDidNotLoad: 'Koltuk planı yüklenemedi',
  checkConnection: 'Bağlantınızı kontrol edip tekrar deneyin.',
  accessPausedTitle: 'Bu koltuklar şu anda beklemede',
  accessPausedCopy:
      'Organizatör bu seçimi duraklattı. Birkaç dakika sonra tekrar deneyin.',
  accessRevokedTitle: 'Bu erişim bağlantısı artık geçerli değil',
  accessRevokedCopy:
      'Bu koltukları almaya devam etmek için sizi buraya yönlendiren kişiden yeni bir bağlantı isteyin.',
  accessUnverifiedTitle: 'Erişiminizi doğrulayamadık',
  accessUnverifiedCopy:
      'Müsait görünen her şeyi yine de satın alabilirsiniz. Geri kalanına erişim için sizi buraya yönlendiren kişiyle iletişime geçin.',
  generalAdmission: 'Genel giriş',
  numberOfGuests: 'Misafir sayısı',
  chooseGuestsCopy:
      'Kaç misafirin birlikte oturacağını seçin. Bu masa yalnızca sizin grubunuz için ayrılır.',
  fewerGuests: 'Daha az misafir',
  moreGuests: 'Daha çok misafir',
  selectTable: 'Masayı seç',
  updateTable: 'Masayı güncelle',
  removeWord: 'Kaldır',
  accessNeeds: <String, String>{
    'wheelchair': 'Tekerlekli sandalye yeri',
    'companion': 'Refakatçi koltuğu',
    'semi-ambulatory': 'Kısıtlı hareket',
    'designated-aisle': 'Koridor / aktarma',
    'step-free': 'Basamaksız',
    'hearing': 'İşitme desteği',
    'cart': 'Canlı altyazı',
    'sign-language': 'İşaret dili',
    'low-vision': 'Az görme',
    'sensory-friendly': 'Duyusal dostu',
    'plus-size': 'Geniş koltuk',
    'lift-armrest': 'Kaldırılabilir kolçak',
  },
  seatsLeft: _seatsLeftTr,
  moreCount: _moreCountTr,
  addMinutes: _addMinutesTr,
  fromPrice: _fromPriceTr,
  sightline: _sightlineTr,
  secureMoreAndCheckout: _secureMoreAndCheckoutTr,
  accessFreeCount: _accessFreeCountTr,
  seatJustTakenByAnother: _seatJustTakenByAnotherTr,
  peekSecured: _peekSecuredTr,
  ticketCount: _ticketCountTr,
  findBestSeats: _findBestSeatsTr,
  reselectSeats: _reselectSeatsTr,
  seatsFree: _seatsFreeTr,
  seatsLeftInSection: _seatsLeftInSectionTr,
  holdLapsedStillFree: _holdLapsedStillFreeTr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenTr,
  holdLapsedAllTaken: _holdLapsedAllTakenTr,
  continueWithTotal: _continueWithTotalTr,
);
