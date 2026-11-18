// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ko)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftKo(int count) => '잔여 $count';

String _moreCountKo(int count) => '+$count개 더';

String _addMinutesKo(int minutes) => '+$minutes분';

String _fromPriceKo(String money) => '$money부터';

String _sightlineKo(String metres) => '무대까지 ≈ ${metres}m';

String _secureMoreAndCheckoutKo(int count) => '$count석 더 확보하고 결제';

String _accessFreeCountKo(int count) => '잔여 $count석';

String _seatJustTakenByAnotherKo(String label) =>
    '방금 다른 고객이 좌석 $label을(를) 예매했어요.';

String _peekSecuredKo(int count, String total) =>
    '✓ $count석 확보 · $total. 아직 결제되지 않았어요';

String _venueMapKo(String venue) => '$venue 좌석 배치도';

String _accessibleStepKo(int index, int total) => '$total개 중 $index번째';

String _chooseMinMaxGuestsKo(int min, int max) => '인원을 $min~$max명으로 선택해 주세요.';

String _chooseMoreKo(int count) => '$count석 더 선택';

String _seatsHeldForNeedMoreTimeKo(String time) =>
    '좌석이 $time 동안 확보돼 있어요. 시간이 더 필요하세요?';

String _ticketCountKo(int count) => '티켓 $count매';

String _findBestSeatsKo(int count) => '추천 좌석 $count석 찾기';

String _reselectSeatsKo(int count) => '다시 선택하기';

String _seatsFreeKo(int count) => '$count석';

String _seatsLeftInSectionKo(int count) => '잔여 $count석';

String _holdLapsedStillFreeKo(int count) =>
    '자리를 비운 사이 확보 시간이 끝났어요. 좌석은 아직 예매 가능해요.';

String _holdLapsedSomeTakenKo(int count) =>
    '자리를 비운 사이 확보 시간이 끝났고, 그중 $count석은 이미 예매됐어요. 나머지 좌석은 아직 예매 가능해요.';

String _holdLapsedAllTakenKo(int count) =>
    '자리를 비운 사이 확보 시간이 끝났고, 좌석은 이미 예매됐어요.';

String _accessibleSectionsKo(int count) => '구역 $count개';

String _placesAvailableKo(int count) => '현재 $count자리 예매 가능';

String _removeTicketsKo(int count) => '티켓 $count매 삭제';

String _holdMinutesLeftKo(int count) => '$count분 남음';

String _holdSecondsLeftKo(int count) => '$count초 남음';

String _holdLapsedBodyKo(int count) => '좌석이 $count분 동안 확보돼 있었어요.';

String _seatsNotRecoveredKo(int count) => '$count석은 다시 확보하지 못했어요';

String _continueWithTotalKo(String money) => '계속 \u00b7 $money';

