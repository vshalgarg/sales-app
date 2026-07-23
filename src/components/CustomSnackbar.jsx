import { Snackbar, Alert } from "@mui/material";
import { BRAND_COLORS } from "../theme/brandColors";

const CustomSnackbar = ({
  open,
  message,
  severity = "success",
  onClose,
  duration = 3000,
  anchorOrigin = { vertical: "bottom", horizontal: "right" },
}) => {
  return (
    <Snackbar
      open={open}
      autoHideDuration={duration}
      onClose={onClose}
      anchorOrigin={anchorOrigin}
      sx={{ zIndex: 9999 }}
    >
      <Alert
        onClose={onClose}
        severity={severity}
        variant="filled"
        sx={
          severity === "success"
            ? { backgroundColor: BRAND_COLORS.primary }
            : undefined
        }
      >
        {message}
      </Alert>
    </Snackbar>
  );
};

export default CustomSnackbar;
