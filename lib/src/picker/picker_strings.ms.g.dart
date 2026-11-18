// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ms)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftMs(int count) => 'Tinggal $count';

String _moreCountMs(int count) => '+$count lagi';

String _addMinutesMs(int minutes) => '+$minutes minit';

String _fromPriceMs(String money) => 'Dari $money';

String _sightlineMs(String metres) => '≈ $metres m ke pentas';

String _secureMoreAndCheckoutMs(int count) => 'Dapatkan $count lagi & bayar';

String _accessFreeCountMs(int count) => '$count kosong';

String _seatJustTakenByAnotherMs(String label) =>
    'Tempat duduk $label baru sahaja diambil pembeli lain.';

String _peekSecuredMs(int count, String total) =>
    '✓ $count ditahan · $total. Anda belum dicaj';

String _ticketCountMs(int count) =>
    count == 1 ? '$count tiket' : '$count tiket';

String _findBestSeatsMs(int count) => count == 1
    ? 'Cari $count tempat duduk terbaik'
    : 'Cari $count tempat duduk terbaik';

String _reselectSeatsMs(int count) =>
    count == 1 ? 'Pilih semula' : 'Pilih semula';

String _seatsFreeMs(int count) =>
    count == 1 ? '$count tempat duduk' : '$count tempat duduk';

String _seatsLeftInSectionMs(int count) =>
    count == 1 ? 'Tinggal $count tempat duduk' : 'Tinggal $count tempat duduk';

String _holdLapsedStillFreeMs(int count) => count == 1
    ? 'Masa tahanan anda tamat semasa anda tiada. Tempat duduk anda masih kosong.'
    : 'Masa tahanan anda tamat semasa anda tiada. Tempat duduk anda masih kosong.';

String _holdLapsedSomeTakenMs(int count) => count == 1
    ? 'Masa tahanan anda tamat semasa anda tiada, dan $count tempat duduk sudah diambil orang lain. Selebihnya masih kosong.'
    : 'Masa tahanan anda tamat semasa anda tiada, dan $count tempat duduk sudah diambil orang lain. Selebihnya masih kosong.';

String _holdLapsedAllTakenMs(int count) => count == 1
    ? 'Masa tahanan anda tamat semasa anda tiada, dan tempat duduk anda sudah diambil orang lain.'
    : 'Masa tahanan anda tamat semasa anda tiada, dan tempat duduk anda sudah diambil orang lain.';

String _continueWithTotalMs(String money) => 'Teruskan \u00b7 $money';

