import plugin from "tailwindcss/plugin";
import themeConfig from "../config/theme.json";

// Helper to extract a clean font name.
const findFont = (fontStr) =>
  fontStr.replace(/\+/g, " ").replace(/:[^:]+/g, "");

// Set font families dynamically, filtering out 'type' keys
const fontFamilies = Object.entries(themeConfig.fonts.font_family)
  .filter(([key]) => !key.includes("type"))
  .reduce((acc, [key, font]) => {
    acc[key] =
      `${findFont(font)}, ${themeConfig.fonts.font_family[`${key}_type`] || "sans-serif"}`;
    return acc;
  }, {});

const defaultColorGroups = [
  { colors: themeConfig.colors.default.theme_color, prefix: "" },
  { colors: themeConfig.colors.default.text_color, prefix: "" },
];
const darkColorGroups = [];
if (themeConfig.colors.darkmode?.theme_color) {
  darkColorGroups.push({
    colors: themeConfig.colors.darkmode.theme_color,
    prefix: "darkmode-",
  });
}
if (themeConfig.colors.darkmode?.text_color) {
  darkColorGroups.push({
    colors: themeConfig.colors.darkmode.text_color,
    prefix: "darkmode-",
  });
}

const getVars = (groups) => {
  const vars = {};
  groups.forEach(({ colors, prefix }) => {
    Object.entries(colors).forEach(([k, v]) => {
      const cssKey = k.replace(/_/g, "-");
      vars[`--color-${prefix}${cssKey}`] = v;
    });
  });
  return vars;
};

const defaultVars = getVars(defaultColorGroups);
const darkVars = getVars(darkColorGroups);

// AltruPets design token palette (full shade ranges)
// These provide utility classes like bg-primary-50, text-accent-80, etc.
const designTokenPalette = {
  // Primary palette
  "--color-primary-0": "#000000",
  "--color-primary-10": "#001E2F",
  "--color-primary-20": "#00344E",
  "--color-primary-30": "#004B6F",
  "--color-primary-40": "#006491",
  "--color-primary-50": "#007FB6",
  "--color-primary-60": "#3699D2",
  "--color-primary-70": "#58B4EE",
  "--color-primary-80": "#8ACEFF",
  "--color-primary-90": "#C9E6FF",
  "--color-primary-95": "#E6F2FF",
  "--color-primary-99": "#FCFCFF",
  "--color-primary-100": "#FFFFFF",
  // Secondary palette
  "--color-secondary-0": "#000000",
  "--color-secondary-10": "#2E1500",
  "--color-secondary-20": "#4C2700",
  "--color-secondary-30": "#6D3A00",
  "--color-secondary-40": "#8F4E00",
  "--color-secondary-50": "#B36300",
  "--color-secondary-60": "#D87800",
  "--color-secondary-70": "#FB911F",
  "--color-secondary-80": "#FFB77A",
  "--color-secondary-90": "#FFDCC2",
  "--color-secondary-95": "#FFEEE2",
  "--color-secondary-99": "#FFFBFF",
  "--color-secondary-100": "#FFFFFF",
  // Accent palette
  "--color-accent-0": "#000000",
  "--color-accent-10": "#001E31",
  "--color-accent-20": "#003351",
  "--color-accent-30": "#004B73",
  "--color-accent-40": "#006496",
  "--color-accent-50": "#167DB9",
  "--color-accent-60": "#3F97D5",
  "--color-accent-70": "#5FB2F1",
  "--color-accent-80": "#91CCFF",
  "--color-accent-90": "#CCE5FF",
  "--color-accent-95": "#E7F2FF",
  "--color-accent-99": "#FCFCFF",
  "--color-accent-100": "#FFFFFF",
  // Warning palette
  "--color-warning-0": "#000000",
  "--color-warning-10": "#281900",
  "--color-warning-20": "#432C00",
  "--color-warning-30": "#604100",
  "--color-warning-40": "#7E5700",
  "--color-warning-50": "#9F6E00",
  "--color-warning-60": "#C08600",
  "--color-warning-70": "#E29E08",
  "--color-warning-80": "#FFBA3A",
  "--color-warning-90": "#FFDEAD",
  "--color-warning-95": "#FFEEDA",
  "--color-warning-99": "#FFFBFF",
  "--color-warning-100": "#FFFFFF",
  // Error palette
  "--color-error-0": "#000000",
  "--color-error-10": "#3A0B00",
  "--color-error-20": "#5E1700",
  "--color-error-30": "#842500",
  "--color-error-40": "#AD3300",
  "--color-error-50": "#D74204",
  "--color-error-60": "#FB5B23",
  "--color-error-70": "#FF8B66",
  "--color-error-80": "#FFB59E",
  "--color-error-90": "#FFDBD0",
  "--color-error-95": "#FFEDE8",
  "--color-error-99": "#FFFBFF",
  "--color-error-100": "#FFFFFF",
  // Success palette
  "--color-success-0": "#000000",
  "--color-success-10": "#002204",
  "--color-success-20": "#003909",
  "--color-success-30": "#005312",
  "--color-success-40": "#1B6D24",
  "--color-success-50": "#38873A",
  "--color-success-60": "#53A252",
  "--color-success-70": "#6DBD6A",
  "--color-success-80": "#88D982",
  "--color-success-90": "#A3F69C",
  "--color-success-95": "#C8FFBF",
  "--color-success-99": "#F6FFF0",
  "--color-success-100": "#FFFFFF",
  // Neutral palette
  "--color-neutral-0": "#000000",
  "--color-neutral-10": "#191C1E",
  "--color-neutral-20": "#2E3133",
  "--color-neutral-30": "#454749",
  "--color-neutral-40": "#5D5E61",
  "--color-neutral-50": "#75777A",
  "--color-neutral-60": "#8F9193",
  "--color-neutral-70": "#AAABAE",
  "--color-neutral-80": "#C5C6C9",
  "--color-neutral-90": "#E2E2E5",
  "--color-neutral-95": "#F0F0F3",
  "--color-neutral-99": "#FCFCFF",
  "--color-neutral-100": "#FFFFFF",
  // Neutral Variant palette
  "--color-neutral-variant-0": "#000000",
  "--color-neutral-variant-10": "#161C21",
  "--color-neutral-variant-20": "#2B3137",
  "--color-neutral-variant-30": "#41474D",
  "--color-neutral-variant-40": "#595F65",
  "--color-neutral-variant-50": "#71787E",
  "--color-neutral-variant-60": "#8B9198",
  "--color-neutral-variant-70": "#A6ACB3",
  "--color-neutral-variant-80": "#C1C7CE",
  "--color-neutral-variant-90": "#DDE3EA",
  "--color-neutral-variant-95": "#ECF1F8",
  "--color-neutral-variant-99": "#FCFCFF",
  "--color-neutral-variant-100": "#FFFFFF",
};

