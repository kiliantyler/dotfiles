// @ts-check
import starlight from "@astrojs/starlight";
import { defineConfig } from "astro/config";

import { starlightConfig } from "./starlight.config";

import markdoc from "@astrojs/markdoc";
import react from "@astrojs/react";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  integrations: [starlight(starlightConfig), react(), markdoc(), sitemap()],
  vite: {
    // @ts-expect-error Vite config doesn't work right now
    plugins: [tailwindcss()],
  },
});
