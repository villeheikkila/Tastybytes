import React, { Context } from "react";

function useStrictContext<TValue>(contextNode: Context<TValue | null>) {
  const context = React.useContext(contextNode);

  if (context === null) {
    throw new Error(`Context Provider is missing`);
  }

  return context;
}

export default useStrictContext;
