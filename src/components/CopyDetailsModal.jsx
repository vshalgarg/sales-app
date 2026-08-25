import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Checkbox,
  FormControlLabel,
  IconButton,
} from "@mui/material";
import {
  Building2,
  Copy,
  FileText,
  Landmark,
  Mail,
  MapPin,
  Phone,
  Truck,
  X,
} from "lucide-react";
import { useSnackbar } from "../contexts/SnackbarContext";
import { useEffect, useMemo, useState } from "react";
import {
  buildStructuredCopyText,
  convertHtmlToWhatsApp,
} from "../utils/copyFormatter";
import AppButton from "./AppButton";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";

const FIELD_ICONS = {
  "Firm Name": Building2,
  Email: Mail,
  Emails: Mail,
  Address: MapPin,
  Contacts: Phone,
  Transports: Truck,
  "GST No": FileText,
  "Bank Details": Landmark,
};

const parseFormattedEntries = (html = "") => {
  if (!html) return [];

  const parser = new DOMParser();
  const doc = parser.parseFromString(`<div>${html}</div>`, "text/html");
  const boldNodes = Array.from(doc.querySelectorAll("b, strong"));

  return boldNodes
    .map((node, index) => {
      const rawLabel = (node.textContent || "").trim().replace(/:$/, "");
      if (!rawLabel) return null;

      let value = "";
      let current = node.nextSibling;
      while (current && current.nodeName !== "BR") {
        value += current.textContent || "";
        current = current.nextSibling;
      }

      const cleanedValue = value.trim();
      if (!cleanedValue) return null;

      return {
        id: `${rawLabel}-${index}`,
        label: rawLabel,
        value: cleanedValue,
      };
    })
    .filter(Boolean);
};

const toFormattedText = (entries) => {
  const html = entries
    .map(({ label, value }, index) => {
      const nextLabel = entries[index + 1]?.label;
      const extraBreak =
        nextLabel === "Name" &&
        label !== "Selected Date" &&
        label !== "Date" &&
        label !== "Customer"
          ? `<div data-copy-gap="true" style="height:12px"></div>`
          : "";
      return `<b>${label}:</b> ${value}<br/>${extraBreak}`;
    })
    .join("");

  return {
    html,
    text: convertHtmlToWhatsApp(html),
  };
};

const PreviewRow = ({ label, value, icon: Icon, showValue = true }) => (
  <div className="flex items-start gap-2.5 py-1.5">
    <div className="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-md bg-violet-100">
      <Icon className="h-3.5 w-3.5 text-violet-600" />
    </div>
    <div className="min-w-0 flex-1">
      <p className="text-sm font-semibold text-brand-navy">{label}</p>
      {showValue && value ? (
        <p className="text-sm text-gray-700 break-words">{value}</p>
      ) : null}
    </div>
  </div>
);

const StructuredCopyPreview = ({ mandatory = [], bank }) => (
  <div className="space-y-1">
    {mandatory.map((field) => {
      const Icon = FIELD_ICONS[field.label] || FileText;
      return (
        <PreviewRow
          key={field.label}
          label={field.label}
          value={field.value}
          icon={Icon}
        />
      );
    })}

    {bank?.accounts?.length > 0 ? (
      <div className="pt-1 space-y-3">
        <PreviewRow
          label="Bank Details"
          icon={FIELD_ICONS["Bank Details"]}
          showValue={false}
        />
        {bank.accounts.map((account) => (
          <div
            key={account.label}
            className="ml-9 space-y-1 border-l border-brand-surface-border pl-3"
          >
            {bank.accounts.length > 1 ? (
              <p className="text-sm font-semibold text-brand-navy">
                {account.label}
              </p>
            ) : null}
            {account.fields.map((field) => (
              <p
                key={`${account.label}-${field.label}`}
                className="text-sm text-gray-700 break-words"
              >
                <span className="font-medium text-brand-navy">
                  {field.label}:
                </span>{" "}
                {field.value}
              </p>
            ))}
          </div>
        ))}
      </div>
    ) : bank?.fields?.length > 0 ? (
      <div className="pt-1">
        <PreviewRow
          label="Bank Details"
          icon={FIELD_ICONS["Bank Details"]}
          showValue={false}
        />
        <div className="ml-9 space-y-1 border-l border-brand-surface-border pl-3">
          {bank.fields
            .filter((field) => !field.isSection)
            .map((field) => (
              <p
                key={field.label}
                className="text-sm text-gray-700 break-words"
              >
                <span className="font-medium text-brand-navy">
                  {field.label}:
                </span>{" "}
                {field.value}
              </p>
            ))}
        </div>
      </div>
    ) : null}
  </div>
);

const writeToClipboard = async ({ html, text }) => {
  if (navigator.clipboard?.write && window.ClipboardItem) {
    await navigator.clipboard.write([
      new ClipboardItem({
        "text/html": new Blob([html], { type: "text/html" }),
        "text/plain": new Blob([text], { type: "text/plain" }),
      }),
    ]);
    return;
  }

  await navigator.clipboard.writeText(text);
};

