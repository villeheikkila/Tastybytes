import { styled } from "~/stitches.config";

export const Stars = ({ rating }: { rating: number }) => {
  const fullStars = Math.floor(rating / 2);
  const halfStar = rating % 2 !== 0;
  const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
  return (
    <div>
      {Array.from({ length: fullStars }, (_, i) => (
        <Star type="filled" key={`filled-${i}`} />
      ))}
      {halfStar && <Star type="half" />}
      {Array.from({ length: emptyStars }, (_, i) => (
        <Star type="empty" key={`empty-${i}`} />
      ))}
    </div>
  );
};

const StarIcon = styled("img", {
  width: "24px",
});

export const Star = ({ type }: { type: "empty" | "filled" | "half" }) => {
  return (
    <StarIcon
      src={`/assets/${
        type === "half" ? "half-" : type === "filled" ? "solid-" : ""
      }star.svg`}
    />
  );
};
