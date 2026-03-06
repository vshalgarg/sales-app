import Autocomplete from "@mui/material/Autocomplete";
import TextField from "@mui/material/TextField";

const GenericAutocomplete = ({
    options = [],
    value = null,
    loading = false,
    label = "",
    placeholder = "",
    onChange,
}) => {
    return (
        <Autocomplete
            options={options}

            getOptionKey={(option) => option.id}

            value={value}
            loading={loading}

            isOptionEqualToValue={(option, value) =>
                option.id === value?.id
            }

            getOptionLabel={(option) =>
                option?.label || option?.name || ""
            }

            onChange={(e, val) => onChange(val)}

            renderInput={(params) => (
                <TextField
                    {...params}
                    label={label}
                    placeholder={placeholder}
                    size="small"
                />
            )}
        />
    );
};

export default GenericAutocomplete;