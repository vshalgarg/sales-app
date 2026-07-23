import { BRAND_TAILWIND_COLORS } from "./src/theme/brandColors.js";

/** @type {import('tailwindcss').Config} */
export default {
  darkMode: "class",
  content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: BRAND_TAILWIND_COLORS,
      },
    },
  },
  plugins: [],
};