export default function CopyDetailsModal({
  open,
  onClose,
  title,
  formattedText,
  showSelection = true,
  splitBankCopy = false,
}) {
  const { showSnackbar } = useSnackbar();
  const [copying, setCopying] = useState(false);
  const [copyingBank, setCopyingBank] = useState(false);
  const [selectedIds, setSelectedIds] = useState([]);

  const isStructuredCopy = Array.isArray(formattedText?.mandatory);
  const hasBankDetails = Boolean(
    formattedText?.bank?.accounts?.length ||
      formattedText?.bank?.fields?.length,
  );

  const legacyEntries = useMemo(
    () =>
      isStructuredCopy ? [] : parseFormattedEntries(formattedText?.html),
    [formattedText?.html, isStructuredCopy],
  );

  useEffect(() => {
    if (!open || isStructuredCopy) return;
    setSelectedIds(legacyEntries.map((entry) => entry.id));
  }, [open, isStructuredCopy, legacyEntries]);

  const selectedLegacyEntries = useMemo(
    () => legacyEntries.filter((entry) => selectedIds.includes(entry.id)),
    [legacyEntries, selectedIds],
  );

  const generalFormattedText = useMemo(() => {
    if (isStructuredCopy) {
      return buildStructuredCopyText(
        formattedText.mandatory,
        false,
        formattedText.bank,
      );
    }

    return toFormattedText(selectedLegacyEntries);
  }, [formattedText, isStructuredCopy, selectedLegacyEntries]);

  const bankFormattedText = useMemo(() => {
    if (!isStructuredCopy || !hasBankDetails) {
      return { html: "", text: "" };
    }

    return buildStructuredCopyText([], true, formattedText.bank);
  }, [formattedText, hasBankDetails, isStructuredCopy]);

  const handleToggle = (id) => {
    setSelectedIds((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id],
    );
  };

  const handleCopy = async () => {
    if (!generalFormattedText.html) {
      showSnackbar("No data to copy", "warning");
      return;
    }

    setCopying(true);

    try {
      await writeToClipboard(generalFormattedText);
      showSnackbar("Details copied to clipboard", "success");
      onClose();
    } catch {
      showSnackbar("Failed to copy details", "error");
    } finally {
      setCopying(false);
    }
  };

  const handleCopyBankDetails = async () => {
    if (!hasBankDetails) {
      showSnackbar("No bank details found", "warning");
      return;
    }

    setCopyingBank(true);

    try {
      await writeToClipboard(bankFormattedText);
      showSnackbar("Bank details copied to clipboard", "success");
      onClose();
    } catch {
      showSnackbar("Failed to copy bank details", "error");
    } finally {
      setCopyingBank(false);
    }
  };

  const hasGeneralCopyContent = isStructuredCopy
    ? formattedText.mandatory.length > 0
    : selectedLegacyEntries.length > 0;

  const showLegacySelection = showSelection && !isStructuredCopy;

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth="md"
      fullWidth
      PaperProps={{
        sx: {
          overflow: "visible",
        },
      }}
    >
      <DialogTitle className="relative pt-8 text-center">
        <div className="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1/2 flex h-12 w-12 items-center justify-center rounded-full border border-brand-surface-border bg-violet-100">
          <Copy className="h-5 w-5 text-violet-600" />
        </div>
        <IconButton
          aria-label="Close"
          onClick={onClose}
          size="medium"
          className="!absolute right-3 top-3"
        >
          <X className="h-5 w-5 text-brand-search-muted" />
        </IconButton>
        <h2 className={`${PAGE_TITLE_CLASS} text-center mt-2`}>{title}</h2>
      </DialogTitle>

      <DialogContent>
        {showLegacySelection ? (
          <>
            <p className="text-center text-sm text-brand-search-muted mb-3">
              Select the details you want to copy
            </p>
            <div className="rounded-xl border border-brand-surface-border bg-brand-tab-inactive/30 p-3 mb-4">
              <p className="text-xs font-semibold text-brand-primary mb-2">
                Select Details to Copy
              </p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                {legacyEntries.map((entry) => (
                  <div
                    key={entry.id}
                    className="rounded-md border border-brand-surface-border bg-white px-2 py-1"
                  >
                    <FormControlLabel
                      sx={{ margin: 0 }}
                      control={
                        <Checkbox
                          size="small"
                          checked={selectedIds.includes(entry.id)}
                          onChange={() => handleToggle(entry.id)}
                        />
                      }
                      label={
                        <span className="text-xs text-brand-navy">
                          {entry.label}
                        </span>
                      }
                    />
                  </div>
                ))}
              </div>
            </div>
          </>
        ) : null}

        {/* <p className="text-xs font-semibold text-brand-primary mb-2">Preview</p> */}
        <div
          className="rounded-[10px] border border-brand-surface-border bg-[#f7f8ff] p-3 max-h-[60vh] overflow-y-auto break-words"
          style={{ lineHeight: 1.8 }}
        >
          {isStructuredCopy ? (
            <StructuredCopyPreview
              mandatory={formattedText.mandatory}
              bank={formattedText.bank}
            />
          ) : (
            <div
              dangerouslySetInnerHTML={{
                __html: generalFormattedText.html,
              }}
            />
          )}
        </div>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 2, gap: 1, flexWrap: "wrap" }}>
        <AppButton type="secondary" onClick={onClose}>
          Cancel
        </AppButton>
        {splitBankCopy && (
          <AppButton
            type="secondary"
            onClick={handleCopyBankDetails}
            disabled={copyingBank || copying || !hasBankDetails}
            startIcon={<Landmark className="h-4 w-4" />}
          >
            {copyingBank ? "Copying..." : "Copy Bank Details"}
          </AppButton>
        )}
        <AppButton
          type="primary"
          onClick={handleCopy}
          disabled={copying || copyingBank || !hasGeneralCopyContent}
          startIcon={<Copy className="h-4 w-4" />}
        >
          {copying ? "Copying..." : "Copy"}
        </AppButton>
      </DialogActions>
    </Dialog>
  );
}
