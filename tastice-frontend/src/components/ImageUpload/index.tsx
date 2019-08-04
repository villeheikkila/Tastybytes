import { Typography } from '@material-ui/core';
import { Image } from 'cloudinary-react';
import React, { useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { CLOUDINARY_CLOUD_NAME } from '../..';
import { uploadCloudinary } from '../../services/cloudinary';

interface ImageUploadProps {
    image: string;
    setImage: any;
}
export const ImageUpload = ({ image, setImage }: ImageUploadProps): JSX.Element | null => {
    const onDrop = useCallback(async acceptedFiles => {
        const publicId = await uploadCloudinary(acceptedFiles[0]);
        setImage(publicId);
    }, []);

    const { getRootProps, getInputProps } = useDropzone({ onDrop });

    return (
        <div {...getRootProps({ className: 'dropzone' })}>
            <input {...getInputProps()} />
            {!image ? (
                <Typography>Click here to add a new image!</Typography>
            ) : (
                <Image cloudName={CLOUDINARY_CLOUD_NAME} publicId={image} width="200" crop="thumb"></Image>
            )}
        </div>
    );
};
