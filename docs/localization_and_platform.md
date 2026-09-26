# Localization and platform baseline (Phase 8)

## Localization

Flutter 3.47.5 generates `AppLocalizations` from `lib/l10n/app_en.arb` using
`l10n.yaml`. Run `flutter gen-l10n` after changing an ARB file. Generated Dart
files live in `lib/l10n/generated/` and are committed with their source; no
synthetic `package:flutter_gen` import is used. `AppRoot` installs the generated
delegates and supported locales. Shared states, sample screens, routing, the
Component Showcase, and failure presentation use these messages.

To add a language, add `lib/l10n/app_<locale>.arb`, translate the English keys,
run `flutter gen-l10n`, and test the resulting locale with its text direction
and longer copy. The English template demonstrates string parameters, ICU
plurals, and `intl` date, time, number, and currency formatting. Date/time
formatters obtain locale data through Flutter's localization delegates; direct
non-widget tests initialize date symbols explicitly.

## Accessibility review

Shared buttons retain at least 48 logical pixel heights through `AppTheme`.
Loading indicators, empty/error icons, and retry actions have localized
semantics. Empty, error, and offline states use text and icons so status is not
communicated by color alone. State content scrolls when enlarged text needs
more height. The Showcase and sample entry screens stay within safe areas;
their long content scrolls. Inputs keep Flutter's native labels, focus,
disabled state, and keyboard behavior. Layout uses symmetric padding and
direction-aware `start` alignment; no hardcoded left/right placement remains.

Widget tests exercise 200–250% text scale, a narrow phone with simulated top
and bottom insets, light and dark theme, semantics, tap targets, and key
foreground/background contrast ratios. A temporary golden capture was visually
reviewed in both themes at 180% text with long copy and safe-area insets; text
wrapped without clipping or overflow. TalkBack and VoiceOver should also be
checked on target devices before a product release.

## Platform review

The Android runner was compared with a fresh Flutter 3.47.5 template. Its
activity, launch/normal themes, and SDK defaults match the template; flavor
labels and backup exclusions are intentional additions. The pinned Flutter
Gradle extension targets Android API 36. Flutter uses edge-to-edge by default
at that target, and the app does not opt out. Scaffolds use app bars and safe
areas to keep content away from system overlays.

The iOS runner was compared with the same fresh template. `AppDelegate`
implements `FlutterImplicitEngineDelegate`, `SceneDelegate` extends
`FlutterSceneDelegate`, and `Info.plist` retains the current scene manifest.
The project-specific differences are flavor display names and identifiers.
The dev iOS simulator build and Android debug build verify the platform setup.
