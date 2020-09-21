import AWS from 'aws-sdk';
import { Stream } from 'aws-sdk/clients/glacier';
import { extname } from 'path';
import { v4 as uuidv4 } from 'uuid';

import {
  AWS_S3_ACCESS_KEY,
  AWS_S3_BUCKET_NAME,
  AWS_S3_SECRET_ACCESS_KEY
} from '../config';

const s3 = new AWS.S3({
  accessKeyId: AWS_S3_ACCESS_KEY,
  secretAccessKey: AWS_S3_SECRET_ACCESS_KEY
});

const s3uploader = async (
  fileName: string,
  content: Stream
): Promise<string> => {
  const { Location: uri } = await s3
    .upload({
      Bucket: AWS_S3_BUCKET_NAME,
      Key: `${uuidv4()}${extname(fileName)}`,
      Body: content
    })
    .promise();

  return uri;
};

export default s3uploader;
