import React, {
  useRef,
  useState,
  useEffect,
  useContext,
  useCallback,
} from "react";
import ReactDOM from "react-dom";
import styled, { keyframes } from "styled-components";

const Portal: React.FC<{ onClose: () => void }> = ({ onClose, children }) => {
  const portalNode = useContext(PortalNodeContext);
  const overlayRef = useRef<HTMLDivElement>(null);

  const onClickOutside = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    const isClickOutside = overlayRef.current?.isEqualNode(e.target as Node);
    if (!isClickOutside) {
      return;
    }
    onClose();
  };

  const closeOnEsc = useCallback(
    (event) => {
      if (event.keyCode === 27) {
        onClose();
      }
    },
    [onClose]
  );

  useEffect(() => {
    document.addEventListener("keydown", closeOnEsc, false);

    return () => {
      document.removeEventListener("keydown", closeOnEsc, false);
    };
  }, [closeOnEsc]);

  return portalNode
    ? ReactDOM.createPortal(
        <Container ref={overlayRef} onMouseDown={onClickOutside}>
          {children}
        </Container>,
        portalNode
      )
    : null;
};

const Container = styled.div`
  position: fixed;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100vw;
  height: 100vh;
  top: 0;
  left: 0;
  z-index: 10;
  background: rgba(0, 0, 0, 0.4);
`;

type PortalNode = Element | null;
export const PortalNodeContext = React.createContext<PortalNode>(null);

export const PortalProvider: React.FC = ({ children }) => {
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

export default Portal;
