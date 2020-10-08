export const config = {
  isLocal: true,
  isProd: process.env.NODE_ENV === "production",
  NODE_ENV: process.env.NODE_ENV,
  RECAPTCHA_SITE_KEY:
    (process.env.REACT_APP_RECAPTCHA_SITE_KEY as string) || "",
  BACKEND_URL: (process.env.REACT_APP_BACKEND_URL as string) || "",
};
