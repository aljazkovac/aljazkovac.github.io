---
name: note-publish
description: Refactor notes for publication, add Mermaid diagrams, and validate Jekyll frontmatter. Use when a draft in `_unpublished_posts/` is ready to be polished and moved to `_posts/`.
---

# Note Publish Workflow

## Workflow Overview

1.  **Duplicate to `_posts/`:** Create a new file in `_posts/` using the content from the draft in `_unpublished_posts/`. The filename MUST follow the `YYYY-MM-DD-title.md` pattern, where `YYYY-MM-DD` is yesterday's date.
2.  **Determine Post Type:** Prompt the user to decide if the post is a "Note" or an "Article".
3.  **Refactor Content (on the copy):** Improve the text's clarity, conciseness, and impact in the new file.
4.  **Add Mermaid Diagrams (on the copy):** Identify where diagrams can clarify the text and write them using [mermaid-patterns.md](references/mermaid-patterns.md).
5.  **Update Metadata (on the copy):**
    *   Set `date` to yesterday's date (matching the filename).
    *   If "Article" was selected, set `layout: article`. If "Note" was selected, ensure no `layout` field is present.
    *   Ensure `title`, `description`, `categories` (max 2), and `tags` are appropriate and correctly formatted according to [jekyll-metadata.md](references/jekyll-metadata.md).
5.  **Check Image Paths (on the copy):** Verify that all image paths correctly point to `assets/images/<post-slug>/` and that the images exist.
6.  **Preserve Original:** Keep the original draft in `_unpublished_posts/` untouched for comparison.

## Guidelines

- **Style:** Maintain a professional and engaging tone, appropriate for a technical blog.
- **Conciseness:** Avoid filler. Prioritize clear, direct explanations.
- **Mermaid Integration:** Ensure `mermaid: true` is added to the frontmatter if any diagrams are created.
- **Categories/Tags:** Use existing categories and tags where possible to maintain site consistency.
- **Images:** If an image is referenced but missing from `assets/images/`, flag it to the user.

## Reference Files

- [jekyll-metadata.md](references/jekyll-metadata.md) - Specifics for Jekyll frontmatter and image organization.
- [mermaid-patterns.md](references/mermaid-patterns.md) - Best practices for identifying and writing Mermaid diagrams.