/// The `ms` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsMs = SeatLayerPickerStrings(
  close: 'Tutup',
  overview: 'Venue',
  backToVenue: 'Kembali ke venue',
  cancel: 'Batal',
  select: 'Pilih',
  removeSeat: 'Buang tempat duduk',
  viewFromHere: 'Pandangan dari sini',
  openVenue360: 'Buka foto venue 360°',
  recentre: 'Fokus semula pada pentas',
  viewFromYourSeat: 'pandangan dari tempat duduk anda',
  emptyTrayHint:
      'Ketik tempat duduk pada pelan, atau biar kami pilihkan yang terbaik untuk anda.',
  anyTicketType: 'Mana-mana jenis tiket',
  anyVenueZone: 'Mana-mana zon',
  bestSeats: 'Tempat duduk terbaik',
  showLess: 'Tunjuk kurang',
  undo: 'Buat asal',
  holdAndCheckout: 'Tahan tempat duduk & bayar',
  poweredBy: 'Dikuasakan oleh SeatLayer',
  testMode: 'MOD UJIAN',
  accessibility: 'Pilihan kebolehcapaian dan warna',
  accessibilityTitle: 'Pilihan kebolehcapaian dan warna',
  fitVenue: 'Tunjuk seluruh venue',
  fitWholeVenue: 'Tunjuk seluruh venue',
  loading: 'Memuatkan pelan tempat duduk…',
  errorMessage: 'Pelan tempat duduk gagal dimuatkan',
  retry: 'Cuba lagi',
  accessRefresh: 'Muat semula',
  noSeatsSelected: 'Belum ada tempat duduk dipilih',
  findBestSeatsCta: 'Cari tempat duduk terbaik',
  organizerNote: 'Nota penganjur',
  accessiblePhysicalSeat: 'Tempat duduk fizikal mesra OKU',
  emptyWheelchairSpace: 'Ruang kerusi roda kosong',
  findSeatsTogether: 'Cari tempat duduk bersebelahan',
  aboutBestSeats: 'Tentang mencari tempat duduk bersebelahan',
  closestGroupChosenInstantly:
      'Kumpulan tempat duduk terdekat yang tersedia, dipilih serta-merta.',
  hideLimitedView: 'Sembunyikan tempat duduk berpandangan terhad',
  colorblindSafe: 'Warna mesra buta warna',
  notAvailable: 'Tidak tersedia',
  restrictedView: 'Pandangan terhad',
  obstructedView: 'Pandangan terhalang',
  premiumSeat: 'Tempat duduk premium',
  continueWord: 'Teruskan',
  allFloors: 'Semua tingkat',
  previousSection: 'Seksyen sebelumnya',
  nextSection: 'Seksyen seterusnya',
  addSeat: 'Tambah tempat duduk',
  added: 'Ditambah',
  sectionWord: 'Seksyen',
  rowWord: 'Baris',
  seatWord: 'Tempat duduk',
  seeItIn3D: 'Lihat dalam 3D',
  viewFromThisSeat: 'Pandangan dari tempat duduk ini',
  allPrices: 'Semua harga',
  ticketType: 'Jenis tiket',
  tierCompanionGuidance: 'Mesti bersama ruang kerusi roda di sebelahnya',
  findingBestSeats: 'Mencari tempat duduk terbaik…',
  findSeats: 'Cari tempat duduk',
  expandCart: 'Buka panel tiket',
  collapseCart: 'Kecilkan panel tiket',
  continueToCheckout: 'Teruskan ke pembayaran',
  secureMore: 'Dapatkan lagi',
  selectSeats: 'Pilih tempat duduk',
  pickYourSeats: 'Pilih tempat duduk anda',
  salesClosedPill: 'Jualan ditutup',
  salesClosedCta: 'Jualan ditutup',
  confirmOrCancelSeat: 'Sahkan atau batalkan tempat duduk ini',
  securingSeats: 'Mendapatkan tempat duduk anda…',
  openingCheckout: 'Membuka halaman pembayaran selamat…',
  testModeExplained:
      'Tempahan di sini bukan tempahan sebenar dan kad tidak dicaj',
  displayOptions: 'Pilihan paparan',
  companionSeatsNote: 'Tempat duduk peneman di sebelahnya masih boleh dipilih',
  zoomIn: 'Zum masuk',
  zoomOut: 'Zum keluar',
  rotateVenue: 'Seret untuk memusingkan venue',
  moveVenue: 'Seret untuk mengalihkan venue',
  mapView: 'Pelan',
  flat2dMap: 'Pelan 2D',
  interactive3dVenueView: 'Paparan venue 3D interaktif',
  venueView: 'Paparan venue',
  holdLapsedTitle: 'Tempat duduk anda telah dilepaskan',
  salesClosed: 'Jualan ditutup',
  salesClosedCopy: 'Jualan tiket untuk acara ini sudah tamat.',
  salesClosedToast: 'Jualan untuk acara ini sudah ditutup.',
  soldOutEyebrow: 'Acara ini',
  soldOutTitle: 'Habis dijual',
  soldOutCopy:
      'Tiada tempat duduk bernombor yang tersedia untuk acara ini buat masa ini.',
  holdExpired:
      'Masa tahanan anda sudah tamat dan tempat duduk telah dilepaskan. Sila pilih semula.',
  addingEllipsis: 'Menambah…',
  moreTimeAdded: 'Masa telah ditambah. Tempat duduk anda masih ditahan.',
  couldNotAddMoreTime:
      'Masa tidak dapat ditambah. Sila terus ke pembayaran sekarang.',
  seatsJustTaken:
      'Satu atau lebih tempat duduk baru sahaja diambil. Sila pilih semula.',
  allSetTitle: 'Semua sudah siap',
  confirmedAndOnWay: 'disahkan. Pengesahan sedang dihantar.',
  backToMap: 'Kembali ke pelan',
  mapDidNotLoad: 'Pelan tempat duduk gagal dimuatkan',
  checkConnection: 'Semak sambungan anda dan cuba lagi.',
  accessPausedTitle: 'Tempat duduk ini sedang ditahan',
  accessPausedCopy:
      'Penganjur telah menghentikan sementara pilihan ini. Cuba lagi dalam beberapa minit.',
  accessRevokedTitle: 'Pautan akses ini sudah tidak aktif',
  accessRevokedCopy:
      'Minta pautan baharu daripada pihak yang menghantarnya untuk terus menempah tempat duduk ini.',
  accessUnverifiedTitle: 'Akses anda tidak dapat disahkan',
  accessUnverifiedCopy:
      'Anda masih boleh menempah apa sahaja yang ditunjukkan sebagai tersedia. Hubungi pihak yang menghantar pautan ini untuk akses ke tempat duduk lain.',
  generalAdmission: 'Kemasukan am',
  numberOfGuests: 'Bilangan tetamu',
  chooseGuestsCopy:
      'Pilih bilangan tetamu yang akan duduk bersama. Meja ini ditahan khas untuk kumpulan anda.',
  fewerGuests: 'Kurangkan tetamu',
  moreGuests: 'Tambah tetamu',
  selectTable: 'Pilih meja',
  updateTable: 'Kemas kini meja',
  removeWord: 'Buang',
  floorWord: 'Tingkat',
  totalWord: 'Jumlah',
  accessNeeds: <String, String>{
    'wheelchair': 'Ruang kerusi roda',
    'companion': 'Tempat duduk peneman',
    'semi-ambulatory': 'Pergerakan terhad',
    'designated-aisle': 'Lorong / pindah',
    'step-free': 'Tanpa tangga',
    'hearing': 'Alat bantu dengar',
    'cart': 'Sari kata langsung',
    'sign-language': 'Bahasa isyarat',
    'low-vision': 'Rabun',
    'sensory-friendly': 'Mesra deria',
    'plus-size': 'Saiz besar',
    'lift-armrest': 'Letak tangan angkat',
  },
  seatsLeft: _seatsLeftMs,
  moreCount: _moreCountMs,
  addMinutes: _addMinutesMs,
  fromPrice: _fromPriceMs,
  sightline: _sightlineMs,
  secureMoreAndCheckout: _secureMoreAndCheckoutMs,
  accessFreeCount: _accessFreeCountMs,
  seatJustTakenByAnother: _seatJustTakenByAnotherMs,
  peekSecured: _peekSecuredMs,
  ticketCount: _ticketCountMs,
  findBestSeats: _findBestSeatsMs,
  reselectSeats: _reselectSeatsMs,
  seatsFree: _seatsFreeMs,
  seatsLeftInSection: _seatsLeftInSectionMs,
  holdLapsedStillFree: _holdLapsedStillFreeMs,
  holdLapsedSomeTaken: _holdLapsedSomeTakenMs,
  holdLapsedAllTaken: _holdLapsedAllTakenMs,
  continueWithTotal: _continueWithTotalMs,
);
