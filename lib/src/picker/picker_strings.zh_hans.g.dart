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

String _secureMoreAndCheckoutZhHans(int count) => '再锁定 $count 个并结算';

String _accessFreeCountZhHans(int count) => '$count 个可选';

String _seatJustTakenByAnotherZhHans(String label) => '座位 $label 刚被另一位买家选走。';

String _peekSecuredZhHans(int count, String total) =>
    '✓ 已锁定 $count 个 · $total，暂不会扣款';

String _ticketCountZhHans(int count) => count == 1 ? '$count 张票' : '$count 张票';

String _findBestSeatsZhHans(int count) =>
    count == 1 ? '查找 $count 个最佳座位' : '查找 $count 个最佳座位';

String _reselectSeatsZhHans(int count) => count == 1 ? '重新选择' : '重新选择';

String _seatsFreeZhHans(int count) => count == 1 ? '$count 个座位' : '$count 个座位';

String _seatsLeftInSectionZhHans(int count) =>
    count == 1 ? '剩余 $count 个座位' : '剩余 $count 个座位';

String _holdLapsedStillFreeZhHans(int count) =>
    count == 1 ? '您离开期间，座位保留已到期。这些座位仍然可选。' : '您离开期间，座位保留已到期。这些座位仍然可选。';

String _holdLapsedSomeTakenZhHans(int count) => count == 1
    ? '您离开期间，座位保留已到期，其中 $count 个座位已被他人选走。其余仍然可选。'
    : '您离开期间，座位保留已到期，其中 $count 个座位已被他人选走。其余仍然可选。';

String _holdLapsedAllTakenZhHans(int count) =>
    count == 1 ? '您离开期间，座位保留已到期，这些座位已被他人选走。' : '您离开期间，座位保留已到期，这些座位已被他人选走。';

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
      fitVenue: '显示整个场馆',
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
      findSeatsTogether: '查找连坐座位',
      aboutBestSeats: '关于查找相邻座位',
      closestGroupChosenInstantly: '已即时选出最近的可售连坐座位。',
      hideLimitedView: '隐藏视野受限的座位',
      colorblindSafe: '色盲友好配色',
      notAvailable: '不可用',
      restrictedView: '视野受限',
      obstructedView: '视野被遮挡',
      premiumSeat: '尊享座位',
      continueWord: '继续',
      allFloors: '所有楼层',
      previousSection: '上一个分区',
      nextSection: '下一个分区',
      addSeat: '添加座位',
      added: '已添加',
      sectionWord: '分区',
      rowWord: '排',
      seatWord: '座位',
      seeItIn3D: '用 3D 查看',
      viewFromThisSeat: '该座位的视野',
      allPrices: '所有价格',
      ticketType: '票种',
      tierCompanionGuidance: '需要相邻的轮椅席位',
      findingBestSeats: '正在查找最佳座位…',
      findSeats: '查找座位',
      expandCart: '打开票务面板',
      collapseCart: '收起票务面板',
      continueToCheckout: '继续结算',
      secureMore: '锁定更多',
      selectSeats: '选择座位',
      pickYourSeats: '选择您的座位',
      salesClosedPill: '已停止售票',
      salesClosedCta: '已停止售票',
      confirmOrCancelSeat: '确认或取消此座位',
      securingSeats: '正在为您锁定座位…',
      openingCheckout: '正在打开安全支付…',
      testModeExplained: '此处的预订并非真实预订，不会有任何银行卡扣款',
      displayOptions: '显示选项',
      companionSeatsNote: '旁边的陪同席位仍可选择',
      zoomIn: '放大',
      zoomOut: '缩小',
      rotateVenue: '拖动以旋转场馆',
      moveVenue: '拖动以移动场馆',
      mapView: '座位图',
      flat2dMap: '平面 2D 座位图',
      interactive3dVenueView: '可交互的 3D 场馆视图',
      venueView: '场馆视图',
      holdLapsedTitle: '您的座位已释放',
      salesClosed: '已停止售票',
      salesClosedCopy: '本场活动的售票已结束。',
      salesClosedToast: '本场活动已停止售票。',
      soldOutEyebrow: '本场活动',
      soldOutTitle: '已售罄',
      soldOutCopy: '本场活动目前没有可售的对号座位。',
      holdExpired: '您的占座已过期，座位已释放。请重新选择。',
      addingEllipsis: '正在添加…',
      moreTimeAdded: '已延长时间。您的座位仍在锁定中。',
      couldNotAddMoreTime: '无法延长时间，请立即前往结算。',
      seatsJustTaken: '有一个或多个座位刚被选走，请重新选择。',
      allSetTitle: '一切就绪',
      confirmedAndOnWay: '已确认。确认信息即将送达。',
      backToMap: '返回座位图',
      mapDidNotLoad: '座位图未能加载',
      checkConnection: '请检查网络连接后重试。',
      accessPausedTitle: '这些座位目前处于锁定状态',
      accessPausedCopy: '主办方已暂停此选座。请几分钟后再试。',
      accessRevokedTitle: '此访问链接已失效',
      accessRevokedCopy: '请向发送链接给您的人索取新链接，以继续预订这些座位。',
      accessUnverifiedTitle: '无法验证您的访问权限',
      accessUnverifiedCopy: '显示为可售的座位仍可购买。如需访问其余座位，请联系向您发送链接的人。',
      generalAdmission: '自由入场',
      numberOfGuests: '宾客人数',
      chooseGuestsCopy: '请选择同桌的宾客人数。此餐桌将专属保留给您这一行人。',
      fewerGuests: '减少宾客',
      moreGuests: '增加宾客',
      selectTable: '选择餐桌',
      updateTable: '更新餐桌',
      removeWord: '移除',
      accessNeeds: <String, String>{
        'wheelchair': '轮椅席位',
        'companion': '陪同席位',
        'semi-ambulatory': '行动不便',
        'designated-aisle': '通道／转移',
        'step-free': '无台阶',
        'hearing': '助听设备',
        'cart': '实时字幕',
        'sign-language': '手语',
        'low-vision': '视力障碍',
        'sensory-friendly': '感官友好',
        'plus-size': '加宽座位',
        'lift-armrest': '可掀式扶手',
      },
      seatsLeft: _seatsLeftZhHans,
      moreCount: _moreCountZhHans,
      addMinutes: _addMinutesZhHans,
      fromPrice: _fromPriceZhHans,
      sightline: _sightlineZhHans,
      secureMoreAndCheckout: _secureMoreAndCheckoutZhHans,
      accessFreeCount: _accessFreeCountZhHans,
      seatJustTakenByAnother: _seatJustTakenByAnotherZhHans,
      peekSecured: _peekSecuredZhHans,
      ticketCount: _ticketCountZhHans,
      findBestSeats: _findBestSeatsZhHans,
      reselectSeats: _reselectSeatsZhHans,
      seatsFree: _seatsFreeZhHans,
      seatsLeftInSection: _seatsLeftInSectionZhHans,
      holdLapsedStillFree: _holdLapsedStillFreeZhHans,
      holdLapsedSomeTaken: _holdLapsedSomeTakenZhHans,
      holdLapsedAllTaken: _holdLapsedAllTakenZhHans,
      continueWithTotal: _continueWithTotalZhHans,
    );
