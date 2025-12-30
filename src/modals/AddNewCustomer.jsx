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

const AddNewCustomer = ({ form, open, setOpen, setForm, fetchCustomers }) => {
  const [errors, setErrors] = useState({
    contacts: [{}],
  });
  const [touched, setTouched] = useState({});

  const [states, setStates] = useState([]);
  const [pinCodes, setPinCodes] = useState([]);
  const [cities, setCities] = useState([]);
  const { showSnackbar } = useSnackbar();
  const [transportSearch, setTransportSearch] = useState("");
  const [transportResults, setTransportResults] = useState([]);
  const [isTransportInputFocused, setIsTransportInputFocused] = useState(false);

  const [allTransports, setAllTransports] = useState([]);
  const [transportLoading, setTransportLoading] = useState(false);
  const [selectedTransports, setSelectedTransports] = useState([]);


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



  const handleTransportSearch = async (value) => {
    setTransportSearch(value);

    if (value.trim().length < 2) {
      setTransportResults([]);
      return;
    }

    try {
      const results = await TransportService.searchTransports(value.trim());
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

  const handleMultiSelectChange = (e) => {
    const { name, value, error } = e.target; // value is guaranteed array by BasicSelect
    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));

    const errMsg = error || validate(name, value); // <- use custom error first
    setErrors((prev) => ({
      ...prev,
      [name]: errMsg,
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
    fetch(
      "http://api.geonames.org/searchJSON?country=IN&featureClass=P&maxRows=1000&username=tarunbaisla_14"
    )
      .then((res) => res.json())
      .then((data) => {
        const uniqueStates = [
          ...new Set(data.geonames.map((c) => c.adminName1)),
        ];
        setStates(uniqueStates.sort().map((s) => ({ name: s })));
      })
      .catch((err) => console.error("Error fetching states:", err));
  }, []);

  useEffect(() => {
    if (!form.state) return;

    fetch(
      "http://api.geonames.org/searchJSON?country=IN&featureClass=P&maxRows=1000&username=tarunbaisla_14"
    )
      .then((res) => res.json())
      .then((data) => {
        const filteredCities = data.geonames
          .filter((c) => c.adminName1 === form.state)
          .map((c) => c.name);
        setCities([...new Set(filteredCities)].sort());
      })
      .catch((err) => console.error("Error fetching cities:", err));
  }, [form.state]);

  // Inside your component
  useEffect(() => {
    if (!form.city) return;

    fetch(
      `http://api.geonames.org/postalCodeSearchJSON?placename=${form.city}&country=IN&maxRows=10&username=tarunbaisla_14`
    )
      .then((res) => res.json())
      .then((data) => {
        if (data.postalCodes && data.postalCodes.length > 0) {
          // Take the first pin only (autofill, not dropdown)
          const pin = data.postalCodes[0].postalCode;
          setForm((prev) => ({ ...prev, pinCode: pin }));
        } else {
          // If no pin found, keep empty so user can type manually
          setForm((prev) => ({ ...prev, pinCode: "" }));
        }
      })
      .catch((err) => console.error("Error fetching pincode:", err));
  }, [form.city]);

  const handleAddCustomer = async () => {
    const newErrors = {};
    let contactErrors = [];

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

    const hasTopLevelErrors = Object.keys(newErrors).some(
      (key) => key !== "contacts" && newErrors[key]
    );

    const hasContactErrors = contactErrors.some((err) =>
      Object.values(err).some(Boolean)
    );

    if (hasTopLevelErrors || hasContactErrors) {
      let errorMessage = "";

      const topError = Object.values(newErrors).find(
        (val) => typeof val === "string"
      );

      if (topError) {
        errorMessage = topError;
      } else {
        // 2️⃣ contact error
        const contactError = contactErrors
          .flatMap((err) => Object.values(err))
          .find(Boolean);

        errorMessage = contactError;
      }

      showSnackbar(errorMessage || "Validation error", "error");
      return;
    }


    // Save customer
    try {
      const response = await CustomerService.saveCustomer(form);
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
      resetForm();
      setOpen(false);
      fetchCustomers();
    } catch (err) {
      console.error("🔥 Error while saving supplier:", err);
      showSnackbar("Network or server error.", "error");
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
                    label="CustomerName*"
                    error={!!errors.customerName}
                    helperText={errors.customerName}
                  />
                  <CustomTextField
                    name="customerGroup"
                    value={form.customerGroup}
                    onChange={handleFormChange}
                    label="GroupName*"
                    error={!!errors.customerGroup}
                    helperText={errors.customerGroup}
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
                    label="MSME*"
                    error={!!errors.customerMsme}
                    helperText={errors.customerMsme}
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
                    label="SelectState*"
                    error={!!errors.state}
                    helperText={errors.state}
                    options={states.map((s) => ({ value: s.name, label: s.name }))}
                  />
                  <BasicSelect
                    name="city"
                    value={form.city}
                    onChange={handleFormChange}
                    label="SelectCity*"
                    error={!!errors.city}
                    helperText={errors.city}
                    options={cities.map((c) => ({ value: c, label: c }))}
                    disabled={!form.state}
                  />
                  <CustomTextField
                    name="pinCode"
                    value={form.pinCode}
                    readOnly
                    label="PinCode*"
                    disabled={!form.state}
                    className="border p-2 rounded cursor-not-allowed"
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
                        label="ContactPerson*"
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
                      multiple
                      options={allTransports}
                      getOptionLabel={(opt) => opt.transportName || opt.name || ""}
                      value={selectedTransports}
                      onChange={(_, newVal) => {
                        setSelectedTransports(newVal);
                        setForm((prev) => ({
                          ...prev,
                          preferredTransportIds: newVal.map((t) => t.id),
                        }));
                        setErrors((prev) => ({ ...prev, preferredTransportIds: "" }));
                      }}
                      loading={transportLoading}
                      disableCloseOnSelect
                      isOptionEqualToValue={(opt, val) => opt.id === val.id}
                      renderInput={(params) => (
                        <CustomTextField
                          {...params}
                          size="small"
                          label="Select transports"
                          error={!!errors.preferredTransportIds}
                          helperText={errors.preferredTransportIds || "Multiple select"}
                          InputProps={{
                            ...params.InputProps,
                            endAdornment: (
                              <>
                                {transportLoading ? (
                                  <span className="text-xs text-gray-500">Loading...</span>
                                ) : null}
                                {params.InputProps.endAdornment}
                              </>
                            ),
                          }}
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
            <div className="p-4 border-t flex justify-end space-x-3">
              <button
                onClick={() => {
                  resetForm();
                  setOpen(false);
                }}
                className="px-4 py-2 border rounded-lg hover:bg-gray-200"
              >
                Cancel
              </button>
              <button
                onClick={handleAddCustomer}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Save Customer
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AddNewCustomer;