---
title: Designing Data-Intensive Applications
date: 2024-07-28 10:36:23 +0200
categories: [software, data] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [software, data, reading] # TAG names should always be lowercase.
description: Notes and thoughts on the book.
---

Here are my notes and thoughts on a few chapters from Martin Kleppman's book [Designing Data-Intensive Applications](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/).

I have greatly enjoyed reading Part I. I find the book to be very well-written in the sense that it walks the fine line between being technical but also not overy complicated. As a developer who is not an expert in the field of databases, I feel like I can perfectly follow the explanations and the more challenging technical passages, and feel like I am learning something valuable. I will summarize some selected chapters, mostly because I enjoy making notes after reading because it helps with long-term memory retention.

## Chapter 1

This chapter introduces the core principles of data systems: reliability, scalability, and maintainability.

**Reliability** refers to the system's ability to function correctly even when faults occur. This involves designing for fault tolerance, ensuring that the system can recover from hardware failures, software bugs, and human errors. I was surprised to learn about the technique of triggering faults deliberately, for example, by randomly killing individual processes without warning, to make sure that the fault-tolerance machinery is properly tested.

**Scalability** deals with the system's capacity to handle increased load. Load can be described with a few numbers, called load parameters. It is important to choose the correct load parameters. The chapter discusses different ways to scale systems, either by adding more powerful hardware (vertical scaling) or by distributing the load across multiple servers (horizontal scaling). In reality, a well-designed system usually involves a mixture or approaches. The chapter also introduces a very interesting and concrete example of how Twitter handled its scaling challenge. I was shocked to learn that Amazon has observed that **100 ms** increase in response time reduces sales by 1%, while other companies report that a **1-second** slowdown reduces customer satisfaction by 16%. It was also interesting to learn how to calculate response time percentiles, e.g., by using one of the following algorithms: forward decay, t-digest, or HdrHistogram. You should also never average percentiles, but rather add the histograms! Another important thing to keep in mind is that data throughput can be deceiving: a system that needs to handle 100000 requests per second, each 1 kB in size, is very different from a system that needs to handle 3 requests per minute, each 2 GB in size.

**Maintainability** focuses on how easy it is to modify and operate the system over time. This includes considerations for operability (ease of managing the system), simplicity (avoiding unnecessary complexity), and evolvability (ease of making changes). Why is it important to discuss maintanence? Well, maintanence is what presents the majority of the cost of software. The initial development is only a small part of the final cost. Therefore, one of the main goals in software development should be reducing complexity, as this greatly improves the maintainability of software. **Simplicity should be a key goal for the systems we build.** However, reducing complexity does not equal reducing functionality. What we want to remove is accidental complexity (complexity that is not inherent in the problem that the software solves but arises only from implementation). One of the best tools for achieving this is abstraction. Finding good abstractions, however, is a real challenge.

## Chapter 2

This chapter explores various data models and their corresponding query languages, which are fundamental to how data is stored, queried, and processed. **Data models are perhaps the most important part of developing software because they influence not only how the software is written, but also how we think about the problem that we are solving.**

**Relational data models** have been dominant for decades and are based on the concept of tables and fixed schemas. SQL is the primary query language for relational databases.

**Document data models** store data in semi-structured formats like JSON or XML, allowing for more flexible schemas. This approach is used in databases like MongoDB and CouchDB, where data is often nested and may vary from document to document.

**Graph data models** represent data as nodes and edges, which is ideal for applications involving relationships, such as social networks. Query languages like Cypher (used in Neo4j) and SPARQL (used in RDF databases) are discussed.

The chapter compares these models, discussing their strengths and weaknesses, and how to choose the appropriate model based on the use case.

It was interesting to learn about the models that competed with the relational model before it came to dominate them. Those models were mainly the network model (CODASYL) and the hierarchical model. The thing that turned out to be the greatest strength of the relational model is that it generalizes very well, much beyond its original scope of business data processing. The latest attempt to overthrow relational model's dominance is NoSQL (document and graph databases). A common criticism of the SQL data model is that if data is stored in relational tables then a translation layer is required between the objects in the application code and the database model. This is called an **impedance mismatch**. For example, a résumé, fits better into a JSON representation because it is a self-contained document. The JSON representation has better **locality** because you don't need to perform multiple queries and joins.

The main benefits of document databases today are:

1. Better performance due to locality
2. Schema flexibility
3. A lesser need to translate data structures used by the application

The main benefits of relational databases today are:

1. Better support for joins
2. Better support for many-to-one and many-to-many relationships

It seems, however, that relational and document databases are coming closer to each other with time, and a hybrid of both models is a good way forward.

Then there is the thid option, as mentioned above, Graph-like data models. These are most appropriate for data that is very interconnected. A graph simply consists of **vertices** (nodes or entities) and **edges** (relationships or arcs). Some typical examples of data that can be modelled as a graph are: social graphs, the web graph, or road and rail networks. There are different ways of structuring and querying data in graphs, e.g., the **property graph model** and the **triple-store model**.

What the two NoSQL data models have in common is that they don't enforce a schema, which makes it easier to adapt applications to changing requirements. However, the application still assumes that data has a structure, so the question is really if the schema is explicit (enforced on write) or implicit (handled on read).

## Chapter 7

This chapter is about transactions and the various problems that arise with transactions, e.g., problems related to concurrency control, and how to solve them. There is an important term that describes the safety guarantees provided by transactions, **ACID**, which stands for Atomicity, Consistency, Isolation, and Durability. But as the author points out, the interpretations and implementations of **ACID** differ greatly.

**Atomicity** is the ability to abort a transaction on error and have all writes from that transaction discarded.

**Consistency** is the idea that we have certain statements about our data (invariants) that must always be true.

**Isolation** means that concurrently executing transactions are isolated from each other.

**Durability** is the promise that once a transaction has committed successfully, the data it has written to the database will not be forgotten.

There exist various isolation levels that are used to control concurrency: **read committed**, **snapshot isolation**, and **serializable**. There are meant to deal with and prevent various race conditions, e.g., **dirty reads**, **dirty writes**, **read skew**, **lost updates**, **write skew**, **phantom reads**, etc. Weak isolation levels protect against some of them, but most of them need to be handled manually. The only isolation level that protects against all of them is serializable isolation. There are three different approaches to implement it:

1. Literally executing transactions in a serial order
2. Two-phase locking
3. Serializable snapshot isolation (SSI): when a transaction wants to commit, it is checked; if the execution was not serializable, the transaction is aborted.
