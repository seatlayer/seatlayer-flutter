// GENERATED — do not edit.
//
// Source: design/locale_strings.json (zh-Hans)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftZhHans(int count) => '剩余 $count';

String _moreCountZhHans(int count) => '其余 $count 项';

String _addMinutesZhHans(int minutes) => '+$minutes 分钟';

String _fromPriceZhHans(String money) => '$money 起';

String _sightlineZhHans(String metres) => '距舞台约 $metres 米';

String _ticketCountZhHans(int count) => count == 1 ? '$count 张票' : '$count 张票';

String _findBestSeatsZhHans(int count) =>
    count == 1 ? '查找 $count 个最佳座位' : '查找 $count 个最佳座位';

String _reselectSeatsZhHans(int count) => count == 1 ? '重新选择' : '重新选择';

String _continueWithTotalZhHans(String money) => '继续 \u00b7 $money';

/// The `zh-Hans` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsZhHans =
    SeatLayerPickerStrings(
      close: '关闭',
      overview: '场馆',
      backToVenue: '返回场馆',
      cancel: '取消',
      select: '选择',
      viewFromHere: '此处的视野',
      openVenue360: '打开场馆 360°',
      recentre: '重新居中到舞台',
      viewFromYourSeat: '从你的座位看出去的视野',
      emptyTrayHint: '在座位图上点按座位，或让我们为您挑选最佳可售座位。',
      anyTicketType: '任意票种',
      anyVenueZone: '任意场馆区域',
      bestSeats: '最佳座位',
      showLess: '收起',
      undo: '撤销',
      holdAndCheckout: '锁定座位并结算',
      poweredBy: '由 SeatLayer 提供支持',
      testMode: '测试模式',
      accessibility: '无障碍与配色选项',
      accessibilityTitle: '无障碍与配色选项',
      fitVenue: '适应屏幕',
      loading: '正在加载座位图…',
      errorMessage: '座位图未能加载',
      retry: '重试',
      hideLimitedView: '隐藏视野受限的座位',
      colorblindSafe: '色盲友好配色',
      seatsLeft: _seatsLeftZhHans,
      moreCount: _moreCountZhHans,
      addMinutes: _addMinutesZhHans,
      fromPrice: _fromPriceZhHans,
      sightline: _sightlineZhHans,
      ticketCount: _ticketCountZhHans,
      findBestSeats: _findBestSeatsZhHans,
      reselectSeats: _reselectSeatsZhHans,
      continueWithTotal: _continueWithTotalZhHans,
    );
