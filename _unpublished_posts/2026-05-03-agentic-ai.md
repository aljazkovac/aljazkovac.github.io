---
title: Agentic AI
date: 2026-05-03 08:00:00 +0100
permalink: /posts/agentic-ai/
categories: [notes, ai]
tags: [ai, agentic ai, software]
description: Notes from the DeepLearning.AI course on agentic AI.
mermaid: true
---

## Module 1: Introduction to Agentic Workflows

An agentic workflow follows, in a more or less autonomous way, a flow where thinking and research is followed by revision, which is followed by more thinking and research, etc. In other words, an LLM-based app executes multiple steps to complete a task.

Agentic AI can range from less autonomous to highly autonomous.

![Degrees of Autonomy](/assets/images/agentic-ai/agentic-ai-degrees-of-autonomy.png)

The benefits of agentic workflows:

- better performance than non-agentic workflows
- parallelization
- modular: can add or update tools, swap out models

![Tasks for Agentic AI](/assets/images/agentic-ai/agentic-ai-tasks.png)

### Task decomposition

Breaking a task down into smaller steps can lead to better results than direct generation or one-shot prompting.

![Breaking Down Tasks for Agentic AI](/assets/images/agentic-ai/agentic-ai-task-decomposition.png)

Building blocks:

- Models: LLMS, other AI models
- Tools: API, information retrieval, code execution

Break down the individual steps until you can implement them meaningfully with one of the building blocks.

### Evaluating agentic AI (evals)

Once you have built an agentic workflow, look at the outputs and focus on the low-quality outputs!

You can either:

- Use objective evals: add an evaluation to track the error in code
- Use subjective evals: use an LLM as a judge

In terms of the scope/focus of evaluation we have:

- End-to-end evals
- Component-level evals

We may also want to examine intermediate outputs and examine traces to perform error analysis.

### Agentic design patterns

The four key design patterns for building agentic workflows:

- Reflection: an agent reflects on its own output, e.g., problems with the code; you could also have a separate critic agent which provides feedback which the main agent reflects and acts upon.
- Tool use: web search tool, code execution tool, etc.
- Planning: plans the sequence of actions and tools needed to finish the task
- Multi-agent collaboration: multiple agents with different roles collaborating on a task outperform a single agent

## Module 2: Reflection Design Pattern

Reflection is much more powerful when you can inject additional, external information, into the reflection process. An example of this would be running the code that the LLM wrote and then use the output of that to improve the code.

![Reflection with External Feedbac](/assets/images/agentic-ai/agentic-ai-reflection.png)

Reflection performs better than zero (zero examples of input and output given, just a direct prompt) or one (one example given) or few-shot prompting (few examples given).

![Tasks for Reflection](/assets/images/agentic-ai/agentic-ai-reflection-tasks.png)

Tips for writing reflection prompts:

- Clearly indicate the reflection action
- Specify criteria to check

You may consider using a different LLM for reflection, e.g., a multimodal LLM which can also take images as reflection input. Using a reasoning model for reflection might work better than using a non-reasoning model.

Evaluating reflection:

- Objective database queries, e.g, calculating various metrics
- Using an LLM as a judge for subjective tasks, e.g., judging which graph is better

Using LLMs for comparison or evaluation is problematic:

- Often not very good
- Position bias (LLMs often prefer the first option)

This can be mitigated with a quality rubric (grading criteria).

Evaluating reflection guidelines:

1. Objective evals:
   - Code-based evals are easier
   - Build a dataset of ground truth examples
2. Subjective evals:
   - Use LLM as a judge
   - Rubric-based grading is better

![External Feedback Improvement](/assets/images/agentic-ai/agentic-ai-external-feedback.png)

![Tools to Help Reflection](/assets/images/agentic-ai/agentic-ai-reflection-tools.png)

## Module 3: Tool use

Tools are functions that enable LLMs to access outside information, perform actions, e.g., web_search, query_database, interest_calc, etc.

In other words, tools are code that the LLM can request to be executed. Modern, premium LLMs, are trained to use tools. At the start of the LLM era, the LLM had to be prompted explicitly to use a specific tool.

You can also let an LLM write and execute code! This can pose risks, so consider executing LLM-written code in sandboxed environments. MCP (Model Context Protocol) is a new standard for developer to get access to a wealth of tools.

## Module 4: Practical Tips for Building Agentic AI

## Module 5: Patterns for Highly Autonomous Agents

## Certificate

![Spec Driven Development Course Accomplishment](/assets/images/spec-driven-development/spec-driven-development-certficate.png)
_Accomplishment - completing the course Spec-Driven Development_

Validate the accomplishment at the [validation link](https://learn.deeplearning.ai/accomplishments/effdff70-8dad-4a3a-8c55-9a66d50cd657).
