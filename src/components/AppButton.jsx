import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import { BRAND_COLORS } from "../theme/brandColors";

const primaryButtonSx = {
  backgroundColor: BRAND_COLORS.primary,
  color: "#fff",
  "&:hover": {
    backgroundColor: BRAND_COLORS.primaryDark,
    boxShadow: "none",
  },
  "&.Mui-disabled": {
    backgroundColor: `${BRAND_COLORS.primary}80`,
    color: "#fff",
  },
};

const typeStyles = {
  primary: {
    variant: "contained",
    color: "primary",
    sx: primaryButtonSx,
  },
  secondary: {
    variant: "outlined",
    color: "primary",
    sx: {
      borderColor: BRAND_COLORS.primary,
      color: BRAND_COLORS.primary,
      "&:hover": {
        borderColor: BRAND_COLORS.primaryDark,
        backgroundColor: `${BRAND_COLORS.primary}14`,
      },
    },
  },
  danger: {
    variant: "contained",
    color: "error",
  },
  cancel: {
    variant: "contained",
    color: "inherit",
    sx: {
      backgroundColor: "#e5e7eb",
      color: "#374151",
      "&:hover": {
        backgroundColor: "#d1d5db",
      },
    },
  },
};

const AppButton = ({
  children,
  onClick,
  disabled = false,
  loading = false,
  type = "primary",
  fullWidth = false,
  startIcon = null,
  sx = {},
}) => {
  const config = typeStyles[type] || typeStyles.primary;

  return (
    <Button
      variant={config.variant}
      color={config.color}
      disabled={disabled || loading}
      onClick={onClick}
      fullWidth={fullWidth}
      startIcon={!loading ? startIcon : null}
      sx={{
        minWidth: "100px",
        textTransform: "none",
        boxShadow: "none",
        "&:hover": { boxShadow: "none" },
        ...(config.sx || {}),
        ...sx,
      }}
    >
      {loading ? (
        <CircularProgress size={18} color="inherit" />
      ) : (
        children
      )}
    </Button>
  );
};

export default AppButton;