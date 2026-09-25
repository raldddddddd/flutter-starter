// A compile-time constant allows release builds to omit the showcase route.
const bool kEnableComponentShowcase = bool.fromEnvironment(
  'ENABLE_COMPONENT_SHOWCASE',
);
