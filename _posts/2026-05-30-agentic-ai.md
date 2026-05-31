---
title: Agentic AI
date: 2026-05-30 08:00:00 +0100
permalink: /posts/agentic-ai/
categories: [notes, ai]
tags: [ai, agentic ai, software]
description: Notes from the DeepLearning.AI course on agentic AI workflows and design patterns.
mermaid: true
---

## Module 1: Introduction to Agentic Workflows

An agentic workflow follows an iterative cycle where thinking and research are followed by revision and further refinement. Unlike traditional linear prompts, an LLM-based application executes multiple steps autonomously to complete a complex task.

Agentic AI can range from low to high levels of autonomy depending on the design.

![Degrees of Autonomy](/assets/images/agentic-ai/agentic-ai-degrees-of-autonomy.png)

### Benefits of Agentic Workflows

- **Superior Performance:** Outperforms non-agentic workflows on complex reasoning tasks.
- **Parallelization:** Ability to run multiple sub-tasks concurrently.
- **Modularity:** Easy to add tools, update capabilities, or swap underlying models.

![Tasks for Agentic AI](/assets/images/agentic-ai/agentic-ai-tasks.png)

### Task Decomposition

Breaking a task down into smaller, manageable steps often yields better results than direct generation or one-shot prompting.

![Breaking Down Tasks for Agentic AI](/assets/images/agentic-ai/agentic-ai-task-decomposition.png)

**Building Blocks:**

- **Models:** LLMs and specialized AI models.
- **Tools:** APIs, information retrieval (RAG), and code execution.

The goal is to decompose tasks until each step can be handled reliably by one of these building blocks.

### Evaluating Agentic AI (Evals)

Once a workflow is built, focus on the low-quality outputs to drive improvements.

- **Objective Evals:** Automated checks (e.g., code execution results, unit tests).
- **Subjective Evals:** Using an LLM as a judge to evaluate qualitative aspects.

Evaluation can happen at different scales:

- **End-to-End:** Testing the entire workflow.
- **Component-Level:** Testing individual steps or tools.

Examining intermediate traces is essential for effective error analysis.

### Agentic Design Patterns

There are four primary design patterns for building agentic workflows:

```mermaid
graph TD
    A[Agentic Design Patterns] --> B[Reflection]
    A --> C[Tool Use]
    A --> D[Planning]
    A --> E[Multi-agent Collaboration]
    B --> B1[Self-reflection]
    B --> B2[Critic Agent]
    D --> D1[JSON/Text Plan]
    D --> D2[Planning with Code]
    E --> E1[Linear Handoff]
    E --> E2[Hierarchical]
```

- **Reflection:** The agent critiques its own output or receives feedback from a critic agent.
- **Tool Use:** Leveraging external tools like web search or database queries.
- **Planning:** The agent determines the sequence of actions needed to reach a goal.
- **Multi-agent Collaboration:** Specialized agents working together often outperform a single generalist agent.

## Module 2: Reflection Design Pattern

Reflection becomes significantly more powerful when external information is injected into the cycle. For example, running generated code and passing the execution errors back to the LLM allows it to self-correct.

```mermaid
graph LR
    A[Initial Prompt] --> B[LLM Generates Code]
    B --> C[Execute Code in Sandbox]
    C --> D{Success?}
    D -- No --> E[Pass Error to LLM]
    E --> F[LLM Reflects and Fixes]
    F --> B
    D -- Yes --> G[Final Output]
```

![Reflection with External Feedback](/assets/images/agentic-ai/agentic-ai-reflection.png)

Reflection consistently outperforms zero-shot, one-shot, and few-shot prompting for complex logic.

![Tasks for Reflection](/assets/images/agentic-ai/agentic-ai-reflection-tasks.png)

### Tips for Reflection Prompts

- Clearly define the reflection action (e.g., "Review the following code for security vulnerabilities").
- Specify explicit criteria for the check.
- Consider using a specialized reasoning model or a multimodal LLM for the reflection step.

### Evaluating Reflection

Using LLMs for evaluation can introduce position bias (preferring the first option). To mitigate this, use a clear **quality rubric** with specific grading criteria.

![External Feedback Improvement](/assets/images/agentic-ai/agentic-ai-external-feedback.png)

![Tools to Help Reflection](/assets/images/agentic-ai/agentic-ai-reflection-tools.png)

## Module 3: Tool Use

Tools are functions that enable LLMs to interact with the world—searching the web, querying databases, or performing calculations.

Modern LLMs are specifically trained for tool calling. A significant advancement is the **Model Context Protocol (MCP)**, which provides a standardized way for agents to access a broad ecosystem of tools.

**Safety Note:** Always execute LLM-generated code in a sandboxed environment to prevent security risks.

## Module 4: Practical Tips for Building Agentic AI

Build a quick prototype first. This helps identify which components are performing unsatisfactorily so you can focus your efforts where they matter most.

### The Iterative Development Process

1. **Build:** Create an end-to-end prototype.
2. **Analyze:** Examine traces and outputs to find weaknesses.
3. **Measure:** Implement evals and track metrics.
4. **Refine:** Improve prompts, swap models, or tune hyperparameters.

### Optimization

- **Latency:** Time each step. Use parallelism or faster models for non-critical steps.
- **Cost:** Measure per-token cost per step to identify expensive components.

## Module 5: Patterns for Highly Autonomous Agents

### Planning

Rather than hardcoding a sequence, ask the LLM to create a plan. Research indicates that **Planning with Code** (where the LLM writes a script to solve the problem) often produces more robust results than simple JSON-based plans.

![Planning with JSON](/assets/images/agentic-ai/agentic-ai-planning.png)
_Example of JSON-based planning_

![Planning with Code](/assets/images/agentic-ai/agentic-ai-planning-with-code.png)
_Planning where the LLM writes and executes code_

### Multi-Agent Systems

Complex tasks often benefit from a "team" of agents (e.g., Researcher, Writer, and Editor).

**Communication Patterns:**

- **Linear:** Sequential handoffs.
- **Hierarchical:** A "manager" agent delegating to specialists.
- **All-to-all:** Collaborative communication.

## Summary

Agentic AI transforms LLMs from passive text generators into active problem solvers through:

- **Reflection** for self-correction.
- **Tool Use** for external interaction.
- **Planning** for complex sequences.
- **Multi-agent Systems** for specialized collaboration.

## Certificate

![Agentic AI Certificate](/assets/images/agentic-ai/agentic-ai-certificate.png)
_Certificate for completion of the Agentic AI course_

Validate the certificate at the [DeepLearning.AI validation link](https://learn.deeplearning.ai/certificates/c9102bb2-5c3e-482e-9cbe-cd9d2ff0f246).
