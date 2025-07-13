import type { StarlightUserConfig } from "@astrojs/starlight/types";
import starlightBlog from "starlight-blog";
import starlightHeadingBadges from "starlight-heading-badges";
import starlightImageZoom from "starlight-image-zoom";
import starlightLinksValidator from "starlight-links-validator";

export const starlightConfig: StarlightUserConfig = {
  title: "Dotfiles",
  logo: {
    dark: "./src/assets/Dottie.svg",
    light: "./src/assets/Dottie_Light.svg",
  },
  favicon: "/favicon.svg",
  head: [
    // Add ICO favicon fallback for Safari.
    {
      tag: "link",
      attrs: {
        rel: "icon",
        href: "/favicon.ico",
        sizes: "32x32",
      },
    },
  ],
  social: [
    {
      icon: "github",
      label: "GitHub",
      href: "https://github.com/kiliantyler/dotfiles",
    },
  ],
  customCss: ["./src/styles/global.css"],
  plugins: [
    starlightHeadingBadges(),
    starlightLinksValidator(),
    starlightBlog(),
    starlightImageZoom(),
  ],
  credits: false,
};
