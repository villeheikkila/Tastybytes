import { useLayoutEffect, useState } from "react";

export const useDimensions = () => {
  const [dimensions, setDimensions] = useState(getDimensions());

  useLayoutEffect(() => {
    const handleResize = () => setDimensions(getDimensions());
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  return dimensions;
};

const getDimensions = () => {
  const { innerWidth: width, innerHeight: height } = window;
  return {
    width,
    height,
  };
};
