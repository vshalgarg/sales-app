import {logicalError} from "../utils/errorHandler"
export const loginUser = async (username, password) => {
  try {
    const response = await fetch("http://localhost:8081/csm/api/v1/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username, password }), // ✅ match backend key
    });

    const data = await response.json();
    const data1=logicalError(data)

    if (!response.ok) {
      throw new Error(data.message || "Login failed");
    }

    return data1;
  } catch (err) {
    throw err;
  }
};
