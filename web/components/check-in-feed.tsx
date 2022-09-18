import { Block, Card } from "konsta/react";
import { useEffect, useRef, useState } from "react";
import { FetchCheckInsResult } from "../api/check-ins";
import { useInfinityScroll, useInView } from "../utils/hooks";
import { Stars } from "./stars";

export const CheckInsFeed = ({
  fetcher,
  initialCheckIns = [],
}: {
  fetcher: (page: number) => Promise<FetchCheckInsResult[]>;
  initialCheckIns?: FetchCheckInsResult[];
}) => {
  const [checkIns, ref] = useInfinityScroll(fetcher, initialCheckIns);

  return (
    <Block
      style={{
        height: "100vh",
      }}
    >
      {checkIns.map((checkIn) => (
        <Card
          key={checkIn.id}
          header={
            <div className="-mx-4 -my-2 h-48 p-4 flex items-end  font-bold bg-cover bg-center">
              {checkIn.products["sub-brands"].brands.companies.name}{" "}
              {checkIn.products["sub-brands"].brands.name}{" "}
              {checkIn.products["sub-brands"].name ?? ""}{" "}
              {checkIn.products.name}
            </div>
          }
          footer={
            <div className="flex justify-between">
              {checkIn.rating ? <Stars rating={checkIn.rating} /> : "Unrated"}
            </div>
          }
        >
          <div className="text-gray-500 mb-3">{checkIn.created_at}</div>
          <p>{checkIn.review}</p>
          <p>{checkIn.rating}</p>
        </Card>
      ))}
      <div ref={ref}>Loading...</div>
    </Block>
  );
};
