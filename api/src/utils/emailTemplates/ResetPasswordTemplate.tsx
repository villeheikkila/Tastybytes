import React, { FC } from 'react';
import { DOMAIN } from '../../config';

const ResetPasswordTemplate: FC<{ token: string }> = ({
  token
}): JSX.Element => (
  <html lang="en-us">
    <head>
      <title>Hello World!</title>
    </head>
    <body>
      <h1>HerQ</h1>
      <p>Reset password for HerQ app by clicking the link below</p>
      <a href={`${DOMAIN}/reset-password/${token}`} />
    </body>
  </html>
);

export default ResetPasswordTemplate;
