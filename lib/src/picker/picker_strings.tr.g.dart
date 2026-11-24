// GENERATED — do not edit.
//
// Source: design/locale_strings.json (tr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableTr(String label) =>
    '$label artık müsait değil. Başka bir koltuk seçin.';

String _labelsNoLongerAvailableTr(String labels) =>
    '$labels artık müsait değil. Başka bir grup seçin.';

String _couldNotFindSeatsTogetherTr(int count) =>
    '$count koltuğu yan yana bulamadık. Daha az koltuk veya başka bir bilet türü deneyin.';

String _couldNotRemoveLabelTr(String label) =>
    '$label kaldırılamadı. Rezervasyonunuz değişmedi.';

String _peekSecuredTr(int count, String total) =>
    '✓ $count güvenceye alındı · $total. Henüz ücret alınmayacak';

String _venueMapTr(String venue) => '$venue koltuk planı';

String _accessibleStepTr(int index, int total) => '$index/$total';

String _chooseMinMaxGuestsTr(int min, int max) =>
    '$min ile $max arasında misafir seçin.';

String _chooseMoreTr(int count) => '$count tane daha seç';

String _seatsHeldForNeedMoreTimeTr(String time) =>
    'Koltuklarınız $time boyunca sizin için tutuluyor. Daha fazla süre mi gerekiyor?';

String _accessNeedWithCountTr(String need, int count) => '$need · $count';

String _ticketCountTr(int count) => switch (pickerPluralCategory('tr', count)) {
  PickerPluralCategory.one => '$count bilet',
  _ => '$count bilet',
};

String _findBestSeatsTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count en iyi koltuğu bul',
      _ => '$count en iyi koltuğu bul',
    };

String _reselectSeatsTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => 'Onu tekrar seç',
      _ => 'Onları tekrar seç',
    };

String _seatsFreeTr(int count) => switch (pickerPluralCategory('tr', count)) {
  PickerPluralCategory.one => '$count koltuk',
  _ => '$count koltuk',
};

String _seatsLeftInSectionTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count koltuk kaldı',
      _ => '$count koltuk kaldı',
    };

String _holdLapsedStillFreeTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one =>
        'Siz yokken rezervasyonunuz sona erdi. O koltuk hâlâ boş.',
      _ => 'Siz yokken rezervasyonunuz sona erdi. O koltuklar hâlâ boş.',
    };

String _holdLapsedSomeTakenTr(int count) => switch (pickerPluralCategory(
  'tr',
  count,
)) {
  PickerPluralCategory.one =>
    'Siz yokken rezervasyonunuz sona erdi ve o koltuklardan $count tanesi alındı. Geri kalanlar hâlâ boş.',
  _ =>
    'Siz yokken rezervasyonunuz sona erdi ve o koltuklardan $count tanesi alındı. Geri kalanlar hâlâ boş.',
};

String _holdLapsedAllTakenTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one =>
        'Siz yokken rezervasyonunuz sona erdi ve o koltuk alındı.',
      _ => 'Siz yokken rezervasyonunuz sona erdi ve o koltuklar alındı.',
    };

String _accessibleSectionsTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count blok',
      _ => '$count blok',
    };

String _placesAvailableTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => 'Şu anda $count yer müsait',
      _ => 'Şu anda $count yer müsait',
    };

String _removeTicketsTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count bilet çıkar',
      _ => '$count bilet çıkar',
    };

String _holdMinutesLeftTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count dakika kaldı',
      _ => '$count dakika kaldı',
    };

String _holdSecondsLeftTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count saniye kaldı',
      _ => '$count saniye kaldı',
    };

String _holdLapsedBodyTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => 'Koltuklar $count dakika boyunca tutuldu.',
      _ => 'Koltuklar $count dakika boyunca tutuldu.',
    };

String _seatsNotRecoveredTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count koltuk yeniden tutulamadı',
      _ => '$count koltuk yeniden tutulamadı',
    };

String _activeFiltersTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count filtre',
      _ => '$count filtre',
    };

String _accessibilityFiltersActiveTr(int count) =>
    switch (pickerPluralCategory('tr', count)) {
      PickerPluralCategory.one => '$count erişilebilirlik filtresi etkin',
      _ => '$count erişilebilirlik filtresi etkin',
    };

String _onlyLeftTr(int count) => switch (pickerPluralCategory('tr', count)) {
  PickerPluralCategory.one => '$count koltuk kaldı',
  _ => '$count koltuk kaldı',
};

