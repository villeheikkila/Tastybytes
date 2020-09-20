import React from "react";
import { useParams } from "react-router-dom";
import { useMutation } from "@apollo/client";
import { VERIFY_EMAIL } from "./grapqh";
import styled from "styled-components";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import Heading from "../components/Heading";
import Text from "../components/Text";
import Spacer from "../components/Spacer";
import { faGlassCheers } from "@fortawesome/free-solid-svg-icons";
import theme from "../theme";
import Link from "../components/Link";

const VerifyAccount = () => {
  const { token } = useParams<{ token: string }>();
  const [verifyAccount, { error }] = useMutation(VERIFY_EMAIL);
  console.log("error: ", error);

  const onClick = async () => {
    try {
      const response = await verifyAccount({
        variables: {
          token,
        },
      });
      console.log(response);
    } catch (error) {
      console.error(error);
    }
  };

  onClick();
  return (
    <Container>
      <Content>{error ? onError() : onSuccess()}</Content>
    </Container>
  );
};

const onSuccess = () => (
  <>
    <FontAwesomeIcon
      color={theme.colors.white}
      icon={faGlassCheers}
      size="5x"
    />
    <Spacer y amount={20} />

    <Heading>Your account has been verified!</Heading>

    <Spacer y amount={10} />

    <Text>
      Please continue by <Link to="/">logging in</Link> with your new account.
    </Text>
  </>
);

const onError = () => (
  <Heading>The verification token is either expired or already used!</Heading>
);

const Container = styled.div`
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
`;

const Content = styled.div`
  display: flex;
  flex-direction: column;
  justify-items: center;
  align-items: center;
`;

export default VerifyAccount;
