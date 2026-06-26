import {
  getCardSurfaceClass,
  SECTION_ICON_CLASS,
  SECTION_ICON_WRAPPER_CLASS,
} from "../../theme/cardTheme";

const FormSection = ({ title, icon: Icon, children, variantIndex = 0 }) => (
  <section
    className={`rounded-xl border p-4 md:p-5 shadow-sm ${getCardSurfaceClass(variantIndex)}`}
  >
    <div className="flex items-center gap-3 mb-4">
      {Icon && (
        <div
          className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
        >
          <Icon className={`h-5 w-5 ${SECTION_ICON_CLASS}`} />
        </div>
      )}
      <h3 className="text-base md:text-lg font-semibold text-gray-900 dark:text-gray-100">
        {title}
      </h3>
    </div>
    {children}
  </section>
);

export default FormSection;
