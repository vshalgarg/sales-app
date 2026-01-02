// api.js
import axios from "axios";

const api = axios.create({
  baseURL: environment.VITA_APP_BASE_URI
});
  
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
   
export default api;
