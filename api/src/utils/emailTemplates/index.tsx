import React from 'react';
import ReactDOMServer from 'react-dom/server';
import ResetPasswordTemplate from './ResetPasswordTemplate';
import VerifyAccountTemplate from './VerifyAccountTemplate';

export const getTemplate = (
  token: string
): { [key: string]: { html: string; subject: string } } => ({
  RESET: {
    html: ReactDOMServer.renderToStaticMarkup(
      <ResetPasswordTemplate token={token} />
    ),
    subject: 'Reset Password for Tastekeeper'
  },
  VERIFY: {
    html: ReactDOMServer.renderToStaticMarkup(
      <VerifyAccountTemplate token={token} />
    ),
    subject: 'Verify Account for Tastekeeper'
  }
});
