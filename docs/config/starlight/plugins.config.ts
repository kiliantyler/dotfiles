import starlightBlog from 'starlight-blog';
import starlightHeadingBadges from 'starlight-heading-badges';
import starlightImageZoom from 'starlight-image-zoom';
import starlightLinksValidator from 'starlight-links-validator';
import starlightViewModes from 'starlight-view-modes';

// Plugin Configs
import viewModesConfig from './viewModes.config.ts';

const starlightPlugins = [
  starlightHeadingBadges(),
  starlightLinksValidator(),
  starlightBlog(),
  starlightImageZoom(),
  starlightViewModes(viewModesConfig)
];

export default starlightPlugins;
