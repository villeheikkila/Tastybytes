import { styled } from "~/stitches.config";

export const Stars = ({ rating }: { rating: number }) => {
  return (
    <div>
      {Array.from({ length: Math.floor(rating / 2) }, (_, i) => (
        <Star src="/assets/solid-star.svg" key={i} />
      ))}
      {rating % 2 !== 0 && <Star src="/assets/star-half.svg" />}
    </div>
  );
};

const Star = styled("img", {
  width: "24px",
});
