// @ts-ignore
const packageJson = require("../../../package.json");

// TODO: customise this with your own settings!

export const fromEmail =
  '"PostGraphile Starter" <no-reply@examples.graphile.org>';
export const awsRegion = "us-east-1";
export const projectName = packageJson.name.replace(/[-_]/g, " ");
export const author = packageJson.author;
export const companyName = projectName; // For copyright ownership
export const emailLegalText = "";
