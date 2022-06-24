/* gulpfile.js */

const uswds = require("@uswds/compile");

/**
 * USWDS version
 * Set the version of USWDS you're using (2 or 3)
 */

uswds.settings.version = 3;

/**
 * Path settings
 * See Step 4 in https://designsystem.digital.gov/documentation/getting-started/developers/phase-two-compile
 *
 * We use the `./public` directory to specify the copied and compiled assets because Next.js expects
 * static assets to be located there.
 * See https://nextjs.org/docs/basic-features/static-file-serving
 */

uswds.paths.dist.theme = './styles';
uswds.paths.dist.img = './public/uswds/img';
uswds.paths.dist.fonts = './public/uswds/fonts';
uswds.paths.dist.js = './public/uswds/js';
uswds.paths.dist.css = './public/css';

/**
 * Exports
 * See Step 4 in https://designsystem.digital.gov/documentation/getting-started/developers/phase-two-compile
 */

/**
 * Run `yarn gulp init` to setup the initial files.
 * This should not be needed! The initial files (i.e styles.scss, _uswds-theme.scss,
 * _uswds-theme-custom-styles.scss) have all been generated.
 */
exports.init = uswds.init;
/**
 * Run `yarn gulp copyAssets` to update the USWDS assets (i.e. copy them
 * from node_modules into ./public).
 */
exports.copyAssets = uswds.copyAssets;
/**
 * Run `yarn gulp compile` to compile icons as well as sass.
 */
exports.compile = uswds.compile;
/**
 * Run `yarn gulp compileSass` to just compile sass and not icons (very slightly faster).
 */
exports.compileSass = uswds.compileSass;
/**
 * Run `yarn gulp watch` to automatically recompile when there are changes to the sass files.
 */
exports.watch = uswds.watch;
