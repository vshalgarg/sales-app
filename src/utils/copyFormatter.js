export const formatDetails = (data) => {
  const filteredEntries = Object.entries(data).filter(
    ([_, value]) => value !== undefined && value !== null && value !== "",
  );

  const html = filteredEntries
    .map(([key, value]) => `<b>${key}:</b> ${value}<br/>`)
    .join("");

  const text = filteredEntries
    .map(([key, value]) => `${key}: ${value}`)
    .join("\n");

  return { html, text };
};

export const cleanText = (text) => {
  if (Array.isArray(text)) {
    return text.map((t) =>
      typeof t === "string" ? t.replace(/\s+/g, " ").trim() : t,
    );
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

const toFieldList = (data) =>
  Object.entries(data)
    .filter(([_, value]) => value !== undefined && value !== null && value !== "")
    .map(([label, value]) => ({ label, value }));

const MAX_BANK_DETAILS = 4;

const buildBankFields = ({
  bankName,
  accountName,
  accountNumber,
  ifscCode,
  ifsc,
  branchName,
  branch,
}) =>
  [
    { label: "Account Holder Name", value: accountName },
    { label: "Bank Name", value: bankName },
    { label: "A/c No", value: accountNumber },
    { label: "IFSC", value: ifscCode || ifsc },
    { label: "Branch", value: branchName || branch },
  ].filter((field) => field.value);

const resolveBankAccounts = (entity) => {
  const accounts = entity?.bankDetails || entity?.bankAccounts;
  let list = [];

  if (Array.isArray(accounts) && accounts.length > 0) {
    list = accounts;
  } else {
    const legacyFields = buildBankFields(entity || {});
    if (legacyFields.length) list = [entity];
  }

  return list
    .slice(0, MAX_BANK_DETAILS)
    .filter((account) => buildBankFields(account || {}).length > 0);
};

const buildBankCopyData = (entity) => {
  const resolved = resolveBankAccounts(entity);
  if (!resolved.length) return null;

  const accounts = resolved.map((account, index) => ({
    label:
      resolved.length === 1
        ? "Bank Account 1"
        : `Bank Account ${index + 1}`,
    fields: buildBankFields(account),
  }));

  const fields = accounts.flatMap((account) => {
    if (accounts.length === 1) return account.fields;

    return [
      { label: account.label, value: account.label, isSection: true },
      ...account.fields,
    ];
  });

  return { accounts, fields };
};

export const buildStructuredCopyText = (
  mandatory = [],
  includeBank = false,
  bank = null,
) => {
  let html = mandatory
    .map(({ label, value }) => `<b>${label}:</b> ${value}<br/>`)
    .join("");

  if (includeBank && bank?.accounts?.length) {
    html += `<b>Bank Details:</b><br/>`;
    bank.accounts.forEach((account) => {
      if (bank.accounts.length > 1) {
        html += `<b>${account.label}:</b><br/>`;
      }
      html += account.fields
        .map(({ label, value }) => `${label}: ${value}<br/>`)
        .join("");
      if (bank.accounts.length > 1) {
        html += `<br/>`;
      }
    });
  } else if (includeBank && bank?.fields?.length) {
    html += `<b>Bank Details:</b><br/>`;
    html += bank.fields
      .filter((field) => !field.isSection)
      .map(({ label, value }) => `${label}: ${value}<br/>`)
      .join("");
  }

  return {
    html,
    text: convertHtmlToWhatsApp(html),
  };
};

export const getSupplierFormattedText = (supplier) => {
  const mobileNumbers = formatContacts(supplier?.contacts);
  const transports = supplier?.preferredTransports
    ?.map((t) => t.name)
    ?.filter(Boolean)
    ?.join(", ");

  const fullAddress = cleanText(
    [
      supplier?.addressLine1 || supplier?.address,
      supplier?.addressLine2,
      supplier?.city,
      supplier?.state,
      supplier?.pinCode,
    ]
      .filter(Boolean)
      .join(", "),
  );

  const mandatory = toFieldList({
    "Firm Name": supplier?.supplierName,
    Email: supplier?.email,
    Address: fullAddress,
    Contacts: mobileNumbers,
    Transports: transports,
    "GST No": supplier?.supplierGstNo || supplier?.gstNo,
  });

  const bank = buildBankCopyData(supplier);
  const base = buildStructuredCopyText(mandatory, Boolean(bank), bank);

  return {
    mandatory,
    bank,
    html: base.html,
    text: base.text,
  };
};

export const getSuppliersFormattedText = (data) => {
  const suppliers = data?.suppliers ?? [];

  if (suppliers.length === 0) return { html: "", text: "" };

  const html = suppliers
    .map((supplier) => {
      const bank = buildBankCopyData(supplier);
      const bankParts = bank?.accounts
        ?.map((account) => {
          const details = account.fields
            .map(({ label, value }) => `${label}: ${value}`)
            .join(", ");
          return bank.accounts.length > 1
            ? `${account.label} (${details})`
            : details;
        })
        .join(" | ");

      const entry = {
        Name: supplier.supplierName,
        ...(bankParts ? { "Bank Details": bankParts } : {}),
      };

      return Object.entries(entry)
        .map(([key, value]) => `<b>${key}:</b> ${value}`)
        .join("<br/>");
    })
    .join("<br/><br/>");

  const text = convertHtmlToWhatsApp(html);

  return { html, text };
};

export const getCustomerFormattedText = (customer) => {
  const mobileNumbers = formatContacts(customer?.contacts);
  const fullAddress = cleanText(
    [
      customer?.addressLine1 || customer?.address,
      customer?.addressLine2,
      customer?.city,
      customer?.state,
      customer?.pinCode,
    ]
      .filter(Boolean)
      .join(", "),
  );

  const transports = customer?.preferredTransports
    ?.map((t) => t.name)
    ?.filter(Boolean)
    ?.join(", ");

  const mandatory = toFieldList({
    "Firm Name": customer?.customerName,
    Email: customer?.email,
    Address: fullAddress,
    Contacts: mobileNumbers,
    Transports: transports,
    "GST No": customer?.gstNo,
  });

  const bank = buildBankCopyData(customer);
  const base = buildStructuredCopyText(mandatory, Boolean(bank), bank);

  return {
    mandatory,
    bank,
    html: base.html,
    text: base.text,
  };
};

export const getTransportFormattedText = (transport) => {
  const mobileNumbers = formatContacts(
    transport?.contacts,
    "contactNumber",
  );
  const fullAddress = cleanText(
    [
      transport?.addressLine1,
      transport?.addressLine2,
      transport?.city,
      transport?.state,
      transport?.pinCode,
    ]
      .filter(Boolean)
      .join(", "),
  );

  const mandatory = toFieldList({
    "Firm Name": transport?.name,
    Address: fullAddress,
    Contacts: mobileNumbers,
    "GST No": transport?.gstNo,
  });

  const base = buildStructuredCopyText(mandatory, false, null);

  return {
    mandatory,
    bank: null,
    html: base.html,
    text: base.text,
  };
};

export const formatContacts = (contacts, numberKey = "mobileNumber") => {
  return contacts
    ?.map((contact) => {
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
