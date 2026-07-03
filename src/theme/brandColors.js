/** Single source of truth for brand hex values (Tailwind + MUI). */
export const BRAND_COLORS = {
  navy: "#1e3a6e",
  primary: "#203A8F",
  primaryDark: "#1a3078",
  sidebar: "#eef2ff",
  sidebarDivider: "#e0e6f4",
  surfaceBorder: "#e8ecf5",
  searchMuted: "#8b93ad",
  tabInactive: "#e8ecfa",
  icon: "#5b6abf",
};

/** Tailwind `theme.extend.colors.brand` shape (kebab-case keys). */
export const BRAND_TAILWIND_COLORS = {
  navy: BRAND_COLORS.navy,
  primary: BRAND_COLORS.primary,
  "primary-dark": BRAND_COLORS.primaryDark,
  sidebar: BRAND_COLORS.sidebar,
  "sidebar-divider": BRAND_COLORS.sidebarDivider,
  "surface-border": BRAND_COLORS.surfaceBorder,
  "search-muted": BRAND_COLORS.searchMuted,
  "tab-inactive": BRAND_COLORS.tabInactive,
  icon: BRAND_COLORS.icon,
};
