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

String _secureMoreAndCheckoutJa(int count) => 'あと$count席確保して決済へ';

String _accessFreeCountJa(int count) => '空き $count';

String _seatJustTakenByAnotherJa(String label) => '座席$labelは他のお客様が確保しました。';

String _labelNoLongerAvailableJa(String label) =>
    '$labelはご利用いただけなくなりました。別の席をお選びください。';

String _labelsNoLongerAvailableJa(String labels) =>
    '$labelsはご利用いただけなくなりました。別の席をお選びください。';

String _couldNotFindSeatsTogetherJa(int count) =>
    '隣り合った$count席が見つかりませんでした。席数を減らすか、別のチケット種別をお試しください。';

String _maxTicketsForOrderJa(int count) => 'このご注文で選べるチケットは$count枚までです。';

String _couldNotRemoveLabelJa(String label) => '$labelを外せませんでした。確保状況は変わっていません。';

String _peekSecuredJa(int count, String total) =>
    '✓ $count席確保 · $total。まだ請求はされません';

String _venueMapJa(String venue) => '$venueの座席図';

String _accessibleStepJa(int index, int total) => '$total件中$index件目';

String _chooseMinMaxGuestsJa(int min, int max) => '$min〜$max名でお選びください。';

String _chooseMoreJa(int count) => 'あと$count席選択';

String _seatsHeldForNeedMoreTimeJa(String time) => '座席の確保は残り$timeです。時間を延長しますか？';

String _accessNeedWithCountJa(String need, int count) => '$need・$count';

String _ticketCountJa(int count) => '$count枚';

String _findBestSeatsJa(int count) => 'おすすめの$count席を探す';

String _reselectSeatsJa(int count) => 'もう一度選ぶ';

String _seatsFreeJa(int count) => '$count席';

String _seatsLeftInSectionJa(int count) => '残り$count席';

String _holdLapsedStillFreeJa(int count) => '離席中に確保の時間が切れました。その席はまだ空いています。';

String _holdLapsedSomeTakenJa(int count) =>
    '離席中に確保の時間が切れ、そのうち $count 席はすでに他の方が確保しました。残りはまだ空いています。';

String _holdLapsedAllTakenJa(int count) => '離席中に確保の時間が切れ、その席はすでに他の方が確保しました。';

String _accessibleSectionsJa(int count) => '$countブロック';

String _placesAvailableJa(int count) => '現在$count名分の空きがあります';

String _removeTicketsJa(int count) => 'チケットを$count枚外す';

String _holdMinutesLeftJa(int count) => '残り$count分';

String _holdSecondsLeftJa(int count) => '残り$count秒';

String _holdLapsedBodyJa(int count) => '座席は$count分間確保されていました。';

String _seatsNotRecoveredJa(int count) => '$count席を再確保できませんでした';

String _activeFiltersJa(int count) => '絞り込み$count件';

String _accessibilityFiltersActiveJa(int count) => 'バリアフリーの絞り込みを$count件適用中';

String _onlyLeftJa(int count) => '残り$count席';

