import { createContext, useContext, useEffect, useState } from "react";
import { createTheme, ThemeProvider } from "@mui/material/styles";
import { BRAND_COLORS } from "../theme/brandColors";

const ThemeContext = createContext();
export const useThemeContext = () => useContext(ThemeContext);

export const ThemeContextProvider = ({ children }) => {
  const [mode, setMode] = useState(localStorage.getItem("theme") || "light");

  const toggleTheme = () => {
    const newMode = mode === "light" ? "dark" : "light";
    setMode(newMode);
    localStorage.setItem("theme", newMode);
  };

  // Tailwind dark class
  useEffect(() => {
    if (mode === "dark") {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  }, [mode]);

  // MUI theme with textfield fixes
  const muiTheme = createTheme({
    palette: {
      mode,
      primary: {
        main: BRAND_COLORS.primary,
        dark: BRAND_COLORS.primaryDark,
      },
    },
    components: {
      MuiOutlinedInput: {
        styleOverrides: {
          root: {
            backgroundColor: mode === "dark" ? "#1e1e1e" : "#fff",
            color: mode === "dark" ? "#fff" : "#000",
          },
        },
      },
      MuiTextField: {
        styleOverrides: {
          root: {
            "& .MuiOutlinedInput-root": {
              backgroundColor: mode === "dark" ? "#1e1e1e" : "#fff",
              color: mode === "dark" ? "#fff" : "#000",
            },
            "& .MuiInputLabel-root": {
              color: mode === "dark" ? "#bbb" : "#555",
            },
          },
        },
      },
      MuiPickersTextField: {
        styleOverrides: {
          root: {
            "& .MuiPickersOutlinedInput-root, & .MuiOutlinedInput-root": {
              backgroundColor: mode === "dark" ? "#1e1e1e" : "#fff",
              color: mode === "dark" ? "#fff" : "#000",
            },
            "& .MuiInputLabel-root": {
              color: mode === "dark" ? "#bbb" : "#555",
            },
          },
        },
      },
      MuiPickersOutlinedInput: {
        styleOverrides: {
          root: {
            backgroundColor: mode === "dark" ? "#1e1e1e" : "#fff",
            color: mode === "dark" ? "#fff" : "#000",
          },
        },
      },
    },
  });

  return (
    <ThemeContext.Provider value={{ mode, toggleTheme }}>
      <ThemeProvider theme={muiTheme}>{children}</ThemeProvider>
    </ThemeContext.Provider>
  );
};
