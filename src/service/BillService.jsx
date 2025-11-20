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
    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};
