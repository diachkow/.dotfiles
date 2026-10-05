# HTML diagrams

Use a diagram when relationships, sequence, topology, state, hierarchy, or process are the central content. Name the question the viewer should answer, then choose a visual grammar:

| Question | Form |
| --- | --- |
| What exists and how is it connected? | Topology or system map |
| What happens over time? | Sequence or timeline |
| What decisions or transformations occur? | Process flow |
| How can something change? | State diagram |
| What contains or owns what? | Hierarchy or boundary map |
| How do alternatives compare? | Matrix |
| How much, how often, or how fast? | Chart; also read [`charts-and-data.md`](charts-and-data.md) |

Use the simplest form that carries the meaning. Avoid combining unrelated questions in one overloaded picture.

## Choose the renderer

- HTML/CSS for reflowing labels, aligned regions, grids, and timelines.
- SVG for crisp relationships, custom connectors, and interactive vector scenes.
- Canvas for dense or frequently changing graphics.
- WebGL only for spatial or high-volume scenes that justify it.

Make grouping, labels, direction, and connectors legible before adding interaction. Minimize edge crossings; use boundaries only when they express ownership, trust, deployment, or responsibility. Keep implementation details only when the audience's question is about code structure.

Add pan, zoom, sequencing, filtering, or animation only when it helps answer the question. Keep meaning available without animation or color alone; make controls keyboard-accessible and overlays dismissible.

Verify the overview, all interactive states, label collisions, arrow direction, narrow-screen behavior, reading order, and overflow. Report the chosen diagram form and key assumptions.
