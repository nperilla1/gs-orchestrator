# GrantSmiths Technology Constitution

**Version**: 0.2
**Date**: 2026-02-21

---

## Preamble

GrantSmiths connects organizations with funding by telling their stories in ways that funding agencies care to hear. Every piece of technology we build exists to serve that mission.

This requires data — legislative data, organizational data, community data, evidence, financial data, geographic data, and more. Each piece of data becomes more valuable when connected to other pieces. An organization's profile is useful. That profile connected to relevant funding opportunities, community need data, and historical evidence is transformative.

This document governs how we build technology. It defines what we believe, how we make decisions, and what rules we follow. It applies to everything we build — every service, every interface, every schema, every line of code. When there's a fork in the road, this document tells us which way to go.

---

## Article I: Beliefs

These are what we hold to be true. They are not negotiable.

### I.1: The accumulated data is our most valuable asset.

Every service we build either contributes data or uses data. Services can be rewritten. Interfaces can be redesigned. Data that has been gathered, cleaned, analyzed, and connected cannot be easily reproduced. We protect it accordingly.

### I.2: Data becomes more valuable when connected.

A funding opportunity in isolation is a record. That opportunity connected to eligible organizations, community need indicators, legislative history, and evidence of past success is intelligence. Our technology exists to build and deepen these connections.

### I.3: The best architecture is the one that ships working software.

We do not build for hypothetical future requirements. We do not build platforms before we have things that need a platform. We build specific things that solve real problems, and we let the architecture emerge from the patterns we observe across those things.

### I.4: Boundaries exist to protect, not to isolate.

We separate concerns so that changes in one area don't break another. But separation is a means to stability, not an end in itself. When separation makes the system harder to build or the data harder to connect, we are doing it wrong.

### I.5: Multiple experiences, same truth.

Users may interact with our capabilities through different interfaces — visual, conversational, automated, or hybrid. All interfaces must operate on the same underlying data and capabilities. No interface should have access to capabilities or data that others cannot reach. The experience differs; the truth does not.

### I.6: Quality of data over speed of development.

When forced to choose between shipping faster and getting the data model right, we get the data model right. A schema that ships on Tuesday instead of Monday and serves us for three years is better than one that ships Monday and requires a painful migration in six months.

---

## Article II: Data

### II.1: The Shared Database

All services and interfaces operate on a single shared database. This is deliberate. The value of our data comes from its interconnection, and a shared database makes that interconnection possible through simple, reliable means. We do not distribute data across separate databases unless there is a compelling and documented reason.

### II.2: Schemas as Boundaries

Within the shared database, each domain owns one schema. A schema is a domain's territory. Only code belonging to that domain may write to that schema. Other domains may read from it. This is enforced at the database level through role-based access, not through developer discipline alone.

### II.3: The Shared Kernel

Some entities genuinely span all domains — organizations, funding opportunities, geographic regions. These live in shared kernel schemas. The shared kernel must be:

- **Small**: Only entities that truly need to be shared belong here.
- **Stable**: Changes require review and coordination because every domain depends on it.
- **Governed**: Writes go through shared validation logic, not through any single domain's code.

When in doubt about whether something belongs in the shared kernel or in a domain schema, put it in the domain schema. It can always be promoted later. Demoting shared kernel entities is painful.

### II.4: Raw Data and Analyzed Data

Every domain that ingests external data has two layers:

- **Raw data**: Information as received from external sources, minimally transformed. Kept for provenance, auditability, and reprocessing. Internal to the domain. Named with a `raw_` prefix.
- **Analyzed data**: The domain's contribution to the ecosystem — enriched, scored, classified, interpreted. This is what other domains consume. Named without prefix.

Raw tables may change structure freely. Analysis tables are the domain's published contract with the rest of the system. Renaming or removing columns from analysis tables requires coordination with consumers.

If a domain improves its analysis methodology, it reprocesses raw data into updated analysis. Consumers of the analysis benefit automatically on their next read.

### II.5: Global Data and Client Data

Not all data is equal in terms of ownership:

- **Global reference data** — funding opportunities, legislation, community statistics, geographic data. This belongs to no single client. It is shared infrastructure that any domain may use.
- **Client work product** — applications, narratives, strategies, deliverables produced for a specific client organization. This is private to that client.

Client work product must be scoped to the client organization it belongs to. Global reference data is accessible to all. Every table should have a clear answer to the question: "Whose data is this?" If the answer is "a specific client," it must be scoped and isolated.

### II.6: Snapshots for Deliverables

