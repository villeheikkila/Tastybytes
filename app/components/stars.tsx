import { styled } from "~/stitches.config";

export const Stars = ({ rating }: { rating: number }) => {
  return (
    <div>
      {Array.from({ length: Math.floor(rating / 2) }, (_, i) => (
        <Star type="filled" />
      ))}
      {rating % 2 !== 0 && <Star type="half" />}
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
