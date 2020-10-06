import { ComponentType, ReactNode, useMemo } from "react";
import { useStrictContext } from ".";
import { ModalContext } from "../providers/ModalProvider";

export function useModal<T>(container: ComponentType<T>) {
  const modal = useStrictContext(ModalContext);

  return useMemo(
    () => ({
      open: (content: ReactNode) =>
        modal({ type: "open", payload: { content, container } }),
      close: () => modal({ type: "close" }),
    }),
    [modal, container]
  );
}
