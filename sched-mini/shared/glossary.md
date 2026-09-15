# Glossary (Layer 3, canonical names)

Every stage uses these names in its output files, whatever words the expert
used in conversation. Stage 1 records the expert's own word alongside each.

| Canonical | Meaning | Typical expert words |
|---|---|---|
| **order** | A demanded quantity of one product with a due date | job, batch, customer order, PO |
| **product** | A thing the plant makes, with a fixed recipe of steps | SKU, beer, part, item |
| **step** | One operation in a product's recipe, performed on a resource | stage, process, operation, station |
| **resource** | A machine, tank, line, or crew that performs steps; finite capacity | tank, line, machine, cell, the guys |
| **duration** | Hours a step occupies its resource for one order | cycle time, how long it takes |
| **due date** | Hour by which an order should be complete | promise date, ship date |
| **release** | Earliest hour an order can start | when the material arrives |
| **setup / changeover** | Time lost on a resource between different products | cleaning, CIP, changeover, teardown |
| **precedence** | Step B cannot start before step A finishes (same order) | "then it goes to…" |
| **objective** | What a good schedule minimizes or maximizes | "I want to…", "the worst thing is…" |
| **flow shop** | Every product visits resources in the same order | (rarely named by expert) |
| **job shop** | Products visit resources in product-specific orders | (rarely named by expert) |
