// api.js
import axios from "axios";

const api = axios.create({
  baseURL: "http://192.168.1.100:8087/csm/api/v1",
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
   
export default api;
