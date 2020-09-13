import nodemailer from 'nodemailer';
import nodemailerSendgrid from 'nodemailer-sendgrid';
import { SENDGRID_API_KEY, EMAIL_SENDER } from '../config';

const transport = nodemailer.createTransport(
  nodemailerSendgrid({
    apiKey: SENDGRID_API_KEY
  })
);

export const sendVerificationMail = async (
  token: string,
  to: string
): Promise<void> => {
  console.log('mail ', EMAIL_SENDER);

  try {
    const response = await transport.sendMail({
      from: EMAIL_SENDER,
      to,
      subject: 'Verify Account for HerQ',
      html: `<h1>Herq</h1><p>Verify your email</p>${token}<p></>`
    });

    console.log('response: ', response);
  } catch (err) {
    console.error('Errors occurred, failed to deliver message');

    if (err.response && err.response.body && err.response.body.errors) {
      err.response.body.errors.forEach((error: any) =>
        console.log('%s: %s', error.field, error.message)
      );
    } else {
      console.log(err);
    }
  }
};
