import api from "../api/api";

export const addCreditEntry = async (formData) => {
  try {
    const response = await api.post(`/credit/entry/add`, formData);
    return response.data;
  } catch (err) {
    throw err.response?.data || err;
  }
};

export const searchCreditHistory = async (
  data,
  supplierId,
  customerId,
  page,
  rowsPerPage
) => {
  const { fromDate, toDate } = data;
  const size = rowsPerPage;
  try {
    const response = await api.get(`/credit/entries/search`, {
      params: {
        fromDate,
        toDate,
        supplierId,
        customerId,
        page,
        size,
      },
    });
    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};
