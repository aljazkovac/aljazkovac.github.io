---
title: Designing Data-Intensive Applications
date: 2024-07-28 10:36:23 +0200
categories: [software, data] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [software, data, reading] # TAG names should always be lowercase.
description: Notes and thoughts on the book.
---

I am currently reading Martin Kleppman's book [Designing Data-Intensive Applications](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/).

I have greatly enjoyed reading Part I. I find the book to be very well-written in the sense that it walks the fine line between being technical but also not overy complicated. As a developer who is not an expert in the field of databases, I feel like I can perfectly follow the explanations and the more challenging technical passages, and feel like I am learning something valuable.

**Chapter 1** introduces the core principles of data systems: reliability, scalability, and maintainability.

**_Reliability_** refers to the system's ability to function correctly even when faults occur. This involves designing for fault tolerance, ensuring that the system can recover from hardware failures, software bugs, and human errors. I was surprised to learn about the technique of triggering faults deliberately, for example, by randomly killing individual processed without warning, to make sure that the fault-tolerance machinery is properly tested.

**_Scalability_** deals with the system's capacity to handle increased load. Load can be described with a few numbers, called load parameters. It is important to choose the correct load parameteres. The chapter discusses different ways to scale systems, either by adding more powerful hardware (vertical scaling) or by distributing the load across multiple servers (horizontal scaling). In reality, a well-designed system usually involves a mixture or approaches. The chapter also introduces a very interesting and concrete example of how Twitter handled its scaling challenge. I was shocked to learn that Amazon has observed that 100 ms increase in response time reduces sales by 1%, while other companies report that a 1-second slowdown reduces customer satisfaction by 16%. It was also interesting to learn how to calculate response time percentilese, e.g., by using one of the following algorithms: forward decay, t-digest, or HdrHistogram. You should also never average percentiles, but rather add the histograms! Another important thing to keep in mind is that data throughput can be deceiving: a system that needs to handle 100000 requests per second, each 1 kB in size, is very different from a system that needs to handle 3 requests per minute, each 2 GB in size.

**_Maintainability_** focuses on how easy it is to modify and operate the system over time. This includes considerations for operability (ease of managing the system), simplicity (avoiding unnecessary complexity), and evolvability (ease of making changes). Why is it important to discuss maintanence? Well, maintanence is what presents the majority of the cost of software. The initial development is only a small part of the final cost. Therefore, one of the main goals in software development should be reducing complexity, as this greatly improves the maintainability of software. Simplicity should be a key goal for the systems we build. However, reducing complexity does not equal reducing functionality. What we want to remove is accidental complexity (complexity that is not inherent in the problem that the software solves but arises only from implementation). One of the best tools for achieving this is abstraction.
