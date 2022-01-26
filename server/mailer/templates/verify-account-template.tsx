import Config from "../../config";

export interface VerifyAccountTemplateProps {
  token: string;
}

const VerifyAccountTemplate = ({ token }: VerifyAccountTemplateProps) => (
  <html lang="en-us">
    <body>
      <h1>Tasted</h1>
      <p>Verify your account for the Tasted app by clicking the link below</p>
      <a href={`${Config.DOMAIN}/verify-account/${token}`}>Verify Account</a>
    </body>
  </html>
);

export default VerifyAccountTemplate;
