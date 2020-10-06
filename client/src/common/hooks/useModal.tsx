import React, { ComponentType, ReactNode } from "react";
import { ModalContext } from "../providers/ModalProvider";
import useStrictContext from "./useStrictContext";

function useModal<T>(container: ComponentType<T>) {
  const dispatch = useStrictContext(ModalContext);

  return React.useMemo(
    () => ({
      open: (content: ReactNode) =>
        dispatch({ type: "open", payload: { content, container } }),
      close: () => dispatch({ type: "close" }),
    }),
    [dispatch]
  );
}

export default useModal;
