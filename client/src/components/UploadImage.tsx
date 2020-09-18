import { gql, useMutation } from "@apollo/client";
import React, { useCallback } from "react";
import { useDropzone } from "react-dropzone";

const UploadFile = () => {
  const [mutate] = useMutation(SINGLE_UPLOAD);
  const onDrop = useCallback((acceptedFiles) => {
    console.log("acceptedFiles: ", acceptedFiles[0]);
    mutate({ variables: { picture: acceptedFiles[0] } });
  }, []);
  const { getRootProps, getInputProps, isDragActive } = useDropzone({ onDrop });

  return (
    <React.Fragment>
      <div {...getRootProps()}>
        <input {...getInputProps()} />
        {isDragActive ? (
          <p>Drop the files here ...</p>
        ) : (
          <p>Drag 'n' drop some files here, or click to select files</p>
        )}
      </div>
    </React.Fragment>
  );
};

const SINGLE_UPLOAD = gql`
  mutation($picture: Upload!) {
    uploadProfilePicture(picture: $picture)
  }
`;

export default UploadFile;