Domains that produce deliverables — documents, reports, applications submitted to external parties — must capture the data they relied on at the time of production. Analysis data may be reprocessed and updated (II.4), but a delivered document reflects what was true when it was created. Subsequent data updates do not retroactively change completed deliverables.

Domains that produce analysis — scores, trends, classifications — should always reflect the latest data. No snapshots needed.

### II.7: Schema Changes Are Governed

Every schema change goes through migration tooling and version control. No direct DDL against production. No exceptions. Emergency changes are documented retroactively with a decision record explaining why the process was bypassed.

Shared kernel schema changes require review from anyone whose domain reads from the affected tables.

### II.8: Data Lifecycle

Raw data accumulates. Not all of it needs to be retained indefinitely. Each domain must define and document retention policies for its raw data, considering compliance obligations, storage costs, and reprocessing needs. Analyzed data follows the lifecycle of its domain. Retention policies are documented in each service's own documentation, not in this constitution, because they vary by data type and compliance context.

---

## Article III: Services

A service is a unit of software that owns a domain, operates on the shared database, and exposes its capabilities through an API.

### III.1: One Service, One Domain

Each service owns exactly one domain and one schema. It is the sole authority on that domain's logic and data. If two services need to write to the same schema, the domain boundary is wrong and must be redrawn.

### III.2: Independence

A service must be buildable, testable, and runnable on its own. It may depend on the shared database and shared kernel schemas. It must not depend on another service's code being importable or another service's process being running to start. Dependencies on other services are runtime and handled gracefully — a service operates in degraded mode when optional dependencies are unavailable, and fails clearly when core dependencies are unavailable.

### III.3: API as the Action Contract

When service A needs service B to perform an action — fetch data, trigger a process, run an analysis — it calls service B's API. It does not write to service B's database tables. It does not rely on service B polling for changes. Every service exposes an API that covers its core operations. The API is documented.

### III.4: Schema as the Read Contract

When service A needs to read service B's data, it reads from service B's analysis tables in the shared database. This is not a violation of boundaries — it is the intended integration mechanism. The analysis tables (non-`raw_*` tables) are service B's published read contract. Service B must not make breaking changes to these tables without coordination.

When a service needs to insulate consumers from its internal table structure, it publishes views (prefixed `v_`). Consumers read the views instead of the underlying tables.

### III.5: Solve Real Problems

Each service exists to solve a specific, real problem. If you cannot explain what problem a service solves in one sentence without referencing other services, it probably should not be a separate service. Do not build services that only have value as infrastructure for other services that don't exist yet.

### III.6: Complete the Data Contribution

A service is not done until its data contribution is usable: schema finalized, API operational, core analysis tables populated. The code can be rough. The UX can be minimal. But the data must be there for other domains to read and benefit from. Incomplete services — started but not contributing data — are dead weight in the ecosystem. Do not abandon a service before its data contribution is complete.

### III.7: Shared Code

Code shared across services — database connection utilities, shared kernel entity models, configuration patterns — lives in a shared package. This package must be kept as small as possible. If the shared package is growing, a domain boundary is likely wrong. Duplicating a small utility across two services is better than creating a shared dependency that couples them.

---

## Article IV: Interfaces

An interface is a layer that gives users or automated systems access to service capabilities. It translates intent into service API calls and presents results.

### IV.1: Interfaces Are Thin

Business logic, data transformation, analysis, and computation belong in services. Interfaces translate intent — they do not perform domain work. If an interface is growing complex, the complexity almost certainly belongs in a service.

### IV.2: Interfaces Call APIs

Interfaces interact with services through their published APIs. They do not import service code. They do not write to service schemas. For read-only display, interfaces may query the shared database through published views — but only views explicitly published for interface consumption, not internal service tables.

### IV.3: Same Capabilities, Different Experiences

All interfaces access the same services and the same data. A capability available through one interface must be reachable through any other. The interfaces differ in how they present information and accept input — not in what they can do.

### IV.4: Interfaces With State

Some interfaces maintain their own persistent state — conversation memory, user preferences, session context, orchestration logic. This is permitted. The state management follows service rules: it owns its own schema, it does not write to other schemas, and it exposes its capabilities through an API. The interface remains thin in terms of domain logic even if it is rich in orchestration logic.

---

## Article V: Boundaries and Integration

### V.1: Write Isolation

A domain's code may only write to its own schema. This is the most important boundary rule. It is enforced at the database level, not by convention. If a domain needs to cause a change in another domain, it calls that domain's API.

### V.2: Read Access

