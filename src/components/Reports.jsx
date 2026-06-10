import { useEffect, useState } from "react";
import {
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  Typography,
} from "@mui/material";

import GenericMultiAutocomplete from "../components/common/GenericMultiAutocomplete";
import CustomDatePicker from "../components/common/CustomDatePicker";
import LineChart from "../components/common/charts/LineChart";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import { getAmountAndCountVsMonth } from "../service/chartsService";

const Reports = () => {
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [supplierLoading, setSupplierLoading] = useState(true);
  const [customerLoading, setCustomerLoading] = useState(true);
  const [lineChartFilters, setLineChartFilters] = useState({
    suppliers: [],
    customers: [],
    fromDate: null,
    toDate: null,
  });

  //   const [selectedSuppliers, setSelectedSuppliers] = useState([]);
  //   const [selectedCustomers, setSelectedCustomers] = useState([]);

  //   const [fromDate, setFromDate] = useState(null);
  //   const [toDate, setToDate] = useState(null);

  const [chartData, setChartData] = useState(null);

  const showSnackbar = useSnackbar();

  useEffect(() => {
    const loadData = async () => {
      try {
        setSupplierLoading(true);
        setCustomerLoading(true);

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
      } finally {
        setSupplierLoading(false);
        setCustomerLoading(false);
      }
    };

    loadData();
  }, []);

  const onFilterChange = (setFilterState, filterName, filterValue) => {
    setFilterState((prev) => ({
      ...prev,
      [filterName]: filterValue,
    }));
  };

  const handleApplyFilters = async () => {
    const payload = {
      supplierIds: lineChartFilters.suppliers.map((s) => s.id),
      customerIds: lineChartFilters.customers.map((c) => c.id),
      fromDate: lineChartFilters.fromDate,
      toDate: lineChartFilters.toDate,
    };

    const result = await getAmountAndCountVsMonth(payload);

    // const response = {
    //   labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"],

    //   datasets: [
    //     {
    //       label: "Bill Amount",
    //       unit: "₹",
    //       data: [10000, 25000, 18000, 35000, 42000, 38000, 50000],
    //     },

    //     {
    //       label: "Credit Amount",
    //       unit: "₹",
    //       data: [5000, 12000, 9000, 15000, 19000, 17000, 22000],
    //     },

    //     {
    //       label: "Bill Count",
    //       unit: "Count",
    //       data: [15, 25, 20, 35, 40, 32, 45],
    //     },

    //     {
    //       label: "Credit Count",
    //       unit: "Count",
    //       data: [10, 18, 14, 25, 28, 24, 33],
    //     },
    //   ],
    // };

    setChartData({
      labels: result?.data?.labels,

      datasets: result?.data?.datasets.map((dataset) => ({
        ...dataset,

        yAxisID: dataset.unit === "COUNT" ? "countAxis" : "amountAxis",

        tension: 0.3,
      })),
    });
  };

  const chartOptions = {
    responsive: true,

    maintainAspectRatio: false,

    interaction: {
      mode: "index",
      intersect: false,
    },

    plugins: {
      legend: {
        position: "top",
      },
    },

    scales: {
      amountAxis: {
        type: "linear",

        position: "left",

        title: {
          display: true,
          text: "Amount (₹)",
        },
      },

      countAxis: {
        type: "linear",

        position: "right",

        title: {
          display: true,
          text: "Count",
        },

        grid: {
          drawOnChartArea: false,
        },
      },
    },
  };

  return (
    <Card>
      <CardContent>
        <Typography variant="h5" gutterBottom>
          Amount & Count vs Month
        </Typography>

        <Box mb={4}>
          <Grid container spacing={2}>
            <Grid size={{ xs: 12, md: 3 }}>
              <GenericMultiAutocomplete
                label="Suppliers"
                options={allSuppliers}
                value={lineChartFilters.suppliers}
                onChange={(value) =>
                  onFilterChange(setLineChartFilters, "suppliers", value)
                }
              />
            </Grid>

            <Grid size={{ xs: 12, md: 3 }}>
              <GenericMultiAutocomplete
                label="Customers"
                options={allCustomers}
                value={lineChartFilters.customers}
                onChange={(value) =>
                  onFilterChange(setLineChartFilters, "customers", value)
                }
              />
            </Grid>

            <Grid size={{ xs: 12, md: 2 }}>
              <CustomDatePicker
                label="From Date"
                value={lineChartFilters.fromDate}
                onChange={(value) =>
                  onFilterChange(setLineChartFilters, "fromDate", value)
                }
              />
            </Grid>

            <Grid size={{ xs: 12, md: 2 }}>
              <CustomDatePicker
                label="To Date"
                value={lineChartFilters.toDate}
                onChange={(value) =>
                  onFilterChange(setLineChartFilters, "toDate", value)
                }
              />
            </Grid>

            <Grid size={{ xs: 12, md: 2 }}>
              <Button
                fullWidth
                variant="contained"
                onClick={handleApplyFilters}
                sx={{ height: "40px" }}
              >
                Apply Filter
              </Button>
            </Grid>
          </Grid>
        </Box>

        {chartData && (
          <Box sx={{ height: 500 }}>
            <LineChart data={chartData} options={chartOptions} />
          </Box>
        )}
      </CardContent>
    </Card>
  );
};

export default Reports;
