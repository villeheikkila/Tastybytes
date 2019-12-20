import React from 'react';
import Lottie from 'react-lottie';
import animationData from './1301-round-cap-material-loading.json';

const options = {
    loop: true,
    autoplay: true,
    animationData,
    rendererSettings: {
        preserveAspectRatio: 'xMidYMid slice',
    },
};

export const Loading = (): JSX.Element => <Lottie options={options} height={200} width={200} />;
