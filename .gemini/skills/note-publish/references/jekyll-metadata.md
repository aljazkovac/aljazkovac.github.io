# Jekyll Metadata Guidelines

## Frontmatter Schema

Ensure every post contains:

- `layout`: Set to `article` ONLY if the post is an "Article". Remove or omit for "Notes".
- `title`: Concise, SEO-friendly (60 chars max)
- `description`: Compelling summary (160 chars max)
- `permalink`: **Required.** Set to `/posts/slug/` where the slug is a URL-friendly version of the title. This ensures the URL remains stable even if the filename changes.
- `date`: Format `YYYY-MM-DD HH:MM:SS +0000`. Use yesterday's date as the default.
- `categories`: Maximum of 2. Use existing ones (e.g., `Management`, `Cloud`, `DevOps`) when possible.
- `tags`: 3-5 relevant keywords.
- `mermaid`: Set to `true` if Mermaid diagrams are used.

## Image Paths

- Post images should reside in `assets/images/<post-slug>/`.
- Reference them using relative paths like `![Alt text](/assets/images/<post-slug>/image.png)`.
- Verify the image exists in the directory or propose its creation if missing.