// Build palette color map for Tailwind utility classes
const paletteColorsMap = {};
for (const [cssVar, _value] of Object.entries(designTokenPalette)) {
  // --color-primary-50 -> primary-50
  const name = cssVar.replace("--color-", "");
  paletteColorsMap[name] = `var(${cssVar})`;
}

const baseSize = Number(themeConfig.fonts.font_size.base);
const scale = Number(themeConfig.fonts.font_size.scale);
const calculateFontSizes = (base, scale) => {
  const sizes = {};
  let currentSize = scale;
  for (let i = 6; i >= 1; i--) {
    sizes[`h${i}`] = `${currentSize}rem`;
    sizes[`h${i}-sm`] = `${currentSize * 0.8}rem`;
    currentSize *= scale;
  }
  sizes.base = `${base}px`;
  sizes["base-sm"] = `${base * 0.8}px`;
  return sizes;
};
const fontSizes = calculateFontSizes(baseSize, scale);

const fontVars = {};
Object.entries(fontSizes).forEach(([key, value]) => {
  fontVars[`--text-${key}`] = value;
});
Object.entries(fontFamilies).forEach(([key, font]) => {
  fontVars[`--font-${key}`] = font;
});

const baseVars = { ...fontVars, ...defaultVars, ...designTokenPalette };

// Build a colorsMap including both sets
const colorsMap = {};
[...defaultColorGroups, ...darkColorGroups].forEach(({ colors, prefix }) => {
  Object.entries(colors).forEach(([key]) => {
    const cssKey = key.replace(/_/g, "-");
    colorsMap[prefix + cssKey] = `var(--color-${prefix}${cssKey})`;
  });
});

// Merge palette colors into colorsMap
Object.assign(colorsMap, paletteColorsMap);

module.exports = plugin.withOptions(() => {
  return function ({ addBase, addUtilities, matchUtilities }) {
    // Default vars on :root; dark vars on .dark
    addBase({
      ":root": baseVars,
      ".dark": darkVars,
    });

    const fontUtils = {};
    Object.keys(fontFamilies).forEach((key) => {
      fontUtils[`.font-${key}`] = { fontFamily: `var(--font-${key})` };
    });
    Object.keys(fontSizes).forEach((key) => {
      fontUtils[`.text-${key}`] = { fontSize: `var(--text-${key})` };
    });
    addUtilities(fontUtils, {
      variants: ["responsive", "hover", "focus", "active", "disabled"],
    });

    matchUtilities(
      {
        bg: (value) => ({ backgroundColor: value }),
        text: (value) => ({ color: value }),
        border: (value) => ({ borderColor: value }),
        fill: (value) => ({ fill: value }),
        stroke: (value) => ({ stroke: value }),
      },
      { values: colorsMap, type: "color" },
    );

    matchUtilities(
      {
        from: (value) => ({
          "--tw-gradient-from": value,
          "--tw-gradient-via-stops":
            "var(--tw-gradient-via-stops, var(--tw-gradient-position), var(--tw-gradient-from) var(--tw-gradient-from-position), var(--tw-gradient-to) var(--tw-gradient-to-position))",
          "--tw-gradient-stops":
            "var(--tw-gradient-via-stops, var(--tw-gradient-position), var(--tw-gradient-from) var(--tw-gradient-from-position), var(--tw-gradient-to) var(--tw-gradient-to-position))",
        }),
        to: (value) => ({
          "--tw-gradient-to": value,
          "--tw-gradient-via-stops":
            "var(--tw-gradient-via-stops, var(--tw-gradient-position), var(--tw-gradient-from) var(--tw-gradient-from-position), var(--tw-gradient-to) var(--tw-gradient-to-position))",
          "--tw-gradient-stops":
            "var(--tw-gradient-via-stops, var(--tw-gradient-position), var(--tw-gradient-from) var(--tw-gradient-from-position), var(--tw-gradient-to) var(--tw-gradient-to-position))",
        }),
        via: (value) => ({
          "--tw-gradient-via": value,
          "--tw-gradient-via-stops":
            "var(--tw-gradient-position), var(--tw-gradient-from) var(--tw-gradient-from-position), var(--tw-gradient-via) var(--tw-gradient-via-position), var(--tw-gradient-to) var(--tw-gradient-to-position)",
        }),
      },
      { values: colorsMap, type: "color" },
    );
  };
});
