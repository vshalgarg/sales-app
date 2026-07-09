import { useCallback, useEffect, useRef, useState } from "react";

export function useModalSectionNav(sectionIds, { enabled = true } = {}) {
  const [activeSection, setActiveSection] = useState(sectionIds[0] ?? "");
  const sectionRefs = useRef({});
  const scrollContainerNodeRef = useRef(null);
  const [scrollContainer, setScrollContainer] = useState(null);

  const scrollContainerRef = useCallback((node) => {
    scrollContainerNodeRef.current = node;
    setScrollContainer(node);
  }, []);

  const setSectionRef = useCallback(
    (id) => (node) => {
      sectionRefs.current[id] = node;
    },
    [],
  );

  const scrollToSection = useCallback((id) => {
    const container = scrollContainerNodeRef.current;
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
    if (!enabled || !scrollContainer || !sectionIds.length) return;

    const updateActiveSection = () => {
      const { scrollTop, clientHeight, scrollHeight } = scrollContainer;
      const atBottom = scrollHeight - scrollTop - clientHeight < 8;

      if (atBottom) {
        setActiveSection(sectionIds[sectionIds.length - 1]);
        return;
      }

      const containerTop = scrollContainer.getBoundingClientRect().top;
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

    scrollContainer.addEventListener("scroll", updateActiveSection, {
      passive: true,
    });
    window.addEventListener("resize", updateActiveSection);

    const resizeObserver = new ResizeObserver(() => {
      updateActiveSection();
    });
    resizeObserver.observe(scrollContainer);

    sectionIds.forEach((id) => {
      const section = sectionRefs.current[id];
      if (section) resizeObserver.observe(section);
    });

    return () => {
      scrollContainer.removeEventListener("scroll", updateActiveSection);
      window.removeEventListener("resize", updateActiveSection);
      resizeObserver.disconnect();
    };
  }, [sectionIds, enabled, scrollContainer]);

  return {
    activeSection,
    scrollToSection,
    scrollContainerRef,
    setSectionRef,
  };
}
