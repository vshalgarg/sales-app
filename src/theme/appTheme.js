export const SHELL_BORDER =
  "border-brand-sidebar-divider dark:border-zinc-700/40";

export const SURFACE_BORDER =
  "border-brand-surface-border dark:border-zinc-700/40";

export const SHELL_HEADER_HEIGHT = "h-16 min-h-[4rem] max-h-[4rem]";

export const GRID_SIDEBAR_BRAND_CLASS = `${SHELL_HEADER_HEIGHT} shrink-0 flex items-center px-4 border-b ${SHELL_BORDER} box-border`;

export const GRID_SIDEBAR_COLUMN_CLASS = `hidden md:flex col-start-1 row-start-2 flex-col min-h-0 min-w-0 overflow-hidden border-r ${SHELL_BORDER} bg-brand-sidebar dark:bg-zinc-900 box-border`;

export const GRID_NAVBAR_CLASS = `${SHELL_HEADER_HEIGHT} flex items-center justify-between gap-4 px-4 border-b ${SHELL_BORDER} bg-white dark:bg-zinc-900 min-w-0 box-border`;

export const GRID_SIDEBAR_NAV_CLASS =
  "flex-1 min-h-0 overflow-y-auto";

export const BRAND_TITLE_CLASS =
  "text-xl font-bold tracking-wide text-brand-navy dark:text-blue-300";

export const NAV_TAB_ACTIVE_CLASS =
  "bg-brand-primary text-white shadow-sm";

export const NAV_TAB_INACTIVE_CLASS =
  "bg-brand-tab-inactive text-brand-navy dark:bg-zinc-800 dark:text-gray-200 hover:bg-violet-100 dark:hover:bg-zinc-700";

export const SIDEBAR_NAV_LIST_CLASS =
  "space-y-1 whitespace-nowrap px-4 pt-5 pb-4";

export const SIDEBAR_ITEM_BASE_CLASS =
  "flex items-center gap-3 px-4 py-2.5 rounded-lg transition-colors text-sm font-medium";

export const getSidebarItemClass = (isActive) =>
  isActive
    ? `${SIDEBAR_ITEM_BASE_CLASS} bg-brand-primary text-white shadow-sm`
    : `${SIDEBAR_ITEM_BASE_CLASS} text-brand-navy dark:text-gray-200 hover:bg-violet-100/80 dark:hover:bg-zinc-800`;

export const getSidebarIconClass = (isActive) =>
  isActive
    ? "h-[18px] w-[18px] shrink-0 text-white"
    : "h-[18px] w-[18px] shrink-0 text-brand-icon dark:text-violet-400";

export const NAV_ICON_BUTTON_CLASS =
  "inline-flex h-10 w-10 items-center justify-center rounded-lg text-brand-navy dark:text-gray-200 hover:bg-brand-tab-inactive dark:hover:bg-zinc-800 transition-colors";

export const NAV_MENU_ICON_CLASS =
  "h-6 w-6 shrink-0 text-brand-navy dark:text-gray-200 cursor-pointer";

export const SETTINGS_ICON_CLASS = "h-5 w-5 shrink-0";

export const PAGE_TITLE_CLASS =
  "text-xl md:text-2xl font-bold text-brand-navy dark:text-gray-100";

export const SEARCH_WRAPPER_CLASS = "relative w-full max-w-md lg:max-w-lg";

export const SEARCH_INPUT_CLASS =
  "w-full pl-11 pr-10 py-3 bg-white dark:bg-zinc-900 border border-brand-surface-border dark:border-zinc-700/40 rounded-xl text-sm text-brand-navy dark:text-gray-100 placeholder:text-brand-search-muted dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-brand-primary/10 focus:border-brand-sidebar-divider transition-colors [&::-webkit-search-cancel-button]:hidden [&::-webkit-search-decoration]:hidden";

export const SEARCH_ICON_CLASS =
  "h-[18px] w-[18px] text-brand-search-muted dark:text-gray-500";

export const SEARCH_CLEAR_CLASS =
  "p-1 rounded-md text-brand-search-muted hover:text-brand-navy hover:bg-brand-tab-inactive dark:hover:bg-zinc-800 transition-colors";

export const SIDEBAR_MOBILE_CLASS =
  "bg-brand-sidebar dark:bg-zinc-900 shadow-[4px_0_24px_rgba(30,58,110,0.08)] dark:shadow-[4px_0_24px_rgba(0,0,0,0.35)]";

export const NAVBAR_SHELL_CLASS = GRID_NAVBAR_CLASS;
export const NAVBAR_INNER_CLASS = "contents";
export const SIDEBAR_HEADER_CLASS = GRID_SIDEBAR_BRAND_CLASS;
export const SIDEBAR_NAV_CLASS = SIDEBAR_NAV_LIST_CLASS;
export const SIDEBAR_COLUMN_CLASS = SIDEBAR_MOBILE_CLASS;
