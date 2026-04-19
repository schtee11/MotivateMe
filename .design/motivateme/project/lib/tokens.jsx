// tokens.jsx — MotivateMe "Morning Light" design system
// Exposes: MMTokens(primaryHue, dark) → { color, type, space, radius, elev, motion }

const HUE_PRESETS = {
  peach: {
    name: 'Sunrise Peach',
    // oklch-based warm tones
    50:  'oklch(0.97 0.024 45)',
    100: 'oklch(0.94 0.045 45)',
    200: 'oklch(0.88 0.075 42)',
    300: 'oklch(0.82 0.095 40)',
    400: 'oklch(0.76 0.115 38)',
    500: 'oklch(0.70 0.125 36)', // primary — #E89F80-adjacent
    600: 'oklch(0.62 0.130 32)',
    700: 'oklch(0.52 0.120 30)',
    800: 'oklch(0.40 0.095 28)',
    900: 'oklch(0.30 0.070 28)',
  },
  honey: {
    name: 'Honey',
    50:  'oklch(0.97 0.028 85)',
    100: 'oklch(0.94 0.055 82)',
    200: 'oklch(0.88 0.085 78)',
    300: 'oklch(0.82 0.110 75)',
    400: 'oklch(0.76 0.130 72)',
    500: 'oklch(0.72 0.135 70)',
    600: 'oklch(0.62 0.125 65)',
    700: 'oklch(0.52 0.105 60)',
    800: 'oklch(0.40 0.085 55)',
    900: 'oklch(0.30 0.060 50)',
  },
  terracotta: {
    name: 'Terracotta',
    50:  'oklch(0.96 0.020 35)',
    100: 'oklch(0.92 0.045 32)',
    200: 'oklch(0.85 0.075 28)',
    300: 'oklch(0.77 0.105 25)',
    400: 'oklch(0.69 0.125 22)',
    500: 'oklch(0.61 0.140 20)',
    600: 'oklch(0.53 0.135 18)',
    700: 'oklch(0.44 0.115 18)',
    800: 'oklch(0.34 0.090 18)',
    900: 'oklch(0.26 0.065 20)',
  },
};

// Sage secondary is constant across hue choices — it's the "grounding" anchor
const SAGE = {
  50:  'oklch(0.96 0.010 135)',
  100: 'oklch(0.92 0.018 135)',
  200: 'oklch(0.86 0.028 135)',
  300: 'oklch(0.78 0.035 135)',
  400: 'oklch(0.70 0.040 135)',
  500: 'oklch(0.62 0.042 135)', // #8A9A7B-adjacent
  600: 'oklch(0.53 0.040 135)',
  700: 'oklch(0.43 0.035 135)',
  800: 'oklch(0.33 0.028 135)',
  900: 'oklch(0.24 0.020 135)',
};

// Warm neutrals — not gray, faintly tinted toward hue 60 (coffee/sand)
const WARM_NEUTRAL_LIGHT = {
  0:   '#FFFFFF',
  50:  'oklch(0.985 0.003 60)',  // page bg
  100: 'oklch(0.970 0.005 60)',  // elevated surface
  150: 'oklch(0.955 0.006 60)',  // card bg
  200: 'oklch(0.930 0.007 60)',  // separator / field bg
  300: 'oklch(0.880 0.008 60)',
  400: 'oklch(0.780 0.008 60)',  // placeholder text
  500: 'oklch(0.640 0.009 60)',  // tertiary text
  600: 'oklch(0.510 0.010 60)',  // secondary text
  700: 'oklch(0.380 0.010 60)',
  800: 'oklch(0.260 0.010 60)',  // primary text
  900: 'oklch(0.180 0.008 60)',
};

