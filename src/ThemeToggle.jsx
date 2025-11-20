import { IconButton } from "@mui/material";
import { Sun, Moon } from "lucide-react";
import { useThemeContext } from "./context/ThemeContext";

export default function ThemeToggle() {
  const { mode, toggleTheme } = useThemeContext();

  return (
    <IconButton onClick={toggleTheme}>
      {mode === "light" ? <Moon /> : <Sun />}
    </IconButton>
  );
}
