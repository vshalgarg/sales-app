import { useState, useEffect, useRef } from "react";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import validate from "../validations/Validation";

export const useBillForm = () => {

  // 🔹 States
  const [supplierTransports, setSupplierTransports] = useState([]);
  const [customerTransports, setCustomerTransports] = useState([]);
  const [suggestions, setSuggestions] = useState([]);
  const [custSuggestions, setCustSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isCustDropdownOpen, setIsCustDropdownOpen] = useState(false);
  const [isTransportDropdownOpen, setIsTransportDropdownOpen] = useState(false);

  const [filterObject, setFilterObject] = useState({
    supplierId: null,
    customerId: null,
    fromDate: "",
    toDate: "",
  });

  // useEffect(() => {
  //   const handleClickOutside = (e) => {
  //     if (
  //       searchSupplierRef.current &&
  //       !searchSupplierRef.current.contains(e.target)
  //     ) {
  //       setIsDropdownOpen(false);
  //     }
  //   };
  //   document.addEventListener("mousedown", handleClickOutside);
  //   return () => {
  //     document.removeEventListener("mousedown", handleClickOutside);
  //   };
  // }, []);

  // useEffect(() => {
  //   const handleClickOutside = (e) => {
  //     if (
  //       searchCustomerRef.current &&
  //       !searchCustomerRef.current.contains(e.target)
  //     ) {
  //       setIsCustDropdownOpen(false);
  //     }
  //   };
  //   document.addEventListener("mousedown", handleClickOutside);
  //   return () => {
  //     document.removeEventListener("mousedown", handleClickOutside);
  //   };
  // }, []);

  // 🔹 Form data
  const initialFormData = {
    customerId: "",
    supplierId: "",
    date: "",
    receivedDate: "",
    order: "",
    supplierName: "",
    supplierGroup: "",
    supplierMsme: "",
    supplierCity: "",
    supplierGstNo: "",
    customerName: "",
    customerGroup: "",
    customerMsme: "",
    customerGstNo: "",
    pieces: "",
    grossAmount: "",
    discountPercent: "",
    discountAmount: "",
    gstPercent: "",
    gstAmount: "",
    billAmount: "",
    addOnAmount: "",
    ecrAmount: "",
    taxableValue: "",
    transport: "",
    lrNumber: "",
    remarks: "",
    referenceBy: "",
  };

  // Load formData and errors from localStorage
  // Load saved formData and errors
  const [formData, setFormData] = useState(() => {
    try {
      return (
        JSON.parse(localStorage.getItem("billFormData")) || initialFormData
      );
    } catch {
      return initialFormData;
    }
  });

  const [errors, setErrors] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem("billFormErrors")) || {};
    } catch {
      return {};
    }
  });

  // ✅ Clear transport if error exists, after errors are loaded
  useEffect(() => {
    if (errors.transport) {
      setFormData((prev) => ({
        ...prev,
        transport: "",
      }));
    }
  }, [errors.transport]); // run whenever transport error is present

  // 🔹 Run whenever errors are restored
  useEffect(() => {
    if (!errors || Object.keys(errors).length === 0) return;

    setFormData((prev) => {
      const updated = { ...prev };
      let changed = false;

      Object.keys(errors).forEach((field) => {
        if (errors[field] && prev[field]) {
          updated[field] = "";
          changed = true;
        }
      });

      return changed ? updated : prev;
    });
  }, [errors]); // ✅ runs after errors are loaded
  // run only once on mount

  // 🔹 Save formData to localStorage (skip empty fields)
  // --- Save logic with debug logs ---
  // useEffect(() => {
  //   const cleaned = Object.fromEntries(
  //     Object.entries(formData).filter(([_, v]) => v !== "")
  //   );

  //   localStorage.setItem("billFormData", JSON.stringify(cleaned));
  // }, [formData]);

  // useEffect(() => {
  //   localStorage.setItem("billFormErrors", JSON.stringify(errors));
  // }, [errors]);

  // 🔹 Handle clicks outside dropdowns
  // useEffect(() => {
  //   const handleClickOutside = (e) => {
  //     if (searchRef.current && !searchRef.current.contains(e.target)) {
  //       setIsDropdownOpen(false);
  //     }
  //     if (custSearchRef.current && !custSearchRef.current.contains(e.target)) {
  //       setIsCustDropdownOpen(false);
  //     }
  //     if (
  //       transportSearchRef.current &&
  //       !transportSearchRef.current.contains(e.target)
  //     ) {
  //       setIsTransportDropdownOpen(false);
  //     }
  //   };

  //   document.addEventListener("mousedown", handleClickOutside);
  //   return () => document.removeEventListener("mousedown", handleClickOutside);
  // }, []);

  // 🔹 Handlers
  const handleChange = (e) => {
    const { name, value } = e.target;

    let finalValue = value;

    // alphabets + numbers + limited special chars  
    if (name === "order" || name === "lrNumber") {
      finalValue = value.replace(/[^a-zA-Z0-9\s\-_/\.@#&()]/g, "");
    }

    setFormData(prev => ({
      ...prev,
      [name]: finalValue,
    }));

    if (
      name === "order" ||
      name === "lrNumber"
    ) {
      return;
    }
    setErrors(prev => ({
      ...prev,
      [name]: validate(name, finalValue) || "",
    }));
  };


  const handleReset = () => {
    setFormData(initialFormData);
    setErrors({});
    setSupplierTransports([]);
    setCustomerTransports([]);
    setSuggestions([]);
    setCustSuggestions([]);
    // localStorage.removeItem("billFormData");
    // localStorage.removeItem("billFormErrors");
  };

  // 🔹 Customer Input
  // Customer Input
  const handleCustomerInput = async (e) => {
    const value = e.target.value;
    setFormData((prev) => ({
      ...prev,
      customerName: value,
      ...(value === "" && {
        customerId: "",
        customerGroup: "",
        customerMsme: "",
        customerGstNo: "",
      }),
    }));

    setErrors((prev) => ({
      ...prev,
      customerName: validate("customerName", value),
      customerGroup: validate("customerGroup", value),
      customerMsme: validate("customerMsme", value),
      customerGstNo: validate("customerGstNo", value),
    }));

    // ✅ NEW LOGIC HERE
    if (value === "") {
      // Customer cleared — check if supplier is still present
      setCustSuggestions([]);
      setIsCustDropdownOpen(false);

      if (formData.supplierName) {
        // supplier still exists, so restore supplier’s transport list
        setCustomerTransports([]); // clear customer transports
        // supplierTransports already holds supplier’s preferred transports
        // So availableTransports will automatically show supplier’s list
      } else {
        // no supplier or customer — clear all transports
        setSupplierTransports([]);
        setCustomerTransports([]);
      }

      return;
    }

    // 🔹 Normal customer search logic continues
    if (value.length > 1) {
      try {
        const result = await CustomerService.searchCustomers(value);
        setCustSuggestions(result || []);
        setIsCustDropdownOpen(result?.length > 0);
      } catch {
        setCustSuggestions([]);
        setIsCustDropdownOpen(false);
      }
    } else {
      setCustSuggestions([]);
      setIsCustDropdownOpen(false);
    }
  };

  const handleCustomerSuggestionClick = (c) => {
    setFormData((prev) => ({
      ...prev,
      customerId: c.id || "",
      customerName: c.customerName || "",
      customerGroup: c.customerGroup || "",
      customerMsme: c.customerMsme || "",
      customerGstNo: c.customerGstNo || "",
    }));
    setErrors((prev) => ({
      ...prev,
      customerName: "",
      customerGroup: "",
      customerMsme: "",
      customerGstNo: "",
    }));
    setCustomerTransports(
      (c.preferredTransport || []).map((t) => ({ value: t, label: t }))
    );
    setCustSuggestions([]);
    setIsCustDropdownOpen(false);
  };

  // 🔹 Supplier Input
  const handleSupplierInput = async (e) => {
    const value = e.target.value;

    setFormData((prev) => ({
      ...prev,
      supplierName: value,
      ...(value === "" && {
        supplierGroup: "",
        supplierMsme: "",
        supplierGstNo: "",
        transport: "",
      }),
    }));

    setErrors((prev) => ({
      ...prev,
      supplierName: validate("supplierName", value),
      supplierGroup: validate("supplierGroup", value),
      supplierMsme: validate("supplierMsme", value),
      supplierGstNo: validate("supplierGstNo", value),
    }));

    if (value.length > 1) {
      try {
        const result = await SupplierService.searchSuppliers(value);
        setSuggestions(result || []);
        setIsDropdownOpen(result?.length > 0);
      } catch {
        setSuggestions([]);
        setIsDropdownOpen(false);
      }
    } else {
      setSuggestions([]);
      setIsDropdownOpen(false);
    }
  };

  const handleSupplierSuggestionClick = (s) => {
    setFormData((prev) => ({
      ...prev,
      supplierId: s.id || "",
      supplierName: s.supplierName,
      supplierGroup: s.supplierGroup || "",
      supplierMsme: s.supplierMsme || "",
      supplierGstNo: s.supplierGstNo || "",
      supplierCity: s.city || "",
    }));

    setErrors((prev) => ({
      ...prev,
      supplierName: "",
      supplierGroup: "",
      supplierMsme: "",
      supplierCity: "",
      supplierGstNo: "",
    }));

    setSupplierTransports(
      (s.preferredTransport || []).map((t) => ({ value: t, label: t }))
    );
    setSuggestions([]);
    setIsDropdownOpen(false);
  };

  const getActiveTransports = () => {
    if (customerTransports.length > 0) return customerTransports;
    if (supplierTransports.length > 0) return supplierTransports;
    return [];
  };

  useEffect(() => {
    const gross = parseFloat(formData.grossAmount) || 0;
    const discPercent = parseFloat(formData.discountPercent) || 0;
    const addOn = parseFloat(formData.addOnAmount) || 0;
    const ecr = parseFloat(formData.ecrAmount) || 0;
    const gstPercent = parseFloat(formData.gstPercent) || 0;

    const discountAmount =
      gross && discPercent ? (gross * discPercent) / 100 : "";

    const taxableValue =
      gross || discPercent || addOn || ecr
        ? gross - (gross * discPercent) / 100 + addOn + ecr
        : "";

    const gstAmount =
      taxableValue && gstPercent
        ? (parseFloat(taxableValue) * gstPercent) / 100
        : "";

    const billAmount =
      taxableValue || gstAmount
        ? (parseFloat(taxableValue) || 0) + (parseFloat(gstAmount) || 0)
        : "";

    setFormData((prev) => ({
      ...prev,
      discountAmount: discountAmount === "" ? "" : discountAmount.toFixed(2),
      taxableValue:
        taxableValue === "" ? "" : parseFloat(taxableValue).toFixed(2),
      gstAmount: gstAmount === "" ? "" : gstAmount.toFixed(2),
      billAmount: billAmount === "" ? "" : billAmount.toFixed(2),
    }));
  }, [
    formData.grossAmount,
    formData.discountPercent,
    formData.addOnAmount,
    formData.ecrAmount,
    formData.gstPercent,
  ]);

  return {
    filterObject,
    setFilterObject,
    formData,
    setFormData,
    errors,
    setErrors,
    handleChange,
    handleReset,
    setSupplierTransports,
    supplierTransports,
    setCustomerTransports,
    customerTransports,
    getActiveTransports,
    suggestions,
    custSuggestions,
    isDropdownOpen,
    isCustDropdownOpen,
    isTransportDropdownOpen,
    setIsDropdownOpen,
    setIsCustDropdownOpen,
    setIsTransportDropdownOpen,
    handleSupplierInput,
    handleSupplierSuggestionClick,
    handleCustomerInput,
    handleCustomerSuggestionClick,
  };
};
