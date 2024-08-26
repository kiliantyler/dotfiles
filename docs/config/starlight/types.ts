import type { StarlightUserConfig } from '@astrojs/starlight/types';

export type StarlightConfig = StarlightUserConfig;

export type Sidebar = NonNullable<StarlightUserConfig['sidebar']>;
export type SidebarSection = Sidebar[number];
export type SidebarGroup = Extract<SidebarSection, { items: any[] }>;
export type SidebarItem = SidebarGroup['items'][number]

export type Plugins = NonNullable<StarlightUserConfig['plugins']>;
