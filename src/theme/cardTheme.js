export const CARD_SURFACE_VARIANTS = [
  {
    surface: "bg-blue-50/80 dark:bg-blue-950/30",
    border: "border-blue-100 dark:border-blue-900",
  },
  {
    surface: "bg-violet-50/80 dark:bg-violet-950/30",
    border: "border-violet-100 dark:border-violet-900",
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
  "bg-white/80 dark:bg-zinc-800 text-blue-700 dark:text-blue-300 border border-blue-100 dark:border-blue-800";

export const FIELD_ICON_CLASS = "text-violet-600 dark:text-violet-400";

export const FORM_SCROLL_AREA_CLASS = "bg-gray-50 dark:bg-zinc-950";

export const DETAIL_FIELD_VALUE_CLASS =
  "bg-white/70 dark:bg-zinc-900/60 border-gray-200 dark:border-zinc-600";

export const TRANSPORT_CHIP_CLASS =
  "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-200";
