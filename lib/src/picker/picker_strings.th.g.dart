// GENERATED — do not edit.
//
// Source: design/locale_strings.json (th)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftTh(int count) => 'เหลือ $count';

String _moreCountTh(int count) => '+อีก $count';

String _addMinutesTh(int minutes) => '+$minutes นาที';

String _fromPriceTh(String money) => 'เริ่มต้น $money';

String _sightlineTh(String metres) => 'ห่างจากเวที ≈ $metres ม.';

String _secureMoreAndCheckoutTh(int count) => 'กันเพิ่มอีก $count และชำระเงิน';

String _accessFreeCountTh(int count) => 'ว่าง $count';

String _seatJustTakenByAnotherTh(String label) =>
    'ที่นั่ง $label เพิ่งถูกผู้ซื้อคนอื่นจองไป';

String _peekSecuredTh(int count, String total) =>
    '✓ กันไว้แล้ว $count · $total ยังไม่มีการตัดเงิน';

String _ticketCountTh(int count) => count == 1 ? '$count ใบ' : '$count ใบ';

String _findBestSeatsTh(int count) => count == 1
    ? 'หาที่นั่งที่ดีที่สุด $count ที่'
    : 'หาที่นั่งที่ดีที่สุด $count ที่';

String _reselectSeatsTh(int count) =>
    count == 1 ? 'เลือกอีกครั้ง' : 'เลือกอีกครั้ง';

String _seatsFreeTh(int count) =>
    count == 1 ? '$count ที่นั่ง' : '$count ที่นั่ง';

String _seatsLeftInSectionTh(int count) =>
    count == 1 ? 'เหลือ $count ที่นั่ง' : 'เหลือ $count ที่นั่ง';

String _holdLapsedStillFreeTh(int count) => count == 1
    ? 'เวลากันที่นั่งหมดระหว่างที่คุณไม่อยู่ ที่นั่งที่คุณเลือกยังว่างอยู่'
    : 'เวลากันที่นั่งหมดระหว่างที่คุณไม่อยู่ ที่นั่งที่คุณเลือกยังว่างอยู่';

String _holdLapsedSomeTakenTh(int count) => count == 1
    ? 'เวลากันที่นั่งหมดระหว่างที่คุณไม่อยู่ และมีผู้อื่นจองไปแล้ว $count ที่ ที่เหลือยังว่างอยู่'
    : 'เวลากันที่นั่งหมดระหว่างที่คุณไม่อยู่ และมีผู้อื่นจองไปแล้ว $count ที่ ที่เหลือยังว่างอยู่';

String _holdLapsedAllTakenTh(int count) => count == 1
    ? 'เวลากันที่นั่งหมดระหว่างที่คุณไม่อยู่ และที่นั่งที่คุณเลือกมีผู้อื่นจองไปแล้ว'
    : 'เวลากันที่นั่งหมดระหว่างที่คุณไม่อยู่ และที่นั่งที่คุณเลือกมีผู้อื่นจองไปแล้ว';

String _continueWithTotalTh(String money) => 'ดำเนินการต่อ \u00b7 $money';

