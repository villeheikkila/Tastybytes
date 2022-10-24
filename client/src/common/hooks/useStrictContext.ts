import React, { Context, useContext } from "react";

export function useStrictContext<TValue>(contextNode: Context<TValue | null>) {
  const context = useContext(contextNode);

  if (context === null) {
    throw new Error(`Context Provider is missing`);
  }

  return context;
}