String _maintenancePausedJa(int count) =>
    '予約はメンテナンスのため一時停止中です。約$count分後にもう一度お試しください。';

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
  fitVenue: '会場全体を表示',
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
  findSeatsTogether: '隣り合った席を探す',
  aboutBestSeats: '隣り合う座席の検索について',
  closestGroupChosenInstantly: '最も近い空きのまとまりを即座に選びました。',
  hideLimitedView: '視界制限のある座席を隠す',
  colorblindSafe: '色覚に配慮した配色',
  notAvailable: '利用できません',
  viewGroupTitle: '表示',
  restrictedView: '視界制限あり',
  obstructedView: '視界を遮るものあり',
  premiumSeat: 'プレミアム席',
  continueWord: '次へ',
  allFloors: 'すべてのフロア',
  previousSection: '前のブロック',
  nextSection: '次のブロック',
  addSeat: '席を追加',
  added: '追加済み',
  sectionWord: 'ブロック',
  rowWord: '列',
  seatWord: '座席',
  seeItIn3D: '3Dで見る',
  viewFromThisSeat: 'この席からの眺め',
  allPrices: 'すべての価格',
  ticketPrices: 'チケット価格',
  yourSeats: 'あなたの座席',
  ticketType: 'チケット種別',
  tierCompanionGuidance: '隣接する車椅子スペースが必要です',
  findingBestSeats: 'おすすめの席を探しています…',
  findSeats: '席を探す',
  expandCart: 'チケットパネルを開く',
  collapseCart: 'チケットパネルを折りたたむ',
  continueToCheckout: '決済に進む',
  secureMore: 'さらに確保',
  selectSeats: '座席を選択',
  pickYourSeats: '座席をお選びください',
  salesClosedPill: '販売終了',
  salesClosedCta: '販売終了',
  confirmOrCancelSeat: 'この座席を確定またはキャンセル',
  securingSeats: '座席を確保しています…',
  openingCheckout: '安全な決済画面を開いています…',
  testModeExplained: 'こちらの予約は実際のものではなく、カードへの請求も発生しません',
  displayOptions: '表示設定',
  companionSeatsNote: '隣の同伴者スペースは引き続き選択できます',
  zoomIn: '拡大',
  zoomOut: '縮小',
  rotateVenue: 'ドラッグして会場を回転',
  moveVenue: 'ドラッグして会場を移動',
  mapView: '座席図',
  flat2dMap: '平面2Dマップ',
  interactive3dVenueView: '操作できる3D会場ビュー',
  venueView: '会場ビュー',
  holdLapsedTitle: '座席の確保が解除されました',
  salesClosed: '販売終了',
  salesClosedCopy: 'このイベントのチケット販売は終了しました。',
  salesClosedToast: 'このイベントの販売は終了しています。',
  soldOutEyebrow: 'このイベント',
  soldOutTitle: '完売',
  soldOutCopy: 'このイベントでご利用いただける指定席は現在ありません。',
  holdExpired: '確保の期限が切れ、座席は解放されました。もう一度お選びください。',
  addingEllipsis: '追加しています…',
  moreTimeAdded: '時間を延長しました。座席は確保されたままです。',
  couldNotAddMoreTime: '時間を延長できませんでした。今すぐ決済にお進みください。',
  seatsJustTaken: '1席以上が他のお客様に確保されました。もう一度お選びください。',
  ticketTypeSoldOut: 'そのチケット種別は完売しました。別の種別をお試しください。',
  seatsNoLongerAvailableTryAnother: 'その座席はご利用いただけなくなりました。枚数かチケット種別を変えてお試しください。',
  companionPairRequired: '同伴者チケットごとに、隣接する車椅子スペースを選択してください。',
  ticketOptionNotApplicable: 'そのチケット種別は、選択した席ではご利用いただけません。',
  maintenancePausedShortly: '予約はメンテナンスのため数分間停止しています。しばらくしてからもう一度お試しください。',
  guestsOnly: 'このイベントは招待されたゲスト専用です。',
  guestChoiceClosed: '現在、座席の選択は受け付けていません。',
  maxOneTicketForOrder: 'このご注文で選べるチケットは1枚までです。',
  tooManyAttempts: '試行回数が多すぎます。しばらく待ってからもう一度お試しください。',
  seatHeldForRenewal:
      'これらの座席のうち1席は、まだ更新できるシーズンチケット保有者のために確保されています。別の座席をお選びください。',
  seatUnavailable: 'この席はご利用いただけません。',
  eventUnavailable: '現在、ここではチケットを予約できません。',
  savedSeatsNotRestored: '以前の座席を復元できませんでした。もう一度お選びください。',
  allSetTitle: '準備完了です',
  confirmedAndOnWay: '確定しました。確認のご連絡をお送りします。',
  backToMap: '座席図に戻る',
  mapDidNotLoad: '座席図を読み込めませんでした',
  checkConnection: '通信環境を確認して、もう一度お試しください。',
  accessPausedTitle: 'これらの座席は現在保留中です',
  accessPausedCopy: '主催者がこの選択を一時停止しています。数分後にもう一度お試しください。',
  accessRevokedTitle: 'このアクセスリンクは無効になりました',
  accessRevokedCopy: '引き続きこの座席を予約するには、このリンクを送った方に新しいリンクをご依頼ください。',
  accessUnverifiedTitle: 'アクセス権を確認できませんでした',
  accessUnverifiedCopy:
      '「空席」と表示されているものは引き続きご購入いただけます。その他へのアクセスは、このリンクを送った方にお問い合わせください。',
  generalAdmission: '自由席',
  numberOfGuests: 'ご人数',
  chooseGuestsCopy: '何名で同席するかをお選びください。このテーブルはお連れ様専用に確保されます。',
  fewerGuests: '人数を減らす',
  moreGuests: '人数を増やす',
  selectTable: 'テーブルを選択',
  updateTable: 'テーブルを更新',
  removeWord: '削除',
  floorWord: 'フロア',
  totalWord: '合計',
  adjustSelection: '座席の選択を調整',
  backToSeatMap: '座席図に戻る',
  chooseSeats: '座席を選ぶ',
  chooseTickets: 'チケットを選ぶ',
  placeWord: 'スペース',
  ticketWord: 'チケット',
  passport: '座席カルテ',
  venue3D: '3D',
  venueZone: '会場エリア',
  venueMapHint: '座席は座席図の周りの操作部から選べます。上部の価格バー、下部のブロック操作、最下部のチケットパネルをご利用ください。',
  previousSeat: '前の席',
  nextSeat: '次の席',
  orbitMode: '会場を回転',
  panMode: '会場を移動',
  openInteractive3dVenue: '操作できる3D会場を開く',
  showSeatsFor: '次の条件で座席を表示',
  accessJumpFirstSection: '最初のブロックへ移動',
  accessJumpNextSection: '次のブロックへ移動',
  fewerTickets: 'チケットを減らす',
  moreTickets: 'チケットを増やす',
  addTickets: 'チケットを追加',
  noSelectableSeats: '現在選択できる座席はありません。',
  confirmYourTickets: 'チケットを確定',
  seatsSecuredOpeningCheckout: '座席を確保しました。お会計画面を開いています…',
  holdInCheckoutTitle: '座席はすでにお会計の手続き中です',
  holdInCheckoutBody:
      '座席を確保したままにするには、お会計を完了してください。別の座席を選ぶ場合は、先にこれらの座席を解放してください。解放した座席は再び販売されます。',
  releaseAndChangeSeats: '解放して座席を変更',
  holdAlreadyHeldTitle: '座席はすでに確保されています',
  holdAlreadyHeldBody: '確保したままにするには、決済に進んでください。',
  accessExpiredTitle: '座席選択のセッションの有効期限が切れました',
  accessExpiredCopy: '続けるには座席図を再読み込みしてください。カートに入っている座席は、タイマーが終わるまで確保されたままです。',
  dismissError: 'エラーを閉じる',
  testModeLong: 'テストモード · 予約は発生しません',
  seatRemoved: 'チケットを外しました',
  reloadSeatMap: '座席図を再読み込み',
  accessNeeds: <String, String>{
    'wheelchair': '車椅子スペース',
    'companion': '同伴者席',
    'semi-ambulatory': '歩行が困難',
    'designated-aisle': '通路側／乗り移り',
    'step-free': '段差なし',
    'hearing': '補聴サポート',
    'cart': 'リアルタイム字幕',
    'sign-language': '手話',
    'low-vision': '視覚障害',
    'sensory-friendly': '感覚に優しい',
    'plus-size': 'ゆったり幅',
    'lift-armrest': '肘掛けが上がる',
  },
  seatsLeft: _seatsLeftJa,
  moreCount: _moreCountJa,
  addMinutes: _addMinutesJa,
  fromPrice: _fromPriceJa,
  sightline: _sightlineJa,
  secureMoreAndCheckout: _secureMoreAndCheckoutJa,
  accessFreeCount: _accessFreeCountJa,
  seatJustTakenByAnother: _seatJustTakenByAnotherJa,
  labelNoLongerAvailable: _labelNoLongerAvailableJa,
  labelsNoLongerAvailable: _labelsNoLongerAvailableJa,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherJa,
  maxTicketsForOrder: _maxTicketsForOrderJa,
  couldNotRemoveLabel: _couldNotRemoveLabelJa,
  peekSecured: _peekSecuredJa,
  venueMap: _venueMapJa,
  accessibleStep: _accessibleStepJa,
  chooseMinMaxGuests: _chooseMinMaxGuestsJa,
  chooseMore: _chooseMoreJa,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeJa,
  accessNeedWithCount: _accessNeedWithCountJa,
  ticketCount: _ticketCountJa,
  findBestSeats: _findBestSeatsJa,
  reselectSeats: _reselectSeatsJa,
  seatsFree: _seatsFreeJa,
  seatsLeftInSection: _seatsLeftInSectionJa,
  holdLapsedStillFree: _holdLapsedStillFreeJa,
  holdLapsedSomeTaken: _holdLapsedSomeTakenJa,
  holdLapsedAllTaken: _holdLapsedAllTakenJa,
  accessibleSections: _accessibleSectionsJa,
  placesAvailable: _placesAvailableJa,
  removeTickets: _removeTicketsJa,
  holdMinutesLeft: _holdMinutesLeftJa,
  holdSecondsLeft: _holdSecondsLeftJa,
  holdLapsedBody: _holdLapsedBodyJa,
  seatsNotRecovered: _seatsNotRecoveredJa,
  activeFilters: _activeFiltersJa,
  accessibilityFiltersActive: _accessibilityFiltersActiveJa,
  onlyLeft: _onlyLeftJa,
  maintenancePaused: _maintenancePausedJa,
  continueWithTotal: _continueWithTotalJa,
);
