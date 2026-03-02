import { useState, useEffect } from "react";
import { Button, IconButton } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import CustomTextField from "../components/CustomTextField";
import StateAutocomplete from "../components/common/StateAutocomplete";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";


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


  /* ================= RESET ================= */
  const resetForm = () => {
    setFormData(initialState);
    setErrors({ contacts: [] });
  };


  /* ================= EDIT MODE ================= */
  useEffect(() => {
    if (editingTransport) {
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
    } else {
      resetForm();
    }
  }, [editingTransport, open]);

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
    <div className="fixed inset-0 bg-black/80 z-50 md:flex md:items-center md:justify-center">
      <div className="bg-white w-full h-screen md:max-w-4xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">

        {/* HEADER */}
        <div className="p-4 md:p-6 border-b flex items-center gap-3">
          <IconButton
            onClick={() => {
              resetForm();
              setOpen(false);
            }}
            className="md:hidden"
          >
            <ArrowBackIcon />
          </IconButton>

          <h2 className="text-lg md:text-xl font-semibold">
            {editingTransport ? "Edit Transport" : "Add New Transport"}
          </h2>
        </div>

        {/* BODY */}
        <div className="px-6 py-4 overflow-y-auto flex-1 space-y-8">

          {/* ===== BASIC INFORMATION ===== */}
          <section>
            <h3 className="text-lg font-semibold mb-3">
              Basic Information
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <CustomTextField label="Transport Name *" name="name" value={formData.name} onChange={handleChange} error={!!errors.name} helperText={errors.name} />
              <CustomTextField label="Email" name="email" value={formData.email} onChange={handleChange} error={!!errors.email} helperText={errors.email} />
              <CustomTextField label="GST Number" name="gstNo" value={formData.gstNo} onChange={handleChange} error={!!errors.gstNo} helperText={errors.gstNo} />
            </div>
          </section>

          {/* ===== ADDRESS DETAILS ===== */}
          <section>
            <h3 className="text-lg font-semibold mb-3">
              Address Details
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

              <CustomTextField label="Address Line 1"
                name="addressLine1"
                value={formData.addressLine1}
                onChange={handleChange}
              />
              <CustomTextField
                label="Address Line 2"
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

              <CustomTextField label="City"
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
          </section>

          {/* ===== CONTACT INFORMATION ===== */}
          <section>
            <h3 className="text-lg font-semibold mb-3">
              Contact Information
            </h3>

            {formData.contacts.map((c, index) => (
              <div key={index} className="mb-6">

                {/* Mobile Contact Card */}
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

                {/* Desktop Layout*/}
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
                        color="error"
                        onClick={() => removeContact(index)}
                      >
                        <DeleteOutlineIcon />
                      </IconButton>
                    )}
                  </div>
                </div>
              </div>
            ))}

            <Button startIcon={<AddIcon />} onClick={addContact} variant="outlined">
              Add Contact
            </Button>
          </section>
        </div>

        {/* FOOTER */}
        <div className="p-4 border-t flex justify-end gap-3">
          <button onClick={() => setOpen(false)} className="px-3 py-1.5 text-xs md:px-4 md:py-2 md:text-sm border rounded-lg">
            Cancel
          </button>

          {!editingTransport && (
            <button onClick={() => handleSubmit({ closeAfterSave: false })}
              className="px-3 py-1.5 text-xs md:px-4 md:py-2 md:text-sm border border-blue-600 text-blue-600 rounded-lg">
              Save & Add New
            </button>
          )}

          <button onClick={() => handleSubmit({ closeAfterSave: true })}
            className="px-3 py-1.5 text-xs md:px-4 md:py-2 md:text-sm bg-blue-600 text-white rounded-lg">
            {editingTransport ? "Update Transport" : "Save Transport"}
          </button>
        </div>
      </div>
    </div>
  );
}
