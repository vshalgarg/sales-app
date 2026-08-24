import React from "react";

const FormFooter = ({
  children,
  sticky = true,
  background = "bg-gray-50",
  align = "end", // start | center | end | between
}) => {
  const alignmentClasses = {
    start: "md:justify-start",
    center: "md:justify-center",
    end: "md:justify-end",
    between: "md:justify-between",
  };

  return (
    <div
      className={`
        p-4 border-t ${background}
        ${sticky ? "sticky bottom-0 z-20" : ""}
        flex flex-col gap-2
        md:flex-row md:gap-3
        ${alignmentClasses[align]}
      `}
    >
      {children}
    </div>
  );
};

export default FormFooter;