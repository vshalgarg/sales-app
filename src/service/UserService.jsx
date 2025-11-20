import api from "../api/api"; 

export const createUser = async (userData) => {
  try {
    const response = await api.post("/user/add", userData);
    return response.data;
  } catch (error) {
    console.error("Error creating user:", error);
    throw error;
  }
};

// Get all users
export const getUsers = async () => {
  try {
    const response = await api.get("/users/get");
    return response.data.users;
  } catch (error) {
    console.error("Error getting users:", error);
    throw error;
  }
};

// Delete user by id or username (depending on backend API)
export const deleteUser = async (username) => {
  try {
    // const userId = localStorage.getItem("userId");
    const userId = 101;
    const response = await api.post(`/user/delete`,{userId,username});
    return response.data;
  } catch (error) {
    console.error("Error deleting user:", error);
    throw error;
  }
};

export const searchUsers = async (keyword) => {
  const res = await api.get(`/users/search`, { params: { keyword } });
  return res.data; // response from your backend (List<String> or DTO)
};


