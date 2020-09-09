import React from "react";
import { useLazyQuery, gql } from "@apollo/client";

const Home = () => {
  const [logOut] = useLazyQuery(LOG_OUT, {
    onCompleted: async () => {
      window.location.reload();
    },
  });

  return (
    <div>
      <button onClick={() => logOut()}>Log Out</button>
    </div>
  );
};

const LOG_OUT = gql`
  query LogOut {
    logOut
  }
`;
export default Home;
