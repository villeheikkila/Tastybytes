import { Typography } from '@material-ui/core';
import React, { useState } from 'react';
import { Bar, BarChart, Cell, XAxis } from 'recharts';

interface RatingChartProps {
    ratings: any;
    setRatingFilter: any;
}
export const RatingChart = ({ ratings, setRatingFilter }: RatingChartProps): JSX.Element => {
    const [activeIndex, setActiveIndex] = useState();
    const selectedRating = ratings[activeIndex] && ratings[activeIndex].value;
    setRatingFilter(selectedRating);

    const handleClick = (entry: any, index: any): void => {
        if (activeIndex === index) setActiveIndex(null);
        else setActiveIndex(index);
    };

    return (
        <>
            <Typography variant="h4">Ratings</Typography>
            <BarChart width={300} height={150} data={ratings}>
                <Bar dataKey="count" onClick={handleClick}>
                    {ratings.map((entry: any, index: any) => (
                        <Cell
                            cursor="pointer"
                            fill={index === activeIndex ? '#1976D2' : '#0097A7'}
                            key={`cell-${index}`}
                        />
                    ))}
                </Bar>
                <XAxis dataKey="value" />
            </BarChart>
        </>
    );
};
