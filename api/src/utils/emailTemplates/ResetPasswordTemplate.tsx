import React, { FC } from 'react';
import config from '../../config';

const ResetPasswordTemplate: FC<{ token: string }> = ({
  token
}): JSX.Element => (
  <html lang="en-us">
    <body>
      <h1>Tastekeeper</h1>
      <p>
        Reset your password for the Tastekeeper app by clicking the link below
      </p>
      <a href={`${config.DOMAIN}/reset-password/${token}`}>Reset Password</a>
    </body>
  </html>
);

export default ResetPasswordTemplate;
