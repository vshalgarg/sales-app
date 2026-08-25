import {
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormHelperText,
} from "@mui/material";

const GenericSingleSelect = ({
  options = [],
  value = "",
  label = "",
  required = false,
  error = false,
  helperText = "",
  disabled = false,
  onChange,
}) => {
  return (
    <FormControl
      fullWidth
      size="small"
      error={error}
      required={required}
    >
      <InputLabel>{label}</InputLabel>

      <Select
        value={value}
        label={label}
        disabled={disabled}
        onChange={(e) => onChange(e.target.value)}
      >
        {options.map((option) => (
          <MenuItem
            key={option.id}
            value={option.value}
          >
            {option.label}
          </MenuItem>
        ))}
      </Select>

      {helperText && (
        <FormHelperText>
          {helperText}
        </FormHelperText>
      )}
    </FormControl>
  );
};

export default GenericSingleSelect;
