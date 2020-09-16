import React from "react";
import styled from "styled-components";
import { ReactComponent as MailEnvelope } from "../assets/mail.svg";

const CheckInbox = () => {
  return (
    <Container>
      <Content>
        <MailEnvelope fill="#fff" width="80px" height="80px" />
        <Header>Check your inbox</Header>
        <p>
          We sent you an activation link. Make sure to check your spam folder
          too.
        </p>
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

const Header = styled.h1`
  margin: 0;
  padding-bottom: 10px;
`;

export default CheckInbox;
