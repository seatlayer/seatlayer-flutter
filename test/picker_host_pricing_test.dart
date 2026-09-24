import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';

void main() {
  group('SeatLayerPickerPricing → host-pricing-v1', () {
    test('a flat price travels as a number, a tiered one as { base, tiers }',
        () {
      const pricing = SeatLayerPickerPricing(
        categories: <String, SeatLayerCategoryPricing>{
          'gold': SeatLayerCategoryPricing(base: 486),
          'vip': SeatLayerCategoryPricing(
            base: 935,
            tiers: <String, double>{'child': 673},
          ),
          'kids': SeatLayerCategoryPricing(
            tiers: <String, double>{'u12': 120},
          ),
          'unset': SeatLayerCategoryPricing(),
        },
      );
      expect(pricing.toBridgeConfig(), <String, Object?>{
        'prices': <String, Object?>{
          'gold': 486.0,
          'vip': <String, Object?>{
            'base': 935.0,
            'tiers': <String, double>{'child': 673},
          },
          'kids': <String, Object?>{
            'tiers': <String, double>{'u12': 120},
          },
        },
      });
    });

    test('no category price means no pricing on the wire', () {
      expect(const SeatLayerPickerPricing().toBridgeConfig(), isNull);
      const formatterOnly = SeatLayerPickerOptions(
        pricing: SeatLayerPickerPricing(formatter: _kroner),
      );
      expect(formatterOnly.toBridgeConfig().containsKey('pricing'), isFalse);
    });

    test('the picker boots the runtime with the prices in init.config', () {
      const options = SeatLayerPickerOptions(
        pricing: SeatLayerPickerPricing(
          categories: <String, SeatLayerCategoryPricing>{
            'gold': SeatLayerCategoryPricing(base: 486),
          },
        ),
      );
      final payload = SeatLayerBridgeProfile.picker(
        config: options.toBridgeConfig(),
      ).initPayload(SeatLayerConfiguration(event: 'ev_dkk', currency: 'DKK'));
      final config = payload['config']! as Map<String, Object?>;
      expect(config['currency'], 'DKK');
      expect(config['pricing'], <String, Object?>{
        'prices': <String, Object?>{'gold': 486.0},
      });
    });

    test('equal prices build an equivalent profile, so nothing reboots', () {
      SeatLayerBridgeProfile profile(double gold) =>
          SeatLayerBridgeProfile.picker(
            config: SeatLayerPickerOptions(
              pricing: SeatLayerPickerPricing(
                categories: <String, SeatLayerCategoryPricing>{
                  'gold': SeatLayerCategoryPricing(base: gold),
                },
              ),
            ).toBridgeConfig(),
          );
      expect(profile(486).equivalentTo(profile(486)), isTrue);
      expect(profile(486).equivalentTo(profile(500)), isFalse);
    });
  });
}

String _kroner(double amount, String currency) => '$currency $amount';
