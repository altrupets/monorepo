import mdx from "@astrojs/mdx";
import react from "@astrojs/react";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";
import AutoImport from "astro-auto-import";
import { defineConfig, sharpImageService, fontProviders } from "astro/config";
import remarkCollapse from "remark-collapse";
import remarkToc from "remark-toc";
import config from "./src/config/config.json";

// https://astro.build/config
export default defineConfig({
  site: config.site.base_url ? config.site.base_url : "http://examplesite.com",
  base: config.site.base_path ? config.site.base_path : "/",
  trailingSlash: config.site.trailing_slash ? "always" : "never",
  image: { service: sharpImageService() },
  vite: { plugins: [tailwindcss()] },
  fonts: [
    // Poppins — primary body font (self-hosted from style-dictionary)
    {
      provider: fontProviders.local(),
      name: "Poppins",
      cssVariable: "--font-primary",
      options: {
        variants: [
          {
            weight: 300,
            style: "normal",
            src: ["./src/assets/fonts/poppins/Poppins-Light.ttf"],
          },
          {
            weight: 400,
            style: "normal",
            src: ["./src/assets/fonts/poppins/Poppins-Regular.ttf"],
          },
          {
            weight: 500,
            style: "normal",
            src: ["./src/assets/fonts/poppins/Poppins-Medium.ttf"],
          },
          {
            weight: 600,
            style: "normal",
            src: ["./src/assets/fonts/poppins/Poppins-SemiBold.ttf"],
          },
          {
            weight: 700,
            style: "normal",
            src: ["./src/assets/fonts/poppins/Poppins-Bold.ttf"],
          },
        ],
      },
    },
    // Inter — tertiary font (Google Fonts)
    {
      provider: fontProviders.google(),
      name: "Inter",
      cssVariable: "--font-tertiary",
      weights: [300, 400, 500, 600, 700],
      display: "swap",
      fallbacks: ["sans-serif"],
    },
    // Lemon Milk — header font (local custom font)
    {
      provider: fontProviders.local(),
      name: "Lemon Milk",
      cssVariable: "--font-header",
      options: {
        variants: [
          {
            weight: 300,
            style: "normal",
            src: ["./src/assets/fonts/lemon-milk/LemonMilkLight-owxMq.otf"],
          },
          {
            weight: 300,
            style: "italic",
            src: ["./src/assets/fonts/lemon-milk/LemonMilkLightItalic-7BjPE.otf"],
          },
          {
            weight: 400,
            style: "normal",
            src: ["./src/assets/fonts/lemon-milk/LemonMilkRegular-X3XE2.otf"],
          },
          {
            weight: 400,
            style: "italic",
            src: [
              "./src/assets/fonts/lemon-milk/LemonMilkRegularItalic-L3AEy.otf",
            ],
          },
          {
            weight: 500,
            style: "normal",
            src: ["./src/assets/fonts/lemon-milk/LemonMilkMedium-mLZYV.otf"],
          },
          {
            weight: 500,
            style: "italic",
            src: [
              "./src/assets/fonts/lemon-milk/LemonMilkMediumItalic-d95nl.otf",
            ],
          },
          {
            weight: 700,
            style: "normal",
            src: ["./src/assets/fonts/lemon-milk/LemonMilkBold-gx2B3.otf"],
          },
          {
            weight: 700,
            style: "italic",
            src: [
              "./src/assets/fonts/lemon-milk/LemonMilkBoldItalic-PKZ3P.otf",
            ],
          },
        ],
      },
    },
  ],
  integrations: [
    react(),
    sitemap(),
    AutoImport({
      imports: [
        "@/shortcodes/Button",
        "@/shortcodes/Accordion",
        "@/shortcodes/Notice",
        "@/shortcodes/Video",
        "@/shortcodes/Youtube",
        "@/shortcodes/Tabs",
        "@/shortcodes/Tab",
      ],
    }),
    mdx(),
  ],
  markdown: {
    remarkPlugins: [remarkToc, [remarkCollapse, { test: "Table of contents" }]],
    shikiConfig: { theme: "one-dark-pro", wrap: true },
  },
});
