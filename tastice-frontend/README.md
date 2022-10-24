# ![tastice](https://fontmeme.com/permalink/190704/0daa2ab57e001e0aa2002608810c7a69.png)

## Scripts

| Script    | Function                                   |
| --------- | ------------------------------------------ |
| npm start | Starts the frontend and reloads on changes |
| npm build | Builds the frontend for deployment         |

## List of environment variables for the frontend

| Environment variable               | Effect                                                                 |
| ---------------------------------- | ---------------------------------------------------------------------- |
| REACT_APP_SERVER_URL               | The address for the backend server. Defaults to http://localhost:4000/ |
| REACT_APP_CLOUDINARY_UPLOAD_PRESET | Cloudinary Upload Preset for storing images. Defaults to "Demo".       |
| REACT_APP_CLOUDINARY_CLOUD_NAME    | Cloudinary Cloud Name for storing images.                              |

## How to get started

1. Move to frontend directory
2. Add the wanted environment variables to an .env file.
3. Run "npm start" and start hacking

## Deployment

Run npm build and serve the frontend using your favorite static file host.
