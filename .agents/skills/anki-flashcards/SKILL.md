---
name: anki-flashcards
description: Generates Anki-ready flashcards in TSV format from blog posts or technical notes. Creates separate sets for Basic (Q&A) and Cloze (fill-in-the-blank) card types.
---

# Anki Flashcard Generation

This skill automates the extraction of key concepts, definitions, and technical workflows from Markdown documents to create high-quality flashcards for Anki.

## Workflow

1.  **Analyze Content:** Read the provided Markdown file. Identify core concepts, definitions, lists, and procedural steps.
2.  **Apply Principles:** Consult [references/flashcard-principles.md](references/flashcard-principles.md) to ensure cards are atomic and effective.
3.  **Storage Setup:** Ensure a directory named `anki/` exists at the project root.
4.  **Generate Basic Cards:** Create a set of Question/Answer cards for definitions and concepts. Save them to `anki/<post-slug>-basic.tsv`.
5.  **Generate Cloze Deletions:** Create a set of fill-in-the-blank cards for workflows, context-heavy facts, or syntax. Save them to `anki/<post-slug>-cloze.tsv`.
6.  **Format as TSV:** Output the content as code blocks and inform the user of the saved file paths.
7.  **Tagging:** Automatically generate a tag based on the post's title or categories (e.g., `ai::agentic-ai`).

## TSV Structure

Both sets should follow this 3-field structure (separated by tabs):

1.  **Front/Text:** The question or the sentence with `{{c1::cloze}}` deletions.
2.  **Back/Extra:** The answer (for Basic) or additional context/explanation (for both).
3.  **Tags:** Space-separated tags.

## Output Format

Always provide the output in two distinct, labeled code blocks:

### 1. Basic Cards

\`\`\`tsv
Question Answer Tags
\`\`\`

### 2. Cloze Cards

\`\`\`tsv
Sentence with {{c1::cloze}} Extra context Tags
\`\`\`

## Guidelines

- **Atomic:** Each card tests one fact.
- **Context:** Use the "Extra" field to add value, like why something is important or a link to the original post.
- **Formatting:** Ensure NO literal tabs exist within the fields; use spaces instead.
