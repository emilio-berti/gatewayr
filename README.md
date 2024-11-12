api-usage
================

``` r
library(gatewayr)
```

# Access the GATEWAy API

The *gatewayr* package is designed to interface with the [GATEWAy
API](http://localhost:8000/gateway/api/). This is achieved using the API
REST framework and the *httr2* R package. There are **n** access points
to the API implmeneted in *gatewayr* (Table 1).

<p style="text-align: center; font-weight: bold;">

Table 1: Endpoints of the GAYEWAy API.
</p>

| **Endpoint** | **filters** | **function** |
|----|----|----|
| `/gateway/api/foodwebs` |  | query foodwebs |
|  | `?foodwebID=` | filter by *foodwebID* |
|  | `?ecosystemType=` | filter by *ecosystemType* |
|  | `?xmin=` | filter by *decimalLongitude* |
|  | `?xmax=` | filter by *decimalLongitude* |
|  | `?ymin=` | filter by *decimalLatitude* |
|  | `?ymax=` | filter by *decimalLatitude* |
| `/gateway/api/taxa` |  | query taxa |
|  | `?taxonID=` | filter by *taxonID* |
|  | `?taxonRank=` | filter by *taxonRank* |
|  | `?taxonomicStatus=` | filter by *taxonomicStatus* |
| `/gateway/api/communities` |  | query communities |
|  | `?foodwebID=` | filter by *foodwebID* |
| `/gateway/api/lifeStages` |  | list all life stages |
| `/gateway/api/mvoementTypes` |  | list all life stages |
| `/gateway/api/metabolicTypes` |  | list all metabolic types |
| `/gateway/api/sizeMethods` |  | list all body size measurement methods |
| `/gateway/api/references` |  | list all measurement references |

All endpoints that filter not based on IDs require one argument.
Endpoints filtering on IDs can take more than one argument; in that
case, arguments are separated by a `,` (coma). As example,
`/gateway/api/foodwebs?ecosystemType=lakes` returns all lake food webs,
and `/gateway/api/foodwebs?foodwebID=1,5,19` returns food webs 1, 5, and
9.

## Access Food Web metadata

The `get_foodweb()` accesses the food web metadata, such as the name of
the food web, its ecosystem type and geographic coordinates.

``` r
fw <- get_foodweb()
fw
#> # A tibble: 336 × 12
#>   foodwebID foodwebName           ecosystemType decimalLongitude decimalLatitude
#>       <int> <chr>                 <chr>                    <dbl>           <dbl>
#> 1         1 grand caricaie marsh… terrestrial …             6.98            46.9
#> 2         2 grand caricaie marsh… lakes                     6.98            46.9
#> 3         3 grand caricaie marsh… terrestrial …             6.98            46.9
#> 4         4 grand caricaie marsh… terrestrial …             6.99            46.9
#> # ℹ 332 more rows
#> # ℹ 7 more variables: geographicLocation <chr>, studySite <chr>,
#> #   verbatimElevation <dbl>, verbatimDepth <dbl>, samplingTime <chr>,
#> #   earliestDateCollected <chr>, latestDateCollected <chr>
table(fw[["ecosystemType"]])
#> 
#>                   lakes                  marine                 streams 
#>                      60                     165                      28 
#> terrestrial aboveground terrestrial belowground 
#>                      21                      62
```

Food webs can be filtered based on their *foodwebID* value.

``` r
get_foodweb(foodwebID = c(1, 9, 125))
#> # A tibble: 3 × 12
#>   foodwebID foodwebName           ecosystemType decimalLongitude decimalLatitude
#>       <int> <chr>                 <chr>                    <dbl>           <dbl>
#> 1         1 grand caricaie marsh… terrestrial …             6.98            46.9
#> 2         9 grand caricaie marsh… lakes                     6.98            46.9
#> 3       125 afon hafren 2005      streams                  -3.7             52.5
#> # ℹ 7 more variables: geographicLocation <chr>, studySite <chr>,
#> #   verbatimElevation <dbl>, verbatimDepth <dbl>, samplingTime <chr>,
#> #   earliestDateCollected <chr>, latestDateCollected <chr>
```

The optional arguments *ecosystemType* and *xmin*, *xmax*, *ymin*,
*ymax* can be used to filter the database to retain only the food webs
from one ecosystem type or within a bounding box.

``` r
get_foodweb(ecosystemType = "lakes")
#> # A tibble: 60 × 12
#>   foodwebID foodwebName           ecosystemType decimalLongitude decimalLatitude
#>       <int> <chr>                 <chr>                    <dbl>           <dbl>
#> 1         2 grand caricaie marsh… lakes                     6.98            46.9
#> 2         5 grand caricaie marsh… lakes                     6.99            46.9
#> 3         7 grand caricaie marsh… lakes                     6.99            46.9
#> 4         9 grand caricaie marsh… lakes                     6.98            46.9
#> # ℹ 56 more rows
#> # ℹ 7 more variables: geographicLocation <chr>, studySite <chr>,
#> #   verbatimElevation <dbl>, verbatimDepth <dbl>, samplingTime <chr>,
#> #   earliestDateCollected <chr>, latestDateCollected <chr>
```

If some, but not all vertices of the bounding box are provided, the
others will be set to not constrain the filtering. This allows to
specify, for instance, minimum longitude only.

``` r
get_foodweb(ecosystemType = "lakes", xmin = 5)
#> # A tibble: 6 × 12
#>   foodwebID foodwebName           ecosystemType decimalLongitude decimalLatitude
#>       <int> <chr>                 <chr>                    <dbl>           <dbl>
#> 1         2 grand caricaie marsh… lakes                     6.98            46.9
#> 2         5 grand caricaie marsh… lakes                     6.99            46.9
#> 3         7 grand caricaie marsh… lakes                     6.99            46.9
#> 4         9 grand caricaie marsh… lakes                     6.98            46.9
#> # ℹ 2 more rows
#> # ℹ 7 more variables: geographicLocation <chr>, studySite <chr>,
#> #   verbatimElevation <dbl>, verbatimDepth <dbl>, samplingTime <chr>,
#> #   earliestDateCollected <chr>, latestDateCollected <chr>
```

## Access Taxon List

The `get_taxon()` accesses the list of all taxa in the GATEWAy database.

``` r
taxa <- get_taxon()
taxa
#> # A tibble: 4,932 × 5
#>   taxonID acceptedTaxonName taxonRank taxonomicStatus vernacularName
#>     <int> <chr>             <chr>     <chr>           <chr>         
#> 1    4359 Tipulidae         family    accepted        nan           
#> 2    1026 Coleoptera        order     accepted        nan           
#> 3     339 Araneidae         family    accepted        nan           
#> 4    4299 Tettigoniidae     family    accepted        nan           
#> # ℹ 4,928 more rows
sort(table(taxa$taxonRank))
#> 
#>       form    kingdom     phylum      class    variety subspecies      order 
#>          1          3         12         16         16         20         26 
#>     family        nan      genus    species 
#>        214        325        737       3562
```

Taxa can be filtered by their *taxonID* value.

``` r
get_taxon(taxonID = c(1, 5, 24, 1243))
#> # A tibble: 4 × 5
#>   taxonID acceptedTaxonName    taxonRank taxonomicStatus vernacularName
#>     <int> <chr>                <chr>     <chr>           <chr>         
#> 1       5 Abax                 genus     accepted        nan           
#> 2    1243 Desmarestia aculeata species   accepted        nan           
#> 3      24 Acanthocyclus gayi   species   accepted        nan           
#> 4       1 Abatus cavernosus    species   accepted        nan
```

The optional arguments *taxonRank* and *taxonomicStatus* can be used to
retain only taxa of a specific rank (e.g., *species* or *family*) or
taxonomic status (e.g., *accepted* or *synonym*),
`{ taxa-filtering-1} get_taxon(taxonRank = "species") get_taxon(taxonRank = "species", taxonomicStatus = "accepted")`

## Access Communities

The `get_community()` accesses the community data and takes only the
argument *foodwebID*.

``` r
get_community(foodwebID = c(2, 5, 12))
#> # A tibble: 21 × 6
#>   foodwebName            acceptedTaxonName lifeStage meanMass meanLength biomass
#>   <chr>                  <chr>             <chr>        <dbl>      <dbl>   <dbl>
#> 1 grand caricaie marsh … Ceratopogonidae   larvae    0.00332        -999       0
#> 2 grand caricaie marsh … Chironomidae      larvae    0.000744       -999       0
#> 3 grand caricaie marsh … Haemopis sanguis… <NA>      0.212          -999       0
#> 4 grand caricaie marsh … Limacidae         <NA>      0.345          -999       0
#> # ℹ 17 more rows
```

The optional argument `columns` can be used to retain only certain
columns.

``` r
communities <- get_community(
  foodwebID = c(2, 5, 12),
  columns = c("foodwebName", "ecosystemType", "acceptedTaxonName")
)
communities
#> # A tibble: 21 × 3
#>   foodwebName                                    ecosystemType acceptedTaxonName
#>   <chr>                                          <chr>         <chr>            
#> 1 grand caricaie marsh dominated by cladietum m… lakes         Ceratopogonidae  
#> 2 grand caricaie marsh dominated by cladietum m… lakes         Chironomidae     
#> 3 grand caricaie marsh dominated by cladietum m… lakes         Haemopis sanguis…
#> 4 grand caricaie marsh dominated by cladietum m… lakes         Limacidae        
#> # ℹ 17 more rows
```

When `columns = "all"` all columns are returned.

``` r
communities <- get_community(foodwebID = 5, columns = "all")
communities
#> # A tibble: 6 × 35
#>   communityID foodwebID taxonID lifeStageID metabolicTypeID movementTypeID
#>         <int>     <int>   <int>       <int>           <int>          <int>
#> 1          53         5     809          10               7              5
#> 2          23         5     885          10               7              5
#> 3         325         5    1908          18               7              5
#> 4         358         5    2305          10               7              6
#> # ℹ 2 more rows
#> # ℹ 29 more variables: sizeMethodID <int>, referenceID <int>,
#> #   foodwebName <chr>, ecosystemType <chr>, decimalLongitude <dbl>,
#> #   decimalLatitude <dbl>, geographicLocation <chr>, studySite <chr>,
#> #   verbatimElevation <dbl>, verbatimDepth <dbl>, samplingTime <chr>,
#> #   earliestDateCollected <chr>, latestDateCollected <chr>,
#> #   acceptedTaxonName <chr>, taxonRank <chr>, taxonomicStatus <chr>, …
```

## Access Interactions

The `get_interaction()` accesses the interaction data and can take the
arguments *resourceID*, *consumerID*, and *foodwebID*.

``` r
library(gatewayr)
interactions <- get_interaction(resourceID = 2291)
interactions
#> # A tibble: 11 × 46
#>   resourceAcceptedTaxonName consumerAcceptedTaxonName resourceLifeStage
#>   <chr>                     <chr>                     <chr>            
#> 1 Cyanobacteriales          Diaptomus minutus         <NA>             
#> 2 Cyanobacteriales          Daphnia catawba           <NA>             
#> 3 Cyanobacteriales          Daphnia galeata           <NA>             
#> 4 Cyanobacteriales          Daphnia longiremis        <NA>             
#> # ℹ 7 more rows
#> # ℹ 43 more variables: consumerLifeStage <chr>, resourceLowestMass <dbl>,
#> #   resourceHighestMass <dbl>, resourceMeanMass <dbl>,
#> #   consumerLowestMass <dbl>, consumerHighestMass <dbl>,
#> #   consumerMeanMass <dbl>, resourceShortestLength <dbl>,
#> #   resourceLongestLength <dbl>, resourceMeanLength <dbl>,
#> #   consumerShortestLength <dbl>, consumerLongestLength <dbl>, …
table(interactions[["foodwebName"]])
#> 
#>      hoel lake lost lake east       rat lake 
#>              5              3              3
```

``` r
interactions <- get_interaction(resourceID = 2291, foodwebID = 100)
interactions
#> # A tibble: 3 × 46
#>   resourceAcceptedTaxonName consumerAcceptedTaxonName resourceLifeStage
#>   <chr>                     <chr>                     <chr>            
#> 1 Cyanobacteriales          Daphnia catawba           <NA>             
#> 2 Cyanobacteriales          Diaptomus minutus         <NA>             
#> 3 Cyanobacteriales          Holopedium gibberum       <NA>             
#> # ℹ 43 more variables: consumerLifeStage <chr>, resourceLowestMass <dbl>,
#> #   resourceHighestMass <dbl>, resourceMeanMass <dbl>,
#> #   consumerLowestMass <dbl>, consumerHighestMass <dbl>,
#> #   consumerMeanMass <dbl>, resourceShortestLength <dbl>,
#> #   resourceLongestLength <dbl>, resourceMeanLength <dbl>,
#> #   consumerShortestLength <dbl>, consumerLongestLength <dbl>,
#> #   consumerMeanLength <dbl>, resourceSizeMethod <chr>, …
```

``` r
interactions <- get_interaction(foodwebID = 100)
interactions
#> # A tibble: 273 × 46
#>   resourceAcceptedTaxonName consumerAcceptedTaxonName resourceLifeStage
#>   <chr>                     <chr>                     <chr>            
#> 1 benthic detritus          Rhinichthys atratulus     <NA>             
#> 2 Arthrodesmus incus        Diaptomus minutus         <NA>             
#> 3 Scenedesmus               Daphnia catawba           <NA>             
#> 4 Tabellaria fenestrata     Holopedium gibberum       <NA>             
#> # ℹ 269 more rows
#> # ℹ 43 more variables: consumerLifeStage <chr>, resourceLowestMass <dbl>,
#> #   resourceHighestMass <dbl>, resourceMeanMass <dbl>,
#> #   consumerLowestMass <dbl>, consumerHighestMass <dbl>,
#> #   consumerMeanMass <dbl>, resourceShortestLength <dbl>,
#> #   resourceLongestLength <dbl>, resourceMeanLength <dbl>,
#> #   consumerShortestLength <dbl>, consumerLongestLength <dbl>, …
```

## Access Static Tables

Static tables are tables that cannot be filtered. These are short tables
for which server-side operations are not particularly useful. They are
called within functions of *gatewayr* to populate the queried tables.
The main reason to request these tables directly by the user is to
inspect available values.

``` r
get_life_stage()
#> # A tibble: 18 × 2
#>   lifeStageID lifeStage
#>         <int> <chr>    
#> 1           1 active   
#> 2           2 adults   
#> 3           3 algae    
#> 4           4 cercaria 
#> # ℹ 14 more rows
get_size_method()
#> # A tibble: 7 × 2
#>   sizeMethodID sizeMethod                                                       
#>          <int> <chr>                                                            
#> 1            1 field measurement                                                
#> 2            2 measurement                                                      
#> 3            3 measurement published account regression                         
#> 4            4 measurement: individuals are field-sampled; then masses are deri…
#> # ℹ 3 more rows
get_movement_type()
#> # A tibble: 7 × 2
#>   movementTypeID movementType
#>            <int> <chr>       
#> 1              1 floating    
#> 2              2 flying      
#> 3              3 other       
#> 4              4 sessile     
#> # ℹ 3 more rows
get_metabolic_type()
#> # A tibble: 10 × 2
#>   metabolicTypeID metabolicType        
#>             <int> <chr>                
#> 1               1 dead organic material
#> 2               2 detritus             
#> 3               3 ectotherm vertebrate 
#> 4               4 endotherm vertebrate 
#> # ℹ 6 more rows
get_reference()
#> # A tibble: 35 × 2
#>   referenceID reference                                                         
#>         <int> <chr>                                                             
#> 1           1 brose et al. 2005                                                 
#> 2           2 c. mulder; unpublished (christian.mulder@rivm.nl)                 
#> 3           3 cattin blandenier (2004)                                          
#> 4           4 cohen & mulder (2014) ecology 95; http://dx.doi.org/10.1890/13-13…
#> # ℹ 31 more rows
```

# Database Coverage

`coverage()` calculates the data coverage of the table, i.e. the
fraction of entries that are not NA.

``` r
library(gatewayr)
interactions <- get_interaction(foodwebID = 1)
coverage(interactions)
#> # A tibble: 46 × 2
#>   column              coverage
#>   <chr>                  <dbl>
#> 1 resourceLowestMass         0
#> 2 resourceHighestMass        0
#> 3 consumerLowestMass         0
#> 4 consumerHighestMass        0
#> # ℹ 42 more rows
```

The coverage table is always arranged in increasing order of coverage.

``` r
coverage(get_foodweb())
#> # A tibble: 12 × 2
#>   column            coverage
#>   <chr>                <dbl>
#> 1 verbatimDepth       0.0744
#> 2 verbatimElevation   0.214 
#> 3 decimalLongitude    0.301 
#> 4 decimalLatitude     0.827 
#> # ℹ 8 more rows
```

``` r
coverage(get_taxon())
#> # A tibble: 5 × 2
#>   column            coverage
#>   <chr>                <dbl>
#> 1 acceptedTaxonName     1.00
#> 2 taxonRank             1.00
#> 3 taxonomicStatus       1.00
#> 4 vernacularName        1.00
#> # ℹ 1 more row
```

``` r
coverage(get_community())
#> # A tibble: 6 × 2
#>   column      coverage
#>   <chr>          <dbl>
#> 1 biomass       0     
#> 2 meanLength    0.0292
#> 3 meanMass      0.830 
#> 4 foodwebName   1.00  
#> # ℹ 2 more rows
coverage(get_community(columns = "all"))
#> # A tibble: 35 × 2
#>   column         coverage
#>   <chr>             <dbl>
#> 1 lowestMass            0
#> 2 highestMass           0
#> 3 shortestLength        0
#> 4 longestLength         0
#> # ℹ 31 more rows
```

``` r
library(gatewayr)
interactions <- get_interaction()
coverage_interactions <- coverage(interactions)
coverage_interactions[coverage_interactions[["coverage"]] > 0, ]
#> # A tibble: 36 × 2
#>   column             coverage
#>   <chr>                 <dbl>
#> 1 resourceMeanLength   0.0681
#> 2 consumerMeanLength   0.0689
#> 3 verbatimElevation    0.120 
#> 4 verbatimDepth        0.168 
#> # ℹ 32 more rows
```
