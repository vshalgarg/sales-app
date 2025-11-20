// BasicSelect.jsx
import React from "react";
import MenuItem from "@mui/material/MenuItem";
import ListItemText from "@mui/material/ListItemText";
import TextField from "@mui/material/TextField";
import Autocomplete from "@mui/material/Autocomplete";

const menuProps = {
  PaperProps: {
    style: {
      maxHeight: 48 * 6 + 8,
      width: 250,
    },
  },
  anchorOrigin: {
    vertical: "bottom",
    horizontal: "left",
  },
  transformOrigin: {
    vertical: "top",
    horizontal: "left",
  },
};

export default function BasicSelect({
  name,
  value,
  onChange,
  label,
  error,
  helperText,
  options = [],
  className,
  showNoneOption = true,
  disabled = false,
  ...rest
}) {
  const isTransport = name === "transport";

  // Autocomplete case (for transport)
  if (isTransport) {
    return (
      <Autocomplete
        freeSolo
        fullWidth
        disabled={disabled}
        options={options}
        value={
          options.find((o) => o.value === value) ||
          (value ? { label: String(value), value: String(value) } : null)
        }
        getOptionLabel={(option) => {
          if (typeof option === "string") return option;
          if (option && typeof option.label === "string") return option.label;
          return "";
        }}
        onChange={(event, newValue) =>
          onChange({
            target: { name, value: newValue ? newValue.value || newValue : "" },
          })
        }
        onInputChange={(event, newInputValue) =>
          onChange({ target: { name, value: newInputValue } })
        }
        renderInput={(params) => (
          <TextField
            {...params}
            size="small"
            label={label}
            variant="outlined"
            error={!!error}
            helperText={helperText}
            sx={{
              "& .MuiOutlinedInput-root": {
                height: 40, // keep same height
              },
              "& .MuiInputLabel-root.Mui-error": {
                color: "red", // Force red label on error
              },
            }}
          />
        )}
      />
    );
  }
  
  return (
    <TextField
      select
      fullWidth
      size="small"
      name={name}
      label={label}
      value={value ?? ""}
      onChange={onChange}
      error={!!error}
      helperText={helperText}
      disabled={disabled}
      SelectProps={{ MenuProps: menuProps }}
      className={className}
      {...rest}
      sx={{
        "& .MuiOutlinedInput-root": {
          height: 40, // keep fixed height
        },
        "& .MuiInputBase-input": {
          padding: "8px 14px", // center text
          boxSizing: "border-box",
        },
        "& .MuiOutlinedInput-notchedOutline": {
          borderColor: error ? "red !important" : undefined,
        },
        "& .MuiInputLabel-root": {
          fontSize: "1rem", // fixed font-size to prevent jumps
        },
        "& .MuiInputLabel-shrink": {
          transform: "translate(14px, -9px) scale(0.75)", // stable shrink
        },
        "& .MuiInputLabel-root.Mui-error": {
          color: "#D32F2F", // Make label red when error
        },
      }}
    >
      {options.map((option) => (
        <MenuItem key={option.value} value={option.value}>
          <ListItemText primary={option.label} />
        </MenuItem>
      ))}
    </TextField>
  );
}
