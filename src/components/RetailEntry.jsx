import CustomTextField from "./CustomTextField";
import { useSnackbar } from "../context/SnackbarContext";
import { useEffect, useState } from "react";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { getAllActiveStaffs } from "../service/StaffService";
import { addPurchaseEntry } from "../service/PurchaseService";
import validate from "../validations/Validation";
import { CheckCircleIcon } from "lucide-react";
import GenericAutocomplete from "./common/GenericAutocomplete";
import { mapToOption } from "../utils/optionMapper";
import { useUnsaved } from "../context/UnsavedChangesContext";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";

const RetailEntry = () => {
  const { showSnackbar } = useSnackbar();

  const [allStaffs, setAllStaffs] = useState([]);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);

  const [isSaving, setIsSaving] = useState(false);
  const [activeSupplierIndex, setActiveSupplierIndex] = useState(null);
  const [userTouched, setUserTouched] = useState(false);
  const { setIsDirty } = useUnsaved();

  const customerOptions = mapToOption(allCustomers, "id", "customerName");
  const staffOptions = mapToOption(allStaffs, "staffId", "staffName");
  const supplierOptions = mapToOption(allSuppliers, "id", "supplierName");

  const [formData, setFormData] = useState({
    name: "",
    staffId: "",
    customerId: "",
  });

  const [suppliers, setSuppliers] = useState(
    Array.from({ length: 1 }, () => ({
      supplierId: null,
      deposit: null,
      balance: null,
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
        deposit: null,
        balance: null,
      },
    ]);
  };

  const filteredSuppliers = supplierOptions.filter(
    (s) => !suppliers.some((sel) => sel.supplierId === s.id),
  );

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (isSaving) return;

    const newErrors = {};

    // const dateError = validate("date", formData.date);
    // if (dateError) newErrors.date = dateError;

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

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      showSnackbar("Please fill all required fields", "error");
      return;
    }
    setIsSaving(true);

    try {
      const payload = {
        name: formData.name,
        staffId: formData.staffId || null,
        customerId: formData.customerId,
        suppliers: suppliers
          .filter((s) => s.supplierId)
          .map((s) => ({
            supplierId: s.supplierId,
            deposit: s.deposit || null,
            balance: s.balance || null,
          })),
      };

      const response = await addPurchaseEntry(payload);
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
      staffId: "",
      customerId: "",
    });
    setErrors({});
  };

  const resetSupplier = () => {
    setSuppliers(
      Array.from({ length: 5 }, () => ({
        supplierId: null,
        deposit: null,
        balance: null,
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
    <div className="flex flex-col h-full overflow-y-auto">
      <div className="bg-gray-50 w-full h-[91vh] flex flex-col rounded-2xl shadow-xl border border-gray-200">
        {/* Header */}
        <div className="px-6 py-3 border-b border-gray-200 shrink-0 bg-gray-50">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-semibold text-gray-900 leading-tight">
                Retail Entry
              </h2>
              <p className="text-sm text-gray-500 mt-1">
                Record purchase transactions and manage inventory
              </p>
            </div>
          </div>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto p-3 md:px-8 md:py-6 space-y-6">
          {/* Party Information */}
          <div className="border border-gray-200 p-6 rounded-xl bg-white">
            <div className="flex items-start mb-5">
              <div className="w-1 h-10 bg-gradient-to-b from-green-500 to-green-700 rounded-full mr-3"></div>
              <div>
                <h3 className="text-lg font-semibold text-gray-800">
                  Information
                </h3>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* name */}
              <CustomTextField
                label="Name"
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
                label="Customer Reference"
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
                required={true}
                error={!!errors.staff}
                helperText={errors.staff || ""}
                onChange={(value) => {
                  handleChange("staffId", value?.id || "");
                }}
              />
            </div>
          </div>

          {/* Suppliers Section */}
          <div className="border border-gray-200 p-6 rounded-xl bg-white shadow-sm">
            {/* Section Header */}
            <div className="flex items-start justify-between mb-5">
              <div className="flex items-start">
                <div className="w-1 h-10 bg-gradient-to-b from-purple-500 to-purple-700 rounded-full mr-3"></div>

                <div>
                  <h3 className="text-lg font-semibold text-gray-800">
                    Suppliers
                  </h3>
                </div>
              </div>

              <button
                type="button"
                onClick={addSuppliers}
                className="px-3 sm:px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold rounded-lg shadow-sm"
              >
                <span className="sm:hidden">+ Add</span>
                <span className="hidden sm:inline">+ Add More Supplier</span>
              </button>
            </div>

            {/* Supplier Card */}
            {suppliers.map((supplier, index) => (
              <div
                key={index}
                className="border border-gray-200 rounded-lg p-4 sm:p-5 bg-gray-50 mb-4"
              >
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 items-start">
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

                  {/* Deposit amount */}
                  <CustomTextField
                    label="Deposit Amount"
                    value={suppliers[index].deposit}
                    onChange={(e) => {
                      handleSupplierFieldChange(
                        index,
                        "deposit",
                        e.target.value,
                      );
                    }}
                  />

                  {/* balance amount */}
                  <CustomTextField
                    label="balance Amount"
                    value={suppliers[index].balance}
                    onChange={(e) => {
                      handleSupplierFieldChange(
                        index,
                        "balance",
                        e.target.value,
                      );
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Footer */}
        <div className="px-4 sm:px-8 py-3 border-t border-gray-200 bg-white shrink-0 shadow-sm">
          <div className="flex items-center justify-end gap-3">
            <button
              onClick={handleReset}
              type="button"
              className="px-4 py-2 text-sm font-medium text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-100"
            >
              Reset
            </button>

            <button
              onClick={handleSubmit}
              type="button"
              className="px-5 py-2 text-sm font-semibold text-white rounded-lg bg-blue-600 hover:bg-blue-700 shadow-md flex items-center justify-center gap-2"
            >
              {isSaving ? "Saving..." : "Save"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RetailEntry;
