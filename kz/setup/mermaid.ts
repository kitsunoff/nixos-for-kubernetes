import { defineMermaidSetup } from '@slidev/types'

// KZ meetup theme for Mermaid diagrams:
//   blue field #0A76EC · white lines and text · ink #00101B for labels
//   green #57C07D only as a fill behind ink text (accent nodes, notes).
const BLUE = '#0A76EC'
const BLUE_DARK = '#0862C4'
const WHITE = '#FFFFFF'
const INK = '#00101B'
const GREEN = '#57C07D'
const INDEX = '#A8D8FF'

export default defineMermaidSetup(() => ({
  theme: 'base',
  themeVariables: {
    darkMode: true,
    background: BLUE,
    fontFamily: "'Martian Mono', 'JetBrains Mono', ui-monospace, monospace",
    fontSize: '15px',

    // flowchart nodes: flat blue boxes with white outlines
    primaryColor: BLUE,
    mainBkg: BLUE,
    primaryTextColor: WHITE,
    primaryBorderColor: WHITE,
    nodeBorder: WHITE,
    nodeTextColor: WHITE,
    textColor: WHITE,
    titleColor: WHITE,
    lineColor: WHITE,
    edgeLabelBackground: BLUE,

    // subgraphs / clusters
    clusterBkg: BLUE_DARK,
    clusterBorder: WHITE,

    secondaryColor: BLUE_DARK,
    tertiaryColor: BLUE_DARK,
    secondaryBorderColor: WHITE,
    tertiaryBorderColor: WHITE,

    // sequence diagram
    actorBkg: BLUE,
    actorBorder: WHITE,
    actorTextColor: WHITE,
    actorLineColor: WHITE,
    signalColor: WHITE,
    signalTextColor: WHITE,
    labelBoxBkgColor: GREEN,
    labelBoxBorderColor: INK,
    labelTextColor: INK,
    loopTextColor: WHITE,
    noteBkgColor: GREEN,
    noteBorderColor: INK,
    noteTextColor: INK,
    activationBkgColor: GREEN,
    activationBorderColor: INK,
    sequenceNumberColor: INK,

    // quadrant chart
    quadrant1Fill: BLUE_DARK,
    quadrant2Fill: BLUE,
    quadrant3Fill: BLUE,
    quadrant4Fill: BLUE,
    quadrant1TextFill: WHITE,
    quadrant2TextFill: WHITE,
    quadrant3TextFill: WHITE,
    quadrant4TextFill: WHITE,
    quadrantPointFill: GREEN,
    quadrantPointTextFill: WHITE,
    quadrantXAxisTextFill: WHITE,
    quadrantYAxisTextFill: WHITE,
    quadrantTitleFill: WHITE,
    quadrantInternalBorderStrokeFill: INDEX,
    quadrantExternalBorderStrokeFill: WHITE,
  },
}))
