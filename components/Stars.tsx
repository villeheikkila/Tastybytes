import Image from "next/image";

export const Stars = ({ rating }: { rating: number }) => {
  const fullStars = Math.floor(rating);
  const halfStar = rating - fullStars > 0;
  return (
    <>
      {Array.from({ length: 5 }).map((_, i) => {
        return (
          <Image
            key={i}
            src={`/icons/${
              fullStars >= i
                ? "star"
                : halfStar && fullStars + 1 === i
                ? "half-star"
                : "empty-star"
            }.svg`}
            height={30}
            width={30}
          />
        );
      })}
    </>
  );
};
