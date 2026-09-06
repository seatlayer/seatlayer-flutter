// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ja)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftJa(int count) => '残り$count';

String _moreCountJa(int count) => '他 $count 件';

String _addMinutesJa(int minutes) => '+$minutes分';

String _fromPriceJa(String money) => '$money〜';

String _sightlineJa(String metres) => 'ステージまで約${metres}m';

String _ticketCountJa(int count) => count == 1 ? '$count枚' : '$count枚';

String _findBestSeatsJa(int count) =>
    count == 1 ? 'おすすめの$count席を探す' : 'おすすめの$count席を探す';

String _reselectSeatsJa(int count) => count == 1 ? 'もう一度選ぶ' : 'もう一度選ぶ';

String _continueWithTotalJa(String money) => '次へ \u00b7 $money';

/// The `ja` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsJa = SeatLayerPickerStrings(
  close: '閉じる',
  overview: '会場',
  backToVenue: '会場に戻る',
  cancel: 'キャンセル',
  select: '選択',
  removeSeat: '席を削除',
  viewFromHere: 'ここからの眺め',
  openVenue360: '会場の360°を開く',
  recentre: 'ステージを中央に戻す',
  viewFromYourSeat: 'この座席からの眺め',
  emptyTrayHint: '座席図で席をタップするか、空いている中から最適な席をこちらでお選びします。',
  anyTicketType: 'すべてのチケット種別',
  anyVenueZone: 'すべての会場エリア',
  bestSeats: 'おすすめの席',
  showLess: '表示を減らす',
  undo: '元に戻す',
  holdAndCheckout: '席を確保して決済へ',
  poweredBy: 'Powered by SeatLayer',
  testMode: 'テストモード',
  accessibility: 'バリアフリーと配色の設定',
  accessibilityTitle: 'バリアフリーと配色の設定',
  fitWholeVenue: '会場全体を表示',
  loading: '座席図を読み込んでいます…',
  errorMessage: '座席図を読み込めませんでした',
  retry: '再試行',
  accessRefresh: '再読み込み',
  noSeatsSelected: '座席が選択されていません',
  findBestSeatsCta: 'おすすめの席を探す',
  organizerNote: '主催者からのお知らせ',
  accessiblePhysicalSeat: 'バリアフリー対応の座席',
  emptyWheelchairSpace: '空きの車椅子スペース',
  hideLimitedView: '視界制限のある座席を隠す',
  colorblindSafe: '色覚に配慮した配色',
  notAvailable: '利用できません',
  restrictedView: '視界制限あり',
  obstructedView: '視界を遮るものあり',
  premiumSeat: 'プレミアム席',
  continueWord: '次へ',
  accessNeeds: <String, String>{
    'wheelchair': '車椅子スペース',
    'companion': '同伴者席',
    'semi-ambulatory': '歩行が困難な方の座席',
    'designated-aisle': '通路側の乗り移り用座席',
    'step-free': '段差のないバリアフリー席',
    'hearing': '補聴サポート',
    'cart': 'リアルタイム字幕（CART）',
    'sign-language': '手話が見える席',
    'low-vision': '視覚障害の方向けの観覧',
    'sensory-friendly': '静かな感覚に優しい座席',
    'plus-size': 'ゆったり幅の座席',
    'lift-armrest': '肘掛けが上がる座席',
  },
  seatsLeft: _seatsLeftJa,
  moreCount: _moreCountJa,
  addMinutes: _addMinutesJa,
  fromPrice: _fromPriceJa,
  sightline: _sightlineJa,
  ticketCount: _ticketCountJa,
  findBestSeats: _findBestSeatsJa,
  reselectSeats: _reselectSeatsJa,
  continueWithTotal: _continueWithTotalJa,
);
