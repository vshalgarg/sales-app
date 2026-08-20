// src/modals/RetailerViewEdit.jsx
import { useState, useEffect } from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Typography,
  Grid,
  TextField,
  IconButton,
  Table,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
  TableContainer,
  Chip,
  Box,
  Button,
  CircularProgress,
} from "@mui/material";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import KeyboardArrowDownIcon from "@mui/icons-material/KeyboardArrowDown";
import KeyboardArrowUpIcon from "@mui/icons-material/KeyboardArrowUp";
import CloseIcon from "@mui/icons-material/Close";
import { Store, History, CircleDollarSign } from "lucide-react";
import dayjs from "dayjs";
import { LocalizationProvider, DatePicker } from "@mui/x-date-pickers";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import GenericAutocomplete from "../components/common/GenericAutocomplete";
import CustomerService from "../service/CustomerService";
import { getAllActiveStaffs } from "../service/StaffService";
import { mapToOption } from "../utils/optionMapper";
import { formatIndianCurrency } from "../utils/currencyUtils";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import {
  SECTION_ICON_CLASS,
  SECTION_ICON_WRAPPER_CLASS,
} from "../theme/cardTheme";
import { BRAND_COLORS } from "../theme/brandColors";
import useResponsive from "../customHooks/useResponsive";

const nestedHeaderCellSx = {
  fontWeight: 600,
  bgcolor: "#f7f5ff",
  color: BRAND_COLORS.primary,
  whiteSpace: "nowrap",
};

const sectionSurfaceBg = (variantIndex = 0) =>
  variantIndex % 2 === 0 ? "rgba(239,246,255,0.8)" : "rgba(245,243,255,0.8)";

const sectionAccordionSx = (variantIndex = 0) => ({
  border: `1px solid ${BRAND_COLORS.surfaceBorder}`,
  borderRadius: "12px !important",
  bgcolor: sectionSurfaceBg(variantIndex),
  "&:before": { display: "none" },
  boxShadow: "0 1px 2px rgba(0,0,0,0.04)",
  flexShrink: 0,
  "& .MuiAccordionDetails-root": {
    p: 0,
    borderBottomLeftRadius: "12px",
    borderBottomRightRadius: "12px",
  },
});

const sectionScrollMaxHeight = {
  xs: "36vh",
  sm: "260px",
};

const historyScrollMaxHeight = {
  xs: "48vh",
  sm: "380px",
};

const ScrollableSectionBody = ({
  variantIndex = 0,
  maxHeight = sectionScrollMaxHeight,
  sx = {},
  children,
}) => (
  <Box
    sx={{
      maxHeight,
      overflowY: "auto",
      overflowX: "hidden",
      overscrollBehavior: "contain",
      WebkitOverflowScrolling: "touch",
      bgcolor: sectionSurfaceBg(variantIndex),
      px: 2,
      py: 2,
      ...sx,
    }}
  >
    {children}
  </Box>
);

const sectionSummarySx = {
  bgcolor: "transparent",
  minHeight: 52,
  flexShrink: 0,
};

const SectionHeader = ({ title, icon: Icon }) => (
  <div className="flex items-center gap-3">
    {Icon && (
      <div
        className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
      >
        <Icon className={`h-4 w-4 ${SECTION_ICON_CLASS}`} />
      </div>
    )}
    <span className="text-base font-semibold text-gray-900 dark:text-gray-100">
      {title}
    </span>
  </div>
);

/* Read-only field */
const InfoField = ({ label, value }) => (
  <div className="flex flex-col gap-1">
    <Typography
      variant="caption"
      color="text.secondary"
      sx={{ fontWeight: 600, letterSpacing: 0.5 }}
    >
      {label}
    </Typography>
    <Typography variant="body2" sx={{ fontWeight: 500 }}>
      {value || "-"}
    </Typography>
  </div>
);

const historyTableCardSx = {
  bgcolor: "#fff",
  border: `1px solid ${BRAND_COLORS.surfaceBorder}`,
  borderRadius: "10px",
  overflow: "hidden",
};

const historyTableSx = {
  minWidth: 640,
  "& .MuiTableCell-root": {
    borderColor: BRAND_COLORS.surfaceBorder,
  },
};

const HistoryTable = ({ children }) => (
  <TableContainer sx={{ maxWidth: "100%", overflowX: "auto" }}>
    <Table size="small" sx={historyTableSx}>
      {children}
    </Table>
  </TableContainer>
);

