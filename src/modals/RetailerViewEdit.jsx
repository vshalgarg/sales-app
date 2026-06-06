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
  Chip,
  Divider,
  Box,
  Button,
  CircularProgress,
} from "@mui/material";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import CloseIcon from "@mui/icons-material/Close";
import dayjs from "dayjs";
import { LocalizationProvider, DatePicker } from "@mui/x-date-pickers";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import GenericAutocomplete from "../components/common/GenericAutocomplete";
import CustomerService from "../service/CustomerService";
import { getAllActiveStaffs } from "../service/StaffService";
import { mapToOption } from "../utils/optionMapper";
import { formatIndianCurrency } from "../utils/currencyUtils";

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

/* Section 2: History accordion per supplier */
const HistorySection = ({ suppliers = [], expanded, onChange }) => (
  <Accordion
    expanded={expanded}
    onChange={onChange}
    disableGutters
    elevation={0}
    sx={{ border: "1px solid", borderColor: "divider", borderRadius: 1 }}
  >
    <AccordionSummary expandIcon={<ExpandMoreIcon />}>
      <Typography variant="subtitle2" fontWeight={600}>
        History
      </Typography>
    </AccordionSummary>
    <AccordionDetails sx={{ p: 0 }}>
      {suppliers.length === 0 ? (
        <Typography variant="body2" color="text.secondary" sx={{ p: 2 }}>
          No supplier history found.
        </Typography>
      ) : (
        suppliers.map((supplier, si) => (
          <Accordion
            key={si}
            disableGutters
            elevation={0}
            sx={{
              borderTop: "1px solid",
              borderColor: "divider",
              "&:before": { display: "none" },
            }}
          >
            <AccordionSummary
              expandIcon={<ExpandMoreIcon />}
              sx={{ bgcolor: "#fafafa", px: 2 }}
            >
              <Box
                sx={{
                  display: "flex",
                  alignItems: "center",
                  gap: 2,
                  width: "100%",
                }}
              >
                <Typography variant="body2" fontWeight={600} sx={{ flex: 1 }}>
                  {supplier.supplierName || "-"}
                </Typography>
                <Chip
                  label={`Total: ₹${formatIndianCurrency(Math.round(supplier.totalAmount ?? 0))}`}
                  size="small"
                  variant="outlined"
                />
                <Chip
                  label={`Deposited: ₹${formatIndianCurrency(Math.round(supplier.depositAmount ?? 0))}`}
                  size="small"
                  color="success"
                  variant="outlined"
                />
                <Chip
                  label={`Remaining: ₹${formatIndianCurrency(Math.round(supplier.balanceAmount ?? 0))}`}
                  size="small"
                  color={supplier.balanceAmount > 0 ? "warning" : "success"}
                  variant="outlined"
                />
              </Box>
            </AccordionSummary>
            <AccordionDetails sx={{ p: 0 }}>
              <Table size="small">
                <TableHead>
                  <TableRow sx={{ bgcolor: "#f5f5f5" }}>
                    <TableCell sx={{ fontWeight: 600 }}>Date</TableCell>
                    <TableCell sx={{ fontWeight: 600 }}>
                      Deposit Amount
                    </TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {(supplier.deposits ?? []).length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={2}>
                        <Typography variant="body2" color="text.secondary">
                          No deposits yet.
                        </Typography>
                      </TableCell>
                    </TableRow>
                  ) : (
                    supplier.deposits.map((dep, di) => (
                      <TableRow key={di} hover>
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
              </Table>
            </AccordionDetails>
          </Accordion>
        ))
      )}
    </AccordionDetails>
  </Accordion>
);

/* Section 3: Deposit form row per supplier (edit only) */
const DepositRow = ({ supplier, depositData, onChange }) => (
  <Box
    sx={{
      display: "flex",
      alignItems: "center",
      gap: 2,
      p: 1.5,
      border: "1px solid",
      borderColor: "divider",
      borderRadius: 1,
      bgcolor: "#fafafa",
    }}
  >
    <TextField
      label="Supplier"
      value={supplier.supplierName || ""}
      size="small"
      disabled
      sx={{ flex: 2 }}
    />
    <TextField
      label="Balance Amount"
      value={
        supplier.balanceAmount != null ? supplier.balanceAmount.toFixed(2) : ""
      }
      size="small"
      disabled
      sx={{ flex: 1 }}
    />
    <LocalizationProvider dateAdapter={AdapterDayjs}>
      <DatePicker
        label="Date"
        format="DD-MM-YYYY"
        value={depositData.date ? dayjs(depositData.date) : dayjs()}
        onChange={(v) =>
          onChange("date", v ? dayjs(v).format("YYYY-MM-DD") : "")
        }
        slotProps={{ textField: { size: "small", sx: { flex: 1 } } }}
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
      sx={{ flex: 1 }}
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
    mode === "view" ? "all" : "retailer",
  );

  const handleAccordionChange = (panel) => (_, isExpanded) => {
    setExpanded(isExpanded ? panel : false);
  };

  // ── Section 1 state ──
  const [retailerInputs, setRetailerInputs] = useState({
    retailName: data?.name ?? "",
    date: data?.date ?? "",
    customerId: data?.referredByCustomerId ?? null,
    staffId: data?.staffId ?? null,
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
      setExpanded("all");
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
      PaperProps={{ sx: { borderRadius: 2 } }}
    >
      <DialogTitle
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          pb: 1,
        }}
      >
        <Typography variant="h6" fontWeight={600}>
          {mode === "edit" ? "Edit Retailer" : "View Retailer"}
        </Typography>
        <IconButton size="small" onClick={onClose}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>

      <Divider />

      <DialogContent
        sx={{ display: "flex", flexDirection: "column", gap: 2, pt: 2 }}
      >
        {/* ── Section 1: Retailer Info ── */}
        <Accordion
          expanded={
            mode === "view"
              ? expanded === "all" || expanded === "retailer"
              : expanded === "retailer"
          }
          onChange={handleAccordionChange("retailer")}
          disableGutters
          elevation={0}
          sx={{ border: "1px solid", borderColor: "divider", borderRadius: 1 }}
        >
          <AccordionSummary expandIcon={<ExpandMoreIcon />}>
            <Typography variant="subtitle2" fontWeight={600}>
              Retailer Info
            </Typography>
          </AccordionSummary>
          <AccordionDetails>
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
          </AccordionDetails>
        </Accordion>

        {/* ── Section 2: Add Deposits (edit only) ── */}
        {mode === "edit" && (
          <Accordion
            expanded={expanded === "deposits"}
            onChange={handleAccordionChange("deposits")}
            disableGutters
            elevation={0}
            sx={{
              border: "1px solid",
              borderColor: "divider",
              borderRadius: 1,
            }}
          >
            <AccordionSummary expandIcon={<ExpandMoreIcon />}>
              <Typography variant="subtitle2" fontWeight={600}>
                Add Deposits
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Box sx={{ display: "flex", flexDirection: "column", gap: 1.5 }}>
                {suppliers.length === 0 ? (
                  <Typography variant="body2" color="text.secondary">
                    No suppliers found.
                  </Typography>
                ) : (
                  <>
                    {suppliers.map((s) => (
                      <DepositRow
                        key={s.supplierId}
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
            </AccordionDetails>
          </Accordion>
        )}

        {/* ── Section 3: History ── */}
        <HistorySection
          suppliers={historyData}
          expanded={
            mode === "view"
              ? expanded === "all" || expanded === "history"
              : expanded === "history"
          }
          onChange={handleAccordionChange("history")}
        />
      </DialogContent>
    </Dialog>
  );
};

export default RetailerViewEdit;
