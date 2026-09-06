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
      removeSeat: '移除座位',
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
      fitWholeVenue: '显示整个场馆',
      loading: '正在加载座位图…',
      errorMessage: '座位图未能加载',
      retry: '重试',
      accessRefresh: '刷新',
      noSeatsSelected: '尚未选择座位',
      findBestSeatsCta: '查找最佳座位',
      organizerNote: '主办方提示',
      accessiblePhysicalSeat: '无障碍实体座位',
      emptyWheelchairSpace: '空闲的轮椅位',
      hideLimitedView: '隐藏视野受限的座位',
      colorblindSafe: '色盲友好配色',
      notAvailable: '不可用',
      restrictedView: '视野受限',
      obstructedView: '视野被遮挡',
      premiumSeat: '尊享座位',
      continueWord: '继续',
      accessNeeds: <String, String>{
        'wheelchair': '轮椅席位',
        'companion': '陪同席位',
        'semi-ambulatory': '行动不便座位',
        'designated-aisle': '指定通道转移座位',
        'step-free': '无台阶无障碍座位',
        'hearing': '助听设备',
        'cart': '实时字幕（CART）',
        'sign-language': '手语观看位',
        'low-vision': '视障观众观看位',
        'sensory-friendly': '安静感官友好座位',
        'plus-size': '加宽座位',
        'lift-armrest': '可掀式扶手',
      },
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
