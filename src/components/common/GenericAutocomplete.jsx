import Autocomplete from "@mui/material/Autocomplete";
import TextField from "@mui/material/TextField";

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