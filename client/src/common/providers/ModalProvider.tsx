import React, { FC, useContext, useReducer } from "react";
import ReactDOM from "react-dom";
import { PortalNodeContext } from "./PortalProvider";

const ModalProvider: FC = ({ children }) => {
  const portalNode = useContext(PortalNodeContext);

  const [state, dispatch] = useReducer((state: State, action: Action) => {
    switch (action.type) {
      case "open": {
        return { ...state, ...action.payload, isOpen: true };
      }
      case "close": {
        return { ...state, isOpen: false, content: null, container: null };
      }
    }
  }, defaultState);

  const Modal = state.container;

  return (
    <ModalStateContext.Provider value={state}>
      <ModalContext.Provider value={dispatch}>
        {children}
        {portalNode && Modal && ReactDOM.createPortal(<Modal />, portalNode)}
      </ModalContext.Provider>
    </ModalStateContext.Provider>
  );
};

const defaultState = {
  container: null,
  content: null,
  isOpen: false,
};

interface State {
  container: React.ComponentType<any> | null;
  content: React.ReactNode | null;
  isOpen: boolean;
}

type Action =
  | {
      type: "open";
      payload: {
        content: React.ReactNode;
        container: React.ComponentType<any>;
      };
    }
  | { type: "close" };

type Dispatch = (action: Action) => void;

export const ModalStateContext = React.createContext<State | null>(null);
export const ModalContext = React.createContext<Dispatch | null>(null);

export default ModalProvider;
