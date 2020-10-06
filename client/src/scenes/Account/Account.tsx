import { faCog } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import React from "react";
import { useHistory } from "react-router-dom";
import styled from "styled-components";
import { useModal } from "../../common";
import {
  Button,
  Card,
  Container,
  Dropzone,
  Header,
  Sheet,
  Typography,
} from "../../components";

import {
  useCurrentAccountQuery,
  useLogOutLazyQuery,
  useUploadProfilePictureMutation,
} from "./queries.hooks";

const Account = () => {
  const { data, loading } = useCurrentAccountQuery();
  const history = useHistory();

  const modal = useModal(Sheet);
  const [mutate] = useUploadProfilePictureMutation({
    refetchQueries: ["CurrentAccount"],
  });

  const onUpload = (picture: any) => {
    mutate({ variables: { picture } });
  };

  const [logOut] = useLogOutLazyQuery({
    onCompleted: async () => {
      history.push("/");
      window.location.reload();
    },
  });

  if (loading || !data) return null;

  const { username, email } = data.currentAccount;

  return (
    <div>
      <HeaderRow>
        <div />
        <Header>Account</Header>
        <SettingsIcon
          icon={faCog}
          size="2x"
          onClick={() =>
            modal.open(
              <Card>
                <Container y centered>
                  <Dropzone onUpload={onUpload}>
                    {data.currentAccount.avatarUri && (
                      <Avatar src={data.currentAccount.avatarUri}></Avatar>
                    )}
                  </Dropzone>
                </Container>
                <Typography>Username: {username}</Typography>
                <Typography>Emai: {email}</Typography>
                <Button onClick={() => logOut()}>Log Out</Button>
              </Card>
            )
          }
        />
      </HeaderRow>
      <Card>
        <Container y centered>
          <Dropzone onUpload={onUpload}>
            {data.currentAccount.avatarUri && (
              <Avatar src={data.currentAccount.avatarUri}></Avatar>
            )}
          </Dropzone>
        </Container>
        <Typography>Username: {username}</Typography>
        <Typography>Emai: {email}</Typography>
        <Button onClick={() => logOut()}>Log Out</Button>
      </Card>
    </div>
  );
};

const HeaderRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
`;

const SettingsIcon = styled(FontAwesomeIcon)`
  :hover {
    path {
      fill: red;
    }
  }
`;

const Avatar = styled.img`
  border-radius: 50%;
  width: 200px;
  height: 200px;
`;

export default Account;
