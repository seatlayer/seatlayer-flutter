// GENERATED — do not edit.
//
// Source: design/locale_strings.json (zh-Hant)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftZhHant(int count) => '剩餘 $count';

String _moreCountZhHant(int count) => '其餘 $count 項';

String _addMinutesZhHant(int minutes) => '+$minutes 分鐘';

String _fromPriceZhHant(String money) => '$money 起';

String _sightlineZhHant(String metres) => '距舞台約 $metres 公尺';

String _ticketCountZhHant(int count) => count == 1 ? '$count 張票' : '$count 張票';

String _findBestSeatsZhHant(int count) =>
    count == 1 ? '尋找 $count 個最佳座位' : '尋找 $count 個最佳座位';

String _reselectSeatsZhHant(int count) => count == 1 ? '重新選擇' : '重新選擇';

String _continueWithTotalZhHant(String money) => '繼續 \u00b7 $money';

/// The `zh-Hant` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsZhHant =
    SeatLayerPickerStrings(
      close: '關閉',
      overview: '場館',
      backToVenue: '返回場館',
      cancel: '取消',
      select: '選擇',
      viewFromHere: '此處的視野',
      openVenue360: '開啟場館 360°',
      recentre: '重新置中至舞台',
      viewFromYourSeat: '從你的座位看出去的視野',
      emptyTrayHint: '在座位圖上點選座位，或讓我們為您挑選最佳可售座位。',
      anyTicketType: '任何票種',
      anyVenueZone: '任何場館區域',
      bestSeats: '最佳座位',
      showLess: '收合',
      undo: '復原',
      holdAndCheckout: '鎖定座位並結帳',
      poweredBy: '由 SeatLayer 提供技術支援',
      testMode: '測試模式',
      accessibility: '無障礙與配色選項',
      accessibilityTitle: '無障礙與配色選項',
      fitVenue: '符合螢幕大小',
      loading: '正在載入座位圖…',
      errorMessage: '座位圖未能載入',
      retry: '重試',
      accessRefresh: '重新整理',
      hideLimitedView: '隱藏視野受限的座位',
      colorblindSafe: '色盲友善配色',
      continueWord: '繼續',
      seatsLeft: _seatsLeftZhHant,
      moreCount: _moreCountZhHant,
      addMinutes: _addMinutesZhHant,
      fromPrice: _fromPriceZhHant,
      sightline: _sightlineZhHant,
      ticketCount: _ticketCountZhHant,
      findBestSeats: _findBestSeatsZhHant,
      reselectSeats: _reselectSeatsZhHant,
      continueWithTotal: _continueWithTotalZhHant,
    );
