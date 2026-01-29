import { useState, useEffect } from "react";
import { Button, IconButton } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import CustomTextField from "../components/CustomTextField";
import BasicSelect from "./BasicSelect";

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
   const [states, setStates] = useState([]);

   
  /* ================= RESET ================= */
  const resetForm = () => {
    setFormData(initialState);
    setErrors({ contacts: [] });
  };

  useEffect(() => {
    fetch("https://countriesnow.space/api/v0.1/countries/states", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ country: "India" }),
    })
      .then(res => res.json())
      .then(data => setStates(data.data.states || []))
      .catch(() => showSnackbar("Failed to load states", "error"));
  }, []);


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

    const newErrors = {};
    const contactErrors = [];

    Object.keys(formData).forEach((field) => {
      if (field !== "contacts") {
        const error = validate(field, formData[field]);
        if (error) newErrors[field] = error;
      }
    });

    formData.contacts.forEach((c, i) => {
      const err = {};
      ["contactPerson", "contactNumber"].forEach((f) => {
        const e = validate(f, c[f]);
        if (e) err[f] = e;
      });
      contactErrors[i] = err;
    });

    newErrors.contacts = contactErrors;
    setErrors(newErrors);

    const hasTopErrors = Object.entries(newErrors)
      .some(([key, value]) => key !== "contacts" && Boolean(value));

    const hasContactErrors = contactErrors
      .some((e) => Object.values(e).some(Boolean));

    const hasErrors = hasTopErrors || hasContactErrors;


    if (hasErrors) {
      showSnackbar("Please fix validation errors", "error");
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
    <div className="fixed inset-0 flex items-center justify-center bg-black/80 z-50">
      <div className="bg-white w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">

        {/* HEADER */}
        <div className="p-6 border-b">
          <h2 className="text-xl font-semibold">
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
              <CustomTextField label="Transport Name*" name="name" value={formData.name} onChange={handleChange} error={!!errors.name} helperText={errors.name} />
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
              <BasicSelect
                name="state"
                value={formData.state}
                onChange={handleChange}
                label="State"
                options={states.map(s => ({ value: s.name, label: s.name }))}
                error={!!errors.state}
                helperText={errors.state}
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

              <CustomTextField label="Address Line 1*" name="addressLine1" value={formData.addressLine1} onChange={handleChange} error={!!errors.addressLine1} helperText={errors.addressLine1} />
              <CustomTextField label="Address Line 2" name="addressLine2" value={formData.addressLine2} onChange={handleChange} />
            </div>
          </section>

          {/* ===== CONTACT INFORMATION ===== */}
          <section>
            <h3 className="text-lg font-semibold mb-3">
              Contact Information
            </h3>

            {formData.contacts.map((c, index) => (
              <div key={index} className="grid grid-cols-1 md:grid-cols-12 gap-4 mb-4">
                <div className="md:col-span-4">
                  <CustomTextField label="Contact Person" value={c.contactPerson} onChange={(e) => handleContactChange(index, "contactPerson", e.target.value)} error={!!errors.contacts?.[index]?.contactPerson} helperText={errors.contacts?.[index]?.contactPerson} />
                </div>
                <div className="md:col-span-4">
                  <CustomTextField label="Contact Number*" value={c.contactNumber} onChange={(e) => /^\d*$/.test(e.target.value) && handleContactChange(index, "contactNumber", e.target.value)} error={!!errors.contacts?.[index]?.contactNumber} helperText={errors.contacts?.[index]?.contactNumber} />
                </div>
                <div className="md:col-span-3">
                  <CustomTextField label="Type" value={c.type} onChange={(e) => handleContactChange(index, "type", e.target.value)} />
                </div>
                <div className="md:col-span-1 flex justify-center">
                  {index > 0 && (
                    <IconButton color="error" onClick={() => removeContact(index)}>
                      <DeleteOutlineIcon />
                    </IconButton>
                  )}
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
          <button onClick={() => setOpen(false)} className="p-2 px-4 border rounded-lg text-sm">
            Cancel
          </button>

          {!editingTransport && (
            <button onClick={() => handleSubmit({ closeAfterSave: false })} className="p-2 px-4 border border-blue-600 text-blue-600 rounded-lg text-sm">
              Save & Add New
            </button>
          )}

          <button onClick={() => handleSubmit({ closeAfterSave: true })} className="p-2 px-4 bg-blue-600 text-white rounded-lg text-sm">
            {editingTransport ? "Update Transport" : "Save Transport"}
          </button>
        </div>
      </div>
    </div>
  );
}
