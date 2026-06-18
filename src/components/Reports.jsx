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
import PieChart from "../components/common/charts/PieChart";
import BarChart from "../components/common/charts/BarChart";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { useSnackbar } from "../context/SnackbarContext";
import {
  getAmountAndCountVsMonth,
  getCustomerVsAmount,
  getStaffAnalytics,
  getSupplierVsAmount,
} from "../service/ChartsService";

// Ordered for max contrast between neighbors (warm/cool alternation, no grays/dark runs).
const CHART_PALETTE = [
  "#2563EB",
  "#F97316",
  "#16A34A",
  "#E11D48",
  "#0891B2",
  "#9333EA",
  "#CA8A04",
  "#DB2777",
  "#0D9488",
  "#6366F1",
  "#EA580C",
  "#22C55E",
  "#7C3AED",
  "#EF4444",
  "#0284C7",
  "#84CC16",
  "#C026D3",
  "#14B8A6",
  "#F59E0B",
  "#EC4899",
];

const withAlpha = (hex, alpha) => {
  const a = Math.round(alpha * 255)
    .toString(16)
    .padStart(2, "0");
  return `${hex}${a}`;
};

const buildLineChartData = (result) => {
  if (!result?.data?.datasets) return null;
  return {
    labels: result.data.labels,
    datasets: result.data.datasets.map((dataset, index) => {
      const color = CHART_PALETTE[index % CHART_PALETTE.length];
      return {
        ...dataset,
        yAxisID: dataset.unit === "COUNT" ? "countAxis" : "amountAxis",
        tension: 0.3,
        borderColor: color,
        backgroundColor: withAlpha(color, 0.2),
        pointBackgroundColor: color,
        pointBorderColor: color,
        borderWidth: 2,
      };
    }),
  };
};

const colorizePieChart = (chart) => {
  if (!chart) return chart;
  const slices = chart.labels?.length ?? 0;
  const colors = Array.from(
    { length: slices },
    (_, i) => CHART_PALETTE[i % CHART_PALETTE.length],
  );
  return {
    ...chart,
    datasets: (chart.datasets || []).map((ds) => ({
      ...ds,
      backgroundColor: colors,
      borderColor: "#ffffff",
      borderWidth: 2,
    })),
  };
};

const buildPieChartData = (result) => {
  const data = result?.data;
  if (!data) {
    return {
      supplierCountVsStaff: null,
      customerCountVsStaff: null,
      suppierAndCustomerCountVsStaff: null,
    };
  }
  return {
    supplierCountVsStaff: colorizePieChart(data.supplierVsStaff),
    customerCountVsStaff: colorizePieChart(data.customerVsStaff),
    suppierAndCustomerCountVsStaff: colorizePieChart(
      data.supplierAndCustomerVsStaff,
    ),
  };
};

const colorizeBarDatasets = (chart) => {
  if (!chart) return chart;
  return {
    ...chart,
    datasets: (chart.datasets || []).map((ds, index) => {
      const color = CHART_PALETTE[index % CHART_PALETTE.length];
      return {
        ...ds,
        backgroundColor: color,
        borderColor: color,
        borderWidth: 0,
        borderRadius: 4,
        maxBarThickness: 36,
      };
    }),
  };
};

const toSupplierOptions = (suppliers) =>
  (suppliers || []).map((s) => ({
    id: s.id,
    label: `${s.supplierName}${s.city ? ` - ${s.city}` : ""}`,
  }));

const toCustomerOptions = (customers) =>
  (customers || []).map((c) => ({
    id: c.id,
    label: `${c.customerName}${c.city ? ` - ${c.city}` : ""}`,
  }));

const getRejectedMessage = (result, fallback) =>
  result.reason?.message || fallback;

const getPieSliceTotal = (dataset) =>
  (dataset?.data || []).reduce((sum, value) => sum + Number(value || 0), 0);