Any domain may read from any other domain's published data (analysis tables or published views). This is the intended integration mechanism — the shared database exists to make this easy. Cross-schema reads create a soft dependency: if the source domain changes its analysis table structure, the consuming domain may break. This is managed through coordination and the schema change governance process (II.7), not by prohibiting cross-schema reads.

### V.3: Foreign Keys

Foreign keys may reference shared kernel tables. Foreign keys must not reference another domain's tables. Cross-domain data references use the ID value stored as a column without a database-enforced constraint. This allows domains to evolve their schemas independently.

### V.4: Three Categories of Schema

Every schema falls into one of three categories:

- **Shared Kernel**: Stable reference entities used by all domains (organizations, funding opportunities, geographic entities). Small, stable, governed. Write access is controlled by shared validation logic.
- **Infrastructure**: Shared capabilities accessed as a service (vector search, document storage, embedding). Internal schemas that other domains do not query directly — they use the service's API. Infrastructure schemas may change freely because no other domain depends on their structure.
- **Domain**: Owned by one service. That service controls reads and writes. The analysis tables are the published contract.

New schemas are classified at creation. Reclassification requires a decision record.

### V.5: No Circular Dependencies

If service A calls service B's API, service B must not call service A's API. Circular dependencies between services make the system fragile and hard to reason about. If two services need to trigger each other, the dependency should be refactored — usually by extracting the shared concern into a third service, or by using the shared database as the coordination mechanism (one service writes data, the other reads it on its own schedule).

---

## Article VI: Decision-Making

### VI.1: Questions That Must Be Asked

Before building anything, these questions must have clear answers:

**For a new service:**
- What specific problem does this solve?
- What data does it contribute to the ecosystem?
- What schema will it own?
- What will other domains be able to read from it?
- What are its core dependencies vs. optional dependencies?

**For a new schema or table:**
- Is this raw data or analyzed data?
- Is this global reference data or client work product?
- Does this belong in an existing schema or a new one?
- If new, which of the three categories (shared kernel, infrastructure, domain)?
- Who are the expected consumers?

**For a new interface:**
- What services does it need?
- Do those services exist and have stable APIs?
- What state, if any, does this interface need to persist?
- Could this capability be exposed through an existing interface instead?

**For connecting to another domain's data:**
- Am I reading or triggering an action?
- If reading: am I using published analysis tables or internal tables?
- If triggering: am I calling the service's API?
- What happens if that domain's data or service is unavailable?

### VI.2: Decision Records

Significant decisions are documented as Architecture Decision Records stored in version control. A decision record captures context (what situation forced the decision), the decision itself, and the consequences accepted.

A decision record is required for:
- Creating a new schema
- Adding to or modifying the shared kernel
- Creating a new service
- Creating a new interface
- Introducing a new technology or framework
- Deviating from any rule in this constitution

A decision record can be as short as three sentences. The value is not in the length — it is in the record existing at all, so that future builders understand why a choice was made.

### VI.3: Priorities

When two principles in this constitution appear to conflict, these priorities apply in order:

1. Protect the integrity of existing data
2. Maintain domain boundaries
3. Ship working software
4. Keep things simple

When a decision is ambiguous and this constitution does not clearly resolve it, prefer the option that keeps domains more independent over the option that couples them. Coupling is easy to add later and hard to remove.

---

## Article VII: Scope and Evolution

### VII.1: What This Constitution Covers

This document governs how technology components relate to each other: data architecture, service boundaries, interface patterns, and decision-making frameworks. It applies to all technology built at GrantSmiths.

### VII.2: What This Constitution Does Not Cover

- Specific technology choices (languages, frameworks, cloud providers)
- Deployment and infrastructure operations
- Security policies and access control implementation
- Testing standards (these belong in each service's documentation)
- Team structure and roles
- Business strategy

These are important but governed by separate documents.

### VII.3: Evolution

This constitution is stored in version control. Changes require a decision record explaining what changed and why. Changes should be infrequent. If we are changing this document often, we got the principles wrong.

### VII.4: Assumptions

This constitution assumes a small team building on shared infrastructure. As the team and system grow, these principles may need to evolve — particularly around schema governance, service coordination, and deployment independence. Growth-driven changes are documented through the standard decision record process.

### VII.5: Enforcement

Principles that can be enforced automatically should be. Schema write isolation is enforced by database roles. Migration governance is enforced by tooling. Code boundaries are enforced by tests. Rules that rely solely on developer discipline will eventually be violated under deadline pressure.

Every service's development guide must reference this constitution and summarize the rules most relevant to that service's domain.
