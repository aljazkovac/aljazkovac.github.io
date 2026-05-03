---
title: Spec-Driven Development with Coding Agents
date: 2026-04-26 08:00:00 +0100
permalink: /posts/spec-driven-development/
categories: [notes, ai]
tags: [ai, generative ai, software]
description: Notes from the DeepLearning.AI course on how to implement spec-driven development with coding agents.
mermaid: true
---

## Introduction

Benefits of spec-driven development with coding agents:

- Control code with small changes to spec
- Eliminate context decay
- Improve intent fidelity

The flow: spec.md ->[SDD] -> source code ->[compiler] -> machine code

## Workflow overview

Project level -> feature level

Level of detail:

- Goals
- Mission
- Target audience
- Constraints

The agent can figure out the low-level details on its own!

Constitution: Mission + Tech stack + Roadmap

**Mission**: The Why - vision, audiences, scope, etc.
**Tech stack**: For the engineering team - a common understanding of the development and deployment technologies
**Roadmap**: A living document with a seqence of phases and features to be implemented

### Project evolution

Flow: Constitution -> Replanning
Documents: mission.md, tech-stack.md, roadmap.md

### Feature phase

Flow: Specification -> Implementation -> Validation
Documents: plan.md, requirements.md, validation.md

Roles:

- Developer: Design, supervise, review and accept or ask for changes
- Builders and agents: Write the code

![Project Evolution](/assets/images/spec-driven-development/sdd-project-feature.png)

## Tips and tricks

- Use the AskUserQuestion tool.
- Use [Context7](https://context7.com/) to give your LLM the latest documentation and libraries
- [Spec Kit](https://github.com/github/spec-kit)
- [Open Spec](https://github.com/Fission-AI/OpenSpec)

## Conclusion

Spec-driven development is one of the latest buzz-words and it is supposed to be the next big thing when working with LLMs. I decided to take this course, expecting to learn an entirely new way of working with agentic coding. Very soon into the course I realized that I have been using my own version of "spec-driven development" for quite a while now. So, what is spec-driven development? It is just a way of working with an LLM in a structured way, using an organized set of .md files to plan, control and validate your work. It does not matter what the actual files are called and how the work is structured as long as it is organized well and your team understands and follows the same convention. I have been using a TODO.md file instead of a ROADMAP.md. AGENTS.md instead of MISSION.md. And README.md instead of TECH-STACK.md. It has worked quite well for me and I did not even realized I have been doing the new hot thing, "spec-driven development"!.

The point is: find your own structured way of working and do not let yourself be bogged down by a specific framework. Working with an LLM introduces a lot of cognitive debt and places great demand on our context-switching capabilities. Find your own way of dealing with this, depending on your ability, preferences and old habits, as well as the project you are working on.

## Accomplishment

![Spec Driven Development Course Accomplishment](/assets/images/spec-driven-development/spec-driven-development-certficate.png)
_Accomplishment - completing the course Spec-Driven Development_

Validate the accomplishment at the [validation link](https://learn.deeplearning.ai/accomplishments/effdff70-8dad-4a3a-8c55-9a66d50cd657).
