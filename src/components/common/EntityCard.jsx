import EntityCardActions from "./EntityCardActions";
import {
  CODE_BADGE_CLASS,
  FIELD_ICON_CLASS,
  getCardSurfaceClass,
} from "../../theme/cardTheme";

const formatValue = (value) =>
  value == null || value === "" ? "-" : String(value);

const EntityCard = ({
  code,
  codeLabel = "Code",
  title,
  fields = [],
  variantIndex = 0,
  onView,
  onEdit,
  onCopy,
  onDelete,
}) => (
  <article
    className={`flex flex-col rounded-xl border p-4 shadow-sm h-full ${getCardSurfaceClass(variantIndex)}`}
  >
    <div className="flex items-center gap-2 mb-2">
      <span className="text-sm text-gray-500 dark:text-gray-400">
        {codeLabel}
      </span>
      {code && (
        <span
          className={`rounded-md px-2 py-0.5 text-xs font-semibold ${CODE_BADGE_CLASS}`}
        >
          {code}
        </span>
      )}
    </div>

    <h3
      className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-3 line-clamp-2"
      title={title}
    >
      {formatValue(title)}
    </h3>

    <div className="flex flex-col gap-2.5 flex-1">
      {fields.map((field) => {
        const Icon = field.icon;
        const value = field.render
          ? field.render(field.value)
          : formatValue(field.value);

        return (
          <div key={field.label} className="flex items-start gap-2 min-w-0">
            {Icon && (
              <Icon
                className={`h-4 w-4 mt-0.5 shrink-0 ${FIELD_ICON_CLASS}`}
              />
            )}
            <div className="min-w-0">
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {field.label}
              </p>
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
