import React, { FC, useCallback } from "react";
import { useDropzone } from "react-dropzone";

export const Dropzone: FC<{ onUpload: (picture: any) => void }> = ({
  children,
  onUpload,
}) => {
  const onDrop = useCallback(
    (acceptedFiles) => {
      const image = acceptedFiles[0];
      onUpload(image);
    },
    [onUpload]
  );

  const { getRootProps, getInputProps } = useDropzone({ onDrop });

  return (
    <div {...getRootProps()}>
      <input {...getInputProps()} />
      {children}
    </div>
  );
};
