PREFIX voc: <https://swapi.co/vocabulary/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX gpt: <http://www.ontotext.com/gpt/>
PREFIX ex: <http://www.example.com/>

# Query 2 - Controlled semantic enrichment
INSERT {
    GRAPH ex:llm-outputs-q2 {
        ?film ex:theme ?theme .
        << ?film ex:theme ?theme >> ex:reason ?reason .
        ?theme rdfs:label ?themeLabel .
    }
}
WHERE {
    {
        # Retrieve all the films from the dataset
        SELECT ?film ?title ?filmContext WHERE {
            ?film a voc:Film ;
                rdfs:label ?title .
            OPTIONAL {
                ?film voc:openingCrawl ?filmContext .
            }
            FILTER(LANG(?title) = "") # Make things simple: Keep only the "default" titles
        }
    }

    # Build the prompt
    BIND(
        CONCAT(
                  "You are enriching a Star Wars film knowledge graph. For the film '", STR(?title), "', choose up to 2 theme IDs.",
                  "Allowed theme IDs only: EmpireVsRebellion, Redemption, Mentorship, Destiny, Betrayal, PoliticalIntrigue, FoundFamily, Survival.",
                  "Available film context: ", ?filmContext,
                  "Return up to 2 rows with exactly 2 columns: theme-ID, short reason.",
                  "If nothing fits, return one row: NONE, no-fit."
              ) AS ?prompt
    )

    # Submit the prompt and filter the results
    (?pickedId ?reason) gpt:table (?prompt 0.2)
    FILTER(UCASE(STR(?pickedId)) != "NONE")

    # Create the theme instances
    VALUES (?theme ?themeId ?themeLabel) {
        (ex:EmpireVsRebellion 	"EmpireVsRebellion" 	"Empire vs Rebellion")
        (ex:Redemption         	"Redemption"         	"Redemption")
        (ex:Mentorship         	"Mentorship"         	"Mentorship")
        (ex:Destiny            	"Destiny"            	"Destiny")
        (ex:Betrayal           	"Betrayal"           	"Betrayal")
        (ex:PoliticalIntrigue  	"PoliticalIntrigue"  	"Political Intrigue")
        (ex:FoundFamily        	"FoundFamily"        	"Found Family")
        (ex:Survival           	"Survival"           	"Survival")
    }
    FILTER(STR(?pickedId) = ?themeId)
}