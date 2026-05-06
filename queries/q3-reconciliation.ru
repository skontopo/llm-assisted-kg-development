PREFIX voc: <https://swapi.co/vocabulary/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <http://schema.org/>
PREFIX gpt: <http://www.ontotext.com/gpt/>
PREFIX helper: <http://www.ontotext.com/helper/>
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX ex: <http://www.example.com/>

# Query 3 - Cross-graph entity reconciliation
INSERT {
    GRAPH ex:llm-outputs-q3 {
        ?source voc:wikidataLink ?match .
        << ?source voc:wikidataLink ?match >> ex:reason ?reason .
    }
}
WHERE {
    # Retrieve Princess Leia from the main Star Wars graph
    VALUES ?source {
        <https://swapi.co/resource/human/5> # Princess Leia
    }
    ?source a voc:Human ;
        rdfs:label ?sourceLabel .
    FILTER(LANG(?sourceLabel) = "")

    # Restrict to entities that are not already linked to Wikidata
    # Princess Leia is not already linked to any Wikidata entity, but this
    # filter could be applied for other entities in the Star Wars graph
    #FILTER NOT EXISTS {
    #    ?source voc:wikidataLink ?_ .
    #}

    # Build the candidate list from the local Wikidata slice
    {
        SELECT (helper:tupleAggr(?row) AS ?candidates) WHERE {
            GRAPH <ex:wikidata-starwars> {
                VALUES ?cand {
                    wd:Q51797		# Princess Leia
                    wd:Q15136385	# Princess Leia's bikini
                    wd:Q125307040	# Princess Leia Organa miniature action figure
                    wd:Q51746		# Luke Skywalker
                    wd:Q51802		# Han Solo
                }
                ?cand rdfs:label ?candLabel .
                FILTER(LANG(?candLabel) = "en")
                OPTIONAL {
                    ?cand schema:description ?candDesc .
                    FILTER(LANG(?candDesc) = "en")
                }
                BIND(
                    helper:tuple(
                                    STR(?cand),
                                    STR(?candLabel),
                                    COALESCE(STR(?candDesc), "")
                                ) AS ?row
                )
            }
        }
    }

    # Build the prompt
    BIND(
        CONCAT(
                  "We are reconciling a Star Wars knowledge graph entity with Wikidata. ",
                  "The local entity label is: ", STR(?sourceLabel), ". ",
                  "Candidate rows are given as: Wikidata IRI, label, description. ",
                  "Choose the best candidate only if it clearly refers to the same fictional character. ",
                  "Do not choose related objects, costumes, merchandise, or different characters. ",
                  "Return exactly one row with 3 columns: Wikidata IRI, label, short reason. ",
                  "If none is a good match, return: NONE, NONE, no-match."
              ) AS ?prompt
    )

    # Ask the LLM to pick the best candidate
    (?matchIri ?matchLabel ?reason) gpt:table (?prompt ?candidates 0.2)
    FILTER(STR(?matchIri) != "NONE")
    BIND(IRI(STR(?matchIri)) AS ?match)
}