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
import Chip from "@mui/material/Chip";

const AddNewSupplier = ({ form, open, setOpen, setForm, fetchSuppliers }) => {
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const [states, setStates] = useState([]);
  const [cities, setCities] = useState([]);
  const [touched, setTouched] = useState({});
  const { showSnackbar } = useSnackbar();

  const [selectedTransports, setSelectedTransports] = useState([]);
  const [transportSearch, setTransportSearch] = useState("");
  const [transportResults, setTransportResults] = useState([]);
  const [isTransportInputFocused, setIsTransportInputFocused] = useState(false);

  const [allTransports, setAllTransports] = useState([]);
  const [transportLoading, setTransportLoading] = useState(false);
  



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

  const handleTransportSearch = async (value) => {
    setTransportSearch(value);

    if (value.trim().length < 2) {
      setTransportResults([]);
      return;
    }

    try {
      const results = await TransportService.searchTransports(value.trim());
      // Remove already selected ones from results
      const filtered = results.filter(
        (t) => !selectedTransports.some((s) => s.id === t.id)
      );
      setTransportResults(filtered || []);
    } catch (err) {
      console.error("Transport search error:", err);
      setTransportResults([]);
    }
  };

  const addTransport = (transport) => {
    if (selectedTransports.find((t) => t.id === transport.id)) return;

    const newSelected = [...selectedTransports, transport];
    setSelectedTransports(newSelected);

    // Update form with IDs
    setForm((prev) => ({
      ...prev,
      preferredTransportIds: newSelected.map((t) => t.id),
    }));

    // Clear input but keep dropdown open for next search
    setTransportSearch("");
    setErrors((prev) => ({ ...prev, preferredTransportIds: "" }));
  };

  const removeTransport = (idToRemove) => {
    const newSelected = selectedTransports.filter((t) => t.id !== idToRemove);
    setSelectedTransports(newSelected);
    setForm((prev) => ({
      ...prev,
      preferredTransportIds: newSelected.map((t) => t.id),
    }));
  };

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

  // Fetch Cities when State changes
  useEffect(() => {
    if (!form.state) return;
    fetch("https://countriesnow.space/api/v0.1/countries/state/cities", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ country: "India", state: form.state }),
    })
      .then((res) => res.json())
      .then((data) => setCities(data.data || []))
      .catch((err) => console.error("Error fetching cities:", err));
  }, [form.state]);

  useEffect(() => {
    if (!form.city) return;

    fetch(`https://api.postalpincode.in/postoffice/${form.city}`)
      .then((res) => res.json())
      .then((data) => {
        const result = data[0];
        if (result.Status === "Success" && result.PostOffice?.length > 0) {
          const firstPin = result.PostOffice[0].Pincode;
          setForm((prev) => ({ ...prev, pinCode: firstPin }));
        } else {
          setForm((prev) => ({ ...prev, pinCode: "" }));
          console.warn("No PIN found for city:", form.city);
        }
      })
      .catch((err) => console.error("Error fetching PIN code:", err));
  }, [form.city]);

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    // 🧠 New: handle dependency clearing
    if (name === "state") {
      setForm((prev) => ({
        ...prev,
        state: value,
        city: "", // clear city when state removed or changed
        pinCode: "", // clear pin when state removed or changed
      }));
    } else if (name === "city") {
      setForm((prev) => ({
        ...prev,
        city: value,
        pinCode: "", // clear pin when city removed or changed
      }));
    } else {
      setForm({ ...form, [name]: value });
    }

    // mark field as touched for validation
    setTouched((prev) => ({ ...prev, [name]: true }));

    // validate current field
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) }));
  };

  const handleAddSupplier = async () => {
   const newErrors = {};
let contactErrors = [];

// Validate top-level fields
Object.keys(form).forEach((field) => {
  if (field !== "contacts") {
    const error = validate(field, form[field]);
    if (error) newErrors[field] = error;
  }
});

// Validate contacts
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

// ---------- ERROR CHECK ----------
const hasTopLevelErrors = Object.keys(newErrors).some(
  (key) => key !== "contacts" && newErrors[key]
);

const hasContactErrors = contactErrors.some((err) =>
  Object.values(err).some(Boolean)
);

// ---------- SHOW ACTUAL ERROR ----------
if (hasTopLevelErrors) {
  // first top-level error message
  const firstErrorMessage = Object.values(newErrors).find(
    (val) => typeof val === "string"
  );
  showSnackbar(firstErrorMessage, "error");
  return;
}

if (hasContactErrors) {
  // first contact error message
  const firstContactError = contactErrors
    .flatMap(err => Object.values(err))
    .find(Boolean);

  showSnackbar(firstContactError, "error");
  return;
}


    const payload = {
      ...form,
      preferredTransportIds: selectedTransports.map(t => t.id),
    };

    console.log("Sending payload:", payload);

    // Save supplier
    try {
      const response = await SupplierService.saveSupplier(payload);
      if (response && response.code && response.message) {
        showSnackbar(response.message, "error");
        return;
      }
      showSnackbar("Supplier added successfully!", "success");
      resetForm();
      setOpen(false);
      fetchSuppliers();
    } catch (err) {
      console.error("Save error:", err);
      showSnackbar("Failed to save supplier", "error");
    }
  };
  // Handle typing (suggestions only)
  // const handleChange = async (e) => {
  //   const value = e.target.value;
  //   setQuery(value);

  //   if (value.length > 1) {
  //     try {
  //       const result = await searchSuppliers(value); // result is array of supplier objects
  //       if (result && result.length) {
  //         // Extract names for suggestions
  //         const names = result.map((supplier) => supplier.name);
  //         setSuggestions(names);
  //       }
  //     } catch (err) {
  //       console.error(err);
  //     }
  //   } else {
  //     setSuggestions([]);
  //   }
  // };

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
    setTransportSearch("");
    setTransportResults([]);
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
                <div className="grid grid-cols-2 gap-4">
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
                    label="Group*"
                    className="border p-2 rounded"
                    error={!!errors.supplierGroup}
                    helperText={errors.supplierGroup}
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
                    label="MSME*"
                    error={!!errors.supplierMsme}
                    helperText={errors.supplierMsme || ""}
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
                    label="Commission Scheme*"
                    error={!!errors.commissionScheme}
                    helperText={errors.commissionScheme || ""}
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
                    label="Commission % (Rate)*"
                    className="border p-2 rounded"
                    error={!!errors.commissionRate}
                    helperText={errors.commissionRate}
                  />
                </div>
              </div>

              {/* Address Details */}
              <div>
                <h3 className="text-lg font-medium mb-2">Address Details</h3>
                <div className="grid grid-cols-2 gap-4">
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
                  <BasicSelect
                    name="city"
                    value={form.city}
                    onChange={handleFormChange}
                    label="City*"
                    error={!!errors.city}
                    helperText={errors.city || ""}
                    options={cities.map((c) => ({
                      value: c,
                      label: c,
                    }))}
                    disabled={!form.state}
                  />

                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode}
                    readOnly
                    label="Pin Code*"
                    disabled={!form.state} // ✅ disabled until state is chosen
                    className="border p-2 rounded cursor-not-allowed"
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
                    className="grid grid-cols-12 gap-4 mb-4 items-start"
                  >
                    <div className="col-span-4">
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
                    <div className="col-span-4">
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
                    <div className="col-span-3">
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
                    <div className="col-span-1 flex justify-center">
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
                <div className="grid grid-cols-2 gap-4">
                   <Autocomplete
                  multiple
                  options={allTransports}
                  getOptionLabel={(option) => option.transportName || option.name || ""}
                  value={selectedTransports}
                  onChange={(event, newValue) => {
                    setSelectedTransports(newValue);
                    setForm((prev) => ({
                      ...prev,
                      preferredTransportIds: newValue.map(t => t.id),
                    }));
                    setErrors((prev) => ({ ...prev, preferredTransportIds: "" }));
                  }}
                  loading={transportLoading}
                  disableCloseOnSelect
                  isOptionEqualToValue={(option, value) => option.id === value.id}
                  renderInput={(params) => (
                    <CustomTextField
                      {...params}
                      label="Select Preferred Transports"
                      error={!!errors.preferredTransportIds}
                      helperText={errors.preferredTransportIds || "Select one or multiple transports"}
                      InputProps={{
                        ...params.InputProps,
                        endAdornment: (
                          <>
                            {transportLoading ? <span className="text-xs text-gray-500">Loading...</span> : null}
                            {params.InputProps.endAdornment}
                          </>
                        ),
                      }}
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

            {/* Footer with buttons */}
            <div className="p-4 border-t flex justify-end space-x-3">
              <button
                onClick={() => {
                  resetForm();
                  setOpen(false);
                }}
                className="px-4 py-2 border rounded-lg hover:bg-gray-100"
              >
                Cancel
              </button>
              <button
                type="submit"
                onClick={handleAddSupplier}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Save Supplier
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AddNewSupplier;
