const validate = (field, value) => {
  let error = "";

  switch (field) {
    case "username":
      if (!value) return "Username is required";
      break;
    case "password":
      if (!value) return "Password is required";
      break;
    case "state":
      if (!value) return "State is required";
      break;
    case "city":
      if (!value) return "City is required";
      break;
    case "fromDate":
      if (!value.trim()) error = "From date is required";
      break;
    case "toDate":
      if (!value.trim()) error = "To Date is required";
      break;
    case "supplier":
      if (!value.trim()) error = "Supplier is required";
      break;
    case "customer":
      if (!value.trim()) error = "Customer is required";
      break;
    case "supplierId":
      if (!value || value === "None" || value === "")
        error = "Supplier is required";
      break;
    case "customerId":
      if (!value || value === "None" || value === "")
        error = "Customer is required";
      break;
    case "supplierCurrentBalance":
      if (!value.trim()) error = "Current Balance is required";
      break;
    case "customerCurrentBalance":
      if (!value.trim()) error = "Current Balance is required";
      break;
    case "chequeNumber":
      if (!value.trim()) error = "Cheque Number is required";
      break;
    case "chequeDate":
      if (!value.trim()) error = "Current Date is required";
      break;
    case "receivedAmount":
      if (value && !/^\d+(\.\d{1,2})?$/.test(value))
        error = "Enter a valid amount";
      break;

    // case "slipNumber":
    //   if (!value.trim()) error = "Slip Number is required";
    //   break;
    case "supplierName":
      if (!value.trim()) error = "Supplier Name is required.";
      break;
    case "customerName":
      if (!value.trim()) error = "Customer Name is required.";
      break;

    case "customerGstNo":
      if (!value || value.trim() === "") {
        error = "";
        break;
      }
      const gstRegx =
        /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
      if (!gstRegx.test(value)) {
        error = "Invalid GST Number format.";
      }
      break;

    case "supplierGstNo":
      if (!value || value.trim() === "") {
        error = "";
        break;
      }
      const gstRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;

      if (!gstRegex.test(value)) {
        error = "Invalid GST Number format.";
      }
      break;

    case "commissionRate":
      if (value !== undefined && value !== null && value !== "") {
        const rate = parseFloat(value);

        if (isNaN(rate)) {
          error = "Commission rate must be a valid number.";
        } else if (rate < 0 || rate > 100) {
          error = "Commission rate must be between 0 and 100.";
        }
      }
      break;

    case "pinCode":
      if (!value || value.trim() === "") {
        return "Pin Code is required";
      }
      if (!/^\d{6}$/.test(value)) {
        return "Pin Code must be exactly 6 digits";
      }
      return "";


    case "addressLine1":
      if (!value.trim()) error = "AddressLine1 is required.";
      break;

    case "contactPerson":
      if (!value.trim()) error = "Contact Person is required.";
      break;

    case "mobileNumber":
      if (!value) return "Contact number is required";
      if (!/^\d+$/.test(value)) return "Only digits allowed";
      // if (value.length < 6) return "Must be at least 6 digits";
      // if (value.length > 13) return "Must be at most 13 digits";
      break;


    // case "phone":
    //   if (!value) return "Phone number is required";
    //   if (!/^\d+$/.test(value)) return "Only digits allowed";
    //   if (value.length < 10) return "Must be at least 10 digits";
    //   break;

    // case "preferredTransport":
    //   if (!value || value.length === 0) {
    //     error = "Select transport is required.";
    //   }
    //   break;

    case "state":
      if (!value || value.length === 0) {
        error = "State is required";
      }
      break;

    case "city":
      if (!value || value.length === 0) {
        error = "City is required";
      }
      break;

    // case "staffName":
    //   if (!value || value.length === 0) {
    //     error = "Staff Name is required";
    //   }
    //   break;

    case "joiningDate":
      if (!value || value.length === 0) {
        error = "Joining Date is required";
      }
      break;

    case "billNumber":
      if (!value.trim() || !value || value.length === 0) {
        error = "Bill Number is required";
      }
      break;
    case "date":
      if (!value.trim() || !value || value.length === 0) {
        error = "Date is required";
      }
      break;
    case "receivedDate":
      if (!value.trim() || !value || value.length === 0) {
        error = "Received Date is required";
      }
      break;
    case "order":
      if (!value?.trim()) return "Order is required";
      return "";

    case "grossAmount":
      if (!value || value.length === 0) {
        error = "Gross Amoount is required";
      }
      break;
    case "pieces":
      if (!value || value.length === 0) {
        error = "Pieces is required";
      }
      break;

    case "taxableValue":
      if (!value || value.length === 0) {
        error = "Taxable value is required";
      }
      break;
    case "billAmount":
      if (!value || value.length === 0) {
        error = "Bill Amount is required";
      }
      break;
    case "lrNumber":
      if (!value.trim() || !value || value.length === 0) {
        error = "LR Number is required";
      }
      break;
    // case "transport":
    //   console.log(value)
    //   if (!value.trim() || !value || value.length === 0) {
    //     error = "Transport is required";
    //   }
    //   break;
    case "paymentType":
      if (!value.trim() || !value || value.length === 0) {
        error = "Payment Type is required";
      }
      break;
    case "staff":
      if (!value.trim() || !value || value.length === 0) {
        error = "Staff is required";
      }
      break;
    case "purchaseAmount":
      if (value && !/^\d+(\.\d{1,2})?$/.test(value))
        return "Enter valid amount";
      break;

    case "referenceNumber":
      if (!value || !value.trim()) {
        error = "Reference Number is required";
        break;
      }
      break;

    case "referenceDate":
      if (!value || !value.trim()) {
        error = "Reference Date is required";
      }
      break;

    case "email":
      if (!value) return ""; //optional
      if (!/^\S+@\S+\.\S+$/.test(value)) return "Invalid email";
      return "";


    default:
      break;
  }

  return error;
};

export default validate;
