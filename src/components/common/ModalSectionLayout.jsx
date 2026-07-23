import { getSidebarIconClass, getSidebarItemClass } from "../../theme/appTheme";
import { FORM_SCROLL_AREA_CLASS } from "../../theme/cardTheme";

const ModalSectionLayout = ({
  sections,
  activeSection,
  onSectionClick,
  scrollContainerRef,
  children,
}) => (
  <div className="flex flex-1 min-h-0 overflow-hidden">
    <nav
      aria-label="Section navigation"
      className={`hidden md:flex w-56 lg:w-60 shrink-0 flex-col gap-0.5 border-r border-brand-surface-border bg-brand-sidebar/60 dark:bg-zinc-900/80 overflow-y-auto p-3 ${FORM_SCROLL_AREA_CLASS}`}
    >
      {sections.map((section) => {
        const Icon = section.icon;
        const isActive = activeSection === section.id;

        return (
          <button
            key={section.id}
            type="button"
            onClick={() => onSectionClick(section.id)}
            className={`${getSidebarItemClass(isActive)} w-full text-left`}
          >
            <Icon className={getSidebarIconClass(isActive)} />
            <span className="truncate">{section.label}</span>
          </button>
        );
      })}
    </nav>

    <div
      ref={scrollContainerRef}
      className={`flex-1 min-h-0 overflow-y-auto p-4 md:p-6 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}
    >
      {children}
    </div>
  </div>
);

export default ModalSectionLayout;
