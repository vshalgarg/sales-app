import CustomTextField from "../components/CustomTextField";
import validate from "../validations/Validation";
import { useState, useEffect } from "react";
import { saveStaff, updateStaff } from "../service/StaffService";
import { useSnackbar } from "../context/SnackbarContext";

import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import { sanitizePayload } from "../utils/sanitizePayload";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";

export default function AddNewStaff({
  open,
  setOpen,
  form,
  setForm,
  fetchStaffs,
  isEdit = false,
  staffId = null
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
  }, [open, isEdit]);



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
  const handleSaveStaff = async ({ closeAfterSave }) => {
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

      const payload = sanitizePayload(form);
      let response;

      if (isEdit) {
        response = await updateStaff(staffId, payload);
        if (!response || response.error) {
          showSnackbar(response?.message || "Failed to save staff", "error");
          return;
        }
        showSnackbar("Staff updated successfully", "success");
      } else {
        response = await saveStaff(payload);
        showSnackbar("Staff added successfully", "success");
      }

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
            {isEdit ? "Edit Staff" : "Add New Staff"}
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
              if (/^[0-9-\s]*$/.test(value)) {
                handleFormChange("phone", value);
              }

            }}
            label="Phone Number"
            error={!!errors.phone}
            helperText={errors.phone || ""}
            type="tel"
            inputProps={{ maxLength: 15 }}
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
        <FormFooter>

          {/* Save Staff */}
          <AppButton
            type="primary"
            loading={isSaving}
            onClick={() => handleSaveStaff({ closeAfterSave: true })}
          >
            {isEdit ? "Update Staff" : "Save Staff"}
          </AppButton>

          {/* Save & Add New */}
          {!isEdit && (
            <AppButton
              type="secondary"
              loading={isSaving}
              onClick={() => handleSaveStaff({ closeAfterSave: false })}
            >
              Save & Add New
            </AppButton>
          )}

          {/* Cancel */}
          <AppButton
            type="cancel"
            disabled={isSaving}
            onClick={() => {
              resetForm();
              setOpen(false);
            }}
          >
            Cancel
          </AppButton>

        </FormFooter>

      </div>
    </div>
  );
}
