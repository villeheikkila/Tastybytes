import axios from 'axios';
import config from '../config';

export const verifyRecaptcha = async (
  recaptchaToken: string
): Promise<boolean> => {
  try {
    const { data } = await axios({
      method: 'POST',
      url: 'https://www.google.com/recaptcha/api/siteverify',
      data: `secret=${config.RECAPTCHA_SECRET_KEY}&response=${recaptchaToken}`
    });

    return !!data.success;
  } catch (error) {
    console.log(error);
    return false;
  }
};
