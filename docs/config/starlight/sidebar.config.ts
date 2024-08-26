import type { Sidebar, SidebarItem } from './types';

const sidebar: Sidebar = []

const intro: SidebarItem = {
  label: 'Introduction',
  slug: 'intro',
  badge: {
    text: 'WIP',
    variant: 'caution',
  },
};

// Sets the order of the sidebar
sidebar.push(intro);

export default sidebar;
