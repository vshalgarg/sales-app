import { useState, useEffect } from "react";

export const useBillForm = () => {

  const initialFormData = {
    customerId: "",
    supplierId: "",
    date: "",
    receivedDate: "",
    order: "",
    billNumber: "",
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

  const [formData, setFormData] = useState(initialFormData);
  const [errors, setErrors] = useState({});

  const [filterObject, setFilterObject] = useState({
    supplierId: null,
    customerId: null,
    fromDate: "",
    toDate: "",
  });


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
    formData,
    setFormData,
    errors,
    setErrors,
    filterObject,
    setFilterObject,
  };
};
