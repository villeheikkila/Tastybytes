import React, {
  ComponentType,
  createContext,
  FC,
  ReactNode,
  useContext,
  useReducer,
} from "react";
import { createPortal } from "react-dom";
import { PortalNodeContext } from "./PortalProvider";

export const ModalProvider: FC = ({ children }) => {
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
        {portalNode && Modal && createPortal(<Modal />, portalNode)}
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
  container: ComponentType<any> | null;
  content: ReactNode | null;
  isOpen: boolean;
}

type Action =
  | {
      type: "open";
      payload: {
        content: ReactNode;
        container: ComponentType<any>;
      };
    }
  | { type: "close" };

type Dispatch = (action: Action) => void;

export const ModalStateContext = createContext<State | null>(null);
export const ModalContext = createContext<Dispatch | null>(null);