/// The `ko` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsKo = SeatLayerPickerStrings(
  close: '닫기',
  overview: '공연장',
  backToVenue: '공연장 전체로 돌아가기',
  cancel: '취소',
  select: '선택',
  removeSeat: '좌석 삭제',
  viewFromHere: '여기서 본 시야',
  openVenue360: '공연장 360° 보기',
  recentre: '무대 중심으로 보기',
  viewFromYourSeat: '내 좌석에서 본 시야',
  emptyTrayHint: '배치도에서 좌석을 누르거나, 남은 좌석 중 추천 좌석을 받아 보세요.',
  anyTicketType: '모든 티켓 종류',
  anyVenueZone: '모든 존',
  bestSeats: '추천 좌석',
  showLess: '간단히 보기',
  undo: '실행 취소',
  holdAndCheckout: '좌석 확보 후 결제',
  poweredBy: 'SeatLayer 제공',
  testMode: '테스트 모드',
  accessibility: '접근성 및 색상 옵션',
  accessibilityTitle: '접근성 및 색상 옵션',
  fitVenue: '공연장 전체 보기',
  fitWholeVenue: '공연장 전체 보기',
  loading: '좌석 배치도를 불러오는 중…',
  errorMessage: '좌석 배치도를 불러오지 못했어요',
  retry: '다시 시도',
  accessRefresh: '새로고침',
  noSeatsSelected: '선택한 좌석 없음',
  findBestSeatsCta: '추천 좌석 찾기',
  organizerNote: '주최 측 안내',
  accessiblePhysicalSeat: '장애인 편의 좌석',
  emptyWheelchairSpace: '빈 휠체어석',
  findSeatsTogether: '연석 찾기',
  aboutBestSeats: '연석 찾기 안내',
  closestGroupChosenInstantly: '가장 가까운 연석을 바로 골라 드려요.',
  hideLimitedView: '시야 제한석 숨기기',
  colorblindSafe: '색각 이상자용 색상',
  notAvailable: '선택 불가',
  viewGroupTitle: '보기',
  restrictedView: '시야 제한석',
  obstructedView: '시야 방해석',
  premiumSeat: '프리미엄 좌석',
  continueWord: '계속',
  allFloors: '전체 층',
  previousSection: '이전 구역',
  nextSection: '다음 구역',
  addSeat: '좌석 추가',
  added: '추가됨',
  sectionWord: '구역',
  rowWord: '열',
  seatWord: '좌석',
  seeItIn3D: '3D로 보기',
  viewFromThisSeat: '이 좌석 시야',
  allPrices: '전체 가격',
  ticketPrices: '티켓 가격',
  yourSeats: '내 좌석',
  ticketType: '티켓 종류',
  tierCompanionGuidance: '옆 휠체어석과 함께 예매해야 해요',
  findingBestSeats: '추천 좌석을 찾는 중…',
  findSeats: '좌석 찾기',
  expandCart: '티켓 패널 열기',
  collapseCart: '티켓 패널 접기',
  continueToCheckout: '결제하기',
  secureMore: '추가 확보',
  selectSeats: '좌석 선택',
  pickYourSeats: '좌석 선택',
  salesClosedPill: '판매 종료',
  salesClosedCta: '판매 종료',
  confirmOrCancelSeat: '이 좌석을 확정하거나 취소해 주세요',
  securingSeats: '좌석을 확보하는 중…',
  openingCheckout: '안전 결제창을 여는 중…',
  testModeExplained: '실제 예매가 아니며 카드 결제도 되지 않아요',
  displayOptions: '표시 옵션',
  companionSeatsNote: '옆 동반자석은 계속 선택할 수 있어요',
  zoomIn: '확대',
  zoomOut: '축소',
  rotateVenue: '드래그해서 공연장 회전',
  moveVenue: '드래그해서 공연장 이동',
  mapView: '배치도',
  flat2dMap: '2D 평면 배치도',
  interactive3dVenueView: '인터랙티브 3D 공연장 보기',
  venueView: '공연장 보기',
  holdLapsedTitle: '좌석이 해제됐어요',
  salesClosed: '판매 종료',
  salesClosedCopy: '이 공연의 티켓 판매가 종료됐어요.',
  salesClosedToast: '이 공연은 판매가 종료됐어요.',
  soldOutEyebrow: '이 공연',
  soldOutTitle: '매진',
  soldOutCopy: '현재 이 공연에 예매 가능한 지정석이 없어요.',
  holdExpired: '좌석 확보 시간이 끝나 좌석이 해제됐어요. 다시 선택해 주세요.',
  addingEllipsis: '추가 중…',
  moreTimeAdded: '시간이 연장됐어요. 좌석은 계속 확보돼 있어요.',
  couldNotAddMoreTime: '시간을 연장하지 못했어요. 지금 바로 결제를 진행해 주세요.',
  seatsJustTaken: '방금 일부 좌석이 예매됐어요. 다시 선택해 주세요.',
  allSetTitle: '예매가 완료됐어요',
  confirmedAndOnWay: '예매 확정. 확인 메일이 곧 도착해요.',
  backToMap: '배치도로 돌아가기',
  mapDidNotLoad: '좌석 배치도를 불러오지 못했어요',
  checkConnection: '인터넷 연결을 확인하고 다시 시도해 주세요.',
  accessPausedTitle: '지금은 이 좌석들이 보류 중이에요',
  accessPausedCopy: '주최 측에서 이 좌석 선택을 잠시 중지했어요. 몇 분 뒤 다시 시도해 주세요.',
  accessRevokedTitle: '더 이상 유효하지 않은 링크예요',
  accessRevokedCopy: '이 좌석을 계속 예매하려면 링크를 보내 준 곳에 새 링크를 요청해 주세요.',
  accessUnverifiedTitle: '접근 권한을 확인하지 못했어요',
  accessUnverifiedCopy:
      '예매 가능으로 표시된 좌석은 계속 예매할 수 있어요. 나머지 좌석은 이 링크를 보내 준 곳에 문의해 주세요.',
  generalAdmission: '비지정석',
  numberOfGuests: '인원 수',
  chooseGuestsCopy: '함께 앉을 인원을 선택해 주세요. 이 테이블은 일행 전용으로 확보돼요.',
  fewerGuests: '인원 줄이기',
  moreGuests: '인원 늘리기',
  selectTable: '테이블 선택',
  updateTable: '테이블 변경',
  removeWord: '삭제',
  floorWord: '층',
  totalWord: '합계',
  chooseSeats: '좌석 선택',
  chooseTickets: '티켓 선택',
  placeWord: '자리',
  ticketWord: '티켓',
  passport: '좌석 프로필',
  venue3D: '3D',
  venueZone: '공연장 존',
  venueMapHint:
      '좌석은 배치도 주변의 컨트롤로 선택해요. 위쪽의 가격 바, 아래쪽의 구역 컨트롤, 맨 아래의 티켓 패널을 이용해 주세요.',
  previousSeat: '이전 좌석',
  nextSeat: '다음 좌석',
  orbitMode: '공연장 회전',
  panMode: '공연장 이동',
  openInteractive3dVenue: '인터랙티브 3D 공연장 열기',
  showSeatsFor: '다음 조건의 좌석 표시',
  accessJumpFirstSection: '첫 번째 구역으로 이동',
  accessJumpNextSection: '다음 구역으로 이동',
  fewerTickets: '티켓 줄이기',
  moreTickets: '티켓 늘리기',
  addTickets: '티켓 추가',
  noSelectableSeats: '현재 선택할 수 있는 좌석이 없어요.',
  confirmYourTickets: '티켓 확정',
  seatsSecuredOpeningCheckout: '좌석을 확보했어요. 결제창을 여는 중…',
  holdInCheckoutTitle: '좌석이 이미 결제 중이에요',
  holdInCheckoutBody:
      '좌석을 유지하려면 결제를 완료해 주세요. 다른 좌석을 고르려면 먼저 이 좌석을 해제해 주세요. 해제한 좌석은 다시 판매돼요.',
  releaseAndChangeSeats: '해제하고 좌석 변경',
  holdAlreadyHeldTitle: '좌석이 이미 확보돼 있어요',
  holdAlreadyHeldBody: '좌석을 유지하려면 결제를 계속해 주세요.',
  accessExpiredTitle: '좌석 선택 세션이 만료됐어요',
  accessExpiredCopy:
      '계속하려면 좌석 배치도를 새로고침해 주세요. 장바구니에 담긴 좌석은 타이머가 끝날 때까지 확보돼 있어요.',
  dismissError: '오류 닫기',
  testModeLong: '테스트 모드 · 실제 예매 없음',
  accessNeeds: <String, String>{
    'wheelchair': '휠체어석',
    'companion': '동반자석',
    'semi-ambulatory': '거동 불편',
    'designated-aisle': '통로석 / 옮겨 앉기',
    'step-free': '계단 없음',
    'hearing': '청각 보조',
    'cart': '실시간 자막',
    'sign-language': '수어 통역',
    'low-vision': '저시력',
    'sensory-friendly': '감각 친화',
    'plus-size': '넓은 좌석',
    'lift-armrest': '팔걸이 올림',
  },
  seatsLeft: _seatsLeftKo,
  moreCount: _moreCountKo,
  addMinutes: _addMinutesKo,
  fromPrice: _fromPriceKo,
  sightline: _sightlineKo,
  secureMoreAndCheckout: _secureMoreAndCheckoutKo,
  accessFreeCount: _accessFreeCountKo,
  seatJustTakenByAnother: _seatJustTakenByAnotherKo,
  peekSecured: _peekSecuredKo,
  venueMap: _venueMapKo,
  accessibleStep: _accessibleStepKo,
  chooseMinMaxGuests: _chooseMinMaxGuestsKo,
  chooseMore: _chooseMoreKo,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeKo,
  ticketCount: _ticketCountKo,
  findBestSeats: _findBestSeatsKo,
  reselectSeats: _reselectSeatsKo,
  seatsFree: _seatsFreeKo,
  seatsLeftInSection: _seatsLeftInSectionKo,
  holdLapsedStillFree: _holdLapsedStillFreeKo,
  holdLapsedSomeTaken: _holdLapsedSomeTakenKo,
  holdLapsedAllTaken: _holdLapsedAllTakenKo,
  accessibleSections: _accessibleSectionsKo,
  placesAvailable: _placesAvailableKo,
  removeTickets: _removeTicketsKo,
  holdMinutesLeft: _holdMinutesLeftKo,
  holdSecondsLeft: _holdSecondsLeftKo,
  holdLapsedBody: _holdLapsedBodyKo,
  seatsNotRecovered: _seatsNotRecoveredKo,
  continueWithTotal: _continueWithTotalKo,
);
