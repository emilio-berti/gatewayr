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
#> #   earliestDateCollected <int>, latestDateCollected <int>
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
#> #   earliestDateCollected <int>, latestDateCollected <int>
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
#> #   earliestDateCollected <int>, latestDateCollected <int>
```

If some, but not all vertices of the bounding box are provided, the
others will be set to not constrain the filtering. This allows to
specify, for instance, minimum longitude only.

``` r
get_foodweb(ecosystemType = "lakes", xmin = 5)
#> # A tibble: 6 × 11
#>   foodwebID foodwebName           ecosystemType decimalLongitude decimalLatitude
#>       <int> <chr>                 <chr>                    <dbl>           <dbl>
#> 1         2 grand caricaie marsh… lakes                     6.98            46.9
#> 2         5 grand caricaie marsh… lakes                     6.99            46.9
#> 3         7 grand caricaie marsh… lakes                     6.99            46.9
#> 4         9 grand caricaie marsh… lakes                     6.98            46.9
#> # ℹ 2 more rows
#> # ℹ 6 more variables: geographicLocation <chr>, studySite <chr>,
#> #   verbatimElevation <dbl>, verbatimDepth <dbl>, earliestDateCollected <int>,
#> #   latestDateCollected <int>
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
required argument *foodwebID*. Specifying too many foodwebIDs results in
hitting the limit of the URL length (most likely when `get_community()`
queries the taxon list).

``` r
tryCatch(
  get_community(foodwebID = 1:200),
  error = function(e) {
    conditionMessage(e)
})
#> [1] "HTTP 414 URI Too Long. Try passing fewer IDs."
```

When this happens, try reducing the number of foodwebIDs queried.

``` r
communities <- get_community(foodwebID = 1:100)
communities
#> # A tibble: 9,289 × 6
#>   foodwebName            acceptedTaxonName lifeStage meanMass meanLength biomass
#>   <chr>                  <chr>             <chr>        <dbl>      <dbl>   <dbl>
#> 1 grand caricaie marsh … Acrididae         larvae    0.0410         -999    -999
#> 2 grand caricaie marsh … Agonum viduum     nan       0.0371         -999    -999
#> 3 grand caricaie marsh … Anacaena limbata  nan       0.000982       -999    -999
#> 4 grand caricaie marsh … Anisoptera        nan       0.241          -999    -999
#> # ℹ 9,285 more rows
```

The optional argument `columns` can be used to retain only certain
columns.

``` r
communities <- get_community(
  foodwebID = c(1, 5, 12),
  columns = c("foodwebName", "ecosystemType", "acceptedTaxonName")
)
communities
#> # A tibble: 224 × 3
#>   foodwebName                                    ecosystemType acceptedTaxonName
#>   <chr>                                          <chr>         <chr>            
#> 1 grand caricaie marsh dominated by cladietum m… terrestrial … Acrididae        
#> 2 grand caricaie marsh dominated by cladietum m… terrestrial … Agonum viduum    
#> 3 grand caricaie marsh dominated by cladietum m… terrestrial … Anacaena limbata 
#> 4 grand caricaie marsh dominated by cladietum m… terrestrial … Anisoptera       
#> # ℹ 220 more rows
```

When `columns = "all"` all columns are returned.

``` r
communities <- get_community(foodwebID = 5, columns = "all")
communities
#> # A tibble: 6 × 31
#>   foodwebID taxonID lifeStageID metabolicTypeID movementTypeID sizeMethodID
#>       <int>   <int>       <int>           <int>          <int>        <int>
#> 1         5     809          10               7              5            3
#> 2         5     885          10               7              5            3
#> 3         5    1908          18               7              5            3
#> 4         5    2305          10               7              6            3
#> # ℹ 2 more rows
#> # ℹ 25 more variables: referenceID <int>, foodwebName <chr>,
#> #   ecosystemType <chr>, decimalLongitude <dbl>, decimalLatitude <dbl>,
#> #   geographicLocation <chr>, studySite <chr>, verbatimElevation <dbl>,
#> #   verbatimDepth <dbl>, acceptedTaxonName <chr>, taxonRank <chr>,
#> #   taxonomicStatus <chr>, vernacularName <chr>, lifeStage <chr>,
#> #   lowestMass <dbl>, highestMass <dbl>, meanMass <dbl>, …
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
