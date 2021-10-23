import { faStar } from "@fortawesome/free-solid-svg-icons/faStar";
import { faStarHalfAlt } from "@fortawesome/free-solid-svg-icons/faStarHalfAlt";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import React from "react";

export const StarSelector = ({ rating }: { rating: number }) => {
  return (
    <div>
      {Array.from({ length: Math.floor(rating / 2) }, (_, i) => (
        <FontAwesomeIcon
          icon={faStar}
          key={i}
          color="rgba(242, 204, 0, 1.00)"
        />
      ))}
      {rating % 2 !== 0 && (
        <FontAwesomeIcon icon={faStarHalfAlt} color="rgba(242, 204, 0, 1.00)" />
      )}
    </div>
  );
};
