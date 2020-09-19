/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: UploadProfilePicture
// ====================================================

export interface UploadProfilePicture_uploadProfilePicture {
  __typename: "Image";
  filename: string;
  avatarUri: string;
}

export interface UploadProfilePicture {
  uploadProfilePicture: UploadProfilePicture_uploadProfilePicture;
}

export interface UploadProfilePictureVariables {
  picture: GraphQL_Upload;
}
