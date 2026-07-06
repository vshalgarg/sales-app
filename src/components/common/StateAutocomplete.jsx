import Autocomplete from "@mui/material/Autocomplete";
import CustomTextField from "../CustomTextField";
import { INDIAN_STATES } from "../../constants/states";

const StateAutocomplete = ({ value, onChange, error, helperText, disabled = false }) => {
  return (
    <Autocomplete
      disabled={disabled}
      options={INDIAN_STATES}
      value={
        INDIAN_STATES.find(
          (option) => option.value === value
        ) || null
      }
      onChange={(event, newValue) => {
        onChange(newValue ? newValue.value : "");
      }}
      getOptionLabel={(option) => option.label}
      isOptionEqualToValue={(option, val) =>
        option.value === val.value
      }
      renderInput={(params) => (
        <CustomTextField
          {...params}
          label="State"
          error={error}
          helperText={helperText}
          disabled={disabled}
        />
      )}
    />
  );
};

export default StateAutocomplete;