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

String _fromPriceTr(String money) => '$money den itibaren';

String _sightlineTr(String metres) => 'Sahneye ≈ $metres m';

String _ticketCountTr(int count) =>
    count == 1 ? '$count bilet' : '$count bilet';

String _findBestSeatsTr(int count) =>
    count == 1 ? '$count en iyi koltuğu bul' : '$count en iyi koltuğu bul';

String _reselectSeatsTr(int count) =>
    count == 1 ? 'Onu tekrar seç' : 'Onları tekrar seç';

String _continueWithTotalTr(String money) => 'Devam \u00b7 $money';

/// The `tr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsTr = SeatLayerPickerStrings(
  close: 'Kapat',
  overview: 'Mekân',
  backToVenue: 'Mekana dön',
  cancel: 'İptal',
  select: 'Seç',
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
  fitVenue: 'Ekrana sığdır',
  loading: 'Koltuk planı yükleniyor…',
  errorMessage: 'Koltuk planı yüklenemedi',
  retry: 'Tekrar dene',
  hideLimitedView: 'Kısıtlı manzaralı koltukları gizle',
  colorblindSafe: 'Renk körlüğüne uygun renkler',
  seatsLeft: _seatsLeftTr,
  moreCount: _moreCountTr,
  fromPrice: _fromPriceTr,
  sightline: _sightlineTr,
  ticketCount: _ticketCountTr,
  findBestSeats: _findBestSeatsTr,
  reselectSeats: _reselectSeatsTr,
  continueWithTotal: _continueWithTotalTr,
);
