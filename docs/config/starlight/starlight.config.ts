import type { StarlightConfig } from './types';

import starlightPlugins from './plugins.config.ts';
// i18n Configs
import de from './i18n/de.config.ts';
import en from './i18n/en.config.ts';

// import Configs
import sidebarConfig from './sidebar.config.ts';

const githubUrl = 'https://github.com/kiliantyler/dotfiles';

// Custom CSS Array
const customCss = [
  './src/css/tailwind.css',
  './src/css/asides.css',
];


// i18n Config
const i18nTitleConfig = {
  en: en.siteTitle,
  de: de.siteTitle
};

// Starlight Config Object to export
const starlightConfig: StarlightConfig = {
  title: i18nTitleConfig,
  logo: {
    dark: './src/assets/Dottie.svg',
    light: './src/assets/Dottie_Light.svg',
  },
  favicon: '/favicon.svg',
  head: [
    // Add ICO favicon fallback for Safari.
    {
      tag: 'link',
      attrs: {
        rel: 'icon',
        href: '/favicon.ico',
        sizes: '32x32',
      },
    },
  ],
  customCss: customCss,
  defaultLocale: 'root',
  locales: {
    root: {
      label: 'English',
      lang: 'en'
    },
    de: {
      label: 'Deutsch',
      lang: 'de'
    }
  },
  social: {
    github: githubUrl
  },
  sidebar: sidebarConfig,
  plugins: starlightPlugins,
  credits: false,
};

export default starlightConfig;
