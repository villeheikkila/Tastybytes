import React from "react";
import { useQuery, useLazyQuery } from "@apollo/client";
import Card from "../../components/Card";
import Header from "../../components/Header";
import { CurrentAccount } from "../../generated/CurrentAccount";
import { LOG_OUT, CURRENT_ACCOUNT } from "./grapqhl";
import Button from "../../components/Button";
import Text from "../../components/Text";
import UploadFile from "../../components/UploadImage";

const Account = () => {
  const { data, loading } = useQuery<CurrentAccount>(CURRENT_ACCOUNT);

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
        <Text>Username: {username}</Text>
        <Text>Emai: {email}</Text>
        <Button onClick={() => logOut()}>Log Out</Button>
        <UploadFile />
      </Card>
    </div>
  );
};

export default Account;