/// The `th` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsTh = SeatLayerPickerStrings(
  close: 'ปิด',
  overview: 'สถานที่',
  backToVenue: 'กลับไปที่สถานที่',
  cancel: 'ยกเลิก',
  select: 'เลือก',
  removeSeat: 'นำที่นั่งออก',
  viewFromHere: 'มุมมองจากตรงนี้',
  openVenue360: 'เปิดภาพ 360° ของสถานที่',
  recentre: 'กลับมาที่เวที',
  viewFromYourSeat: 'มุมมองจากที่นั่งของคุณ',
  emptyTrayHint: 'แตะที่นั่งบนผัง หรือให้เราเลือกที่นั่งว่างที่ดีที่สุดให้',
  anyTicketType: 'บัตรประเภทใดก็ได้',
  anyVenueZone: 'กลุ่มโซนใดก็ได้',
  bestSeats: 'ที่นั่งที่ดีที่สุด',
  showLess: 'แสดงน้อยลง',
  undo: 'เลิกทำ',
  holdAndCheckout: 'กันที่นั่งและชำระเงิน',
  poweredBy: 'ให้บริการโดย SeatLayer',
  testMode: 'โหมดทดสอบ',
  accessibility: 'ตัวเลือกการเข้าถึงและสี',
  accessibilityTitle: 'ตัวเลือกการเข้าถึงและสี',
  fitVenue: 'แสดงทั้งสถานที่',
  fitWholeVenue: 'แสดงทั้งสถานที่',
  loading: 'กำลังโหลดผังที่นั่ง…',
  errorMessage: 'โหลดผังที่นั่งไม่สำเร็จ',
  retry: 'ลองอีกครั้ง',
  accessRefresh: 'รีเฟรช',
  noSeatsSelected: 'ยังไม่ได้เลือกที่นั่ง',
  findBestSeatsCta: 'หาที่นั่งที่ดีที่สุด',
  organizerNote: 'หมายเหตุจากผู้จัดงาน',
  accessiblePhysicalSeat: 'ที่นั่งสำหรับผู้พิการ',
  emptyWheelchairSpace: 'ที่สำหรับรถเข็นที่ว่าง',
  findSeatsTogether: 'หาที่นั่งติดกัน',
  aboutBestSeats: 'เกี่ยวกับการหาที่นั่งติดกัน',
  closestGroupChosenInstantly: 'เลือกกลุ่มที่นั่งว่างที่ใกล้กันที่สุดให้ทันที',
  hideLimitedView: 'ซ่อนที่นั่งมุมมองจำกัด',
  colorblindSafe: 'สีสำหรับผู้ตาบอดสี',
  notAvailable: 'ไม่ว่าง',
  restrictedView: 'มุมมองจำกัด',
  obstructedView: 'มีสิ่งบดบังการมองเห็น',
  premiumSeat: 'ที่นั่งพรีเมียม',
  continueWord: 'ดำเนินการต่อ',
  allFloors: 'ทุกชั้น',
  previousSection: 'โซนก่อนหน้า',
  nextSection: 'โซนถัดไป',
  addSeat: 'เพิ่มที่นั่ง',
  added: 'เพิ่มแล้ว',
  sectionWord: 'โซน',
  rowWord: 'แถว',
  seatWord: 'ที่นั่ง',
  seeItIn3D: 'ดูแบบ 3D',
  viewFromThisSeat: 'มุมมองจากที่นั่งนี้',
  allPrices: 'ทุกราคา',
  ticketType: 'ประเภทบัตร',
  tierCompanionGuidance: 'ต้องจองคู่กับที่สำหรับรถเข็นที่อยู่ติดกัน',
  findingBestSeats: 'กำลังหาที่นั่งที่ดีที่สุด…',
  findSeats: 'หาที่นั่ง',
  expandCart: 'เปิดแผงบัตร',
  collapseCart: 'ย่อแผงบัตร',
  continueToCheckout: 'ไปที่หน้าชำระเงิน',
  secureMore: 'กันเพิ่ม',
  selectSeats: 'เลือกที่นั่ง',
  pickYourSeats: 'เลือกที่นั่ง',
  salesClosedPill: 'ปิดการขายแล้ว',
  salesClosedCta: 'ปิดการขาย',
  confirmOrCancelSeat: 'ยืนยันหรือยกเลิกที่นั่งนี้',
  securingSeats: 'กำลังกันที่นั่งให้คุณ…',
  openingCheckout: 'กำลังเปิดหน้าชำระเงินที่ปลอดภัย…',
  testModeExplained: 'การจองในหน้านี้เป็นการทดสอบ ไม่มีการตัดเงินจากบัตร',
  displayOptions: 'ตัวเลือกการแสดงผล',
  companionSeatsNote: 'ที่นั่งผู้ติดตามที่อยู่ข้างกันยังเลือกได้',
  zoomIn: 'ซูมเข้า',
  zoomOut: 'ซูมออก',
  rotateVenue: 'ลากเพื่อหมุนสถานที่',
  moveVenue: 'ลากเพื่อเลื่อนสถานที่',
  mapView: 'ผัง',
  flat2dMap: 'ผัง 2D',
  interactive3dVenueView: 'มุมมองสถานที่แบบ 3D ที่โต้ตอบได้',
  venueView: 'มุมมองสถานที่',
  holdLapsedTitle: 'ที่นั่งของคุณถูกปล่อยแล้ว',
  salesClosed: 'ปิดการขายแล้ว',
  salesClosedCopy: 'การขายบัตรของงานนี้สิ้นสุดแล้ว',
  salesClosedToast: 'งานนี้ปิดการขายแล้ว',
  soldOutEyebrow: 'งานนี้',
  soldOutTitle: 'บัตรหมด',
  soldOutCopy: 'ขณะนี้ไม่มีที่นั่งแบบระบุที่นั่งเหลือสำหรับงานนี้',
  holdExpired: 'หมดเวลากันที่นั่งแล้ว ที่นั่งถูกปล่อยกลับไปขาย กรุณาเลือกใหม่',
  addingEllipsis: 'กำลังเพิ่ม…',
  moreTimeAdded: 'เพิ่มเวลาแล้ว ที่นั่งของคุณยังถูกกันไว้',
  couldNotAddMoreTime: 'เพิ่มเวลาไม่ได้ กรุณาไปชำระเงินตอนนี้',
  seatsJustTaken: 'มีที่นั่งเพิ่งถูกจองไป กรุณาเลือกใหม่',
  allSetTitle: 'เรียบร้อยแล้ว',
  confirmedAndOnWay: 'ยืนยันแล้ว กำลังส่งอีเมลยืนยันถึงคุณ',
  backToMap: 'กลับไปที่ผัง',
  mapDidNotLoad: 'โหลดผังที่นั่งไม่สำเร็จ',
  checkConnection: 'ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง',
  accessPausedTitle: 'ที่นั่งเหล่านี้ถูกระงับชั่วคราว',
  accessPausedCopy:
      'ผู้จัดงานหยุดการเลือกที่นั่งส่วนนี้ชั่วคราว ลองใหม่อีกครั้งในอีกไม่กี่นาที',
  accessRevokedTitle: 'ลิงก์เข้าถึงนี้ใช้งานไม่ได้แล้ว',
  accessRevokedCopy:
      'ขอลิงก์ใหม่จากผู้ที่ส่งลิงก์ให้คุณเพื่อจองที่นั่งเหล่านี้ต่อ',
  accessUnverifiedTitle: 'ยืนยันสิทธิ์เข้าถึงของคุณไม่ได้',
  accessUnverifiedCopy:
      'คุณยังจองที่นั่งที่แสดงว่าว่างได้ทั้งหมด ติดต่อผู้ที่ส่งลิงก์ให้คุณเพื่อขอสิทธิ์เข้าถึงส่วนที่เหลือ',
  generalAdmission: 'บัตรไม่ระบุที่นั่ง',
  numberOfGuests: 'จำนวนแขก',
  chooseGuestsCopy:
      'เลือกจำนวนแขกที่จะนั่งด้วยกัน โต๊ะนี้จะถูกกันไว้ให้กลุ่มของคุณเท่านั้น',
  fewerGuests: 'ลดจำนวนแขก',
  moreGuests: 'เพิ่มจำนวนแขก',
  selectTable: 'เลือกโต๊ะ',
  updateTable: 'อัปเดตโต๊ะ',
  removeWord: 'นำออก',
  floorWord: 'ชั้น',
  totalWord: 'รวม',
  accessNeeds: <String, String>{
    'wheelchair': 'ที่สำหรับรถเข็น',
    'companion': 'ที่นั่งผู้ติดตาม',
    'semi-ambulatory': 'เคลื่อนไหวไม่สะดวก',
    'designated-aisle': 'ริมทางเดิน / ย้ายที่',
    'step-free': 'ไม่มีบันได',
    'hearing': 'ช่วยฟัง',
    'cart': 'คำบรรยายสด',
    'sign-language': 'ภาษามือ',
    'low-vision': 'สายตาเลือนราง',
    'sensory-friendly': 'โซนเงียบ',
    'plus-size': 'ขนาดใหญ่',
    'lift-armrest': 'ที่วางแขนยกได้',
  },
  seatsLeft: _seatsLeftTh,
  moreCount: _moreCountTh,
  addMinutes: _addMinutesTh,
  fromPrice: _fromPriceTh,
  sightline: _sightlineTh,
  secureMoreAndCheckout: _secureMoreAndCheckoutTh,
  accessFreeCount: _accessFreeCountTh,
  seatJustTakenByAnother: _seatJustTakenByAnotherTh,
  peekSecured: _peekSecuredTh,
  ticketCount: _ticketCountTh,
  findBestSeats: _findBestSeatsTh,
  reselectSeats: _reselectSeatsTh,
  seatsFree: _seatsFreeTh,
  seatsLeftInSection: _seatsLeftInSectionTh,
  holdLapsedStillFree: _holdLapsedStillFreeTh,
  holdLapsedSomeTaken: _holdLapsedSomeTakenTh,
  holdLapsedAllTaken: _holdLapsedAllTakenTh,
  continueWithTotal: _continueWithTotalTh,
);
