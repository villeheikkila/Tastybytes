import React, { createContext, FC, useEffect, useRef, useState } from "react";

export const PortalProvider: FC = ({ children }) => {
  const portalRef = useRef<HTMLDivElement>(null);
  const [context, setContext] = useState<HTMLDivElement | null>(null);

  useEffect(() => {
    setContext(portalRef.current);
  }, []);

  return (
    <div style={{ zIndex: 0 }}>
      <PortalNodeContext.Provider value={context}>
        {children}
      </PortalNodeContext.Provider>
      <div ref={portalRef} />
    </div>
  );
};

type PortalNode = Element | null;

export const PortalNodeContext = createContext<PortalNode>(null);
