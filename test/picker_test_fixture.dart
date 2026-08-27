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
      'mode': 'test',
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
