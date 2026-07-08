import { useCallback, useEffect, useRef, useState } from "react";

export function useModalSectionNav(sectionIds) {
  const [activeSection, setActiveSection] = useState(sectionIds[0] ?? "");
  const scrollContainerRef = useRef(null);
  const sectionRefs = useRef({});

  const setSectionRef = useCallback(
    (id) => (node) => {
      sectionRefs.current[id] = node;
    },
    [],
  );

  const scrollToSection = useCallback((id) => {
    const container = scrollContainerRef.current;
    const section = sectionRefs.current[id];
    if (!container || !section) return;

    container.scrollTo({
      top: Math.max(0, section.offsetTop - container.offsetTop - 8),
      behavior: "smooth",
    });
    setActiveSection(id);
  }, []);

  useEffect(() => {
    setActiveSection((prev) =>
      sectionIds.includes(prev) ? prev : sectionIds[0] ?? "",
    );
  }, [sectionIds]);

  useEffect(() => {
    const container = scrollContainerRef.current;
    if (!container || !sectionIds.length) return;

    const updateActiveSection = () => {
      const { scrollTop, clientHeight, scrollHeight } = container;
      const atBottom = scrollHeight - scrollTop - clientHeight < 8;

      if (atBottom) {
        setActiveSection(sectionIds[sectionIds.length - 1]);
        return;
      }

      const containerTop = container.getBoundingClientRect().top;
      const anchor = containerTop + 48;
      let currentId = sectionIds[0];

      for (const id of sectionIds) {
        const section = sectionRefs.current[id];
        if (!section) continue;

        const { top } = section.getBoundingClientRect();
        if (top <= anchor) {
          currentId = id;
        }
      }

      setActiveSection(currentId);
    };

    updateActiveSection();
    container.addEventListener("scroll", updateActiveSection, { passive: true });
    window.addEventListener("resize", updateActiveSection);

    return () => {
      container.removeEventListener("scroll", updateActiveSection);
      window.removeEventListener("resize", updateActiveSection);
    };
  }, [sectionIds]);

  return {
    activeSection,
    scrollToSection,
    scrollContainerRef,
    setSectionRef,
  };
}
