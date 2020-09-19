import React from "react";
import { useQuery, useLazyQuery, useMutation } from "@apollo/client";
import Card from "../../components/Card";
import Header from "../../components/Header";
import { CurrentAccount } from "../../generated/CurrentAccount";
import { LOG_OUT, CURRENT_ACCOUNT, UPDATE_AVATAR } from "./grapqhl";
import Button from "../../components/Button";
import Text from "../../components/Text";
import styled from "styled-components";
import Container from "../../components/Container";
import Dropzone from "../../components/Dropzone";

const Account = () => {
  const { data, loading } = useQuery<CurrentAccount>(CURRENT_ACCOUNT);

  const [mutate] = useMutation(UPDATE_AVATAR, {
    refetchQueries: ["CurrentAccount"],
  });

  const onUpload = (picture: any) => {
    mutate({ variables: { picture } });
  };

  const [logOut] = useLazyQuery(LOG_OUT, {
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
            <Avatar src={data.currentAccount?.avatarUri}></Avatar>
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
