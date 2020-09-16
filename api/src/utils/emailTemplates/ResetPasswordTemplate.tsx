import React, { FC } from 'react';
import { DOMAIN } from '../../config';

const ResetPasswordTemplate: FC<{ token: string }> = ({
  token
}): JSX.Element => (
  <html lang="en-us">
    <body>
      <h1>Tastekeeper</h1>
      <p>Reset password for Tastekeeper app by clicking the link below</p>
      <a href={`${DOMAIN}/reset-password/${token}`}>Reset Password</a>
    </body>
  </html>
);

export default ResetPasswordTemplate;
