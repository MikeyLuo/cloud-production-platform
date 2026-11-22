// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
    site: 'https://mikeyluo.github.io',
    base: '/cloud-production-platform',
    output: 'static',
    trailingSlash: 'always',
    build: {
    format: 'directory',
    },
});
