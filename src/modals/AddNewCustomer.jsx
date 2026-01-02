import { Button, IconButton, Autocomplete, TextField, Chip } from "@mui/material";
import { useState, useEffect } from "react";
import BasicSelect from "../components/BasicSelect";
import CustomTextField from "../components/CustomTextField";
import AddIcon from "@mui/icons-material/Add";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import CustomerService from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import TransportService from "../service/TransportService";
import { sanitizePayload } from "../utils/sanitizePayload";

const AddNewCustomer = ({ form, open, setOpen, setForm, fetchCustomers }) => {
  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const [touched, setTouched] = useState({});

  const [states, setStates] = useState([]);
  const { showSnackbar } = useSnackbar();
  const [transportSearch, setTransportSearch] = useState("");
  const [transportResults, setTransportResults] = useState([]);

  const [allTransports, setAllTransports] = useState([]);
  const [transportLoading, setTransportLoading] = useState(false);
  const [selectedTransports, setSelectedTransports] = useState([]);
  const [selectedTransport, setSelectedTransport] = useState(null);


  /* ---------- Load all transports once ---------- */
  useEffect(() => {
    const loadTransports = async () => {
      try {
        setTransportLoading(true);
        const data = await TransportService.getAllTransports();
        setAllTransports(data || []);
      } catch (err) {
        console.error(err);
        showSnackbar("Failed to load transports", "error");
      } finally {
        setTransportLoading(false);
      }
    };
    loadTransports();
  }, []);


  const addTransport = (transport) => {
    if (selectedTransports.find((t) => t.id === transport.id)) return;

    const newSelected = [...selectedTransports, transport];
    setSelectedTransports(newSelected);

    setForm((prev) => ({
      ...prev,
      preferredTransportIds: newSelected.map((t) => t.id),
    }));

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

  const handleFormChange = (e) => {
    const { name, value } = e.target;

    // PinCode: digits only, max 6
    if (name === "pinCode") {
      if (!/^\d{0,6}$/.test(value)) return;

      setForm(prev => ({ ...prev, pinCode: value }));
      setTouched(prev => ({ ...prev, pinCode: true }));
      setErrors(prev => ({ ...prev, pinCode: validate("pinCode", value) }));
      return;
    }

    // fields (state, city, others)
    setForm(prev => ({
      ...prev,
      [name]: value,
    }));

    setTouched(prev => ({ ...prev, [name]: true }));
    setErrors(prev => ({ ...prev, [name]: validate(name, value) }));
  };


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

  useEffect(() => {
    fetch("https://countriesnow.space/api/v0.1/countries/states", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ country: "India" }),
    })
      .then((res) => res.json())
      .then((data) => setStates(data.data.states || []))
      // .then((data) => {
      //   const uniqueStates = [
      //     ...new Set(data.geonames.map((c) => c.adminName1)),
      //   ];
      //   setStates(uniqueStates.sort().map((s) => ({ name: s })));
      // })
      .catch((err) => console.error("Error fetching states:", err));
  }, []);


  const handleAddCustomer = async ({ closeAfterSave }) => {
    if (isSaving) return;

    const newErrors = {};
    let contactErrors = [];

    // ---------- VALIDATION ----------
    Object.keys(form).forEach((field) => {
      if (field !== "contacts") {
        const error = validate(field, form[field]);
        if (error) newErrors[field] = error;
      }
    });

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

    const hasTopErrors = Object.keys(newErrors).some(
      (k) => k !== "contacts" && newErrors[k]
    );

    const hasContactErrors = contactErrors.some((e) =>
      Object.values(e).some(Boolean)
    );

    if (hasTopErrors || hasContactErrors) {
      const msg =
        Object.values(newErrors).find((v) => typeof v === "string") ||
        contactErrors.flatMap((e) => Object.values(e)).find(Boolean);

      showSnackbar(msg || "Validation error", "error");
      return;
    }

    const payload = sanitizePayload({
      ...form,
      preferredTransportIds: selectedTransports.map((t) => t.id),
    });

    try {
      setIsSaving(true);

      const response = await CustomerService.saveCustomer(payload);

      if (response?.code && response?.message) {
        showSnackbar(response.message, "error");
        return;
      }

      showSnackbar("Customer added successfully", "success");
      fetchCustomers();
      resetForm();

      if (closeAfterSave) {
        setOpen(false);
      }
    } catch (err) {
      console.error(err);
      showSnackbar("Network or server error", "error");
    } finally {
      setIsSaving(false);
    }
  };

  const resetTransport = () => {
    setSelectedTransport(null);
    setFormData(prev => ({
      ...prev,
      transportId: null,
      transportName: "",
      transportCity: "",
    }));
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
    setTransportSearch("");
    setTransportResults([]);
  };

  return (
    <>
      {open && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
          <div className="bg-white w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
            {/* Header */}
            <div className="p-6 border-b">
              <h2 className="text-xl font-semibold">Add New Customer</h2>
            </div>

            {/* Scrollable form content */}
            <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
              {/* Basic Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">Basic Information</h3>
                <div className="grid grid-cols-2 gap-4">
                  <CustomTextField
                    name="customerName"
                    value={form.customerName}
                    onChange={handleFormChange}
                    label="Customer Name*"
                    error={!!errors.customerName}
                    helperText={errors.customerName}
                  />
                  <CustomTextField
                    name="customerGroup"
                    value={form.customerGroup}
                    onChange={handleFormChange}
                    label="Group Name"
                  />
                  <CustomTextField
                    name="customerGstNo"
                    value={form.customerGstNo}
                    onChange={handleFormChange}
                    label="GST Number"
                  />
                  <BasicSelect
                    name="customerMsme"
                    value={form.customerMsme}
                    onChange={handleFormChange}
                    label="MSME"
                    options={[
                      { value: "Micro", label: "Micro" },
                      { value: "Small", label: "Small" },
                      { value: "Medium", label: "Medium" },
                    ]}
                  />
                  <CustomTextField
                    name="referencedBy"
                    value={form.referencedBy}
                    onChange={handleFormChange}
                    label="Referenced By"
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
                    error={!!errors.addressLine1}
                    helperText={errors.addressLine1}
                  />
                  <CustomTextField
                    name="addressLine2"
                    value={form.addressLine2}
                    onChange={handleFormChange}
                    label="Address Line 2 (Optional)"
                  />
                  <BasicSelect
                    name="state"
                    value={form.state}
                    onChange={handleFormChange}
                    label="State*"
                    error={!!errors.state}
                    helperText={errors.state}
                    options={states.map((s) => ({ value: s.name, label: s.name }))}
                  />
                  <CustomTextField
                    name="city"
                    value={form.city}
                    onChange={handleFormChange}
                    label="City*"
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
                    inputProps={{
                      maxLength: 6,
                      inputMode: "numeric",
                      pattern: "[0-9]*",
                    }}
                  />
                </div>
              </div>

              {/* Contact Information */}
              <div>
                <h3 className="text-lg font-medium mb-2">Contact Information</h3>
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
                        label="MobileNo.*"
                        type="tel"
                        inputProps={{ maxLength: 10 }}
                        error={!!errors.contacts?.[index]?.mobileNumber}
                        helperText={errors.contacts?.[index]?.mobileNumber}
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
                        type="tel"
                        inputProps={{ maxLength: 10 }}
                      />
                    </div>
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

              {/* Financial & Logistics - Transport & Remark*/}
              <div>
                <h3 className="text-lg font-medium mb-3">Financial & Logistics</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Transport Autocomplete */}
                  <div>
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Preferred Transports
                    </label>
                    <Autocomplete
                      options={allTransports}
                      value={selectedTransport}
                      isOptionEqualToValue={(o, v) => o.id === v?.id}
                      getOptionLabel={(o) =>
                        o?.name ? `${o.name} - ${o.city || ""}` : ""
                      }
                      onChange={(e, value) => {
                        if (!value) {
                          resetTransport();
                          return;
                        }

                        setSelectedTransport(value);
                        setFormData(prev => ({
                          ...prev,
                          transportId: value.id,
                          transportName: value.name,
                          transportCity: value.city,
                        }));

                        setErrors(prev => ({ ...prev, transport: "" }));
                      }}
                      renderInput={(params) => (
                        <CustomTextField
                          {...params}
                          label="Transport"
                        // error={!!errors.transport}
                        // helperText={errors.transport || "Search transport"}
                        />
                      )}
                    />
                  </div>

                  {/* Remark */}
                  <div>
                    <label className=" text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Remarks
                    </label>
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
                className="px-4 py-2 border rounded-lg text-sm
      hover:bg-gray-100
      disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Cancel
              </button>

              {/* Save & Add New */}
              <button
                disabled={isSaving}
                onClick={() => handleAddCustomer({ closeAfterSave: false })}
                className="px-4 py-2 border border-blue-600 text-blue-600
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

              {/* Save Customer */}
              <button
                disabled={isSaving}
                onClick={() => handleAddCustomer({ closeAfterSave: true })}
                className="px-4 py-2 bg-blue-600 text-white
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
                  "Save Customer"
                )}
              </button>
            </div>



          </div>
        </div>
      )}
    </>
  );
};

export default AddNewCustomer;