---
layout: article
title: "The Sugar Rush of Vibe Coding: A YARP Experiment"
date: 2025-06-02 16:33:00 +0200
categories: [articles, software] # MAX 2 categories, TOP and SUB.
tags: [.net, yarp, reverse proxy, prometheus, grafana, vibe-coding, ai]
permalink: /posts/yarp/
description: "I built a reverse proxy twice: once with AI, once by hand. Here is what I learned about the future of engineering."
---

"Vibe coding" is having a moment. The idea is seductive: stop worrying about syntax and boilerplate, just "vibe" with the LLM, describe your intent, and let the machine handle the implementation. I find this promise both exciting and terrifying.

Exciting, because it lowers the barrier to entry and accelerates prototyping. Terrifying, because it risks creating a generation of "black box" engineers who can assemble systems but cannot repair them.

Recently, I had a real-world problem to solve at [Caspeco](https://caspeco.com/). We were migrating to Azure Container Apps and needed a custom reverse proxy to handle dynamic routing for our microservices. Since we are mostly a .NET shop, [YARP (Yet Another Reverse Proxy)](https://github.com/dotnet/yarp) was the obvious choice.

I decided to turn this task into an experiment. I would build the proxy twice.

1. **The Vibe Code:** Entirely AI-generated (Gemini 2.5 Pro / Cursor), with me acting only as the "prompt engineer."
2. **The Deep Work:** Written by hand, after reading the documentation and understanding the architecture.

Here is what I learned about the trade-off between speed and substance.

## Round 1: The AI "Sugar Rush"

I started with the AI. My prompt was high-level: _"I need a YARP reverse proxy that routes requests based on a query parameter. It needs to look up the target service in a database."_

The result was instant. In seconds, I had working code. It compiled. It routed traffic. It was magic.

But when I actually _looked_ at the code, the magic faded.

```csharp
// The AI-generated approach
app.Map("/products-api/{**rest}", async (HttpContext httpContext, string rest) =>
{
    // ... manual query parsing ...
    // ... manual database lookup ...

    var error = await forwarder.SendAsync(httpContext, targetUri, httpClient);

    if (error != ForwarderError.None)
    {
       // ... manual error handling ...
    }
});
```

The AI had treated YARP not as a framework, but as a low-level tool. It was manually constructing HTTP requests, handling forwarding errors, and parsing query strings inside a massive endpoint handler.

It was **brute-force engineering**. It worked, but it was fragile. It completely ignored YARP's powerful middleware pipeline, opting instead to reinvent the wheel inside a single function. It was the code equivalent of a sugar rush: instant energy, followed by a crash when you realize you have to maintain it.

## Round 2: The Craftsman Approach

For the second attempt, I closed the LLM and opened the [YARP documentation](https://microsoft.github.io/reverse-proxy/). I spent a few hours reading. I learned about the proxy pipeline, `IReverseProxyFeature`, and configuration providers.

The process was slower. It felt "tedious" compared to the chat interface. But the resulting code was radically different.

```csharp
// The Manual approach
app.MapReverseProxy(proxyPipeline =>
{
    // Injecting a custom step into the standard pipeline
    proxyPipeline.Use(MyCustomProxyStep);
    proxyPipeline.UseSessionAffinity();
    proxyPipeline.UseLoadBalancing();
});

// ...

Task MyCustomProxyStep(HttpContext context, Func<Task> next)
{
    // Using the framework's native features
    var proxyFeature = context.Features.Get<IReverseProxyFeature>();

    // ... clean, declarative logic ...

    return next();
}
```

This version was **idiomatic**. Instead of fighting the framework, it extended it. By hooking into the `proxyPipeline`, I leveraged YARP's built-in error handling, load balancing, and session affinity for free.

## The Verdict: Architect vs. Assembler

The difference between the two solutions wasn't just aesthetic; it was architectural.

The AI acted as an **Assembler**. It found pieces that fit together and glued them shut. It solved the _task_ ("route this request"), but missed the _intent_ ("build a maintainable proxy").

The manual approach required me to act as an **Architect**. I had to understand the system's design philosophy before writing a line of code.

This experiment highlighted a critical truth for my team: **AI is a multiplier for knowledge, not a replacement for it.** If I hadn't gone back and read the docs, I would have committed the AI version. It would have worked fine—until we needed to add load balancing, or retries, or distributed tracing. Then, the technical debt of that "vibe coded" solution would have crushed us.

## The Proof is in the Metrics

Of course, in Platform Engineering, "it feels better" isn't a valid metric. We need data.

To objectively compare the systems (and because I'm a metrics nerd), I spun up a monitoring stack with **Prometheus** and **Grafana**. I implemented the **RED Method** (Rate, Errors, Duration) for the services and the **USE Method** (Utilization, Saturation, Errors) for the infrastructure.

![Final Grafana Dashboard](/assets/images/yarp/grafana.png)

Interestingly, the performance difference was negligible for low traffic. But the _observability_ of the manual solution was superior. Because I used the standard YARP pipeline, the built-in metrics (like `yarp_requests_active`) worked out of the box. The AI version, with its custom forwarding logic, required me to manually instrument everything.

## Conclusion

Vibe coding is a powerful tool for exploration. It got me from "zero" to "working prototype" in minutes. But for production systems, there is no substitute for **Deep Work**.

As we integrate more AI into our workflows, our role as engineers shifts. We are doing less typing, but we must do _more_ thinking. We need to be the ones who know _why_ the code works, not just that it does.

If you are just "vibing," you aren't building software; you're just borrowing technical debt from the future.
