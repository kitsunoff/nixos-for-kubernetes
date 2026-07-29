import { defineMermaidSetup } from '@slidev/types'

// Brand theme for all Mermaid diagrams (Kubernetes Community template tokens):
//   bg black · nodes dark #141414 · borders/arrows muted grey · text white Verdana
//   accent teal #18C0B1 applied per-node via `classDef accent` inside each diagram.
export default defineMermaidSetup(() => ({
  theme: 'base',
  themeVariables: {
    darkMode: true,
    background: '#000000',
    fontFamily: "'Verdana', 'Geneva', 'DejaVu Sans', sans-serif",
    fontSize: '15px',

    // flowchart nodes
    primaryColor: '#141414',
    mainBkg: '#141414',
    primaryTextColor: '#ffffff',
    primaryBorderColor: '#4a4a4a',
    nodeBorder: '#4a4a4a',
    nodeTextColor: '#ffffff',
    textColor: '#ffffff',
    titleColor: '#ffffff',
    lineColor: '#9aa0a6',
    edgeLabelBackground: '#000000',

    // subgraphs / clusters
    clusterBkg: '#0b0b0b',
    clusterBorder: '#2c4f4a',

    secondaryColor: '#0d0d0d',
    tertiaryColor: '#0d0d0d',
    secondaryBorderColor: '#4a4a4a',
    tertiaryBorderColor: '#4a4a4a',

    // sequence diagram
    actorBkg: '#141414',
    actorBorder: '#4a4a4a',
    actorTextColor: '#ffffff',
    actorLineColor: '#5a5a5a',
    signalColor: '#9aa0a6',
    signalTextColor: '#d6d9db',
    labelBoxBkgColor: '#0b0b0b',
    labelBoxBorderColor: '#18C0B1',
    labelTextColor: '#ffffff',
    loopTextColor: '#d6d9db',
    noteBkgColor: '#10302c',
    noteBorderColor: '#18C0B1',
    noteTextColor: '#ffffff',
    activationBkgColor: '#18C0B1',
    activationBorderColor: '#18C0B1',
    sequenceNumberColor: '#04231f',

    // quadrant chart
    quadrant1Fill: '#0f1413',
    quadrant2Fill: '#0c0c0c',
    quadrant3Fill: '#0a0a0a',
    quadrant4Fill: '#0d100f',
    quadrant1TextFill: '#d6d9db',
    quadrant2TextFill: '#9aa0a6',
    quadrant3TextFill: '#9aa0a6',
    quadrant4TextFill: '#9aa0a6',
    quadrantPointFill: '#18C0B1',
    quadrantPointTextFill: '#ffffff',
    quadrantXAxisTextFill: '#d6d9db',
    quadrantYAxisTextFill: '#d6d9db',
    quadrantTitleFill: '#ffffff',
    quadrantInternalBorderStrokeFill: '#2e2e2e',
    quadrantExternalBorderStrokeFill: '#555555',
  },
}))
