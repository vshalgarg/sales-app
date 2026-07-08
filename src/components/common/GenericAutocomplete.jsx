import Autocomplete from "@mui/material/Autocomplete";
import TextField from "@mui/material/TextField";

const listboxSx = {
  "& .MuiAutocomplete-option": {
    fontSize: "0.8125rem",
    minHeight: 32,
    paddingTop: 0.25,
    paddingBottom: 0.25,
    paddingLeft: 1,
    paddingRight: 1,
  },
};

const GenericAutocomplete = ({
    options = [],
    value = null,
    loading = false,
    label = "",
    placeholder = "",
    required = false,
    error = false,
    helperText = "",
    onChange,
}) => {
    return (
        <Autocomplete
            options={options}

            getOptionKey={(option) => option.id}

            value={value}
            loading={loading}

            isOptionEqualToValue={(option, value) => option?.id === value?.id}

            getOptionLabel={(option) => option?.label || ""}

            onChange={(e, val) => onChange(val)}

            slotProps={{ listbox: { sx: listboxSx } }}

            renderInput={(params) => (
                <TextField
                    {...params}
                    label={label}
                    placeholder={placeholder}
                    required={required}
                    error={error}
                    helperText={helperText}
                    size="small"
                />
            )}
        />
    );
};

export default GenericAutocomplete;