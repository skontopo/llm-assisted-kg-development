PREFIX voc: <https://swapi.co/vocabulary/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX gpt: <http://www.ontotext.com/gpt/>
PREFIX ex: <http://www.example.com/>

# Query 1 - Alias enrichment
INSERT {
    GRAPH ex:llm-outputs-q1 {
        ?entity skos:altLabel ?alias .
    }
}
WHERE {
    {
        # Retrieve all the relevant entities from the dataset
        SELECT DISTINCT ?entity ?label WHERE {
            ?entity a ?type ;
                rdfs:label ?label .
            VALUES ?type { # Modify the set of entity types as needed
                voc:Character
                voc:Human
                voc:Droid
                voc:Planet
                voc:Film
                voc:Starship
                voc:Vehicle
                voc:Species
            }
            FILTER(LANG(?label) = "") # Make things simple: Keep only the "default" labels
        }
    }

    # Build the prompt
    BIND(
        CONCAT(
                  "For the Star Wars entity '", STR(?label), "', suggest up to 3 short alternative labels or aliases. ",
                  "Only return plausible Star Wars aliases, lexical variants, or shortened forms. ",
                  "If there is no good alias, return NONE. ",
                  "Return one alias per line. No numbering. No explanation."
              ) AS ?prompt
    )

    # Submit the prompt and filter the results
    ?alias gpt:list (?prompt 0.2)
    FILTER(UCASE(STR(?alias)) != "NONE")
    FILTER(LCASE(STR(?alias)) != LCASE(STR(?label))) # Make sure the proposed alias does not match the existing label
    FILTER NOT EXISTS { # Make sure the proposed alias has not already been added
        ?entity skos:altLabel ?alias
    }
}
