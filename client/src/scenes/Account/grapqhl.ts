import { gql } from "@apollo/client";

export const CURRENT_ACCOUNT = gql`
  query CurrentAccount {
    currentAccount {
      username
      email
      avatarUri
    }
  }
`;

export const LOG_OUT = gql`
  query LogOut {
    logOut
  }
`;

export const UPDATE_AVATAR = gql`
  mutation UploadProfilePicture($picture: Upload!) {
    uploadProfilePicture(picture: $picture) {
      filename
      avatarUri
    }
  }
`;
