import React from "react";
import { useState, useEffect } from "react";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import GenericAutocomplete from "./common/GenericAutocomplete";
import GenericSingleSelect from "./common/GenericSingleSelect";
import { Button } from "@mui/material";
import { downloadLedger, getLedger } from "../service/LedgerService";
import dayjs from "dayjs";
import DataTable from "./DataTable";
import { formatIndianCurrency } from "../utils/currencyUtils";

const forOptions = [
  {
    id: 1,
    label: "Supplier",
    value: "SUPPLIER",
  },
  {
    id: 2,
    label: "Customer",
    value: "CUSTOMER",
  },
];

const columns = {
  desktop: [
    { key: "invoiceNo", width: "20%", label: "Invoice Number" },
    {
      key: "date",
      label: "Date",
      width: "20%",
      render: (row) => (row.date ? dayjs(row.date).format("DD-MM-YYYY") : "-"),
    },
    { key: "particular", label: "Particular", width: "20%" },
    {
      key: "debit",
      label: "Debit",
      width: "20%",
      render: (s) =>
        s.debit ? `₹${formatIndianCurrency(Math.round(s.debit))}` : "-",
    },
    {
      key: "credit",
      label: "Credit",
      width: "20%",
      render: (s) =>
        s.credit ? `₹${formatIndianCurrency(Math.round(s.credit))}` : "-",
    },
  ],
};

function Ledger() {
  const { showSnackbar } = useSnackbar();
  const [filterObject, setFilterObject] = useState({
    selectedSupplier: null,
    selectedCustomer: null,
    selectedFor: null,
  });
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [ledgerData, setLedgerData] = useState({});
  const [filtersApplied, setFiltersApplied] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleChange = (key, value) => {
    setFilterObject((prev) => ({
      ...prev,
      [key]: value,
    }));
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      setFiltersApplied(true);

      const payload = {
        supplierId: filterObject.selectedSupplier.id,
        customerId: filterObject.selectedCustomer.id,
        viewType: filterObject.selectedFor,
      };

      const result = await getLedger(payload);
      if (result.data.entries.length === 0) {
        showSnackbar("No transactions found", "warning");
      } else {
        showSnackbar(
          result.message || "Ledger fetched successfully",
          "success",
        );
      }
      setLedgerData(result.data);
    } catch (error) {
      setFiltersApplied(true);
      showSnackbar(error.message || "something went wrong!", "error");
    } finally {
      setLoading(false);
    }
  };

  const isDisabled = () => {
    const { selectedSupplier, selectedCustomer, selectedFor } = filterObject;
    if (!selectedSupplier || !selectedCustomer || !selectedFor) {
      return true;
    } else {
      return false;
    }
  };

const handleDownload = async () => {
  try {
    const payload = {
      supplierId: filterObject.selectedSupplier.id,
      customerId: filterObject.selectedCustomer.id,
      viewType: filterObject.selectedFor,
    };

    const response = await downloadLedger(payload);

    const blob = new Blob([response.data]);

    const url = window.URL.createObjectURL(blob);

    const link = document.createElement("a");

    link.href = url;

  
    const disposition = response.headers["content-disposition"];

    let fileName = "ledger.xlsx";

    if (disposition) {
      const match = disposition.match(/filename="?(.+)"?/);

      if (match) {
        fileName = match[1];
      }
    }

    link.download = fileName;

    document.body.appendChild(link);

    link.click();

    link.remove();

    window.URL.revokeObjectURL(url);

  } catch (err) {
    showSnackbar(err.message || "Download failed", "error");
  }
};

  useEffect(() => {
    const loadData = async () => {
      try {
        const [suppliers, customers] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
        ]);

        const supplierOptions = (suppliers || []).map((s) => ({
          id: s.id,
          label: `${s.supplierName}${s.city ? ` - ${s.city}` : ""}`,
        }));

        const customerOptions = (customers || []).map((c) => ({
          id: c.id,
          label: `${c.customerName}${c.city ? ` - ${c.city}` : ""}`,
        }));
        setAllSuppliers(supplierOptions || []);
        setAllCustomers(customerOptions || []);
      } catch {
        showSnackbar("Error loading suppliers/customers", "error");
      }
    };
    loadData();
  }, []);

  return (
    <div className="flex flex-col h-full  text-gray-500 shadow-sm my-4 overflow-y-auto">
      <div className="bg-gray-50 border sticky top-0 z-20 rounded-lg shadow-sm ">
        <div className="px-6 py-4 border-b">
          <h2 className="text-xl font-semibold">Ledger</h2>
          <p className="text-sm text-gray-500 mt-1">
            Filter and review transaction history
          </p>
        </div>
        <div className="px-6 py-5">
          <div className="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-8 gap-3">
            {/* Supplier */}
            <div className="col-span-2 sm:col-span-1 md:col-span-2">
              <GenericAutocomplete
                options={allSuppliers}
                value={filterObject.selectedSupplier}
                label="Supplier*"
                placeholder="Select supplier*"
                onChange={(value) => handleChange("selectedSupplier", value)}
              />
            </div>

            {/* Customer */}
            <div className="col-span-2 sm:col-span-1 md:col-span-2">
              <GenericAutocomplete
                options={allCustomers}
                value={filterObject.selectedCustomer}
                label="Customer*"
                placeholder="Select customer*"
                onChange={(value) => handleChange("selectedCustomer", value)}
              />
            </div>

            {/* Genereted For */}
            <div className="col-span-2 sm:col-span-1 md:col-span-2">
              <GenericSingleSelect
                label="Generating For*"
                value={filterObject.selectedFor}
                options={forOptions}
                onChange={(value) => handleChange("selectedFor", value)}
              />
            </div>
            <div className="col-span-2 sm:col-span-1 md:col-span-2 flex gap-2">
              <Button
                variant="contained"
                disabled={isDisabled()}
                onClick={handleSubmit}
              >
                Submit
              </Button>

              <Button
                variant="outlined"
                disabled={isDisabled()}
                onClick={handleDownload}
              >
                Download
              </Button>
            </div>
          </div>
        </div>
      </div>
      {ledgerData.party && (
        <div className="mt-4 rounded-lg border bg-gray-50 shadow-sm">
          <div className="border-b px-5 py-3">
            <h3 className="font-semibold text-lg">
              {ledgerData?.ledgerType === "SUPPLIER"
                ? "Customer"
                : "Supplier"}{" "}
              Details
            </h3>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 px-5 py-4">
            <div>
              <p className="text-sm text-gray-500">Name</p>
              <p className="font-medium">{ledgerData.party.name}</p>
            </div>

            <div>
              <p className="text-sm text-gray-500">Phone</p>
              <p className="font-medium">{ledgerData.party.phone || "-"}</p>
            </div>

            <div>
              <p className="text-sm text-gray-500">Email</p>
              <p className="font-medium">{ledgerData.party.email || "-"}</p>
            </div>

            <div>
              <p className="text-sm text-gray-500">Address</p>
              <p className="font-medium">{ledgerData.party.address || "-"}</p>
            </div>
            
            <div>
              <p className="text-sm text-gray-500">GST No.</p>
              <p className="font-medium">{ledgerData.party.gstNo || "-"}</p>
            </div>
          </div>
        </div>
      )}
      <div className="mb-8 mt-4 rounded-lg text-gray-500 shadow-sm">
        <DataTable
          columns={columns.desktop}
          actions={false}
          data={ledgerData.entries || []}
          loading={loading}
          emptyMessage={
            filtersApplied
              ? "No data found for selected filters"
              : "Apply filters to view transaction history"
          }
        />
      </div>
    </div>
  );
}

export default Ledger;
