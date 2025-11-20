import { useState, useRef, useEffect } from "react";

export default function UniversalSearch({
  placeholder = "Search...",
  query,
  setQuery,
  searchFn,
  onResult,
}) {
  const [suggestions, setSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const searchRef = useRef(null);

  useEffect(() => {
    const handler = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  const handleChange = async (e) => {
    const value = e.target.value;
    setQuery(value);

    if (!value.trim()) {
      setSuggestions([]);
      onResult([], "");
      return;
    }

    if (value.length > 1) {
      try {
        const results = await searchFn(value);
        const names = results.map(
          (item) => item.name || item.supplierName || item.customerName
        );
        setSuggestions(names);
        setIsDropdownOpen(true);
      } catch (err) {
        console.error(err);
        setSuggestions([]);
      }
    } else {
      setSuggestions([]);
    }
  };

  const handleKeyDown = async (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!query.trim()) return;

      try {
        const results = await searchFn(query.trim());
        onResult(results, query.trim()); // <-- FIXED
        setIsDropdownOpen(false);
        setSuggestions([]);
      } catch (err) {
        console.error(err);
      }
    }
  };

  const handleSuggestionClick = async (name) => {
    setQuery(name);
    setIsDropdownOpen(false);

    try {
      const results = await searchFn(name);
      const selected = results.find(
        (item) =>
          item.name === name ||
          item.supplierName === name ||
          item.customerName === name
      );

      onResult(selected ? [selected] : [], name); // <-- FIXED
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div ref={searchRef} className="relative w-1/2">
      <input
        type="text"
        placeholder={placeholder}
        value={query}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        onFocus={() => setIsDropdownOpen(true)}
        className="w-full border rounded-lg p-2 bg-white dark:bg-gray-800"
      />

      {isDropdownOpen && suggestions.length > 0 && (
        <ul className="absolute bg-white dark:bg-gray-800 border rounded-lg shadow w-full mt-1 z-10">
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