String _maintenancePausedTr(int count) => switch (pickerPluralCategory(
  'tr',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervasyon bakım nedeniyle duraklatıldı. Lütfen yaklaşık $count dakika sonra tekrar deneyin.',
  _ =>
    'Rezervasyon bakım nedeniyle duraklatıldı. Lütfen yaklaşık $count dakika sonra tekrar deneyin.',
};

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
  testMode: 'Test modu',
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
  viewGroupTitle: 'GÖRÜNÜM',
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
  ticketPrices: 'Bilet fiyatları',
  yourSeats: 'Koltuklarınız',
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
  ticketTypeSoldOut: 'Bu bilet türü tükendi. Başka bir bilet türü deneyin.',
  seatsNoLongerAvailableTryAnother:
      'O koltuklar artık müsait değil. Başka bir adet veya bilet türü deneyin.',
  companionPairRequired:
      'Her refakatçi bileti için bitişikteki tekerlekli sandalye yerini seçin.',
  ticketOptionNotApplicable:
      'Bu bilet seçeneği seçilen koltuk için kullanılamıyor.',
  maintenancePausedShortly:
      'Rezervasyon bakım nedeniyle birkaç dakikalığına duraklatıldı. Lütfen kısa süre sonra tekrar deneyin.',
  guestsOnly: 'Bu etkinlik davetli konuklar içindir.',
  guestChoiceClosed: 'Koltuk seçimi şu anda açık değil.',
  tooManyAttempts: 'Çok fazla deneme yapıldı. Biraz bekleyip tekrar deneyin.',
  seatHeldForRenewal:
      'Bu koltuklardan biri, hâlâ yenileyebilecek bir sezon bileti sahibi için ayrıldı. Başka bir koltuk seçin.',
  seatUnavailable: 'Bu koltuk müsait değil.',
  eventUnavailable: 'Şu anda burada bilet ayırtılamıyor.',
  savedSeatsNotRestored:
      'Önceki koltuklarınız geri yüklenemedi. Lütfen yeniden seçin.',
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
  floorWord: 'Kat',
  totalWord: 'Toplam',
  adjustSelection: 'Koltuk seçimini düzenle',
  backToSeatMap: 'Koltuk planına dön',
  chooseSeats: 'Koltuklarınızı seçin',
  chooseTickets: 'Bilet seçin',
  placeWord: 'YER',
  ticketWord: 'Bilet',
  passport: 'Koltuk profili',
  venue3D: '3D',
  venueZone: 'Mekân bölgesi',
  venueMapHint:
      'Koltuklar planın çevresindeki kontrollerle seçilir: üstte fiyat şeridi, altta blok kontrolleri ve en altta bilet paneli.',
  previousSeat: 'Önceki koltuk',
  nextSeat: 'Sonraki koltuk',
  orbitMode: 'Mekânı döndür',
  panMode: 'Mekânı kaydır',
  openInteractive3dVenue: 'Etkileşimli 3B mekân görünümünü aç',
  showSeatsFor: 'KOLTUKLARI GÖSTER:',
  accessJumpFirstSection: 'İlk bloğa git',
  accessJumpNextSection: 'Sonraki bloğa git',
  fewerTickets: 'Daha az bilet',
  moreTickets: 'Daha fazla bilet',
  addTickets: 'Bilet ekle',
  noSelectableSeats: 'Şu anda seçilebilir koltuk yok.',
  confirmYourTickets: 'Biletlerinizi onaylayın',
  seatsSecuredOpeningCheckout: 'Koltuklar güvenceye alındı. Ödeme açılıyor…',
  holdInCheckoutTitle: 'Koltuklarınız zaten ödeme aşamasında',
  holdInCheckoutBody:
      'Koltukları korumak için ödemeyi tamamlayın. Farklı koltuklar seçmek için önce bunları serbest bırakın — yeniden satışa çıkarlar.',
  releaseAndChangeSeats: 'Serbest bırak ve koltukları değiştir',
  holdAlreadyHeldTitle: 'Koltuklarınız zaten tutuluyor',
  holdAlreadyHeldBody: 'Koltukları korumak için ödemeye devam edin.',
  accessExpiredTitle: 'Oturumunuzun süresi doldu',
  accessExpiredCopy:
      'Devam etmek için koltuk planını yeniden yükleyin. Sepetinizdeki koltuklar süre bitene kadar sizin için tutulmaya devam eder.',
  dismissError: 'Hatayı kapat',
  testModeLong: 'Test modu · hiçbir şey rezerve edilmez',
  seatRemoved: 'Bilet kaldırıldı',
  reloadSeatMap: 'Koltuk planını yeniden yükle',
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
  labelNoLongerAvailable: _labelNoLongerAvailableTr,
  labelsNoLongerAvailable: _labelsNoLongerAvailableTr,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherTr,
  couldNotRemoveLabel: _couldNotRemoveLabelTr,
  peekSecured: _peekSecuredTr,
  venueMap: _venueMapTr,
  accessibleStep: _accessibleStepTr,
  chooseMinMaxGuests: _chooseMinMaxGuestsTr,
  chooseMore: _chooseMoreTr,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeTr,
  accessNeedWithCount: _accessNeedWithCountTr,
  ticketCount: _ticketCountTr,
  findBestSeats: _findBestSeatsTr,
  reselectSeats: _reselectSeatsTr,
  seatsFree: _seatsFreeTr,
  seatsLeftInSection: _seatsLeftInSectionTr,
  holdLapsedStillFree: _holdLapsedStillFreeTr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenTr,
  holdLapsedAllTaken: _holdLapsedAllTakenTr,
  accessibleSections: _accessibleSectionsTr,
  placesAvailable: _placesAvailableTr,
  removeTickets: _removeTicketsTr,
  holdMinutesLeft: _holdMinutesLeftTr,
  holdSecondsLeft: _holdSecondsLeftTr,
  holdLapsedBody: _holdLapsedBodyTr,
  seatsNotRecovered: _seatsNotRecoveredTr,
  activeFilters: _activeFiltersTr,
  accessibilityFiltersActive: _accessibilityFiltersActiveTr,
  onlyLeft: _onlyLeftTr,
  maintenancePaused: _maintenancePausedTr,
  continueWithTotal: _continueWithTotalTr,
);
