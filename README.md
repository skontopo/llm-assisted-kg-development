# llm-assisted-kg-development
Practical examples and resources for using LLMs as human-guided assistants in knowledge graph enrichment, semantic linking, and entity reconciliation.


## About

This repository accompanies the article **“Building Knowledge Graphs with an AI Wingman”**.

The goal is to show how an LLM can support a Knowledge Graph engineer during KG development, without replacing the human expert. The examples use [Graphwise GraphDB](https://graphwise.ai/components/graphdb/) and its [GPT/SPARQL integration](https://graphdb.ontotext.com/documentation/11.3/gpt-queries.html) to demonstrate three small but practical workflows:

1. adding alternative labels to existing entities;
2. enriching entities with controlled semantic categories;
3. reconciling a local KG entity with candidate Wikidata entities.

The main idea is simple: the LLM proposes, but the human validates and commits.


## Data

The `data/` folder contains the input data used by the examples.

- `starwars-data.ttl`: This is the main Star Wars RDF Knowledge Graph. It contains entities such as characters, species, films, planets, starships, and vehicles. Downloaded from [here](https://www.ontotext.com/blog/the-rise-of-the-knowledge-graph/). 
- `wikidata-slice.ttl`: This is a small local Wikidata slice with selected Star Wars-related entities. It is used in the [reconciliation example](queries/q3-reconciliation.ru), where the LLM chooses the best Wikidata match for a local KG entity. The slice intentionally contains similar or related entities, so that the LLM needs to disambiguate between them.


## Queries

The `queries/` folder contains three SPARQL Update queries.

1. [Query 1 - Lexical enrichment](queries/q1-synonyms.ru): This query asks the LLM to suggest alternative labels or aliases for existing entities in the Star Wars KG. The output is inserted into a separate named graph.
2. [Query 2: Controlled semantic enrichment](queries/q2-semantic-enrichment.ru): This query asks the LLM to classify Star Wars films into a small set of human-defined themes. The LLM does not invent arbitrary new concepts; instead, it chooses only from a controlled list of themes. This keeps the enrichment process more controlled and easier to review.
3. [Query 3: Cross-graph reconciliation](queries/q3-reconciliation.ru): This query retrieves Princess Leia from the local Star Wars KG and asks the LLM to choose the best matching Wikidata entity from the local Wikidata slice. The point is to show the LLM as a disambiguation assistant. It receives a small candidate set and chooses the entity that best matches the local KG entity. The final decision should still be reviewed by a human.


## Output

The `output/` folder contains exported named graphs produced by the three queries. The files use the .trigs extension because the outputs contain named graph data and RDF-star triples.


## Setup

The examples in this repository are designed to be run on a local GraphDB instance.

1. Install Graphwise GraphDB locally.
2. Configure LLM access by providing an API key in the GraphDB configuration.
3. Create a local repository in GraphDB.
4. Load the [input data](data). The Star Wars dataset can be loaded into the default graph, while the Wikidata slice should be loaded into a named graph, e.g. `wikidata-slice`. Make sure this graph IRI matches the graph IRI used in `q3-reconciliation.ru`.
5. Running the examples: Run the SPARQL queries in the [queries](queries) folder. Each query writes its results into a separate named graph.

> [!CAUTION]
> The exact LLM output may vary slightly, because LLMs are not fully deterministic. The queries use low temperature to reduce variation, but human review is still expected.


## Important note

The results produced by the LLM should be treated as suggestions, not as final truth.

This repository demonstrates a human-in-the-loop pattern: `KG data → LLM suggestion → human review → accepted KG enrichment`.

This is especially important for semantic enrichment and entity reconciliation, where a wrong link can introduce misleading knowledge into the graph.

## License

This repository is released under the MIT License.
