import React from "react";
import styled from "styled-components";
import Button from "../../components/Button";
import Card from "../../components/Card";
import Container from "../../components/Container";
import Dropzone from "../../components/Dropzone";
import Header from "../../components/Header";
import Text from "../../components/Text";
import {
  useCurrentAccountQuery,
  useLogOutLazyQuery,
  useUploadProfilePictureMutation,
} from "./queries.hooks";

const Account = () => {
  const { data, loading } = useCurrentAccountQuery();

  const [mutate] = useUploadProfilePictureMutation({
    refetchQueries: ["CurrentAccount"],
  });

  const onUpload = (picture: any) => {
    mutate({ variables: { picture } });
  };

  const [logOut] = useLogOutLazyQuery({
    onCompleted: async () => {
      window.location.reload();
    },
  });

  if (loading || !data) return null;

  const { username, email } = data.currentAccount;

  return (
    <div>
      <Header>Account</Header>
      <Card>
        <Container y centered>
          <Dropzone onUpload={onUpload}>
            {data.currentAccount.avatarUri && (
              <Avatar src={data.currentAccount.avatarUri}></Avatar>
            )}
          </Dropzone>
        </Container>
        <Text>Username: {username}</Text>
        <Text>Emai: {email}</Text>
        <Button onClick={() => logOut()}>Log Out</Button>
      </Card>
    </div>
  );
};

const Avatar = styled.img`
  border-radius: 50%;
  width: 200px;
  height: 200px;
`;

export default Account;
