/* Use via `node -r @api/config/env path/to/file.js` */

/*
In order to support multiplatform and docker development in the same repository,
we use `node -r @api/config/env path/to/code` to run various parts of the
project. `node -r` requires a specific module before running the main script; in
this case we're requiring [@api/config/env.js](./env.js) which sources the
settings from `.env` in the root folder and then builds some derivative
environmental variables from them. This is a fairly advanced technique.
*/

require("dotenv").config({ path: `${__dirname}/../../.env` });
require("./extra");
