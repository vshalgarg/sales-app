import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";

const typeStyles = {
  primary: {
    variant: "contained",
    color: "primary",
  },
  secondary: {
    variant: "outlined",
    color: "primary",
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