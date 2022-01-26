import Config from "../../config";

export interface ResetPasswordTemplateProps {
  token: string;
}

const ResetPasswordTemplate = ({ token }: ResetPasswordTemplateProps) => (
  <html lang="en-us">
    <body>
      <h1>Tasted</h1>
      <p>Reset your password for the Tasted app by clicking the link below</p>
      <a href={`${Config.DOMAIN}/reset-password/${token}`}>Reset Password</a>
    </body>
  </html>
);

export default ResetPasswordTemplate;
