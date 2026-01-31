## Appendix: Solution Folders vs. Project Directories

When structuring a .NET solution in IDEs like Rider or Visual Studio, it's important to understand the distinction between Solution Folders and Project Directories:

- **Project Directory:**
  - This is a **physical folder** on your computer's file system (disk).
  - It's **mandatory** for every project (`.csproj`) and contains the project's files (source code, configuration, etc.).
  - The actual path of your code files is determined by these directories.

- **Solution Folder:**
  - This is a **logical folder** that exists _only_ within the Solution Explorer view of your IDE.
  - It's defined in the solution file (`.sln`) and is used purely for **organizing** projects and other solution items visually.
  - It **does not necessarily** correspond directly to a physical directory, although aligning them is common practice. You can group projects from different physical locations under one Solution Folder.

**Key Takeaway:** Creating a new project requires specifying a physical directory location. If you add a project via a Solution Folder in the IDE, the IDE might (not Rider) create the corresponding physical directories if they don't already exist, often leading to alignment between the logical (Solution Folder) and physical (Project Directory) structures. However, the core purpose of Solution Folders is IDE organization, while Project Directories are about the physical file layout.

---

## Appendix: Dependency Injection (DI) and Service Lifetimes

Dependency Injection is a design pattern crucial for building maintainable and testable applications, especially with microservices.

**Core Concept:**

- Instead of a class creating its own dependencies (e.g., `new ProductAppService(new InMemoryProductRepository())`), it declares what it needs (usually interfaces) via its constructor (`public ProductsController(ProductAppService appService)`).
- An external **DI Container** (provided by ASP.NET Core) is configured (in `Program.cs`) to know how to create instances of these dependencies.
- When an object is needed, the DI container automatically creates its required dependencies and "injects" them into the constructor. This inverts the control of dependency creation.

**Benefits:**

- **Loose Coupling:** Classes depend on abstractions (interfaces) rather than concrete implementations.
- **Testability:** Easy to substitute mock/fake dependencies during unit testing.
- **Flexibility:** Can swap implementations (e.g., in-memory repo for database repo) just by changing the DI configuration.

**Service Lifetimes (ASP.NET Core):**

When registering services with the DI container, you specify their lifetime:

- **`Transient` (`.AddTransient<>()`):** A new instance is created _every time_ the service is requested. Good for lightweight, stateless services.
- **`Scoped` (`.AddScoped<>()`):** A new instance is created _once per scope_ (typically per HTTP request in web apps). The same instance is reused within that single request. Ideal for services needing request-specific state (like EF Core DbContext) or depending on other Scoped services. **Most common choice.**
- **`Singleton` (`.AddSingleton<>()`):** A single instance is created on the first request and reused for _all subsequent requests_ across the application's lifetime. Use for stateless services, shared configuration/caches, or services managing application-wide state (must be thread-safe if mutable).

Choosing the correct lifetime is important for resource management, state handling, and thread safety.

---

## Appendix: Layered Input Validation Principles

In a layered architecture (like the one used for our microservices), validation often occurs at multiple levels, each with a specific responsibility:

- **API Layer (Controller / Request Models):**
  - **Responsibility:** Validates the incoming request _shape_ and _format_ against the API contract. Ensures required fields are present, data types are correct, values are within API-defined ranges/lengths.
  - **Mechanism:** Framework features like Data Annotations (`[Required]`, `[StringLength]`, `[Range]`) or libraries like FluentValidation on request DTOs.

- **Application Layer (Application Service / Use Case Handlers):**
  - **Responsibility:** Validates rules specific to the _use case_ being executed. May involve querying data (e.g., checking for uniqueness) or coordinating logic.
  - **Mechanism:** Custom code within the service/handler methods.

- **Domain Layer (Entity / Aggregate Root):**
  - **Responsibility:** Enforces _core business invariants_ – fundamental rules ensuring the domain object is always in a consistent, valid state according to business definitions.
  - **Mechanism:** Code within the entity's constructor and state-modifying methods.

This layered approach provides "defense in depth" against invalid data.

---
