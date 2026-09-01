import React, { createContext, useContext, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSnackbar } from './SnackbarContext';
const AuthContext = createContext();
export const AuthProvider = ({ children }) => {
  const navigate = useNavigate();
  const {showSnackbar}=useSnackbar();
  const [auth, setAuth] = useState(() => {
    const token = localStorage.getItem('token');
    const role = JSON.parse(localStorage.getItem('role') || '[]');
    const userId = localStorage.getItem('userId');
    const username = localStorage.getItem('username');

    return token && role.length > 0
      ? {
          token,
          role,
          userId,
          username
        }
      : null;
  });

  useEffect(() => {
    const onAppLogout = (event) => {
      // event.detail has the payload
      console.log('Received logout event', event.detail);
      // Clear local storage and in-memory auth state
      localStorage.clear();
      setAuth(null);
      // Navigate using React Router (SPA navigation)
      navigate('/', { replace: true });
      // Optionally show a toast/snackbar: "Session expired"
      showSnackbar("Session expired! login again","error");
    };

    // Register listener
    window.addEventListener('app:logout', onAppLogout);

    // Clean up listener when provider unmounts
    return () => {
      window.removeEventListener('app:logout', onAppLogout);
    };
  }, [navigate]);

  const login = ({
    token,
    role,
    userId,
    username
  }) => {
    localStorage.setItem('token', token);
    localStorage.setItem('role', JSON.stringify(role));
    localStorage.setItem('userId', userId);
    localStorage.setItem('username', String(username));
    

    setAuth({
      token,
      role,
      userId,
      username,
    
    });
  };

  const logout = () => {
    localStorage.clear();
    setAuth({
      token: null,
      role: null,
      userId: null,
      username:null
    });
  };

  return (
    <AuthContext.Provider value={{ auth, login, logout, setAuth }}>{children}</AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);