import { Tooltip } from "@mui/material";

/**
 * Truncated name with full value on hover.
 */
export default function NameWithTooltip({ name, city, className = "" }) {
  const displayName = name || "-";

  return (
    <div className={`flex flex-col min-w-0 ${className}`.trim()}>
      <Tooltip title={name || ""} disableHoverListener={!name} arrow>
        <span className="block truncate cursor-default">{displayName}</span>
      </Tooltip>
      {city ? (
        <span className="text-xs text-gray-500 truncate">{city}</span>
      ) : null}
    </div>
  );
}
