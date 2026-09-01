import { useTheme, useMediaQuery } from "@mui/material";

/**
 * Generic responsive hook using MUI breakpoints
 */
const useResponsive = () => {
  const theme = useTheme();

  return {
    isMobile: useMediaQuery(theme.breakpoints.down("sm")), // <600px
    isTablet: useMediaQuery(theme.breakpoints.between("sm", "md")),
    isDesktop: useMediaQuery(theme.breakpoints.up("md")),
  };
};

export default useResponsive;
