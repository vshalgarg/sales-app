import { useState, useRef, useEffect } from "react";


export default function UniversalSearch({
  placeholder = "Search...",
  query,
  setQuery,
  searchFn,
  onResult,
  searchOnType = true,
  minChars = 2,
  pageSize = 8,
  suggestionKey = "name",
   onClear
}) {
  const [suggestions, setSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const searchRef = useRef(null);
  const timeoutRef = useRef(null);

  useEffect(() => {
    const handler = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  // Debounced search function
  const debouncedSearch = async (searchTerm) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    return new Promise((resolve) => {
      timeoutRef.current = setTimeout(async () => {
        try {
          setIsLoading(true);
          const results = await searchFn(searchTerm, 0, pageSize);
          resolve(results);
        } catch (err) {
          console.error(err);
          resolve({ content: [], totalPages: 0 });
        } finally {
          setIsLoading(false);
        }
      }, 300);
    });
  };

  const handleChange = async (e) => {
      const value = e.target.value;
    setQuery(value);

    if (!value.trim()) {
      setSuggestions([]);
      setIsDropdownOpen(false);
      
      if (onClear) {
        onClear();
      }
      
      if (onResult) {
        onResult({ content: [], totalPages: 0 }, "");
      }
      
      return;
    }

    if (searchOnType && value.length >= minChars) {
      const response = await debouncedSearch(value);
      const results = response.content || response || [];
      
      // Extract suggestions based on suggestionKey
      const suggestionValues = results.map(item => 
        item[suggestionKey] || item.name || item.supplierName || item.customerName || ""
      ).filter(Boolean);
      
      setSuggestions(suggestionValues);
      setIsDropdownOpen(true);
      
      // Pass results to parent
      if (onResult) onResult(response, value);
    } else {
      setSuggestions([]);
    }
  };

  const handleKeyDown = async (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!query.trim()) {
        if (onResult) onResult({ content: [], totalPages: 0 }, "");
        setIsDropdownOpen(false);
        return;
      }

      try {
        setIsLoading(true);
        const response = await searchFn(query.trim(), 0, pageSize);
        if (onResult) onResult(response, query.trim());
        setIsDropdownOpen(false);
        setSuggestions([]);
      } catch (err) {
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleSuggestionClick = async (selectedName) => {
    setQuery(selectedName);
    setIsDropdownOpen(false);

    try {
      const response = await searchFn(selectedName, 0, pageSize);
      const results = response.content || response || [];
      const selected = results.find(item => 
        item[suggestionKey] === selectedName || 
        item.name === selectedName ||
        item.supplierName === selectedName ||
        item.customerName === selectedName
      );

      if (onResult) onResult(
        { content: selected ? [selected] : [], totalPages: 1 },
        selectedName
      );
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div ref={searchRef} className="relative w-1/2">
      <div className="relative">
        <input
          type="text"
          placeholder={placeholder}
          value={query}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          onFocus={() => setIsDropdownOpen(true)}
          className="w-full border rounded-lg p-2 bg-white dark:bg-gray-800 pr-10"
        />
        {isLoading && (
          <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
          </div>
        )}
      </div>

      {isDropdownOpen && suggestions.length > 0 && (
        <ul className="absolute bg-white dark:bg-gray-800 border rounded-lg shadow w-full mt-1 z-10 max-h-60 overflow-y-auto">
          {suggestions.map((name, index) => (
            <li
              key={index}
              className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 cursor-pointer"
              onClick={() => handleSuggestionClick(name)}
            >
              {name}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}