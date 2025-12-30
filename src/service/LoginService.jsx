// src/service/LoginService.js
import api from "../api/api";

export const loginUser = async (username, password) => {
  try {
    const { data } = await api.post("/login", { username, password });
    console.log("chhhhhhhh")
    return data;
  } catch (err) {
    const message =
      err.response?.data?.message ||
      err.response?.data?.error ||
      err.message ||
      "Login failed. Please try again.";

    throw new Error(message);
  }
};