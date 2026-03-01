# Mermaid Diagram Patterns

## When to Add a Diagram

Identify text-heavy sections that describe:

- **Workflows:** Complex sequences of events (Sequence Diagram).
- **Processes:** Step-by-step logic (Flowchart).
- **Structures:** Hierarchies or relationships (Class or ER Diagram).
- **Timelines:** Historical or project events (Gantt or Timeline).

## Diagram Style

- **Flowcharts:** Use `graph TD` for top-down, `graph LR` for left-to-right.
- **Complexity:** Keep diagrams simple (max 7-10 nodes).
- **Integration:** Place the diagram immediately after the text it clarifies.
- **Wrapper:** Always use the `{% mermaid %}` block if the site's layout requires it, or standard ` ```mermaid ` code blocks.

## Examples

- Use for: Cloud architecture (simple), CI/CD pipelines, organizational changes, or technical troubleshooting steps.
