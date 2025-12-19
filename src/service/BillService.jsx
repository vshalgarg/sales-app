import api from "../api/api";

export const addBill = async (billData) => {
  try {
    const response = await api.post("/bill/entry/add", billData);
    return response.data;
  } catch (error) {
    console.error("Error creating user:", error);
    throw error;
  }
};

export const getBillHistory = async () => {
  try {
    const response = await api.get(`/bill/entries/get`);
    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};

// api.js already has axios instance configured
export const updateBillApi = async (billNumber, updates) => {
  try {
    const response = await api.patch(
      `/bill/entry/update/${billNumber}`,
      updates
    );
    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const searchBillHistory = async (data, page, rowsPerPage) => {
  const { fromDate, toDate, supplierName, customerName } = data;
  const size = rowsPerPage;
  try {
    const response = await api.get(`/bill/entries/search`, {
      params: {
        fromDate,
        toDate,
        supplierName,
        customerName,
        page,
        size,
      },
    });
console.log("search data:", JSON.stringify(response.data));

    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const searchTransports = async (query) => {
  if (!query || query.trim().length < 1) {
    return [];
  }

  try {
    const response = await api.get("/transports/search", {
      params: { query: query.trim() }
    });
    console.log("Transport search response:", response.data);
    return response.data || [];
  } catch (error) {
    console.error("Transport search failed:", error);
    return [];
  }
};
