import CustomTextField from "./CustomTextField";
import { useSnackbar } from "../context/SnackbarContext";
import { useEffect, useState } from "react";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { getAllActiveStaffs } from "../service/StaffService";
import { addRetailEntry } from "../service/RetailService";
import { CheckCircleIcon } from "lucide-react";
import GenericAutocomplete from "./common/GenericAutocomplete";
import { mapToOption } from "../utils/optionMapper";
import { useUnsaved } from "../context/UnsavedChangesContext";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import CustomDatePicker from "./common/CustomDatePicker";
import dayjs from "dayjs";
import DeleteIcon from "@mui/icons-material/Delete";
import IconButton from "@mui/material/IconButton";
import FormSection from "./common/FormSection";
import FormFooter from "./common/FormFooter";
import AppButton from "./common/AppButton";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { CARD_GRID_SHELL_CLASS, FORM_SCROLL_AREA_CLASS } from "../theme/cardTheme";
import { FileText, Building2, Plus } from "lucide-react";

const RetailEntry = () => {
  const { showSnackbar } = useSnackbar();
  const [allStaffs, setAllStaffs] = useState([]);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [isSaving, setIsSaving] = useState(false);
  const [userTouched, setUserTouched] = useState(false);
  const { setIsDirty } = useUnsaved();
  const customerOptions = mapToOption(allCustomers, "id", "customerName");
  const staffOptions = mapToOption(allStaffs, "staffId", "staffName");
  const supplierOptions = mapToOption(allSuppliers, "id", "supplierName");

  const [formData, setFormData] = useState({
    name: "",
    date: dayjs(),
    staffId: "",
    customerId: "",
    commission: "",
  });

  const [suppliers, setSuppliers] = useState(
    Array.from({ length: 5 }, () => ({
      supplierId: null,
      totalAmount: "",
      depositAmount: "",
      balanceAmount: "",
    })),
  );

  const combinedData = {
    formData,
    suppliers,
  };
  const { isDirty: localDirty } = useUnsavedChanges(combinedData);

  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (!userTouched) {
      setIsDirty(false);
      return;
    }

    setIsDirty(localDirty());
  }, [formData, suppliers, userTouched]);

  useEffect(() => {
    const fetchAllData = async () => {
      try {
        const staffs = await getAllActiveStaffs();
        setAllStaffs(staffs || []);

        const suppliers = await SupplierService.getAllSuppliers();
        setAllSuppliers(suppliers || []);

        const customers = await CustomerService.getAllCustomers();
        setAllCustomers(customers || []);
      } catch (err) {
        console.error("Error loading data:", err);
        showSnackbar("Failed to load data", "error");
      }
    };

    fetchAllData();
  }, []);

  const addSuppliers = () => {
    setSuppliers((prev) => [
      ...prev,
      {
        supplierId: null,
        depositAmount: "",
        balanceAmount: "",
      },
    ]);
  };

  const removeSupplier = (indexToRemove) => {
    setSuppliers((prev) => {
      if (prev.length === 1) {
        return prev;
      }

      return prev.filter((_, index) => index !== indexToRemove);
    });
  };

  const filteredSuppliers = supplierOptions.filter(
    (s) => !suppliers.some((sel) => sel.supplierId === s.id),
  );

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (isSaving) return;

    const newErrors = {};

    const hasAtLeastOneSupplier = suppliers.some(
      (s) => s.supplierId != null && s.supplierId !== "",
    );
    if (!hasAtLeastOneSupplier) {
      newErrors.supplierIds = "Please select at least one supplier";
    }

    if (!formData.customerId) {
      newErrors.customerId = "Please select a Customer";
    }

    if (!formData.name) {
      newErrors.name = "Please enter a retailer name";
    }

    if (!formData.date) {
      newErrors.date = "Please select date";
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      showSnackbar("Please fill all required fields", "error");
      return;
    }
    setIsSaving(true);

    try {
      const payload = {
        name: formData.name,
        date: formData.date || null,
        staffId: formData.staffId || null,
        referredByCustomerId: formData.customerId,
        commission: formData.commission || null,
        suppliers: suppliers
          .filter((s) => s.supplierId)
          .map((s) => ({
            supplierId: s.supplierId,
            totalAmount: Number(s.totalAmount) || null,
            depositAmount: Number(s.depositAmount) || null,
            balanceAmount: Number(s.balanceAmount) || null,
          })),
      };

      const response = await addRetailEntry(payload);
      showSnackbar(response.message || "retail entry saved", "success");
      handleReset();
    } catch (error) {
      showSnackbar(error.message, "error");
      console.error(error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleReset = () => {
    setUserTouched(false);
    setIsDirty(false);
    resetSupplier();
    resetCustomer();
    setFormData({
      name: "",
      date: dayjs(),
      staffId: "",
      customerId: "",
      commission: "",
    });
    setErrors({});
  };

  const resetSupplier = () => {
    setSuppliers(
      Array.from({ length: 5 }, () => ({
        supplierId: null,
        totalAmount: "",
        depositAmount: "",
        balanceAmount: "",
      })),
    );
  };

  const resetCustomer = () => {
    setFormData((prev) => ({
      ...prev,
      customerId: "",
    }));
  };

  const handleChange = (name, value) => {
    setUserTouched(true);

    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    setErrors((prev) => ({
      ...prev,
      [name]: "",
    }));
  };

  const handleSupplierFieldChange = (index, field, value) => {
    setUserTouched(true);

    setSuppliers((prev) => {
      const updated = [...prev];
      updated[index] = {
        ...updated[index],
        [field]: value,
      };

      const total = Number(updated[index].totalAmount) || 0;

      const deposit = Number(updated[index].depositAmount) || 0;
      let balance = total - deposit;
      updated[index].balanceAmount = balance.toFixed(2);
      return updated;
    });

    if (field === "supplierId") {
      setErrors((prev) => ({
        ...prev,
        supplierIds: "",
      }));
    }
  };

  return (
    <div className="flex flex-col h-full min-h-0">
      <div className={`flex flex-col h-full min-h-0 overflow-hidden ${CARD_GRID_SHELL_CLASS}`}>
        <div className="px-4 md:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 shrink-0 bg-white dark:bg-zinc-900">
          <h2 className={PAGE_TITLE_CLASS}>Retail Entry</h2>
          <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
            Record purchase transactions and manage inventory
          </p>
        </div>

        <div className={`flex-1 overflow-y-auto p-3 md:p-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
          <FormSection title="Information" icon={FileText} variantIndex={0}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Date */}
              <CustomDatePicker
                label="Date*"
                value={formData.date}
                // maxDate={dayjs()}
                required={true}
                error={!!errors.date}
                helperText={errors.date || ""}
                onChange={(val) => handleChange("date", val)}
              />

              {/* Retailer Name */}
              <CustomTextField
                label="Retailer Name"
                value={formData.name}
                onChange={(e) => {
                  handleChange("name", e.target.value);
                }}
                required={true}
                error={!!errors.name}
                helperText={errors.name || ""}
              />

              {/* Customer Reference */}
              <GenericAutocomplete
                options={customerOptions}
                value={
                  customerOptions.find((c) => c.id === formData.customerId) ||
                  null
                }
                label="ReferredBy"
                required={true}
                error={!!errors.customerId}
                helperText={errors.customerId || ""}
                onChange={(value) => {
                  if (!value) {
                    resetCustomer();
                    return;
                  }
                  handleChange("customerId", value.id);
                }}
              />

              {/* Staff */}
              <GenericAutocomplete
                options={staffOptions}
                value={
                  staffOptions.find((s) => s.id === formData.staffId) || null
                }
                label="Staff"
                onChange={(value) => {
                  handleChange("staffId", value?.id || "");
                }}
              />

              {/* Commission */}
              <CustomTextField
                label="Commission"
                value={formData.commission}
                onChange={(e) => {
                  handleChange("commission", e.target.value);
                }}
              />
            </div>
          </FormSection>

          <FormSection title="Suppliers" icon={Building2} variantIndex={1}>

            {/* Supplier Card */}
            {suppliers.map((supplier, index) => (
              <div
                key={index}
                className="border border-gray-200 rounded-lg p-4 sm:p-5 bg-gray-50 mb-4"
              >
                {/* Card Header */}
                <div className="flex justify-between items-center mb-4">
                  <h4 className="font-medium text-gray-700">
                    Supplier {index + 1}
                  </h4>

                  {suppliers.length > 1 && (
                    <IconButton
                      color="error"
                      size="small"
                      onClick={() => removeSupplier(index)}
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  )}
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-4 gap-3 items-start">
                  {/* Supplier */}
                  <GenericAutocomplete
                    options={filteredSuppliers}
                    value={
                      supplierOptions.find(
                        (s) => s.id === suppliers[index]?.supplierId,
                      ) || null
                    }
                    label="Supplier"
                    required={index === 0}
                    error={index === 0 && !!errors.supplierIds}
                    helperText={index === 0 ? errors.supplierIds : ""}
                    onChange={(value) =>
                      handleSupplierFieldChange(
                        index,
                        "supplierId",
                        value?.id || null,
                      )
                    }
                  />
                  {/* Total Amount */}
                  <CustomTextField
                    label="Total Amount"
                    value={suppliers[index].totalAmount}
                    onChange={(e) => {
                      let val = e.target.value;
                      if (/^\d*\.?\d{0,2}$/.test(val)) {
                        handleSupplierFieldChange(index, "totalAmount", val);
                      }
                    }}
                  />

                  {/* Deposit amount */}
                  <CustomTextField
                    label="Deposit Amount"
                    value={suppliers[index].depositAmount}
                    onChange={(e) => {
                      let val = e.target.value;
                      if (/^\d*\.?\d{0,2}$/.test(val)) {
                        handleSupplierFieldChange(index, "depositAmount", val);
                      }
                    }}
                  />

                  {/* balance amount */}
                  <CustomTextField
                    label="Balance Amount"
                    value={suppliers[index].balanceAmount}
                    disabled
                  />

                  {/* {suppliers.length > 1 && (
                    <div className="flex items-end h-full">
                      <IconButton
                        color="error"
                        onClick={() => removeSupplier(index)}
                        title="Remove Supplier"
                        size="small"
                      >
                        <DeleteIcon />
                      </IconButton>
                    </div>
                  )} */}
                </div>
              </div>
            ))}
            <div className="flex justify-end mt-2">
              <AppButton
                type="primary"
                onClick={addSuppliers}
                startIcon={<Plus className="h-4 w-4" />}
              >
                <span className="sm:hidden">Add</span>
                <span className="hidden sm:inline">Add More Supplier</span>
              </AppButton>
            </div>
          </FormSection>
        </div>

        <FormFooter background="bg-white dark:bg-zinc-900 border-brand-surface-border dark:border-zinc-700">
          <AppButton type="secondary" onClick={handleReset}>
            Reset
          </AppButton>
          <AppButton type="primary" onClick={handleSubmit} loading={isSaving}>
            {isSaving ? "Saving..." : "Save"}
          </AppButton>
        </FormFooter>
      </div>
    </div>
  );
};

export default RetailEntry;
