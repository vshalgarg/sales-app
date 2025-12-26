import { TextField, styled } from "@mui/material";
import React, { forwardRef } from "react";

// 1️⃣ Styled version (handles disabled+error border)
const StyledTextField = styled(TextField)(({ theme }) => ({
  // 🔹 Change label color to red when error (always, not just shrink)
  "& .MuiInputLabel-root.Mui-error": {
    color: theme.palette.error.main,
  },

  // Keep border red when error + disabled
  "& .MuiOutlinedInput-root.Mui-disabled.Mui-error fieldset": {
    borderColor: theme.palette.error.main,
  },
}));

// 2️⃣ Wrapper component
const CustomTextField = forwardRef(
  (
    {
      label,
      name,
      value,
      onChange,
      onKeyDown,
      className,
      error,
      onBlur,
      helperText,
      disabled,
      margin = "none",
      autoFocus = false,
      hideErrorUI = false, // 🔹 New prop to hide red border/helperText
      ...rest
    },
    ref
  ) => {
    return (
      <StyledTextField
        {...rest}
        label={label}
        name={name}
        variant="outlined"
        margin={margin}
        value={value ?? ""}
        size="small"
        onChange={onChange}
        onKeyDown={onKeyDown}
        className={className}
        error={error && !hideErrorUI} // 🔹 hide border if hideErrorUI true
        onBlur={onBlur}
        disabled={disabled}
        helperText={hideErrorUI ? "" : helperText || ""} // 🔹 hide helperText
        autoFocus={autoFocus}
        fullWidth
        inputRef={ref}
      />
    );
  }
);

export default CustomTextField;
