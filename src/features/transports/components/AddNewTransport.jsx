import { useState, useEffect } from "react";
import { Button, IconButton } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import TransportService from "@/services/TransportService";
import { useSnackbar } from "@/contexts/SnackbarContext";
import validate from "@/validations/Validation";
import CustomTextField from "@/components/CustomTextField";
import StateAutocomplete from "@/components/StateAutocomplete";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import AppButton from "@/components/AppButton";
import FormFooter from "@/components/FormFooter";
import FormSection from "@/components/FormSection";
import { FORM_SCROLL_AREA_CLASS } from "@/theme/cardTheme";
import ConfirmDialog from "@/components/ConfirmDialog";
import useUnsavedChanges from "@/hooks/useUnsavedChanges";
import { Building2, MapPin, Phone } from "lucide-react";


export default function AddNewTransport({
  open,
  setOpen,
  editingTransport = null,
  onSuccess,
}) {

  /* ================= STATE ================= */
  const initialState = {
    name: "",
    email: "",
    gstNo: "",
    contacts: [{ contactPerson: "", contactNumber: "", type: "" }],
    state: "",
    city: "",
    pincode: "",
    addressLine1: "",
    addressLine2: "",
    status: "ACTIVE",
  };

  const { showSnackbar } = useSnackbar();
  const [formData, setFormData] = useState(initialState);
  const [errors, setErrors] = useState({ contacts: [] });
  const [isSaving, setIsSaving] = useState(false);
  const [isLoaded, setIsLoaded] = useState(false);
  const { isDirty } = useUnsavedChanges(formData, open && isLoaded);
  const [confirmOpen, setConfirmOpen] = useState(false);


  /* ================= RESET ================= */
  const resetForm = () => {
    setFormData(initialState);
    setErrors({ contacts: [] });
    setIsLoaded(false);
  };


  /* ================= EDIT MODE ================= */
  useEffect(() => {
    if (!open) return;
    if (editingTransport) {
      setIsLoaded(false);
      setFormData({
        name: editingTransport.name || "",
        email: editingTransport.email || "",
        gstNo: editingTransport.gstNo || "",
        contacts:
          editingTransport.contacts?.length > 0
            ? editingTransport.contacts
            : [{ contactPerson: "", contactNumber: "", type: "" }],
        state: editingTransport.state || "",
        city: editingTransport.city || "",
        pincode: editingTransport.pincode || "",
        addressLine1: editingTransport.addressLine1 || "",
        addressLine2: editingTransport.addressLine2 || "",
        status: editingTransport.status || "ACTIVE",
      });
      setTimeout(() => setIsLoaded(true), 0);
    } else {
      resetForm();
      setIsLoaded(true);
    }
  }, [editingTransport, open]);

  const handleClose = () => {
    if (isDirty()) {
      setConfirmOpen(true);
      return;
    }

    resetForm();
    setOpen(false);
  };

  const handleConfirmLeave = () => {
    setConfirmOpen(false);
    resetForm();
    setOpen(false);
  };

  const handleStay = () => {
    setConfirmOpen(false);
  };

  useEffect(() => {
    if (!open) {
      setIsLoaded(false);
    }
  }, [open]);

  /* ================= CONTACT HANDLERS ================= */
  const addContact = () => {
    setFormData((prev) => ({
      ...prev,
      contacts: [
        ...prev.contacts,
        { contactPerson: "", contactNumber: "", type: "" },
      ],
    }));
  };

  const removeContact = (index) => {
    if (index === 0) return;
    setFormData((prev) => ({
      ...prev,
      contacts: prev.contacts.filter((_, i) => i !== index),
    }));
  };

  const handleContactChange = (index, field, value) => {
    const updated = [...formData.contacts];
    updated[index][field] = value;
    setFormData((prev) => ({ ...prev, contacts: updated }));
  };

  /* ================= BASIC CHANGE ================= */
  const handleChange = (e) => {
    const { name, value } = e.target;

    if (name === "pincode" && !/^\d{0,6}$/.test(value)) return;

    setFormData((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  /* ================= SUBMIT ================= */
  const handleSubmit = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const nameError = validate("supplierName", formData.name);

    if (nameError) {
      setErrors({ name: nameError });
      showSnackbar(nameError, "error");
      return;
    }

    try {
      setIsSaving(true);

      const payload = {
        ...formData,
        email: formData.email || null,
        gstNo: formData.gstNo || null,
        pincode: formData.pincode || null,
      };

      const response = editingTransport
        ? await TransportService.updateTransport(editingTransport.id, payload)
        : await TransportService.createTransport(payload);

      if (!response?.success) {
        showSnackbar(response?.message || "Failed to save transport", "error");
        return;
      }

      showSnackbar(
        editingTransport
          ? "Transport updated successfully"
          : "Transport added successfully",
        "success"
      );

      onSuccess();
      resetForm();
      if (closeAfterSave) setOpen(false);
    }

    catch (e) {

      showSnackbar(
        e.message || "Something went wrong while saving transport",
        "error"
      );
    }

    finally {
      setIsSaving(false);
    }
  };

  /* ================= UI ================= */
  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-start md:items-center justify-center">
      <div className="bg-white dark:bg-gray-900 w-full h-[100dvh] md:h-auto md:max-w-5xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">
        <div className="p-4 md:p-6 border-b border-gray-200 dark:border-zinc-700">
          <div className="flex items-center gap-3">
            <IconButton onClick={handleClose} aria-label="Go back">
              <ArrowBackIcon />
            </IconButton>
            <div>
              <h2 className="text-lg md:text-xl font-semibold">
                {editingTransport ? "Edit Transport" : "Add New Transport"}
              </h2>
              {!editingTransport && (
                <p className="text-sm text-gray-500 dark:text-gray-400 mt-0.5">
                  Enter transport details to add a new transport
                </p>
              )}
            </div>
          </div>
        </div>

        <div
          className={`flex-1 overflow-y-auto px-4 md:px-6 py-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}
        >
          <FormSection title="Basic Information" icon={Building2} variantIndex={0}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <CustomTextField
                label="Transport Name *"
                name="name"
                value={formData.name}
                onChange={handleChange}
                error={!!errors.name}
                helperText={errors.name}
              />
              <CustomTextField
                label="Email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                error={!!errors.email}
                helperText={errors.email}
              />
              <CustomTextField
                label="GST Number"
                name="gstNo"
                value={formData.gstNo}
                onChange={handleChange}
                error={!!errors.gstNo}
                helperText={errors.gstNo}
              />
            </div>
          </FormSection>

          <FormSection title="Address Details" icon={MapPin} variantIndex={1}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <CustomTextField
                label="Address Line 1"
                name="addressLine1"
                value={formData.addressLine1}
                onChange={handleChange}
              />
              <CustomTextField
                label="Address Line 2 (Optional)"
                name="addressLine2"
                value={formData.addressLine2}
                onChange={handleChange}
              />
              <StateAutocomplete
                value={formData.state}
                onChange={(val) =>
                  setFormData((prev) => ({ ...prev, state: val }))
                }
              />
              <CustomTextField
                label="City"
                name="city"
                value={formData.city}
                onChange={handleChange}
              />
              <CustomTextField
                label="Pin Code"
                name="pincode"
                value={formData.pincode}
                onChange={handleChange}
              />
            </div>
          </FormSection>

          <FormSection title="Contact Information" icon={Phone} variantIndex={2}>
            {formData.contacts.map((c, index) => (
              <div key={index} className="mb-6">
                <div className="md:hidden border rounded-xl p-4 space-y-4 bg-gray-50">
                  <div className="flex justify-between items-center">
                    <h4 className="text-sm font-semibold text-gray-700">
                      Contact {index + 1}
                    </h4>
                    {index > 0 && (
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => removeContact(index)}
                      >
                        <DeleteOutlineIcon fontSize="small" />
                      </IconButton>
                    )}
                  </div>
                  <CustomTextField
                    label="Contact Person"
                    value={c.contactPerson}
                    onChange={(e) =>
                      handleContactChange(index, "contactPerson", e.target.value)
                    }
                  />
                  <CustomTextField
                    label="Contact Number"
                    value={c.contactNumber}
                    onChange={(e) =>
                      /^[0-9-\s]*$/.test(e.target.value) &&
                      handleContactChange(index, "contactNumber", e.target.value)
                    }
                  />
                  <CustomTextField
                    label="Type"
                    value={c.type}
                    onChange={(e) =>
                      handleContactChange(index, "type", e.target.value)
                    }
                  />
                </div>

                <div className="hidden md:grid grid-cols-12 gap-4 items-start">
                  <div className="col-span-4">
                    <CustomTextField
                      label="Contact Person"
                      value={c.contactPerson}
                      onChange={(e) =>
                        handleContactChange(index, "contactPerson", e.target.value)
                      }
                    />
                  </div>
                  <div className="col-span-4">
                    <CustomTextField
                      label="Contact Number"
                      value={c.contactNumber}
                      onChange={(e) =>
                        /^[0-9-\s]*$/.test(e.target.value) &&
                        handleContactChange(index, "contactNumber", e.target.value)
                      }
                    />
                  </div>
                  <div className="col-span-3">
                    <CustomTextField
                      label="Type"
                      value={c.type}
                      onChange={(e) =>
                        handleContactChange(index, "type", e.target.value)
                      }
                    />
                  </div>
                  <div className="col-span-1 flex justify-center">
                    {index > 0 && (
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => removeContact(index)}
                      >
                        <DeleteOutlineIcon fontSize="small" />
                      </IconButton>
                    )}
                  </div>
                </div>
              </div>
            ))}

            <Button startIcon={<AddIcon />} onClick={addContact} variant="outlined">
              Add Contact
            </Button>
          </FormSection>
        </div>

        <FormFooter>
          <AppButton
            type="primary"
            loading={isSaving}
            onClick={() => handleSubmit({ closeAfterSave: true })}
          >
            {editingTransport ? "Update Transport" : "Save Transport"}
          </AppButton>

          {!editingTransport && (
            <AppButton
              type="secondary"
              loading={isSaving}
              onClick={() => handleSubmit({ closeAfterSave: false })}
            >
              Save & Add New
            </AppButton>
          )}

          <AppButton type="cancel" disabled={isSaving} onClick={handleClose}>
            Cancel
          </AppButton>
        </FormFooter>

        <ConfirmDialog
          open={confirmOpen}
          onConfirm={handleConfirmLeave}
          onCancel={handleStay}
        />
      </div>
    </div>
  );
}
