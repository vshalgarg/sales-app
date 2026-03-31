export const formatDetails = (data, requiredKeys = []) => {

  const filteredEntries = Object.entries(data)
    .filter(([key, value]) => {
      if (requiredKeys.includes(key)) return true;
      return value !== undefined && value !== null && value !== "";
    });

  const html = filteredEntries
    .map(([key, value]) => `<b>${key}:</b> ${value || ""}<br/>`)
    .join("");

  const text = filteredEntries
    .map(([key, value]) => `${key}: ${value || ""}`)
    .join("\n");

  return { html, text };
};

export const cleanText = (text) => {
  if (Array.isArray(text)) {
    return text.map(t => (typeof t === "string" ? t.replace(/\s+/g, " ").trim() : t));
  }

  if (typeof text === "string") {
    return text.replace(/\s+/g, " ").trim();
  }

  return text;
};

export const convertHtmlToWhatsApp = (html) => {
  if (!html) return "";

  return html
    .replace(/<b>(.*?)<\/b>/gi, "*$1*")
    .replace(/<strong>(.*?)<\/strong>/gi, "*$1*")
    .replace(/<i>(.*?)<\/i>/gi, "_$1_")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/p>/gi, "\n")
    .replace(/<li>(.*?)<\/li>/gi, "• $1\n")
    .replace(/<[^>]+>/g, "")
    .trim();
};

export const getSupplierFormattedText = (supplier) => {

 const mobileNumbers = formatContacts(supplier?.contacts);
  const transports = supplier?.preferredTransports
    ?.map(t => t.name)
    ?.filter(Boolean)
    ?.join(", ");

  const fullAddress = cleanText([
    supplier?.addressLine1 || supplier?.address,
    supplier?.addressLine2,
    supplier?.city,
    supplier?.state,
    supplier?.pinCode
  ]
    .filter(Boolean)
    .join(", ")
  );

  return formatDetails({
    "Firm Name": supplier?.supplierName,
    "Address": fullAddress,
    "Contacts": mobileNumbers,
    "Emails": supplier?.email,
    "Transports": transports,
    "GST No": supplier?.supplierGstNo || supplier?.gstNo
  },
  ["Firm Name", "Address", "Contacts", "GST No"]
);
};


export const getCustomerFormattedText = (customer) => {

  const mobileNumbers = formatContacts(customer?.contacts)
  const fullAddress = cleanText([
    customer?.addressLine1 || customer?.address,
    customer?.addressLine2,
    customer?.city,
    customer?.state,
    customer?.pinCode
  ]
    .filter(Boolean)
    .join(", ")
  );

  const transports = customer?.preferredTransports
    ?.map(t => t.name)
    ?.filter(Boolean)
    ?.join(", ");

  return formatDetails({
    "Firm Name": customer?.customerName || "-",
    "Address": fullAddress || "-",
    "Contacts": mobileNumbers,
    "Emails": customer?.email,
    "Transports": transports,
    "GST No": customer?.customerGstNo
  }
,
  ["Firm Name", "Address", "Contacts", "GST No"]
);
};

export const getTransportFormattedText = (transport) => {

  const mobileNumbers = formatContacts(transport?.contacts, "contactNumber");
  const fullAddress = cleanText([
    transport?.addressLine1,
    transport?.addressLine2,
    transport?.city,
    transport?.state,
    transport?.pinCode
  ]
    .filter(Boolean)
    .join(", ")
  );

  return formatDetails({
    "Firm Name": transport?.name || "-",
    "Address": fullAddress || "-",
    "Contacts": mobileNumbers,
    "GST No": transport?.gstNo
  }
,
["Firm Name", "Address", "Contacts", "GST No"]
);
};

export const formatContacts = (contacts, numberKey = "mobileNumber") => {
  return contacts
    ?.map(contact => {
      const name = contact?.contactPerson?.trim() || "";
      const number = contact?.[numberKey]?.trim() || "";

      if (!name && !number) return null;

      if (name && number) return `${name} - ${number}`;
      if (number) return number;
      if (name) return name;

      return null;
    })
    ?.filter(Boolean)
    ?.join(", ");
};