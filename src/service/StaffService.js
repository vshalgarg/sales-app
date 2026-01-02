import api from "../api/api";

export const saveStaff = async (staffData) => {
  try {
    const response = await api.post(`/staff/add`, staffData);
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const getStaffs = async (page = 1, size = 5) => {
  try {
    const response = await api.get(`/staffs/get`, {
      params: {
        page,
        size,
      },
    });
    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const searchStaffs = async (keyword,page=0,size=10) => {
  try {
    const response = await api.get(`/staffs/search`, { 
      params: {
         keyword,
         page,
         size

        } });
    return response.data; 
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const getAllActiveStaffs = async () => {
  try {
    const response = await api.get(`/staffs/get/all`);
    return response.data;
  } catch (error) {
    console.error("Error fetching all active staffs:", error);
    throw error.response?.data || error.message || "Failed to load active staffs";
  }
};

export const deleteStaff = async (staffId) => {
  try {
    const response = await api.put(`/staff/delete`, { staffId });
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};
