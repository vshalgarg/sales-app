import CustomTextField from "../components/CustomTextField";
import validate from "../validations/Validation";
import { useState } from "react";
import { saveStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";

// ⬇️ Import DatePicker
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";

export default function AddNewStaff({
  open,
  setOpen,
  form,
  setForm,
  fetchStaffs,
}) {
  const [errors, setErrors] = useState({});
  const { showSnackbar } = useSnackbar();

  if (!open) return null;

  const handleFormChange = (e) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  const handleAddStaff = async () => {
    const newErrors = {};

    Object.keys(form).forEach((field) => {
      const error = validate(field, form[field]);
      if (error) newErrors[field] = error;
    });

    setErrors(newErrors);

    const hasTopLevelErrors = Object.keys(newErrors).some(
      (key) => key !== "contacts" && newErrors[key]
    );

    if (hasTopLevelErrors) {
      showSnackbar("Please fill required fields in the form.", "error");
      return;
    }

    try {
      const response = await saveStaff(form);
      if (
        response &&
        typeof response === "object" &&
        "code" in response &&
        "message" in response &&
        "timestamp" in response
      ) {
        showSnackbar(response.message, "error");
        return;
      }
      showSnackbar(response.message, "success");
      console.log("Customer added successfully : ", response);
      setErrors({});
      setForm({ staffName: "", phone: "", joiningDate: "" });
      setOpen(false);
      fetchStaffs();
    } catch (err) {
      console.error("🔥 Error while saving supplier:", err);
      showSnackbar("Network or server error.", "error");
    }
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
      <div className="bg-white w-full max-w-md max-h-[50vh] rounded-lg shadow-lg flex flex-col">
        {/* Header */}
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-bold">Add New Staff</h2>
        </div>

        {/* Form content */}
        <div className="px-6 py-4 overflow-y-auto flex-1 space-y-3">
          <CustomTextField
            name="staffName"
            value={form.staffName}
            onChange={handleFormChange}
            label="Staff Name"
            className="border p-2 rounded w-full"
            error={!!errors.staffName}
            helperText={errors.staffName || ""}
          />

          <CustomTextField
            name="phone"
            value={form.phone}
            onChange={(e) => {
              const value = e.target.value;
              if (/^\d{0,10}$/.test(value)) {
                handleFormChange(e);
              }
            }}
            label="Phone"
            className="border p-2 rounded w-full"
            error={!!errors.phone}
            helperText={errors.phone || ""}
            type="tel"
            inputProps={{ maxLength: 10 }}
          />

          <LocalizationProvider dateAdapter={AdapterDayjs}>
            <DatePicker
              label="Joining Date"
              value={form.joiningDate ? dayjs(form.joiningDate) : null}
              onChange={(newValue) => {
                const formatted = newValue
                  ? dayjs(newValue).format("YYYY-MM-DD")
                  : "";
                setForm({ ...form, joiningDate: formatted });
                setErrors((prev) => ({
                  ...prev,
                  joiningDate: validate("joiningDate", formatted),
                }));
              }}
              slotProps={{
                textField: {
                  size: "small",
                  fullWidth: true,
                  error: !!errors.joiningDate,
                  helperText: errors.joiningDate || "",
                  onClick: (e) => {
                    const iconButton =
                      e.currentTarget.parentElement.querySelector(
                        "button[aria-label]"
                      );
                    iconButton?.click();
                  },
                },
              }}
            />
          </LocalizationProvider>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t flex justify-end space-x-2">
          <button
            onClick={() => {
              setOpen(false);
              setErrors({});
              setForm({ staffName: "", phone: "", joiningDate: "" });
            }}
            className="px-3 py-2 border rounded-lg hover:bg-gray-200 text-sm"
          >
            Cancel
          </button>
          <button
            type="submit"
            onClick={handleAddStaff}
            className="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm"
          >
            Save Staff
          </button>
        </div>
      </div>
    </div>
  );
}
