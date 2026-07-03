export const CARD_SURFACE_VARIANTS = [
  {
    surface: "bg-blue-50/80 dark:bg-blue-950/30",
    border: "border-blue-50/90 dark:border-blue-900/50",
  },
  {
    surface: "bg-violet-50/80 dark:bg-violet-950/30",
    border: "border-violet-50/90 dark:border-violet-900/50",
  },
];

export const getCardSurfaceClass = (index = 0) => {
  const variant =
    CARD_SURFACE_VARIANTS[index % CARD_SURFACE_VARIANTS.length];
  return `${variant.surface} ${variant.border}`;
};

export const SECTION_ICON_WRAPPER_CLASS =
  "bg-violet-100 dark:bg-violet-900/40";

export const SECTION_ICON_CLASS = "text-violet-600 dark:text-violet-400";

export const CODE_BADGE_CLASS =
  "bg-white/80 dark:bg-zinc-800 text-blue-700 dark:text-blue-300 border border-blue-50 dark:border-blue-900/50";

export const FIELD_ICON_CLASS = "text-violet-600 dark:text-violet-400";

export const FORM_SCROLL_AREA_CLASS = "bg-gray-50 dark:bg-zinc-950";

export const DETAIL_FIELD_VALUE_CLASS =
  "bg-white/70 dark:bg-zinc-900/60 border-brand-surface-border dark:border-zinc-600/50";

export const TRANSPORT_CHIP_CLASS =
  "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-200";

export const CARD_GRID_SHELL_CLASS =
  "border border-brand-surface-border dark:border-zinc-700/40 rounded-lg bg-white dark:bg-zinc-900";

export const CARD_ACTION_BORDER_CLASS =
  "border-brand-surface-border dark:border-zinc-600/50";

export const CARD_ACTION_DIVIDER_CLASS =
  "border-t border-brand-surface-border/80 dark:border-zinc-600/40";

export const PAGINATION_SHELL_CLASS =
  "rounded-xl border border-brand-surface-border dark:border-zinc-700/40 bg-white dark:bg-zinc-900 shadow-sm";

export const ROWS_PER_PAGE_OPTIONS = [5, 10, 15, 20, 25];

export const PAGINATION_TEXT_CLASS =
  "text-sm text-brand-search-muted dark:text-gray-400";

export const PAGINATION_PAGE_ACTIVE_CLASS =
  "bg-brand-primary text-white border-brand-primary";

export const PAGINATION_PAGE_INACTIVE_CLASS =
  "border-brand-surface-border text-brand-navy hover:bg-brand-tab-inactive dark:border-zinc-600 dark:text-gray-200 dark:hover:bg-zinc-800";

export const PAGINATION_NAV_CLASS =
  "border-brand-surface-border text-brand-navy hover:bg-brand-tab-inactive disabled:opacity-40 disabled:pointer-events-none dark:border-zinc-600 dark:text-gray-200 dark:hover:bg-zinc-800";

export const PAGINATION_SELECT_CLASS =
  "appearance-none rounded-lg border border-brand-surface-border bg-white px-3 py-1.5 pr-8 text-sm text-brand-navy cursor-pointer hover:bg-brand-tab-inactive/50 focus:outline-none focus:ring-2 focus:ring-brand-primary/10 dark:border-zinc-600 dark:bg-zinc-900 dark:text-gray-200 dark:hover:bg-zinc-800";
