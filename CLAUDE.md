# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a Jekyll-based GitHub Pages blog built with the Chirpy theme. It's a static site generator that creates a personal technical blog focused on software development, DevOps, and learning documentation.

### Content Structure

- `_posts/` - Published blog posts (YYYY-MM-DD-title.md format)
- `_unpublished_posts/` - Draft posts not yet published
- `_tabs/` - Static pages (About, Archives, Categories, Tags)
- `_data/` - YAML data files for site configuration
- `_site/` - Generated static site (auto-generated, don't edit directly)
- `assets/` - Images, CSS, JS, and other static assets

### Post Format

Blog posts use Jekyll front matter with:

```yaml
---
title: Post Title
date: YYYY-MM-DD HH:MM:SS +TIMEZONE
categories: [primary, secondary] # Maximum 2 categories
tags: [tag1, tag2, tag3] # Always lowercase
description: Brief description for SEO
---
```

## Common Commands

### Development

```bash
# Install dependencies
bundle install

# Serve locally (usually on http://127.0.0.1:4000)
bundle exec jekyll serve

# Build the site
bundle exec jekyll build

# Build for production
JEKYLL_ENV=production bundle exec jekyll build
```

### Testing

```bash
# Test built site with HTML Proofer
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```

## Deployment

The site deploys automatically via GitHub Actions (`.github/workflows/pages-deploy.yml`) when changes are pushed to the main branch. The workflow:

1. Builds the Jekyll site
2. Tests with HTML Proofer
3. Deploys to GitHub Pages

## Jekyll Configuration

The site uses `_config.yml` for configuration including:

- Site metadata and SEO settings
- Theme configuration (jekyll-theme-chirpy)
- Collections setup for posts and tabs
- Plugin configuration
- URL structure and permalinks

## Content Guidelines

- Posts should be placed in `_posts/` with proper date formatting
- Use `_unpublished_posts/` for drafts
- Images go in `assets/images/`
- All content is written in Markdown with Jekyll/Liquid templating

## Exercise posts - format and style

The exercise posts should follow this format and style:

### Exercise $1: Exercise Title

**Objective:**

$2

**Requirements:**

Summarize the requirements in a list.

**Implementation Summary:**

Summarize the implementation.

**Key Technical Issues and Solutions:**

Summarize the key technical issues we came upon and how we solved them.

**Application Workflow:**

Explain the workflow of the application after the implementation of the exercise.

**Debugging and Deployment:**

Explain the debugging and deployment process.

**Kubernetes Resource Configuration:**

Summarize the Kubernetes configuration needed for the exercise.

**Release**:

Link to the GitHub release for this exercise: `https://github.com/aljazkovac/devops-with-kubernetes/tree/$3`.
