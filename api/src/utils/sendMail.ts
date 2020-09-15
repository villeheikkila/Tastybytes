import nodemailer from 'nodemailer';
import nodemailerSendgrid from 'nodemailer-sendgrid';
import { SENDGRID_API_KEY, EMAIL_SENDER } from '../config';
import { getTemplate } from './emailTemplates';

const transport = nodemailer.createTransport(
  nodemailerSendgrid({
    apiKey: SENDGRID_API_KEY
  })
);

export const sendMail = async (
  token: string,
  template: 'RESET' | 'VERIFY',
  to: string
): Promise<void> => {
  const getHTML = getTemplate(token)[template];

  try {
    await transport.sendMail({
      from: EMAIL_SENDER,
      to,
      ...getHTML
    });
  } catch (err) {
    console.error('Errors occurred, failed to deliver message');
  }
};
