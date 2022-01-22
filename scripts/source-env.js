if (process.env.NODE_ENV === "production") {
  console.log("Running against production");
  require("dotenv").config({ path: `${__dirname}/../.env.prod` });
} else {
  console.log("Running against development");
  require("dotenv").config({ path: `${__dirname}/../.env` });
}
