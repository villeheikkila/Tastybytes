import { faStar, faStarHalfAlt } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

export const Stars = ({ rating }: { rating: number }) => {
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
