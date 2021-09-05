import React from "react";

export const ButtonLink: React.FC<
  React.HTMLAttributes<HTMLButtonElement> & {
    href: string;
  }
> = ({ href, ...rest }) => {
  return (
    <a href={href}>
      <button {...rest} />
    </a>
  );
};
