// @ts-ignore
const packageJson = require("../../../package.json");

// TODO: customise this with your own settings!

// the email address to send emails from
export const fromEmail =
  '"PostGraphile Starter" <no-reply@examples.graphile.org>';

// used for sending emails with Amazon SES
export const awsRegion = "us-east-1";
export const projectName = 'maku';
export const author = packageJson.author;
export const companyName = projectName; // For copyright ownership
/* legal text to put at the bottom of emails. Since all emails
  in this project is transactional, an `unsubscribe` link is not needed, but you
  should definitely consider how you intend to handle complaints */
export const emailLegalText = "";
