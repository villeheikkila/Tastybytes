import Link from "next/link";
import React from "react";

export function ErrorOccurred() {
  return (
    <div>
      <h2>Something Went Wrong</h2>
      <p>
        We're not sure what happened there; how embarrassing! Please try again
        later, or if this keeps happening then let us know.
      </p>
      <p>
        <Link href="/">
          <a>Go to the homepage</a>
        </Link>
      </p>
    </div>
  );
}
