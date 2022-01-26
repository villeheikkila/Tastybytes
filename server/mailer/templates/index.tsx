import ReactDOMServer from "react-dom/server";
import ResetPasswordTemplate, {
  ResetPasswordTemplateProps,
} from "./reset-password-template";
import VerifyAccountTemplate from "./verify-account-template";

const renderMail = (subject: string, children: JSX.Element) => ({
  html: ReactDOMServer.renderToStaticMarkup(children),
  subject,
});

const templates = {
  reset_password: (props: ResetPasswordTemplateProps) =>
    renderMail(
      "Reset Password for Tasted",
      <ResetPasswordTemplate {...props} />
    ),
  confirm_email: (props: ResetPasswordTemplateProps) =>
    renderMail(
      "Verify Account for Tasted",
      <VerifyAccountTemplate {...props} />
    ),
};

export const getTemplate = (template: keyof typeof templates) =>
  templates[template];
