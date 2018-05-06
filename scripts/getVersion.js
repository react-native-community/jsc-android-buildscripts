const webkitGTK = process.env.npm_package_config_webkitGTK;
const androidICU = process.env.npm_package_config_android_icu;
const bitness = process.env.npm_package_config_x64 === true ? 'x64' : 'x32';
const i18n = process.env.npm_package_config_i18n === true ? 'i18n' : 'en';
const hint = process.env.npm_package_config_hint;

module.exports = () => {
  return `${webkitGTK}-${androidICU}-${bitness}-${i18n}-${hint}`
};