const Reports = () => {
  const showSnackbar = useSnackbar();
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [lineChartFilters, setLineChartFilters] = useState({
    suppliers: [],
    customers: [],
    fromDate: null,
    toDate: null,
  });
  const [pieChartFilters, setPieChartFilters] = useState({
    fromDate: null,
    toDate: null,
  });
  const [supplierBarFilters, setSupplierBarFilters] = useState({
    suppliers: [],
    fromDate: null,
    toDate: null,
  });
  const [customerBarFilters, setCustomerBarFilters] = useState({
    customers: [],
    fromDate: null,
    toDate: null,
  });

  const [lineChartData, setLineChartData] = useState(null);
  const [pieChartData, setPieChartData] = useState({
    supplierCountVsStaff: null,
    customerCountVsStaff: null,
    suppierAndCustomerCountVsStaff: null,
  });
  const [supplierBarData, setSupplierBarData] = useState(null);
  const [customerBarData, setCustomerBarData] = useState(null);
  const [lineChartRevision, setLineChartRevision] = useState(0);
  const [pieChartRevision, setPieChartRevision] = useState(0);
  const [supplierBarRevision, setSupplierBarRevision] = useState(0);
  const [customerBarRevision, setCustomerBarRevision] = useState(0);

  useEffect(() => {
    const loadData = async () => {
      const results = await Promise.allSettled([
        SupplierService.getAllSuppliers(),
        CustomerService.getAllCustomers(),
        getAmountAndCountVsMonth({
          supplierIds: [],
          customerIds: [],
          fromDate: null,
          toDate: null,
        }),
        getStaffAnalytics({
          fromDate: null,
          toDate: null,
        }),
        getSupplierVsAmount({
          supplierIds: [],
          fromDate: null,
          toDate: null,
        }),
        getCustomerVsAmount({
          customerIds: [],
          fromDate: null,
          toDate: null,
        }),
      ]);

      const [
        suppliersResult,
        customersResult,
        lineChartResult,
        staffAnalyticsResult,
        supplierBarResult,
        customerBarResult,
      ] = results;

      if (suppliersResult.status === "fulfilled") {
        setAllSuppliers(toSupplierOptions(suppliersResult.value));
      } else {
        showSnackbar(
          getRejectedMessage(suppliersResult, "Failed to load suppliers"),
          "error",
        );
      }

      if (customersResult.status === "fulfilled") {
        setAllCustomers(toCustomerOptions(customersResult.value));
      } else {
        showSnackbar(
          getRejectedMessage(customersResult, "Failed to load customers"),
          "error",
        );
      }

      if (lineChartResult.status === "fulfilled") {
        setLineChartData(buildLineChartData(lineChartResult.value));
      } else {
        showSnackbar(
          getRejectedMessage(
            lineChartResult,
            "Failed to load amount & count chart",
          ),
          "error",
        );
      }

      if (staffAnalyticsResult.status === "fulfilled") {
        setPieChartData(buildPieChartData(staffAnalyticsResult.value));
      } else {
        showSnackbar(
          getRejectedMessage(
            staffAnalyticsResult,
            "Failed to load staff chart",
          ),
          "error",
        );
      }

      if (supplierBarResult.status === "fulfilled") {
        setSupplierBarData(
          colorizeBarDatasets(supplierBarResult.value?.data?.supplierVsAmount),
        );
      } else {
        showSnackbar(
          getRejectedMessage(
            supplierBarResult,
            "Failed to load supplier amount chart",
          ),
          "error",
        );
      }

      if (customerBarResult.status === "fulfilled") {
        setCustomerBarData(
          colorizeBarDatasets(customerBarResult.value?.data?.customerVsAmount),
        );
      } else {
        showSnackbar(
          getRejectedMessage(
            customerBarResult,
            "Failed to load customer amount chart",
          ),
          "error",
        );
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

  const handleLineChartApplyFilters = async () => {
    try {
      const payload = {
        supplierIds: lineChartFilters.suppliers.map((s) => s.id),
        customerIds: lineChartFilters.customers.map((c) => c.id),
        fromDate: lineChartFilters.fromDate,
        toDate: lineChartFilters.toDate,
      };

      const result = await getAmountAndCountVsMonth(payload);
      setLineChartData(buildLineChartData(result));
      setLineChartRevision((prev) => prev + 1);
    } catch (error) {
      showSnackbar(error.message || "failed to load data", "error");
    }
  };

  const handlePieChartApplyFilters = async () => {
    try {
      const payload = {
        fromDate: pieChartFilters.fromDate,
        toDate: pieChartFilters.toDate,
      };

      const result = await getStaffAnalytics(payload);
      setPieChartData(buildPieChartData(result));
      setPieChartRevision((prev) => prev + 1);
    } catch (error) {
      showSnackbar(error.message || "failed to load data", "error");
    }
  };

  const handleSupplierBarApplyFilters = async () => {
    try {
      const payload = {
        supplierIds: supplierBarFilters.suppliers.map((s) => s.id),
        fromDate: supplierBarFilters.fromDate,
        toDate: supplierBarFilters.toDate,
      };

      const result = await getSupplierVsAmount(payload);
      setSupplierBarData(colorizeBarDatasets(result?.data?.supplierVsAmount));
      setSupplierBarRevision((prev) => prev + 1);
    } catch (error) {
      showSnackbar(error.message || "failed to load data", "error");
    }
  };

  const handleCustomerBarApplyFilters = async () => {
    try {
      const payload = {
        customerIds: customerBarFilters.customers.map((c) => c.id),
        fromDate: customerBarFilters.fromDate,
        toDate: customerBarFilters.toDate,
      };

      const result = await getCustomerVsAmount(payload);
      setCustomerBarData(colorizeBarDatasets(result?.data?.customerVsAmount));
      setCustomerBarRevision((prev) => prev + 1);
    } catch (error) {
      showSnackbar(error.message || "failed to load data", "error");
    }
  };

  const buildBarOptions = (xAxisTitle) => ({
    responsive: true,
    maintainAspectRatio: false,
    interaction: {
      mode: "index",
      intersect: false,
    },
    plugins: {
      legend: {
        position: "top",
        align: "start",
        labels: {
          usePointStyle: true,
          pointStyle: "circle",
          boxWidth: 8,
          boxHeight: 8,
        },
      },
    },
    scales: {
      x: {
        title: {
          display: true,
          text: xAxisTitle,
        },
        grid: {
          display: false,
        },
      },
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: "Amount (₹)",
        },
      },
    },
  });

  const supplierBarOptions = buildBarOptions("Supplier");
  const customerBarOptions = buildBarOptions("Customer");

  const lineChartOptions = {
    responsive: true,

    maintainAspectRatio: false,

    interaction: {
      mode: "index",
      intersect: false,
    },

    plugins: {
      legend: {
        position: "top",
        labels: {
          usePointStyle: true,
          pointStyle: "circle",
          boxWidth: 8,
          boxHeight: 8,
        },
      },
    },

    scales: {
      x: {
        grid: {
          display: false,
        },
      },

      amountAxis: {
        type: "linear",

        position: "left",

        border: {
          display: true,
        },

        title: {
          display: true,
          text: "Amount (₹)",
        },

        grid: {
          display: true,
        },
      },

      countAxis: {
        type: "linear",

        position: "right",

        border: {
          display: true,
        },

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

  const pieOptions = {
    responsive: true,
    maintainAspectRatio: false,
    cutout: "65%",
    plugins: {
      legend: {
        position: "bottom",
        labels: {
          usePointStyle: true,
          pointStyle: "circle",
          boxWidth: 8,
          boxHeight: 8,
        },
      },
      tooltip: {
        callbacks: {
          label: (context) => {
            const count = Number(context.parsed || 0);
            const total = getPieSliceTotal(context.dataset);
            const percentage = total
              ? ((count / total) * 100).toFixed(1)
              : "0.0";
            return `${context.label}: ${count} (${percentage}%)`;
          },
        },
      },
    },
  };

  return (
    <div className="h-full flex flex-col text-gray-500">
      <div className="flex-1 min-h-0 overflow-y-auto py-4">
        <div className="flex flex-col gap-4 px-1">
          <Card sx={{ boxShadow: "0 0 10px rgba(0, 0, 0, 0.14)" }}>
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
                      onClick={handleLineChartApplyFilters}
                      sx={{ height: "40px" }}
                    >
                      Apply Filter
                    </Button>
                  </Grid>
                </Grid>
              </Box>

              {lineChartData && (
                <Box>
                  <LineChart
                    key={lineChartRevision}
                    data={lineChartData}
                    options={lineChartOptions}
                  />
                </Box>
              )}
            </CardContent>
          </Card>
          <Card sx={{ boxShadow: "0 0 14px rgba(0, 0, 0, 0.12)" }}>
            <CardContent>
              <Typography variant="h5" gutterBottom>
                Count vs Staff
              </Typography>

              <Box mb={4}>
                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, md: 2 }}>
                    <CustomDatePicker
                      label="From Date"
                      value={pieChartFilters.fromDate}
                      onChange={(value) =>
                        onFilterChange(setPieChartFilters, "fromDate", value)
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <CustomDatePicker
                      label="To Date"
                      value={pieChartFilters.toDate}
                      onChange={(value) =>
                        onFilterChange(setPieChartFilters, "toDate", value)
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <Button
                      fullWidth
                      variant="contained"
                      onClick={handlePieChartApplyFilters}
                      sx={{ height: "40px" }}
                    >
                      Apply Filter
                    </Button>
                  </Grid>
                </Grid>
              </Box>

              {pieChartData.supplierCountVsStaff && (
                <Grid container spacing={3}>
                  {pieChartData.supplierCountVsStaff && (
                    <Grid size={{ xs: 12, md: 4 }}>
                      <Typography
                        variant="subtitle1"
                        align="center"
                        gutterBottom
                      >
                        Supplier Count vs Staff
                      </Typography>

                      <Box>
                        <PieChart
                          key={`supplier-${pieChartRevision}`}
                          data={pieChartData.supplierCountVsStaff}
                          options={pieOptions}
                        />
                      </Box>
                    </Grid>
                  )}

                  {pieChartData.customerCountVsStaff && (
                    <Grid size={{ xs: 12, md: 4 }}>
                      <Typography
                        variant="subtitle1"
                        align="center"
                        gutterBottom
                      >
                        Customer Count vs Staff
                      </Typography>

                      <Box>
                        <PieChart
                          key={`customer-${pieChartRevision}`}
                          data={pieChartData.customerCountVsStaff}
                          options={pieOptions}
                        />
                      </Box>
                    </Grid>
                  )}

                  {pieChartData.suppierAndCustomerCountVsStaff && (
                    <Grid size={{ xs: 12, md: 4 }}>
                      <Typography
                        variant="subtitle1"
                        align="center"
                        gutterBottom
                      >
                        Supplier + Customer Count vs Staff
                      </Typography>

                      <Box>
                        <PieChart
                          key={`combined-${pieChartRevision}`}
                          data={pieChartData.suppierAndCustomerCountVsStaff}
                          options={pieOptions}
                        />
                      </Box>
                    </Grid>
                  )}
                </Grid>
              )}
            </CardContent>
          </Card>

          <Card sx={{ boxShadow: "0 0 14px rgba(0, 0, 0, 0.12)" }}>
            <CardContent>
              <Typography variant="h5" gutterBottom>
                Supplier vs Amount
              </Typography>

              <Box mb={4}>
                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, md: 4 }}>
                    <GenericMultiAutocomplete
                      label="Suppliers"
                      options={allSuppliers}
                      value={supplierBarFilters.suppliers}
                      onChange={(value) =>
                        onFilterChange(
                          setSupplierBarFilters,
                          "suppliers",
                          value,
                        )
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <CustomDatePicker
                      label="From Date"
                      value={supplierBarFilters.fromDate}
                      onChange={(value) =>
                        onFilterChange(setSupplierBarFilters, "fromDate", value)
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <CustomDatePicker
                      label="To Date"
                      value={supplierBarFilters.toDate}
                      onChange={(value) =>
                        onFilterChange(setSupplierBarFilters, "toDate", value)
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <Button
                      fullWidth
                      variant="contained"
                      onClick={handleSupplierBarApplyFilters}
                      sx={{ height: "40px" }}
                    >
                      Apply Filter
                    </Button>
                  </Grid>
                </Grid>
              </Box>

              {supplierBarData && (
                <Box>
                  <BarChart
                    key={supplierBarRevision}
                    data={supplierBarData}
                    options={supplierBarOptions}
                  />
                </Box>
              )}
            </CardContent>
          </Card>

          <Card sx={{ boxShadow: "0 0 14px rgba(0, 0, 0, 0.12)" }}>
            <CardContent>
              <Typography variant="h5" gutterBottom>
                Customer vs Amount
              </Typography>

              <Box mb={4}>
                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, md: 4 }}>
                    <GenericMultiAutocomplete
                      label="Customers"
                      options={allCustomers}
                      value={customerBarFilters.customers}
                      onChange={(value) =>
                        onFilterChange(
                          setCustomerBarFilters,
                          "customers",
                          value,
                        )
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <CustomDatePicker
                      label="From Date"
                      value={customerBarFilters.fromDate}
                      onChange={(value) =>
                        onFilterChange(setCustomerBarFilters, "fromDate", value)
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <CustomDatePicker
                      label="To Date"
                      value={customerBarFilters.toDate}
                      onChange={(value) =>
                        onFilterChange(setCustomerBarFilters, "toDate", value)
                      }
                    />
                  </Grid>

                  <Grid size={{ xs: 12, md: 2 }}>
                    <Button
                      fullWidth
                      variant="contained"
                      onClick={handleCustomerBarApplyFilters}
                      sx={{ height: "40px" }}
                    >
                      Apply Filter
                    </Button>
                  </Grid>
                </Grid>
              </Box>

              {customerBarData && (
                <Box>
                  <BarChart
                    key={customerBarRevision}
                    data={customerBarData}
                    options={customerBarOptions}
                  />
                </Box>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default Reports;
