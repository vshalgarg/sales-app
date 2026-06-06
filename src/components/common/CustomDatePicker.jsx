import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { formatDate, parseDate } from "../../utils/dateUtils";
import { DATE_FORMAT } from "../../constants/dateConstants";

const CustomDatePicker = ({
  label,
  value,
  onChange,
  maxDate,
  minDate,
  error,
  helperText,
}) => {
  return (
    <LocalizationProvider dateAdapter={AdapterDayjs}>
      <DatePicker
        label={label}
        format={DATE_FORMAT}
        value={parseDate(value)}
        maxDate={maxDate}
        minDate={minDate}
        onChange={(newValue) => onChange(formatDate(newValue))}
        slotProps={{
          textField: {
            size: "small",
            fullWidth: true,
            error: !!error,
            helperText: helperText || "",
          },
        }}
      />
    </LocalizationProvider>
  );
};

export default CustomDatePicker;