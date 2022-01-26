import nodemailer from "nodemailer";
import Config from "../config";

const transport = nodemailer.createTransport({
  host: "smtp.ethereal.email",
  port: 587,
  auth: {
    user: Config.ETHEREAL_USERNAME,
    pass: Config.ETHEREAL_PASSWORD,
  },
});

interface SendMailProps {
  to: string;
  subject: string;
  html: string;
}

const sendMail = async (props: SendMailProps) => {
  console.log("props: ", props);
  const info = await transport.sendMail({
    from: Config.SENDER,
    ...props,
  });

  const url = nodemailer.getTestMessageUrl(info);

  if (url) {
    console.log(`Mail: ${url}`);
  }
};

export { sendMail };
