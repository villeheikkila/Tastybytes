import { Box, makeStyles, Typography } from '@material-ui/core';
import { Image } from 'cloudinary-react';
import React from 'react';
import { CLOUDINARY_CLOUD_NAME } from '../..';

const useStyles = makeStyles(() => ({
    box: (props: any) => ({
        width: 200,
        height: 100,
        backgroundColor: props.color,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
    }),
    text: {
        fontWeight: 800,
    },
}));

interface BoxImageProps {
    text: string;
    image: string;
    color: string;
}

export const BoxImage = ({ image, text, color }: BoxImageProps): JSX.Element => {
    const classes = useStyles({ color });

    return (
        <>
            {image ? (
                <Image cloudName={CLOUDINARY_CLOUD_NAME} publicId={image} width="200" crop="thumb" />
            ) : (
                <Box className={classes.box}>
                    <Typography variant="h4" className={classes.text}>
                        {text.toUpperCase()}
                    </Typography>
                </Box>
            )}
        </>
    );
};
