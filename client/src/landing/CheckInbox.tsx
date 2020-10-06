import { faEnvelope } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import React from "react";
import styled from "styled-components";
import { theme } from "../common";
import { Heading, Spacer, Typography } from "../components";

const CheckInbox = () => {
  return (
    <Container>
      <Content>
        <FontAwesomeIcon
          color={theme.colors.white}
          icon={faEnvelope}
          size="5x"
        />
        <Spacer y amount={20} />

        <Heading>Check your inbox</Heading>

        <Spacer y amount={10} />

        <Typography>
          We sent you an activation link. Make sure to check your spam folder
          too.
        </Typography>
      </Content>
    </Container>
  );
};

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

export default CheckInbox;
