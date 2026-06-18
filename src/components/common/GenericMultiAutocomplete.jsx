import { useMemo } from "react";
import Autocomplete from "@mui/material/Autocomplete";
import TextField from "@mui/material/TextField";
import Chip from "@mui/material/Chip";
import CheckBoxIcon from "@mui/icons-material/CheckBox";
import CheckBoxOutlineBlankIcon from "@mui/icons-material/CheckBoxOutlineBlank";
import IndeterminateCheckBoxIcon from "@mui/icons-material/IndeterminateCheckBox";

const SELECT_ALL_ID = "__select_all__";
const SELECT_ALL_OPTION = { id: SELECT_ALL_ID, label: "Select All" };

const isSelectAllOption = (option) => option?.id === SELECT_ALL_ID;

const optionIconSx = {
  fontSize: 18,
  marginRight: 1,
  flexShrink: 0,
};

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

const GenericMultiAutocomplete = ({
  options = [],
  value = [],
  loading = false,
  label = "",
  placeholder = "",
  required = false,
  error = false,
  helperText = "",
  showSelectAll = true,
  maxVisibleTags = 3,
  onChange,
}) => {
  const selectableOptions = useMemo(
    () => options.filter((o) => !isSelectAllOption(o)),
    [options],
  );

  const allSelected =
    selectableOptions.length > 0 &&
    value.length === selectableOptions.length;

  const someSelected = value.length > 0 && !allSelected;

  const displayOptions = useMemo(() => {
    if (!showSelectAll || selectableOptions.length === 0) {
      return selectableOptions;
    }
    return [SELECT_ALL_OPTION, ...selectableOptions];
  }, [showSelectAll, selectableOptions]);

  const handleChange = (_event, nextValue) => {
    if (nextValue.some(isSelectAllOption)) {
      onChange(allSelected ? [] : [...selectableOptions]);
      return;
    }
    onChange(nextValue);
  };

  return (
    <Autocomplete
      multiple
      options={displayOptions}
      value={value}
      loading={loading}
      disableCloseOnSelect
      disableListWrap
      isOptionEqualToValue={(option, val) => option?.id === val?.id}
      getOptionLabel={(option) => option?.label ?? ""}
      onChange={handleChange}
      slotProps={{ listbox: { sx: listboxSx } }}
      renderOption={(props, option, { selected }) => {
        const selectAll = isSelectAllOption(option);
        const checked = selectAll ? allSelected : selected;
        const indeterminate = selectAll && someSelected;

        let Icon;
        if (indeterminate) Icon = IndeterminateCheckBoxIcon;
        else if (checked) Icon = CheckBoxIcon;
        else Icon = CheckBoxOutlineBlankIcon;

        return (
          <li {...props} key={option.id}>
            <Icon
              sx={{
                ...optionIconSx,
                color: checked || indeterminate ? "primary.main" : "grey.500",
              }}
            />
            <span
              style={{
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
                flex: 1,
              }}
            >
              {option.label}
            </span>
          </li>
        );
      }}
      renderTags={(tagValue, getTagProps) => {
        const visible = tagValue.slice(0, maxVisibleTags);
        const overflow = tagValue.length - visible.length;
        return (
          <>
            {visible.map((option, index) => {
              const tagProps = getTagProps({ index });
              return (
                <Chip
                  {...tagProps}
                  key={option.id ?? index}
                  size="small"
                  label={option.label}
                />
              );
            })}
            {overflow > 0 && (
              <Chip
                key="__overflow__"
                size="small"
                label={`+${overflow} more`}
                sx={{ ml: 0.5 }}
              />
            )}
          </>
        );
      }}
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

export default GenericMultiAutocomplete;
