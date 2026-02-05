import CustomTextField from "../components/CustomTextField";
import validate from "../validations/Validation";
import { useState, useEffect } from "react";
import { saveStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";

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
  const [isSaving, setIsSaving] = useState(false);
  const { showSnackbar } = useSnackbar();

  if (!open) return null;

  useEffect(() => {
    if (open) {
      setForm((prev) => ({
        ...prev,
        joiningDate: dayjs().format("YYYY-MM-DD"),
      }));
    }
  }, [open]);



  const resetForm = () => {
    setForm({ staffName: "", phone: "", joiningDate: "" });
    setErrors({});
  };

  // ---------- CHANGE ----------
  const handleFormChange = (name, value) => {
    setForm((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  // ---------- SUBMIT----------
  const handleAddStaff = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const newErrors = {
      staffName: validate("staffName", form.staffName),
      joiningDate: validate("joiningDate", form.joiningDate),
    };

    setErrors(newErrors);

    if (Object.values(newErrors).some(Boolean)) {
      showSnackbar("Please fill all required fields.", "error");
      return;
    }

    try {
      setIsSaving(true);

      const response = await saveStaff(form);

      if (response?.code && response?.message) {
        showSnackbar(response.message, "error");
        return;
      }

      showSnackbar("Staff added successfully", "success");
      fetchStaffs();
      resetForm();

      if (closeAfterSave) {
        setOpen(false);
      }
    } catch (error) {
      showSnackbar(error.message, "error");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
      <div className="bg-white w-full max-w-md mx-4 md:mx-0
 rounded-lg shadow-lg flex flex-col">

        {/* Header */}
        <div className="p-6 border-b">
          <h2 className="text-lg font-semibold text-gray-900">
            Add New Staff
          </h2>
        </div>

        {/* Body */}
        <div className="px-6 py-4 space-y-4">
          <CustomTextField
            name="staffName"
            value={form.staffName}
            onChange={(e) => handleFormChange("staffName", e.target.value)}
            label="Staff Name *"
            error={!!errors.staffName}
            helperText={errors.staffName || ""}
          />

          <CustomTextField
            name="phone"
            value={form.phone}
            onChange={(e) => {
              const value = e.target.value;
              if (/^\d*$/.test(value)) {
                handleFormChange("phone", value);
              }

            }}
            label="Phone Number"
            error={!!errors.phone}
            helperText={errors.phone || ""}
            type="tel"
            inputProps={{ maxLength: 10 }}
          />

          <LocalizationProvider dateAdapter={AdapterDayjs}>
            <DatePicker
              label="Joining Date *"
              format="DD-MM-YYYY"
              value={
                form.joiningDate
                  ? dayjs(form.joiningDate, "YYYY-MM-DD")
                  : null
              }
              onChange={(newValue) => {
                const formatted = newValue
                  ? dayjs(newValue).format("YYYY-MM-DD")
                  : "";

                handleFormChange("joiningDate", formatted);
              }}
              slotProps={{
                textField: {
                  fullWidth: true,
                  size: "small",
                  error: !!errors.joiningDate,
                  helperText: errors.joiningDate || "",
                },
              }}
            />
          </LocalizationProvider>

        </div>

        {/* Footer */}
        <div className="p-4 border-t flex justify-end gap-3 bg-gray-50">

          {/* Cancel */}
          <button
            disabled={isSaving}
            onClick={() => {
              resetForm();
              setOpen(false);
            }}
            className="px-2 py-1 md:px-4 md:py-2 border rounded-lg text-sm
              hover:bg-gray-100
              disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Cancel
          </button>

          {/* Save & Add New */}
          <button
            disabled={isSaving}
            onClick={() => handleAddStaff({ closeAfterSave: false })}
            className="px-2 py-1 md:px-4 md:py-2 border border-blue-600 text-blue-600
              rounded-lg text-sm hover:bg-blue-50
              flex items-center gap-2
              disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {isSaving ? (
              <>
                <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                  <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                  <path fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                </svg>
                Saving…
              </>
            ) : (
              "Save & Add New"
            )}
          </button>

          {/* Save Staff */}
          <button
            disabled={isSaving}
            onClick={() => handleAddStaff({ closeAfterSave: true })}
            className="px-2 py-1 md:px-4 md:py-2 bg-blue-600 text-white
              rounded-lg text-sm hover:bg-blue-700
              flex items-center gap-2
              disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {isSaving ? (
              <>
                <svg className="animate-spin h-4 w-4 text-white" viewBox="0 0 24 24">
                  <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                  <path fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                </svg>
                Saving…
              </>
            ) : (
              "Save Staff"
            )}
          </button>
        </div>

      </div>
    </div>
  );
}
