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

spec.md ->[SDD] -> source code ->[compiler] -> machine code

## Workflow overview

Project level -> feature level

Level of detail:

- Goals
- Mission
- Target audience
- Constraints

The agent can figure out the low-level details on its own!

Constitution: Mission + Tech stack + Roadmap

Mission: The Why - vision, audiences, scope, etc.
Tech stack: For the engineering team - a common understanding of the development and deployment technologies
Roadmap: A living document with a seqence of phases and features to be implemented

Project evolution: Constitution -> Replanning
Feature phase: Specification -> Implementation -> Validation

Roles:

- Developer: Design, supervise, review and accept or ask for changes
- Builders and agents: Write the code

![Project Evolution](/assets/images/spec-driven-development/sdd-project-feature.png)

## Accomplishment

![](/assets/images/generative-ai-for-software-development/generative-ai-for-software-development-certificate.png)
_Professional Certificate for completing the Generative AI for Software Development specialization_

Validate the certificate at the [validation link](https://learn.deeplearning.ai/certificates/f850bfc9-a310-48f2-b83e-a4e078b18c66).
