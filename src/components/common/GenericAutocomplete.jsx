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

            getOptionKey={(option) => option.id || option.staffId}

            value={value}
            loading={loading}

            isOptionEqualToValue={(option, value) =>
                (option?.id || option?.staffId) === (value?.id || value?.staffId)
            }

            getOptionLabel={(option) =>
                option?.label ||
                option?.name ||
                option?.customerName ||
                option?.supplierName ||
                option?.staffName ||
                ""
            }

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