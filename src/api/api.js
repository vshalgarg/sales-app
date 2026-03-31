// api.js
import axios from "axios";
const BASE_URL = import.meta.env.VITE_API_BASE_URL;
const api = axios.create({
  baseURL: BASE_URL
});

let loaderInstance;
export const setLoader = (loader) => {
  loaderInstance = loader;
};

api.interceptors.request.use((config) => {
   loaderInstance?.startLoading();
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => {
    loaderInstance?.stopLoading();
    return response;
  },
  async (error) => {
   loaderInstance?.stopLoading();
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
