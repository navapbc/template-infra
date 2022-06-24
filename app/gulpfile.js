/* gulpfile.js */

const uswds = require("@uswds/compile");

/**
 * USWDS version
 * Set the version of USWDS you're using (2 or 3)
 */

uswds.settings.version = 3;

/**
 * Path settings
 * Set as many as you need
 */

uswds.paths.dist.theme = './styles';
uswds.paths.dist.img = './public/uswds/images';
uswds.paths.dist.fonts = './public/uswds/fonts';
uswds.paths.dist.js = './public/uswds/js';
uswds.paths.dist.css = './public/css';

/**
 * Exports
 * Add as many as you need
 */

exports.init = uswds.init;
exports.compile = uswds.compile;
exports.compileSass = uswds.compileSass;
exports.copyAssets = uswds.copyAssets;