const WARM_NEUTRAL_DARK = {
  0:   '#000000',
  50:  'oklch(0.165 0.008 60)',  // page bg — warm coffee, not black
  100: 'oklch(0.200 0.009 60)',  // elevated surface
  150: 'oklch(0.225 0.010 60)',  // card bg
  200: 'oklch(0.260 0.010 60)',  // elevated card
  300: 'oklch(0.310 0.012 60)',  // modal / sheet
  400: 'oklch(0.400 0.010 60)',
  500: 'oklch(0.520 0.010 60)',  // tertiary
  600: 'oklch(0.650 0.010 60)',  // secondary
  700: 'oklch(0.780 0.008 60)',
  800: 'oklch(0.900 0.006 60)',
  900: 'oklch(0.970 0.004 60)',  // primary text
};

function MMTokens(primaryHue = 'peach', dark = false) {
  const p = HUE_PRESETS[primaryHue] || HUE_PRESETS.peach;
  const n = dark ? WARM_NEUTRAL_DARK : WARM_NEUTRAL_LIGHT;

  return {
    color: {
      // Brand
      primary:       p[500],
      primaryHover:  p[600],
      primaryMuted:  dark ? p[800] : p[100],
      primaryTint:   dark ? 'oklch(0.225 0.045 36)' : p[50],
      onPrimary:     '#FFFFFF',

      secondary:     SAGE[500],
      secondaryMuted: dark ? SAGE[800] : SAGE[100],
      secondaryTint: dark ? 'oklch(0.225 0.020 135)' : SAGE[50],

      // Semantic — all within warm family
      success:       SAGE[500],          // sage = healthy
      successTint:   dark ? 'oklch(0.225 0.020 135)' : SAGE[100],
      warning:       'oklch(0.75 0.115 75)',  // honey amber
      warningTint:   dark ? 'oklch(0.28 0.055 75)' : 'oklch(0.96 0.040 75)',
      info:          'oklch(0.68 0.060 220)', // dusty blue, low chroma
      infoTint:      dark ? 'oklch(0.26 0.030 220)' : 'oklch(0.96 0.020 220)',
      error:         'oklch(0.60 0.135 25)',  // warm clay red
      errorTint:     dark ? 'oklch(0.25 0.060 25)' : 'oklch(0.96 0.035 25)',

      // Surfaces (iOS-style elevation layers)
      bg:            n[50],
      surface:       dark ? n[100] : '#FFFFFF',
      surfaceRaised: dark ? n[150] : '#FFFFFF',
      surfaceCard:   dark ? n[150] : '#FFFFFF',
      surfaceElevated: dark ? n[200] : '#FFFFFF',
      surfaceModal:  dark ? n[300] : '#FFFFFF',
      surfaceInput:  dark ? n[150] : n[100],

      // Text
      textPrimary:   dark ? n[900] : n[800],
      textSecondary: dark ? n[600] : n[600],
      textTertiary:  dark ? n[500] : n[500],
      textOnColor:   '#FFFFFF',

      // Lines
      separator:     dark ? 'rgba(255,255,255,0.08)' : 'rgba(60,45,30,0.08)',
      separatorStrong: dark ? 'rgba(255,255,255,0.14)' : 'rgba(60,45,30,0.14)',
      border:        dark ? 'rgba(255,255,255,0.10)' : 'rgba(60,45,30,0.10)',

      // Raw scales (for heatmaps, rings, etc.)
      primaryScale: p,
      sageScale: SAGE,
      neutralScale: n,
    },
    type: {
      // Apple Dynamic Type scale @ default size
      largeTitle: { size: 34, weight: 700, lh: 41, track: 0.37, family: 'rounded' },
      title1:     { size: 28, weight: 700, lh: 34, track: 0.36, family: 'rounded' },
      title2:     { size: 22, weight: 700, lh: 28, track: 0.35, family: 'rounded' },
      title3:     { size: 20, weight: 600, lh: 25, track: 0.38, family: 'rounded' },
      headline:   { size: 17, weight: 600, lh: 22, track: -0.43, family: 'text' },
      body:       { size: 17, weight: 400, lh: 22, track: -0.43, family: 'text' },
      callout:    { size: 16, weight: 400, lh: 21, track: -0.32, family: 'text' },
      subhead:    { size: 15, weight: 400, lh: 20, track: -0.24, family: 'text' },
      footnote:   { size: 13, weight: 400, lh: 18, track: -0.08, family: 'text' },
      caption1:   { size: 12, weight: 400, lh: 16, track: 0,    family: 'text' },
      caption2:   { size: 11, weight: 500, lh: 13, track: 0.06, family: 'text' },
      // Special
      encourage:  { size: 22, weight: 600, lh: 28, track: 0,    family: 'rounded' },
      streakHero: { size: 72, weight: 700, lh: 76, track: -2,   family: 'rounded' },
      counter:    { size: 15, weight: 500, lh: 20, track: 0,    family: 'mono' },
    },
    family: {
      rounded: '"SF Pro Rounded", -apple-system, ui-rounded, system-ui, sans-serif',
      text:    '-apple-system, "SF Pro Text", system-ui, sans-serif',
      mono:    '"SF Mono", ui-monospace, Menlo, monospace',
    },
    space: { 0.5: 2, 1: 4, 2: 8, 3: 12, 4: 16, 5: 20, 6: 24, 7: 28, 8: 32, 10: 40, 12: 48, 16: 64 },
    radius: {
      xs: 6, sm: 10, md: 14, lg: 18, xl: 22, '2xl': 26, card: 20, cardLg: 28, sheet: 32, pill: 9999,
    },
    elev: {
      // Warm shadows — tinted toward hue 40 (amber) at low opacity
      none:  'none',
      xs:    dark ? '0 1px 2px rgba(0,0,0,0.32)'
                  : '0 1px 2px rgba(70,45,25,0.06)',
      sm:    dark ? '0 2px 6px rgba(0,0,0,0.35), 0 1px 2px rgba(0,0,0,0.2)'
                  : '0 2px 6px rgba(70,45,25,0.06), 0 1px 2px rgba(70,45,25,0.04)',
      md:    dark ? '0 6px 16px rgba(0,0,0,0.4), 0 2px 6px rgba(0,0,0,0.25)'
                  : '0 6px 16px rgba(70,45,25,0.08), 0 2px 6px rgba(70,45,25,0.05)',
      lg:    dark ? '0 14px 36px rgba(0,0,0,0.5), 0 4px 12px rgba(0,0,0,0.3)'
                  : '0 14px 36px rgba(70,45,25,0.10), 0 4px 12px rgba(70,45,25,0.06)',
      xl:    dark ? '0 28px 60px rgba(0,0,0,0.55), 0 8px 20px rgba(0,0,0,0.35)'
                  : '0 28px 60px rgba(70,45,25,0.13), 0 8px 20px rgba(70,45,25,0.07)',
      // Glow for streak celebrations
      glow:  `0 0 0 4px ${dark ? 'oklch(0.22 0.08 36 / 0.35)' : 'oklch(0.92 0.08 40 / 0.6)'}, 0 8px 24px ${dark ? 'rgba(0,0,0,0.35)' : 'oklch(0.7 0.12 36 / 0.25)'}`,
    },
    motion: {
      // Spring curves (cubic-bezier approximations of SwiftUI springs)
      gentleSpring: 'cubic-bezier(0.34, 1.2, 0.64, 1)',
      softSpring:   'cubic-bezier(0.25, 0.9, 0.35, 1.05)',
      ease:         'cubic-bezier(0.4, 0, 0.2, 1)',
      dur: { instant: 100, fast: 180, base: 260, slow: 420, celebrate: 620 },
    },
  };
}

// Helper: resolve a type token to a React style object
function typeStyle(t, family) {
  return {
    fontFamily: family[t.family],
    fontSize: t.size,
    fontWeight: t.weight,
    lineHeight: `${t.lh}px`,
    letterSpacing: t.track,
  };
}

Object.assign(window, { MMTokens, typeStyle });
