import { createContext, useContext, useState } from "react";
import CustomSnackbar from "../components/CustomSnackbar";

const SnackbarContext = createContext();

export const useSnackbar = () => useContext(SnackbarContext);

export const SnackbarProvider = ({ children }) => {
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "success",
    anchorOrigin: { vertical: "bottom", horizontal: "right" },
    duration: 3000,
  });
   
  const showSnackbar = (
    message,
    severity = "success",
    duration = 3000,
    anchorOrigin
  ) => {
    if (!message || !message.trim()) return;
    setSnackbar({ open: true, message, severity, duration, anchorOrigin });
  };
   
  const closeSnackbar = () => {
    setSnackbar((prev) => ({ ...prev, open: false }));
  };

  return (
    <SnackbarContext.Provider value={{ showSnackbar }}>
      {children}
      <CustomSnackbar
        open={snackbar.open}
        message={snackbar.message}
        severity={snackbar.severity}
        duration={snackbar.duration}
        onClose={closeSnackbar}
      />
    </SnackbarContext.Provider>
  );
};