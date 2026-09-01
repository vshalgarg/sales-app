import EntityCardActions from "./EntityCardActions";
import {
  CODE_BADGE_CLASS,
  FIELD_ICON_CLASS,
  getCardSurfaceClass,
} from "../theme/cardTheme";

const formatValue = (value) =>
  value == null || value === "" ? "-" : String(value);

const EntityCard = ({
  code,
  codeAside,
  title,
  titleAside,
  fields = [],
  variantIndex = 0,
  onView,
  onEdit,
  onCopy,
  onDelete,
}) => (
  <article
    className={`flex flex-col rounded-xl border p-3.5 shadow-sm h-full ${getCardSurfaceClass(variantIndex)}`}
  >
    {code && (
      <div className="flex items-center gap-2 mb-1.5 min-w-0">
        {codeAside != null && String(codeAside).trim() !== "" && (
          <span
            className="text-sm font-medium text-gray-700 dark:text-gray-300 truncate min-w-0 max-w-[55%]"
            title={String(codeAside)}
          >
            {codeAside}
          </span>
        )}
        <span
          className={`ml-auto rounded-md px-2 py-0.5 text-xs font-semibold shrink-0 ${CODE_BADGE_CLASS}`}
        >
          {code}
        </span>
      </div>
    )}

    <div className="flex items-start gap-2 mb-2 min-w-0">
      <h3
        className="text-base font-bold text-gray-900 dark:text-gray-100 line-clamp-2 min-w-0 flex-1"
        title={title}
      >
        {formatValue(title)}
      </h3>
      {titleAside != null && titleAside !== "" && (
        <div className="shrink-0 pt-0.5">
          {typeof titleAside === "string" || typeof titleAside === "number" ? (
            <span
              className="text-sm font-medium text-gray-700 dark:text-gray-300 truncate min-w-0 max-w-[35%] text-right block"
              title={String(titleAside)}
            >
              {titleAside}
            </span>
          ) : (
            titleAside
          )}
        </div>
      )}
    </div>

    <div className="flex flex-col gap-1.5 flex-1">
      {fields.map((field) => {
        const Icon = field.icon;
        const value = field.render
          ? field.render(field.value)
          : formatValue(field.value);
        const showLabel = Boolean(field.label) && field.showLabel !== false;
        const fieldKey = field.key || field.label;

        return (
          <div key={fieldKey} className="flex items-start gap-2 min-w-0">
            {Icon && (
              <Icon
                className={`h-4 w-4 mt-0.5 shrink-0 ${FIELD_ICON_CLASS}`}
              />
            )}
            <div className="min-w-0">
              {showLabel && (
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  {field.label}
                </p>
              )}
              <p
                className="text-sm text-gray-800 dark:text-gray-200 break-words line-clamp-2"
                title={typeof value === "string" ? value : undefined}
              >
                {value}
              </p>
            </div>
          </div>
        );
      })}
    </div>

    <EntityCardActions
      onView={onView}
      onEdit={onEdit}
      onCopy={onCopy}
      onDelete={onDelete}
    />
  </article>
);

export default EntityCard;
