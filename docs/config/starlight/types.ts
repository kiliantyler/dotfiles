import type { StarlightUserConfig } from '@astrojs/starlight/types';

export type StarlightConfig = StarlightUserConfig;

export type Plugins = NonNullable<StarlightUserConfig['plugins']>;
