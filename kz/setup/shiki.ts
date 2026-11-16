import { defineShikiSetup } from '@slidev/types'

// Flat, low-chroma code theme for an ink (#00101B) code panel on the blue field.
// Palette is restricted to the design system: white, blue-200 and a muted blue
// for comments. Green is never used for text.
const WHITE = '#FFFFFF'
const INDEX = '#A8D8FF'
const MUTED = '#7FA6CF'

const kzInk = {
  name: 'kz-ink',
  type: 'dark' as const,
  colors: {
    'editor.background': '#00101B',
    'editor.foreground': WHITE,
  },
  tokenColors: [
    { settings: { foreground: WHITE } },
    {
      scope: ['comment', 'punctuation.definition.comment'],
      settings: { foreground: MUTED, fontStyle: 'italic' },
    },
    {
      scope: ['keyword', 'storage', 'keyword.operator.word', 'support.function.builtin'],
      settings: { foreground: INDEX, fontStyle: 'bold' },
    },
    {
      scope: ['string', 'string.quoted', 'string.unquoted', 'string.other.path', 'markup.inline.raw'],
      settings: { foreground: INDEX },
    },
    {
      scope: ['constant', 'constant.numeric', 'constant.language', 'variable.parameter'],
      settings: { foreground: INDEX },
    },
    {
      scope: ['entity.name.function', 'support.function', 'entity.other.attribute-name', 'variable.other.member'],
      settings: { foreground: WHITE, fontStyle: 'bold' },
    },
    {
      scope: ['punctuation', 'keyword.operator', 'meta.brace'],
      settings: { foreground: MUTED },
    },
  ],
}

export default defineShikiSetup(() => ({
  themes: {
    dark: kzInk,
    light: kzInk,
  },
}))
