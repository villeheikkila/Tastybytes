import React, { ComponentType, ReactNode } from "react";
import { useStrictContext } from ".";
import { ModalContext } from "../providers/ModalProvider";

export function useModal<T>(container: ComponentType<T>) {
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
