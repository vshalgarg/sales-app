export const handleApiError = (error) => {
  if (error?.response) {
    // API responded with a status code != 2xx
    const { data, status } = error.response;
    if (status === 401) {
      return "";
    }
    return data?.message || `Server error (${status})`;
    
  }
  if (error?.request) {
    // Request made but no response received
    return 'Network error. Please check your connection.';
  }

  // Something else (like manual throw, logical error)
  return error?.message || 'Something went wrong.';
};

export const checkLogicalError = (data, fallbackMessage = 'Action failed') => {
  if (data?.code) {
    const errorMessage = data.message || fallbackMessage;
    throw new Error(errorMessage);
  }

  return data;
};