import React, { FC } from 'react';
import { DOMAIN } from '../../config';

const VerifyAccountTemplate: FC<{ token: string }> = ({
  token
}): JSX.Element => (
  <html lang="en-us">
    <body>
      <h1>Tastekeeper</h1>
      <p>Verify account for Tastekeeper app by clicking the link below</p>
      <a href={`${DOMAIN}/reset-password/${token}`}>Verify Account</a>
    </body>
  </html>
);

export default VerifyAccountTemplate;
