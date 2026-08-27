/// Three sections in snapshot order, for dock-bar stepping.
List<Object?> pickerSections() => <Object?>[
      <String, Object?>{
        'id': 'section-a',
        'label': 'Gallery',
        'color': '#635BFF',
        'seatsLeft': 74,
      },
      <String, Object?>{
        'id': 'section-b',
        'label': 'Terrace',
        'color': '#22A06B',
        'seatsLeft': 12,
      },
      <String, Object?>{
        'id': 'section-c',
        'label': 'Orchestra',
        'color': '#E5A100',
        'seatsLeft': null,
      },
    ];

Map<String, Object?> pickerSnapshot({
  int revision = 1,
  String sessionId = 'session-1',
  String? holdOwner,
  bool withSelection = true,
  String rung = 'seats',
  String focusedSectionId = 'section-a',
  List<Object?>? sections,
  List<Object?>? cartItems,
  int? ticketCount,
  double? cartTotal,
  bool testEvent = true,
}) {
  final lines = withSelection
      ? <Object?>[
          <String, Object?>{
            'lineKey': 'seat:A-1:adult',
            'label': 'A-1',
            'displayLabel': 'Row A, Seat 1',
            'displayType': 'Seat',
            'objectId': 'seat-a-1',
            'objectType': 'seat',
            'categoryKey': 'standard',
            'tierId': 'adult',
            'unitPrice': 25.0,
            'currency': 'EUR',
            'quantity': 1,
          },
        ]
      : <Object?>[];
  final hold = holdOwner == null
      ? <String, Object?>{
          'active': false,
          'expiresAt': null,
          'ownership': null,
        }
      : <String, Object?>{
          'active': true,
          'expiresAt': 1999999999000.0,
          'ownership': holdOwner,
        };

  return <String, Object?>{
    'schema': 'seatlayer.picker.snapshot/1',
    'sessionId': sessionId,
    'revision': revision,
    'event': <String, Object?>{
      'key': 'ev_test',
      'name': 'Mobile Test Event',
      'mode': testEvent ? 'test' : 'live',
      'currency': 'EUR',
      'venue': 'Riverside Auditorium',
      'salesClosed': false,
    },
    'branding': <String, Object?>{
      'brandName': 'Reference app',
      'attributionRequired': true,
      'accent': '#635BFF',
    },
    'features': <String, Object?>{
      'bestAvailable': true,
      'floors': true,
      'venue3d': true,
      'seatView': true,
      'accessibilityFilter': true,
    },
    'catalog': <String, Object?>{
      'categories': <Object?>[
        <String, Object?>{
          'key': 'standard',
          'label': 'Standard',
          'color': '#635BFF',
          'priceMin': 25.0,
          'priceMax': 25.0,
          'available': 42,
          'notForSale': false,
          'tiers': <Object?>[
            <String, Object?>{
              'id': 'adult',
              'name': 'Adult',
              'price': 25.0,
            },
          ],
        },
      ],
      'gaAreas': <Object?>[],
      'zones': <Object?>[],
      'sections': sections ?? <Object?>[],
      'bestAvailableZones': <Object?>[],
    },
    'map': <String, Object?>{
      'rung': rung,
      'viewMode': 'flat',
      'buyerView': 'map',
      'view3dNavigationMode': 'orbit',
      'activeFloorId': 'ground',
      'floors': <Object?>[
        <String, Object?>{'id': 'ground', 'name': 'Ground floor'},
      ],
      'colorblindSafe': false,
      'hideLimitedView': false,
      'canZoomIn': true,
      'canZoomOut': true,
      'categoryFilter': <Object?>['standard'],
      'focusedSectionId': rung == 'overview' ? null : focusedSectionId,
      'focusedSection': rung == 'overview'
          ? null
          : (sections ?? <Object?>[])
                  .cast<Map<String, Object?>>()
                  .where((item) => item['id'] == focusedSectionId)
                  .firstOrNull ??
              <String, Object?>{
                'id': focusedSectionId,
                'label': 'Section A',
              },
    },
    'selection': <String, Object?>{
      'seats': withSelection
          ? <Object?>[
              <String, Object?>{
                'id': 'seat-a-1',
                'label': 'A-1',
                'displayLabel': 'Row A, Seat 1',
                'displayType': 'Row',
                'objectId': 'row-a',
                'objectType': 'seat',
                'sectionLabel': 'Gallery',
                'rowLabel': 'A',
                'seatNumber': '1',
                'categoryKey': 'standard',
                'price': 25.0,
                'currency': 'EUR',
                'tiers': <Object?>[
                  <String, Object?>{
                    'id': 'adult',
                    'name': 'Adult',
                    'price': 25.0,
                  },
                ],
                'tierId': 'adult',
              },
            ]
          : <Object?>[],
      'validity': <String, Object?>{
        'isValid': true,
        'count': withSelection ? 1 : 0,
        'required': 0,
        'remaining': 0,
      },
      'maxSelection': 10,
    },
    'cart': <String, Object?>{
      'items': cartItems ?? lines,
      'quantity': ticketCount ?? (withSelection ? 1 : 0),
      'total': cartTotal ?? (withSelection ? 25.0 : 0.0),
      'currency': 'EUR',
    },
    'hold': hold,
    'access': <String, Object?>{
      'configured': false,
      'status': 'public',
    },
  };
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

Map<String, Object?> checkoutHandoff() => <String, Object?>{
      'holdId': 'hold-1',
      'expiresAt': 1999999999000.0,
      'currency': 'EUR',
      'lineItems': (pickerSnapshot(holdOwner: 'host')['cart']!
          as Map<String, Object?>)['items'],
      'total': 25.0,
    };

/// A cart holding [count] consecutive seats in one row.
Map<String, Object?> snapshotWithTicketCount(int count, {int revision = 2}) {
  final snapshot = pickerSnapshot(revision: revision);
  final cart = snapshot['cart']! as Map<String, Object?>;
  final selection = snapshot['selection']! as Map<String, Object?>;
  final originalLine = Map<String, Object?>.from(
    (cart['items']! as List<Object?>).single! as Map<String, Object?>,
  );
  final originalSeat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  cart['items'] = List<Object?>.generate(count, (index) {
    final number = index + 1;
    return <String, Object?>{
      ...originalLine,
      'lineKey': 'seat:A-$number:adult',
      'label': 'A-$number',
      'displayLabel': 'Row A, Seat $number',
      'objectId': 'seat-a-$number',
    };
  });
  cart['quantity'] = count;
  cart['total'] = count * 25.0;
  selection['seats'] = List<Object?>.generate(count, (index) {
    final number = index + 1;
    return <String, Object?>{
      ...originalSeat,
      'id': 'seat-a-$number',
      'label': 'A-$number',
      'displayLabel': 'Row A, Seat $number',
      'seatNumber': '$number',
    };
  });
  selection['validity'] = <String, Object?>{
    'isValid': true,
    'count': count,
    'required': 0,
    'remaining': 0,
  };
  return snapshot;
}

/// A venue with zones and several categories, focused on one section.
Map<String, Object?> bestAvailableSnapshot({
  List<Object?> categoryFilter = const <Object?>['standard'],
}) {
  final snapshot = pickerSnapshot(withSelection: false);
  final catalog = snapshot['catalog']! as Map<String, Object?>;
  catalog['sections'] = <Object?>[
    <String, Object?>{
      'id': 'gallery-a',
      'label': 'Gallery A',
      'zoneId': 'gallery',
    },
  ];
  catalog['bestAvailableZones'] = <Object?>[
    <String, Object?>{'id': 'gallery', 'label': 'Gallery'},
    <String, Object?>{'id': 'orchestra', 'label': 'Orchestra'},
  ];
  catalog['categories'] = <Object?>[
    ...catalog['categories']! as List<Object?>,
    <String, Object?>{
      'key': 'premium',
      'label': 'Premium',
      'color': '#D97706',
      'priceMin': 50.0,
      'priceMax': 50.0,
      'available': 12,
      'notForSale': false,
      'tiers': <Object?>[],
    },
    <String, Object?>{
      'key': 'internal',
      'label': 'Internal',
      'color': '#64748B',
      'priceMin': 0.0,
      'priceMax': 0.0,
      'available': 5,
      'notForSale': true,
      'tiers': <Object?>[],
    },
  ];
  final map = snapshot['map']! as Map<String, Object?>;
  map['focusedSectionId'] = 'gallery-a';
  map['categoryFilter'] = categoryFilter;
  return snapshot;
}

/// A Best Available result: seats held, and NO renderer selection behind them.
///
/// This is the shape that made the address disappear. Best Available clears
/// the selection before it holds and a resumed hold was never in one, so a
/// host joining cart lines back to `selection` finds nothing for exactly the
/// two paths where the buyer did not tap the seat. Each line carries its own
/// section, row and seat number instead.
Map<String, Object?> bestAvailableHeldSnapshot({
  int count = 2,
  int firstSeat = 9,
  String sectionLabel = 'Choir',
  String rowLabel = 'A',
  bool identityOnLines = true,
}) {
  final snapshot = pickerSnapshot(holdOwner: 'picker', withSelection: false);
  final cart = snapshot['cart']! as Map<String, Object?>;
  cart['items'] = List<Object?>.generate(count, (index) {
    final number = firstSeat + index;
    return <String, Object?>{
      'lineKey': 'seat:$rowLabel-$number:adult',
      'label': '$rowLabel-$number',
      'objectId': 'seat-$rowLabel-$number',
      'objectType': 'seat',
      'categoryKey': 'standard',
      'tierId': 'adult',
      'unitPrice': 25.0,
      'currency': 'EUR',
      'quantity': 1,
      if (identityOnLines) ...<String, Object?>{
        'seatId': 'seat-$rowLabel-$number',
        'sectionLabel': sectionLabel,
        // Charts are commonly authored with fully qualified row names.
        'rowLabel': '$sectionLabel $rowLabel',
        'seatNumber': '$number',
      },
    };
  });
  cart['quantity'] = count;
  cart['total'] = count * 25.0;
  return snapshot;
}
