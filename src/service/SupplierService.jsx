import api from "../api/api";

export const saveSupplier = async (supplierData) => {
  try {
    const response = await api.post(`/supplier/add`, supplierData);
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const getSuppliers = async (page = 1, size = 8) => {
  try {
    const response = await api.get(`/suppliers/get`, {
      params: {
        page,
        size,
      },
    });
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const deleteSupplier = async (code) => {
  try {
    const response = await api.put(`/supplier/delete`, { code });
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const searchSuppliers = async (keyword) => {
  try {
    console.log("serach api called")
    const response = await api.get(`/suppliers/search`, {
      params: { keyword },
    });
    console.log("resp",response.data)
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};
