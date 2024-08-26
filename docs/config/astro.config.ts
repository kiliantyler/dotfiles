import starlight from '@astrojs/starlight';
import { defineConfig } from 'astro/config';

// Astro Integrations
import markdoc from "@astrojs/markdoc";
import react from "@astrojs/react";
import tailwind from "@astrojs/tailwind";

// Starlight Config
import starlightConfig from './starlight/starlight.config.ts';

export default defineConfig({
  site: 'https://dotfiles.kiliantyler.com',
  integrations: [
    starlight(starlightConfig),
    markdoc(),
    react(),
    tailwind({
      // Disable the default base styles:
      applyBaseStyles: false,
    }),
  ]
});
