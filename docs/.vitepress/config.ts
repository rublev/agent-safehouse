import fs from 'node:fs'
import { defineConfig } from 'vitepress'

const VERSION_FILE = new URL('../../VERSION', import.meta.url)
const RELEASE_RAW_DIST_BASE_URL_TOKEN = '__SAFEHOUSE_RELEASE_RAW_DIST_BASE_URL__'

type MarkdownToken = {
  content?: string
  children?: MarkdownToken[]
}

function readSafehouseVersion(): string {
  const version = fs.readFileSync(VERSION_FILE, 'utf8').trim()

  if (!version) {
    throw new Error(`VERSION file is empty: ${VERSION_FILE.pathname}`)
  }

  return version
}

const safehouseVersion = readSafehouseVersion()
const safehouseReleaseRawDistBaseUrl = `https://raw.githubusercontent.com/eugene1g/agent-safehouse/v${safehouseVersion}/dist`

function replaceLauncherUrlTokens(tokens: MarkdownToken[]): void {
  for (const token of tokens) {
    if (typeof token.content === 'string' && token.content.length > 0) {
      token.content = token.content.replaceAll(
        RELEASE_RAW_DIST_BASE_URL_TOKEN,
        safehouseReleaseRawDistBaseUrl,
      )
    }

    if (Array.isArray(token.children) && token.children.length > 0) {
      replaceLauncherUrlTokens(token.children)
    }
  }
}

export default defineConfig({
  title: 'Agent Safehouse',
  description: 'Sandbox your LLM coding agents on macOS. Kernel-level enforcement via sandbox-exec — deny-first, composable, zero dependencies.',

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/favicon-32.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/favicon-16.png' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:url', content: 'https://agent-safehouse.dev/' }],
    ['meta', { property: 'og:title', content: 'Agent Safehouse' }],
    ['meta', { property: 'og:description', content: 'Sandbox your LLM coding agents on macOS. Kernel-level enforcement via sandbox-exec — deny-first, composable, zero dependencies.' }],
    ['meta', { property: 'og:image', content: 'https://agent-safehouse.dev/og-image.png' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: 'Agent Safehouse' }],
    ['meta', { name: 'twitter:description', content: 'Sandbox your LLM coding agents on macOS. Kernel-level enforcement via sandbox-exec — deny-first, composable, zero dependencies.' }],
    ['meta', { name: 'twitter:image', content: 'https://agent-safehouse.dev/og-image.png' }],
  ],

  appearance: false,

  markdown: {
    theme: {
      light: 'one-light',
      dark: 'one-dark-pro',
    },
    config(md) {
      md.core.ruler.push('safehouse-launcher-url-replacements', (state) => {
        replaceLauncherUrlTokens(state.tokens as MarkdownToken[])
      })
    },
  },

  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Docs', link: '/docs/' },
      { text: 'LLM Instructions', link: '/llm-instructions.txt' },
      { text: 'Policy Builder', link: '/policy-builder' },
    ],

    sidebar: {
      '/docs/': [
        {
          text: 'Start Here',
          items: [
            { text: 'Docs Home', link: '/docs/' },
            { text: 'Overview & Philosophy', link: '/docs/overview' },
            { text: 'Isolation Models', link: '/docs/isolation-models' },
            { text: 'Default Assumptions', link: '/docs/default-assumptions' },
            { text: 'Getting Started', link: '/docs/getting-started' },
            { text: 'Generate a Custom Profile with an LLM', link: '/docs/llm-profile-generator' },
            { text: 'Usage', link: '/docs/usage' },
            { text: 'Options', link: '/docs/options' },
          ],
        },
        {
          text: 'Build Up',
          items: [
            { text: 'Policy Architecture', link: '/docs/policy-architecture' },
            { text: 'Distribution Artifacts', link: '/docs/distribution' },
            { text: 'Customization', link: '/docs/customization' },
            { text: 'Testing', link: '/docs/testing' },
            { text: 'Debugging Sandbox Denials', link: '/docs/debugging' },
            { text: 'Reference & Prior Art', link: '/docs/references' },
          ],
        },
        {
          text: 'Agent Investigations',
          link: '/docs/agent-investigations/',
          items: [
            { text: 'Aider', link: '/docs/agent-investigations/aider' },
            { text: 'Auggie (Augment Code)', link: '/docs/agent-investigations/auggie' },
            { text: 'Claude Code', link: '/docs/agent-investigations/claude-code' },
            { text: 'Cline', link: '/docs/agent-investigations/cline' },
            { text: 'Codex', link: '/docs/agent-investigations/codex' },
            { text: 'Copilot CLI', link: '/docs/agent-investigations/copilot-cli' },
            { text: 'Cursor Agent', link: '/docs/agent-investigations/cursor-agent' },
            { text: 'Droid (Factory CLI)', link: '/docs/agent-investigations/droid' },
            { text: 'Gemini CLI', link: '/docs/agent-investigations/gemini-cli' },
            { text: 'Goose', link: '/docs/agent-investigations/goose' },
            { text: 'Kilo Code', link: '/docs/agent-investigations/kilo-code' },
            { text: 'OpenCode', link: '/docs/agent-investigations/opencode' },
            { text: 'Pi', link: '/docs/agent-investigations/pi' },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/eugene1g/agent-safehouse' },
    ],

    footer: {
      message: 'Open source under the Apache 2.0 License.',
      copyright: 'Agent Safehouse',
    },
  },
})