const amountChipSx = {
  total: {
    bgcolor: "#eff6ff",
    color: BRAND_COLORS.primary,
    borderColor: "#bfdbfe",
  },
  deposited: {
    bgcolor: "#f0fdf4",
    color: "#16a34a",
    borderColor: "#bbf7d0",
  },
  remaining: {
    bgcolor: "#fef2f2",
    color: "#dc2626",
    borderColor: "#fecaca",
  },
};

const SupplierHistoryRow = ({ supplier }) => {
  const [open, setOpen] = useState(false);
  const deposits = supplier.deposits ?? [];

  const rowSx = {
    bgcolor: "#fff",
    "& td": {
      borderBottom: `1px solid ${BRAND_COLORS.surfaceBorder}`,
    },
  };

  return (
    <>
      <TableRow sx={rowSx}>
        <TableCell sx={{ fontWeight: 600, color: BRAND_COLORS.navy }}>
          {supplier.supplierName || "-"}
        </TableCell>
        <TableCell>
          <Chip
            label={`Total: ₹${formatIndianCurrency(Math.round(supplier.totalAmount ?? 0))}`}
            size="small"
            variant="outlined"
            sx={amountChipSx.total}
          />
        </TableCell>
        <TableCell>
          <Chip
            label={`Deposited: ₹${formatIndianCurrency(Math.round(supplier.depositAmount ?? 0))}`}
            size="small"
            variant="outlined"
            sx={amountChipSx.deposited}
          />
        </TableCell>
        <TableCell>
          <Chip
            label={`Remaining: ₹${formatIndianCurrency(Math.round(supplier.balanceAmount ?? 0))}`}
            size="small"
            variant="outlined"
            sx={amountChipSx.remaining}
          />
        </TableCell>
        <TableCell align="center" sx={{ width: 48, px: 1 }}>
          <IconButton
            size="small"
            onClick={() => setOpen((prev) => !prev)}
            disabled={deposits.length === 0}
            aria-label={open ? "Collapse deposits" : "Expand deposits"}
          >
            {open ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
          </IconButton>
        </TableCell>
      </TableRow>

      {open && (
        <TableRow>
          <TableCell colSpan={5} sx={{ p: 0, bgcolor: "#fff", border: 0 }}>
            <Box
              sx={{
                mx: { xs: 1, sm: 2 },
                mb: 2,
                ...historyTableCardSx,
              }}
            >
              <HistoryTable>
              <TableHead>
                <TableRow>
                  <TableCell sx={nestedHeaderCellSx}>Date</TableCell>
                  <TableCell sx={nestedHeaderCellSx}>Deposit Amount</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {deposits.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={2}>
                      <Typography variant="body2" color="text.secondary">
                        No deposits yet.
                      </Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  deposits.map((dep, di) => (
                    <TableRow key={di} hover sx={{ bgcolor: "#fff" }}>
                      <TableCell>
                        {dep.date
                          ? dayjs(dep.date).format("DD-MM-YYYY")
                          : "-"}
                      </TableCell>
                      <TableCell>
                        {dep.amount
                          ? `₹${formatIndianCurrency(Math.round(dep.amount))}`
                          : "-"}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
              </HistoryTable>
            </Box>
          </TableCell>
        </TableRow>
      )}
    </>
  );
};

/* Section 2: History grid per supplier */
const HistorySection = ({ suppliers = [], expanded, onChange }) => (
  <Accordion
    expanded={expanded}
    onChange={onChange}
    disableGutters
    elevation={0}
    sx={sectionAccordionSx(1)}
  >
    <AccordionSummary
      expandIcon={<ExpandMoreIcon sx={{ color: BRAND_COLORS.primary }} />}
      sx={sectionSummarySx}
    >
      <SectionHeader title="History" icon={History} />
    </AccordionSummary>
    <AccordionDetails sx={{ bgcolor: sectionSurfaceBg(1) }}>
      <ScrollableSectionBody variantIndex={1} maxHeight={historyScrollMaxHeight}>
      {suppliers.length === 0 ? (
        <Typography variant="body2" color="text.secondary">
          No supplier history found.
        </Typography>
      ) : (
        <Box sx={historyTableCardSx}>
          <HistoryTable>
          <TableHead>
            <TableRow>
              <TableCell sx={nestedHeaderCellSx}>Supplier</TableCell>
              <TableCell sx={nestedHeaderCellSx}>Total Amount</TableCell>
              <TableCell sx={nestedHeaderCellSx}>Deposited</TableCell>
              <TableCell sx={nestedHeaderCellSx}>Remaining</TableCell>
              <TableCell sx={{ ...nestedHeaderCellSx, width: 48 }} />
            </TableRow>
          </TableHead>
          <TableBody>
            {suppliers.map((supplier, si) => (
              <SupplierHistoryRow
                key={supplier.retailSupplierId ?? supplier.supplierId ?? si}
                supplier={supplier}
              />
            ))}
          </TableBody>
          </HistoryTable>
        </Box>
      )}
      </ScrollableSectionBody>
    </AccordionDetails>
  </Accordion>
);

/* Section 3: Deposit form row per supplier (edit only) */
const DepositRow = ({ supplier, depositData, onChange, variantIndex = 0 }) => (
  <Box
    sx={{
      display: "flex",
      flexWrap: "wrap",
      alignItems: { xs: "stretch", sm: "center" },
      gap: 2,
      p: 1.5,
      border: `1px solid ${BRAND_COLORS.surfaceBorder}`,
      borderRadius: 2,
      bgcolor: sectionSurfaceBg(variantIndex),
    }}
  >
    <TextField
      label="Supplier"
      value={supplier.supplierName || ""}
      size="small"
      disabled
      sx={{ flex: { xs: "1 1 100%", sm: "2 1 180px" }, minWidth: 0 }}
    />
    <TextField
      label="Balance Amount"
      value={
        supplier.balanceAmount != null ? supplier.balanceAmount.toFixed(2) : ""
      }
      size="small"
      disabled
      sx={{ flex: { xs: "1 1 100%", sm: "1 1 120px" }, minWidth: 0 }}
    />
    <LocalizationProvider dateAdapter={AdapterDayjs}>
      <DatePicker
        label="Date"
        format="DD-MM-YYYY"
        value={depositData.date ? dayjs(depositData.date) : dayjs()}
        onChange={(v) =>
          onChange("date", v ? dayjs(v).format("YYYY-MM-DD") : "")
        }
        slotProps={{
          textField: {
            size: "small",
            sx: { flex: { xs: "1 1 100%", sm: "1 1 140px" }, minWidth: 0 },
          },
        }}
      />
    </LocalizationProvider>
    <TextField
      label="Amount"
      type="number"
      size="small"
      value={depositData.amount}
      onChange={(e) => {
        let val = e.target.value;
        if (/^\d*\.?\d{0,2}$/.test(val)) {
          onChange("amount", val);
        }
      }}
      sx={{ flex: { xs: "1 1 100%", sm: "1 1 120px" }, minWidth: 0 }}
      inputProps={{ min: 0 }}
    />
  </Box>
);

/* ─── Main modal ─── */
const RetailerViewEdit = ({
  open,
  onClose,
  data,
  historyData = [],
  mode = "view",
  onSaveRetailer,
  onSaveDeposits,
}) => {
  const { isMobile } = useResponsive();

  // ── Dropdown options ──
  const [allCustomers, setAllCustomers] = useState([]);
  const [allStaffs, setAllStaffs] = useState([]);

  useEffect(() => {
    if (mode !== "edit") return; // only fetch in edit mode
    const load = async () => {
      try {
        const [customers, staffs] = await Promise.all([
          CustomerService.getAllCustomers(),
          getAllActiveStaffs(),
        ]);
        setAllCustomers(mapToOption(customers || [], "id", "customerName"));
        setAllStaffs(mapToOption(staffs || [], "staffId", "staffName"));
      } catch {
        // silently fail — fields will just be empty
      }
    };
    load();
  }, [mode]);

  const [expanded, setExpanded] = useState(
    mode === "view" ? null : "retailer",
  );
  const [viewOpen, setViewOpen] = useState({
    retailer: true,
    history: true,
  });

  const handleAccordionChange = (panel) => (_, isExpanded) => {
    if (mode === "view") {
      setViewOpen((prev) => ({ ...prev, [panel]: isExpanded }));
      return;
    }
    setExpanded(isExpanded ? panel : false);
  };

  // ── Section 1 state ──
  const [retailerInputs, setRetailerInputs] = useState({
    retailName: data?.name ?? "",
    date: data?.date ?? "",
    customerId: data?.referredByCustomerId ?? null,
    staffId: data?.staffId ?? null,
    commission: data?.commission ?? "",
  });

  const [savingRetailer, setSavingRetailer] = useState(false);

  const handleRetailerChange = (field, value) => {
    setRetailerInputs((prev) => ({ ...prev, [field]: value }));
  };

  const handleSaveRetailer = async () => {
    try {
      setSavingRetailer(true);
      await onSaveRetailer({
        retailId: data?.id,
        payload: {
          name: retailerInputs.retailName,
          date: retailerInputs.date,
          referredByCustomerId: retailerInputs.customerId,
          staffId: retailerInputs.staffId,
          commission: retailerInputs.commission || null,
        },
      });
      setExpanded(false);
    } finally {
      setSavingRetailer(false);
    }
  };

  // ── Section 2 state ──
  const [depositInputs, setDepositInputs] = useState(() => {
    const init = {};
    (data?.suppliers ?? []).forEach((s) => {
      init[s.supplierId] = { date: dayjs().format("YYYY-MM-DD"), amount: "" };
    });
    return init;
  });
  const [savingDeposits, setSavingDeposits] = useState(false);

  const handleDepositChange = (supplierId, field, value) => {
    setDepositInputs((prev) => ({
      ...prev,
      [supplierId]: { ...prev[supplierId], [field]: value },
    }));
  };

  const handleSaveDeposits = async () => {
    const deposits = (data?.suppliers ?? [])
      .filter(
        (s) =>
          depositInputs[s.supplierId]?.date &&
          depositInputs[s.supplierId]?.amount,
      )
      .map((s) => ({
        retailSupplierId: s.retailSupplierId,
        depositDate: depositInputs[s.supplierId].date,
        amount: Number(depositInputs[s.supplierId].amount),
      }));

    if (deposits.length === 0) return;

    try {
      setSavingDeposits(true);
      await onSaveDeposits(deposits);
      setDepositInputs((prev) => {
        const reset = {};

        Object.keys(prev).forEach((supplierId) => {
          reset[supplierId] = {
            date: dayjs().format("YYYY-MM-DD"),
            amount: "",
          };
        });

        return reset;
      });
      setExpanded(false);
    } finally {
      setSavingDeposits(false);
    }
  };

  const suppliers = data?.suppliers ?? [];

  const selectedCustomer =
    allCustomers.find((c) => c.id === retailerInputs.customerId) ?? null;
  const selectedStaff =
    allStaffs.find((s) => s.id === retailerInputs.staffId) ?? null;

  useEffect(() => {
    if (mode === "view") {
      setViewOpen({ retailer: true, history: true });
    } else {
      setExpanded("retailer");
    }
  }, [mode]);

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth="md"
      fullWidth
      fullScreen={isMobile}
      PaperProps={{
        sx: {
          borderRadius: isMobile ? 0 : 3,
          height: isMobile ? "100dvh" : "90vh",
          maxHeight: isMobile ? "100dvh" : "90vh",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
          m: isMobile ? 0 : 2,
        },
      }}
    >
      <DialogTitle
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          pb: 2,
          pt: 2.5,
          px: { xs: 2, sm: 3 },
          flexShrink: 0,
        }}
      >
        <div className="flex items-center gap-3">
          <div
            className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
          >
            <Store className={`h-5 w-5 ${SECTION_ICON_CLASS}`} />
          </div>
          <h2 className={PAGE_TITLE_CLASS}>
            {mode === "edit" ? "Edit Retailer" : "View Retailer"}
          </h2>
        </div>
        <IconButton
          size="small"
          onClick={onClose}
          sx={{
            border: `1px solid ${BRAND_COLORS.surfaceBorder}`,
            borderRadius: 2,
          }}
        >
          <CloseIcon fontSize="small" />
        </IconButton>
      </DialogTitle>

      <DialogContent
        dividers
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: 2,
          p: 0,
          px: { xs: 2, sm: 3 },
          py: 2,
          overflowY: "auto",
          overflowX: "hidden",
          flex: "1 1 auto",
          minHeight: 0,
        }}
      >
        <Accordion
          expanded={
            mode === "view" ? viewOpen.retailer : expanded === "retailer"
          }
          onChange={handleAccordionChange("retailer")}
          disableGutters
          elevation={0}
          sx={sectionAccordionSx(0)}
        >
          <AccordionSummary
            expandIcon={<ExpandMoreIcon sx={{ color: BRAND_COLORS.primary }} />}
            sx={sectionSummarySx}
          >
            <SectionHeader title="Retailer Info" icon={Store} />
          </AccordionSummary>
          <AccordionDetails sx={{ bgcolor: sectionSurfaceBg(0) }}>
            <ScrollableSectionBody variantIndex={0}>
            {mode === "view" ? (
              <Grid container spacing={2}>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <InfoField label="Retailer" value={data?.name} />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <InfoField
                    label="Date"
                    value={
                      data?.date ? dayjs(data.date).format("DD-MM-YYYY") : "-"
                    }
                  />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <InfoField label="Referred By" value={data?.customerName} />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <InfoField label="Staff" value={data?.staffName} />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <InfoField label="Commission" value={data?.commission} />
                </Grid>
              </Grid>
            ) : (
              <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
                <Grid container spacing={2}>
                  {/* Retailer name */}
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      label="Retailer"
                      value={retailerInputs.retailName}
                      onChange={(e) =>
                        handleRetailerChange("retailName", e.target.value)
                      }
                      size="small"
                      fullWidth
                    />
                  </Grid>

                  {/* Date */}
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <LocalizationProvider dateAdapter={AdapterDayjs}>
                      <DatePicker
                        label="Date"
                        format="DD-MM-YYYY"
                        value={
                          retailerInputs.date
                            ? dayjs(retailerInputs.date)
                            : null
                        }
                        onChange={(v) =>
                          handleRetailerChange(
                            "date",
                            v ? dayjs(v).format("YYYY-MM-DD") : "",
                          )
                        }
                        slotProps={{
                          textField: { size: "small", fullWidth: true },
                        }}
                      />
                    </LocalizationProvider>
                  </Grid>

                  {/* Referred By — autocomplete */}
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <GenericAutocomplete
                      options={allCustomers}
                      value={selectedCustomer}
                      label="Referred By"
                      placeholder="Select customer"
                      onChange={(value) =>
                        handleRetailerChange("customerId", value?.id ?? null)
                      }
                    />
                  </Grid>

                  {/* Staff — autocomplete */}
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <GenericAutocomplete
                      options={allStaffs}
                      value={selectedStaff}
                      label="Staff"
                      placeholder="Select staff"
                      onChange={(value) =>
                        handleRetailerChange("staffId", value?.id ?? null)
                      }
                    />
                  </Grid>

                  {/* Commission */}
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      label="Commission"
                      value={retailerInputs.commission}
                      onChange={(e) =>
                        handleRetailerChange("commission", e.target.value)
                      }
                      size="small"
                      fullWidth
                    />
                  </Grid>
                </Grid>

                <Box
                  sx={{ display: "flex", justifyContent: "flex-end", gap: 1 }}
                >
                  <Button
                    variant="contained"
                    size="small"
                    onClick={handleSaveRetailer}
                    disabled={savingRetailer}
                    startIcon={
                      savingRetailer ? <CircularProgress size={14} /> : null
                    }
                  >
                    {savingRetailer ? "Saving..." : "Save Info"}
                  </Button>
                </Box>
              </Box>
            )}
            </ScrollableSectionBody>
          </AccordionDetails>
        </Accordion>

        {/* ── Section 2: Add Deposits (edit only) ── */}
        {mode === "edit" && (
          <Accordion
            expanded={expanded === "deposits"}
            onChange={handleAccordionChange("deposits")}
            disableGutters
            elevation={0}
            sx={sectionAccordionSx(1)}
          >
            <AccordionSummary
              expandIcon={<ExpandMoreIcon sx={{ color: BRAND_COLORS.primary }} />}
              sx={sectionSummarySx}
            >
              <SectionHeader title="Add Deposits" icon={CircleDollarSign} />
            </AccordionSummary>
            <AccordionDetails sx={{ bgcolor: sectionSurfaceBg(1) }}>
              <ScrollableSectionBody variantIndex={1}>
              <Box sx={{ display: "flex", flexDirection: "column", gap: 1.5 }}>
                {suppliers.length === 0 ? (
                  <Typography variant="body2" color="text.secondary">
                    No suppliers found.
                  </Typography>
                ) : (
                  <>
                    {suppliers.map((s, index) => (
                      <DepositRow
                        key={s.supplierId}
                        variantIndex={index}
                        supplier={s}
                        depositData={
                          depositInputs[s.supplierId] ?? {
                            date: "",
                            amount: "",
                          }
                        }
                        onChange={(field, value) =>
                          handleDepositChange(s.supplierId, field, value)
                        }
                      />
                    ))}
                    <Box
                      sx={{
                        display: "flex",
                        justifyContent: "flex-end",
                        gap: 1,
                        pt: 1,
                      }}
                    >
                      <Button
                        variant="contained"
                        onClick={handleSaveDeposits}
                        disabled={savingDeposits}
                        startIcon={
                          savingDeposits ? <CircularProgress size={16} /> : null
                        }
                      >
                        {savingDeposits ? "Saving..." : "Save Deposits"}
                      </Button>
                    </Box>
                  </>
                )}
              </Box>
              </ScrollableSectionBody>
            </AccordionDetails>
          </Accordion>
        )}

        {/* ── Section 3: History ── */}
        <HistorySection
          suppliers={historyData}
          expanded={
            mode === "view" ? viewOpen.history : expanded === "history"
          }
          onChange={handleAccordionChange("history")}
        />
      </DialogContent>
    </Dialog>
  );
};

export default RetailerViewEdit;
