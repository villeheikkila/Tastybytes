#!/usr/bin/env node
try {
  const rimraf = require("rimraf");

  rimraf.sync(`${__dirname}/../@pwa/*/dist`);
  rimraf.sync(`${__dirname}/../@pwa/*/tsconfig.tsbuildinfo`);
  rimraf.sync(`${__dirname}/../@api/*/dist`);
  rimraf.sync(`${__dirname}/../@api/*/tsconfig.tsbuildinfo`);
  rimraf.sync(`${__dirname}/../@pwa/client/.next`);
} catch (e) {
  console.error("Failed to clean up, perhaps rimraf isn't installed?");
  console.error(e);
}
