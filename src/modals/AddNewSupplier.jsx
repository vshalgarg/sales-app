import { Button, IconButton } from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import BasicSelect from "../components/BasicSelect";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import CustomTextField from "../components/CustomTextField";
import { useEffect, useState } from "react";
import AddIcon from "@mui/icons-material/Add";
import SupplierService from "../service/SupplierService";
import TransportService from "../service/TransportService";
import Autocomplete from "@mui/material/Autocomplete";
import { sanitizePayload } from "../utils/sanitizePayload";
import Chip from "@mui/material/Chip";

const AddNewSupplier = ({ form, open, setOpen, setForm, fetchSuppliers }) => {
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const [states, setStates] = useState([]);
  const [touched, setTouched] = useState({});
  const { showSnackbar } = useSnackbar();
  const [selectedTransports, setSelectedTransports] = useState([]);
  const [allTransports, setAllTransports] = useState([]);
  const [transportLoading, setTransportLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);


  useEffect(() => {
    const fetchTransports = async () => {
      try {
        setTransportLoading(true);
        const transports = await TransportService.getAllTransports();
        setAllTransports(transports || []);
      } catch (err) {
        console.error(err);
      } finally {
        setTransportLoading(false);
      }
    };
    fetchTransports();
  }, []);

  // Add new empty contact
  const addContact = () => {
    setForm({
      ...form,
      contacts: [
        ...form.contacts,
        { contactPerson: "", mobileNumber: "", phone: "" },
      ],
    });

    setErrors((prevErrors) => ({
      ...prevErrors,
      contacts: [...(prevErrors.contacts || []), {}],
    }));
  };

  const deleteContact = (index) => {
    if (index === 0) return;

    const updatedContacts = form.contacts.filter((_, i) => i !== index);
    const updatedErrors = errors.contacts.filter((_, i) => i !== index);

    setForm((prev) => ({
      ...prev,
      contacts: updatedContacts,
    }));

    setErrors((prev) => ({
      ...prev,
      contacts: updatedErrors,
    }));
  };

  const handleContactChange = (index, e) => {
    const { name, value } = e.target;

    // Update form
    const newContacts = [...form.contacts];
    newContacts[index][name] = value;
    setForm({ ...form, contacts: newContacts });

    // Validate field
    const errorMsg = validate(name, value);
    const updatedContactErrors = [...errors.contacts];
    if (!updatedContactErrors[index]) updatedContactErrors[index] = {};
    updatedContactErrors[index][name] = errorMsg;

    setErrors((prev) => ({
      ...prev,
      contacts: updatedContactErrors,
    }));
  };

  // Fetch Indian States on mount
  useEffect(() => {
    fetch("https://countriesnow.space/api/v0.1/countries/states", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ country: "India" }),
    })
      .then((res) => res.json())
      .then((data) => setStates(data.data.states || []))
      .catch((err) => console.error("Error fetching states:", err));
  }, []);


  const handleFormChange = (e) => {
    const { name, value } = e.target;

    if (name === "pinCode" && !/^\d{0,6}$/.test(value)) return;

    // 🔹commissionRate (max 100, 2 decimals)
    if (name === "commissionRate") {
      if (
        /^\d*\.?\d{0,2}$/.test(value) &&
        (value === "" || parseFloat(value) <= 100)
      ) {
        setForm(prev => ({ ...prev, commissionRate: value }));

        setTouched(prev => ({ ...prev, commissionRate: true }));
        setErrors(prev => ({
          ...prev,
          commissionRate: validate("commissionRate", value),
        }));
      }
      return;
    }

    // 🔹fields (state, city, pinCode, others)
    setForm(prev => ({
      ...prev,
      [name]: value,
    }));

    // 🔹 Validation
    setTouched(prev => ({ ...prev, [name]: true }));
    setErrors(prev => ({ ...prev, [name]: validate(name, value) }));
  };


  const handleAddSupplier = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const newErrors = {};
    let contactErrors = [];

    // ---- validate top-level ----
    Object.keys(form).forEach((field) => {
      if (field !== "contacts") {
        const error = validate(field, form[field]);
        if (error) newErrors[field] = error;
      }
    });

    // ---- validate contacts ----
    contactErrors = form.contacts.map((contact) => {
      const contactError = {};
      ["contactPerson", "mobileNumber"].forEach((field) => {
        const error = validate(field, contact[field]);
        if (error) contactError[field] = error;
      });
      return contactError;
    });

    newErrors.contacts = contactErrors;
    setErrors(newErrors);

    const hasTopLevelErrors = Object.keys(newErrors).some(
      (key) => key !== "contacts" && newErrors[key]
    );

    const hasContactErrors = contactErrors.some((err) =>
      Object.values(err).some(Boolean)
    );

    if (hasTopLevelErrors) {
      const msg = Object.values(newErrors).find((v) => typeof v === "string");
      showSnackbar(msg, "error");
      return;
    }

    if (hasContactErrors) {
      const msg = contactErrors.flatMap((e) => Object.values(e)).find(Boolean);
      showSnackbar(msg, "error");
      return;
    }

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map((t) => t.id),
    });

    try {
      setIsSaving(true);

      const response = await SupplierService.saveSupplier(payload);

      if (response?.code && response?.message) {
        showSnackbar(response.message, "error");
        return;
      }

      showSnackbar("Supplier added successfully!", "success");
      fetchSuppliers();
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


  const resetForm = () => {
    setForm({
      ...Object.fromEntries(
        Object.keys(form).map((key) => [
          key,
          Array.isArray(form[key]) ? [] : "",
        ])
      ),
      contacts: [{ contactPerson: "", mobileNumber: "", phone: "" }],
      preferredTransportIds: [],
    });

    setErrors({ contacts: [{}] });
    setSelectedTransports([]);
  };


  return (
    <>
      {open && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div className="bg-white dark:bg-gray-900 w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
            {/* Header */}
            <div className="p-6 border-b">
              <h2 className="text-xl font-semibold">Add New Supplier</h2>
            </div>

            {/* Scrollable form content */}
            <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
              {/* Basic Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">Basic Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <CustomTextField
                    name="supplierName"
                    value={form.supplierName}
                    onChange={handleFormChange}
                    label="Supplier Name*"
                    className="border p-2 rounded"
                    error={!!errors.supplierName}
                    helperText={errors.supplierName}
                  />
                  <CustomTextField
                    name="supplierGroup"
                    value={form.supplierGroup}
                    onChange={handleFormChange}
                    label="Group"
                    className="border p-2 rounded"
                  />
                  <CustomTextField
                    name="supplierGstNo"
                    value={form.supplierGstNo}
                    onChange={handleFormChange}
                    label="GST Number"
                    className="border p-2 rounded"

                  />
                  <BasicSelect
                    name="supplierMsme"
                    value={form.supplierMsme}
                    onChange={handleFormChange}
                    label="MSME"
                    options={[
                      { value: "Micro", label: "Micro" },
                      { value: "Small", label: "Small" },
                      { value: "Medium", label: "Medium" },
                    ]}
                  />
                  <BasicSelect
                    name="commissionScheme"
                    value={form.commissionScheme}
                    onChange={handleFormChange}
                    label="Commission Scheme"
                    options={[
                      { value: "Fixed", label: "Fixed" },
                      { value: "Percentage", label: "Percentage" },
                      { value: "Tiered", label: "Tiered" },
                    ]}
                  />
                  <CustomTextField
                    name="commissionRate"
                    value={form.commissionRate}
                    onChange={handleFormChange}
                    label="Commission % (Rate)"
                    className="border p-2 rounded"
                  />
                </div>
              </div>

              {/* Address Details */}
              <div>
                <h3 className="text-lg font-medium mb-2">Address Details</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <CustomTextField
                    name="addressLine1"
                    value={form.addressLine1}
                    onChange={handleFormChange}
                    label="Address Line 1*"
                    className="border p-2 rounded"
                    error={!!errors.addressLine1}
                    helperText={errors.addressLine1}
                  />
                  <CustomTextField
                    name="addressLine2"
                    value={form.addressLine2}
                    onChange={handleFormChange}
                    label="Address Line 2 (Optional)"
                    className="border p-2 rounded"
                  />
                  <BasicSelect
                    name="state"
                    value={form.state}
                    onChange={handleFormChange}
                    label="State*"
                    error={!!errors.state}
                    helperText={errors.state || ""}
                    options={states.map((s) => ({
                      value: s.name,
                      label: s.name,
                    }))}
                  />
                  <CustomTextField
                    name="city"
                    value={form.city}
                    onChange={handleFormChange}
                    label="City*"
                    className="border p-2 rounded"
                    error={!!errors.city}
                    helperText={errors.city}
                  />

                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode}
                    onChange={handleFormChange}
                    label="Pin Code*"
                    error={!!errors.pinCode}
                    helperText={errors.pinCode}
                  />
                </div>
              </div>

              {/* Contact Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">
                  Contact Information
                </h3>
                {form.contacts.map((contact, index) => (
                  <div
                    key={index}
                    className="grid grid-cols-1 md:grid-cols-12 gap-4 mb-4 items-start"
                  >
                    <div className="md:col-span-4">
                      <CustomTextField
                        name="contactPerson"
                        value={contact.contactPerson}
                        onChange={(e) => handleContactChange(index, e)}
                        label="Contact Person*"
                        className="w-full border p-2 rounded"
                        error={!!errors.contacts?.[index]?.contactPerson}
                        helperText={errors.contacts?.[index]?.contactPerson}
                      />
                    </div>
                    <div className="md:col-span-4">
                      <CustomTextField
                        name="mobileNumber"
                        value={contact.mobileNumber}
                        onChange={(e) => {
                          const value = e.target.value;
                          if (/^\d{0,10}$/.test(value)) {
                            handleContactChange(index, e);
                          }
                        }}
                        label="Mobile No.*"
                        className="w-full border p-2 rounded"
                        error={!!errors.contacts?.[index]?.mobileNumber}
                        helperText={errors.contacts?.[index]?.mobileNumber}
                        type="tel"
                        inputProps={{ maxLength: 10 }}
                      />
                    </div>
                    <div className="md:col-span-3">
                      <CustomTextField
                        name="phone"
                        value={contact.phone}
                        onChange={(e) => {
                          const value = e.target.value;
                          if (/^\d{0,10}$/.test(value)) {
                            handleContactChange(index, e);
                          }
                        }}
                        label="Phone No."
                        className="w-full border p-2 rounded"
                        error={!!errors.contacts?.[index]?.phone}
                        helperText={errors.contacts?.[index]?.phone}
                        type="tel"
                        inputProps={{ maxLength: 10 }}
                      />
                    </div>

                    {/* Delete icon button - hidden for first contact */}
                    <div className="md:col-span-1 flex justify-center">
                      {index > 0 && (
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => deleteContact(index)}
                        >
                          <DeleteOutlineIcon fontSize="small" />
                        </IconButton>
                      )}
                    </div>
                  </div>
                ))}

                <Button
                  variant="outlined"
                  startIcon={<AddIcon />}
                  onClick={addContact}
                  sx={{ mt: 1 }}
                >
                  Add Contact
                </Button>
              </div>

              {/* Transport Section */}
              <div>
                <h3 className="text-lg font-medium mb-2">Preferred Transports</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Autocomplete
                    multiple
                    options={allTransports}
                    value={selectedTransports}
                    loading={transportLoading}
                    filterSelectedOptions
                    isOptionEqualToValue={(o, v) => o.id === v.id}

                    getOptionLabel={(o) => o.name}

                    renderOption={(props, option) => (
                      <li {...props} key={option.id}>
                        {option.name} – {option.city}
                      </li>
                    )}

                    onChange={(e, values) => {
                      setSelectedTransports(values);
                      setForm((prev) => ({
                        ...prev,
                        preferredTransportIds: values.map((v) => v.id),
                      }));
                      setErrors((prev) => ({ ...prev, preferredTransportIds: "" }));
                    }}

                    renderTags={(value, getTagProps) =>
                      value.map((option, index) => {
                        const { key, ...tagProps } = getTagProps({ index });

                        return (
                          <Chip
                            key={key}
                            label={option.name}
                            size="small"
                            {...tagProps}
                          />
                        );
                      })
                    }

                    renderInput={(params) => (
                      <CustomTextField
                        {...params}
                        label="Preferred Transports"
                        placeholder="Type transport name"
                        error={!!errors.preferredTransportIds}
                        helperText={errors.preferredTransportIds}
                      />
                    )}
                  />
                  <CustomTextField
                    name="remark"
                    value={form.remark}
                    onChange={handleFormChange}
                    label="Remarks (optional)"
                    size="small"
                    multiline
                  />
                </div>

              </div>
            </div>

            {/* Footer*/}
            <div className="p-4 border-t flex justify-end gap-3 bg-gray-50">

              {/* Cancel */}
              <button
                disabled={isSaving}
                onClick={() => {
                  resetForm();
                  setOpen(false);
                }}
                className="p-2 md:px-4 md:py-2 border rounded-lg text-sm
               text-gray-700 hover:bg-gray-100
               disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Cancel
              </button>

              {/* Save & Add New */}
              <button
                disabled={isSaving}
                onClick={() => handleAddSupplier({ closeAfterSave: false })}
                className="p-2 md:px-4 md:py-2 border border-blue-600 text-blue-600
               rounded-lg text-sm hover:bg-blue-50
               flex items-center gap-2
               disabled:opacity-60 disabled:cursor-not-allowed"
              >
                {isSaving ? (
                  <>
                    <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                        fill="none"
                      />
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                      />
                    </svg>
                    Saving…
                  </>
                ) : (
                  "Save & Add New"
                )}
              </button>

              {/* Save Supplier */}
              <button
                disabled={isSaving}
                onClick={() => handleAddSupplier({ closeAfterSave: true })}
                className="p-2 md:px-4 md:py-2 bg-blue-600 text-white
               rounded-lg text-sm hover:bg-blue-700
               flex items-center gap-2
               disabled:opacity-60 disabled:cursor-not-allowed"
              >
                {isSaving ? (
                  <>
                    <svg className="animate-spin h-4 w-4 text-white" viewBox="0 0 24 24">
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                        fill="none"
                      />
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                      />
                    </svg>
                    Saving…
                  </>
                ) : (
                  "Save Supplier"
                )}
              </button>
            </div>

          </div>
        </div>
      )}
    </>
  );
};

export default AddNewSupplier;
