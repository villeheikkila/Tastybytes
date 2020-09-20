import React, { FC } from 'react';
import { DOMAIN } from '../../config';

const VerifyAccountTemplate: FC<{ token: string }> = ({
  token
}): JSX.Element => (
  <html lang="en-us">
    <body>
      <h1>Tastekeeper</h1>
      <p>
        Verify your account for the Tastekeeper app by clicking the link below
      </p>
      <a href={`${DOMAIN}/verify-account/${token}`}>Verify Account</a>
    </body>
  </html>
);

export default VerifyAccountTemplate;
