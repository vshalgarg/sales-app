// api.js
import axios from "axios";
const BASE_URL = import.meta.env.VITE_API_BASE_URL;
const api = axios.create({
  baseURL: BASE_URL
});
  
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => {
    console.log(
      ' [Axios Response]',
      response.status,
      `${response.config.baseURL}${response.config.url}`
    );
    return response;
  },
  async (error) => {
    const status = error?.response?.status;
    if (status === 401) {
      console.warn(' Token expired or unauthorized. Logging out...');
      window.dispatchEvent(
        new CustomEvent('app:logout', {
          detail: { reason: 'unauthorized', status: 401, message: 'Session expired' },
        })
      );
    }
    return Promise.reject(error);
  }
);
   
export default api;
