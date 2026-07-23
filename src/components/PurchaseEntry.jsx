import CustomTextField from "./CustomTextField";
import dayjs from "dayjs";
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
import CustomDatePicker from "./common/CustomDatePicker";
import UploadDialog from "./common/UploadDialog";
import FormSection from "./common/FormSection";
import FormFooter from "./common/FormFooter";
import AppButton from "./common/AppButton";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { CARD_GRID_SHELL_CLASS, FORM_SCROLL_AREA_CLASS } from "../theme/cardTheme";
import { FileText, Building2, Plus } from "lucide-react";


const PurchaseEntry = () => {
  const { showSnackbar } = useSnackbar();

  const [allStaffs, setAllStaffs] = useState([]);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);

  const [isSaving, setIsSaving] = useState(false);
  const [openUploader, setOpenUploader] = useState(false);
  const [activeSupplierIndex, setActiveSupplierIndex] = useState(null);
  const [tempImages, setTempImages] = useState([]);
  const [userTouched, setUserTouched] = useState(false);
  const { setIsDirty } = useUnsaved();

  const customerOptions = mapToOption(allCustomers, "id", "customerName");
  const staffOptions = mapToOption(allStaffs, "staffId", "staffName");
  const supplierOptions = mapToOption(allSuppliers, "id", "supplierName");


  const [formData, setFormData] = useState({
    date: dayjs().format("YYYY-MM-DD"),
    staffId: "",
    customerId: "",
  });

  const [suppliers, setSuppliers] = useState(
    Array.from({ length: 5 }, () => ({
      supplierId: null,
      remarks: "",
      images: []
    }))
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
    setSuppliers(prev => [
      ...prev,
      {
        supplierId: null,
        remarks: "",
        images: []
      }
    ]);
  };

  const handleImageSave = () => {
    if (activeSupplierIndex === null) return;

    const updated = [...suppliers];
    updated[activeSupplierIndex].images = tempImages;

    setSuppliers(updated);
    setOpenUploader(false);
    setActiveSupplierIndex(null);
    setTempImages([]);

    showSnackbar("Images saved", "success");
  };

  const handleImageCancel = () => {
    setOpenUploader(false);
    setActiveSupplierIndex(null);
    setTempImages([]);
  };

  const filteredSuppliers = supplierOptions.filter(
    s => !suppliers.some(sel => sel.supplierId === s.id)
  );

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (isSaving) return;

    const newErrors = {};

    const dateError = validate("date", formData.date);
    if (dateError) newErrors.date = dateError;

    const hasAtLeastOneSupplier = suppliers.some(s => s.supplierId != null && s.supplierId !== "");
    if (!hasAtLeastOneSupplier) {
      newErrors.supplierIds = "Please select at least one supplier";
    }

    if (!formData.customerId) {
      newErrors.customerId = "Please select a Customer";
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      showSnackbar("Please fill all required fields", "error");
      return;
    }
    setIsSaving(true);

    try {

      const payload = {
        date: formData.date,
        staffId: formData.staffId || null,
        customerId: formData.customerId,
        suppliers: suppliers
          .filter(s => s.supplierId)
          .map(s => ({
            supplierId: s.supplierId,
            remarks: s.remarks || null
          }))
      };
      const formDataObj = new FormData();

      formDataObj.append(
        "payload",
        new Blob([JSON.stringify(payload)], {
          type: "application/json",
        })
      );

      suppliers.forEach((supplier) => {
        if (!supplier.supplierId) return;

        supplier.images.forEach((file) => {
          formDataObj.append(
            `supplier_${supplier.supplierId}_images`,
            file
          );
        });
      });

      const response = await addPurchaseEntry(formDataObj);
      showSnackbar(response.message || "Purchase entry saved", "success");
      handleReset();
    } catch (error) {
      showSnackbar(error.message, "error");
      console.error(error);
    }
    finally {
      setIsSaving(false);
    }
  };

  const handleReset = () => {
    setUserTouched(false);
    setIsDirty(false);
    resetSupplier();
    resetCustomer();
    setFormData({
      date: dayjs().format("YYYY-MM-DD"),
      staffId: "",
      customerId: "",
    });
    setErrors({});
  };

  const resetSupplier = () => {
    setSuppliers(
      Array.from({ length: 5 }, () => ({
        supplierId: null,
        remarks: "",
        images: []
      }))
    );
  };

  const resetCustomer = () => {
    setFormData(prev => ({
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
    <div className="flex flex-col h-full min-h-0">
      <div className={`flex flex-col h-full min-h-0 overflow-hidden ${CARD_GRID_SHELL_CLASS}`}>
        <div className="px-4 md:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 shrink-0 bg-white dark:bg-zinc-900">
          <h2 className={PAGE_TITLE_CLASS}>Purchase Entry</h2>
          <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
            Record purchase transactions and manage inventory
          </p>
        </div>

        <div className={`flex-1 overflow-y-auto p-3 md:p-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
          <FormSection title="Information" icon={FileText} variantIndex={0}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

              {/* Customer */}
              <GenericAutocomplete
                options={customerOptions}
                value={customerOptions.find(c => c.id === formData.customerId) || null}
                label="Customer"
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
                value={staffOptions.find(s => s.id === formData.staffId) || null}
                label="Staff"
                error={!!errors.staff}
                helperText={errors.staff || ""}
                onChange={(value) => {
                  handleChange("staffId", value?.id || "");
                }}
              />

              {/* Transaction Date */}
              <CustomDatePicker
                label="Transaction Date *"
                value={formData.date}
                error={errors.date}
                helperText={errors.date}
                onChange={(val) => {
                  handleChange("date", val);

                  setErrors((prev) => ({
                    ...prev,
                    date: validate("date", val) || "",
                  }));
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

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 items-start">

                  {/* Supplier */}
                  <GenericAutocomplete
                    options={filteredSuppliers}
                    value={
                      supplierOptions.find(
                        s => s.id === suppliers[index]?.supplierId
                      ) || null
                    }
                    label="Supplier"
                    required={index === 0}
                    error={index === 0 && !!errors.supplierIds}
                    helperText={index === 0 ? errors.supplierIds : ""}
                    onChange={(value) =>
                      handleSupplierFieldChange(index, "supplierId", value?.id || null)
                    }
                  />

                  {/* Remarks */}
                  <CustomTextField
                    label="Remarks"
                    value={suppliers[index].remarks}
                    onChange={(e) => {
                      handleSupplierFieldChange(index, "remarks", e.target.value);
                    }}
                  />

                  {/* Upload Button */}
                  <button
                    type="button"
                    onClick={() => {
                      setActiveSupplierIndex(index);
                      setTempImages(suppliers[index]?.images || []);
                      setOpenUploader(true);
                    }}
                    className={`
    h-[40px] px-4 text-sm font-medium rounded-lg shadow-sm 
    flex items-center gap-2 justify-center transition-all duration-200
    ${supplier.images.length > 0
                        ? 'bg-green-600 hover:bg-green-700 text-white'
                        : 'bg-gray-200 text-gray-600 border-gray-300 hover:bg-gray-200'
                      }
  `}
                  >
                    <svg
                      className="w-4 h-4"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"
                      />
                    </svg>

                    <span className="hidden sm:inline">
                      {supplier.images.length > 0 ? 'Files Uploaded' : 'Upload files'}
                    </span>
                    <span className="sm:hidden">
                      {supplier.images.length > 0 ? 'Uploaded' : 'Upload'}
                    </span>

                    {supplier.images.length > 0 && (
                      <>
                        <span className="w-px h-5 bg-white/20 mx-1 hidden sm:block"></span>

                        <span className="bg-white text-green-600 text-xs font-bold px-2 py-0.5 rounded-full shadow-sm">
                          {supplier.images.length}
                        </span>

                        <CheckCircleIcon size={18} className="text-white/90" />
                      </>
                    )}
                  </button>

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

        <UploadDialog
          open={openUploader}
          onClose={handleImageCancel}
          files={tempImages}
          setFiles={(files) => {
            setUserTouched(true);
            setTempImages(files);
          }}
          onSave={handleImageSave}
          title="Upload Order Form"
          maxFiles={3}
          onError={(msg) => showSnackbar(msg, "error")}
        />

      </div>
    </div>
  );

};

export default PurchaseEntry;