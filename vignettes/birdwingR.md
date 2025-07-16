
Use a temporary working directory

``` r
setwd(tempdir())
library(magrittr)
library(BeeBDC)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(bdc)
```

Access stored and downloaded data

``` r
  # Download data
utils::download.file(url = "https://raw.githubusercontent.com/jbdorey/BIOL361_25/main/vignettes/records-2025-02-20/records-2025-02-20.csv",
                     destfile = "records-2025-02-20.csv",
                     method="curl")
```

Read in the data and apply some filtering

``` r
# Read data and run initial flags
RichmondBirdwingData <- readr::read_csv("records-2025-02-20/records-2025-02-20.csv",
                                        col_types = BeeBDC::ColTypeR()) %>%
  dplyr::mutate(database_id = paste0("RBB_", 1:nrow(.)),
                .before = scientificName) %>% 
  bdc::bdc_scientificName_empty(data = ., sci_name = "scientificName") %>%
  bdc::bdc_coordinates_empty(data = ., lat = "decimalLatitude",
                             lon = "decimalLongitude") %>%
  bdc::bdc_coordinates_outOfRange(data = ., lat = "decimalLatitude",
                                  lon = "decimalLongitude") %>%
  bdc::bdc_basisOfRecords_notStandard(
    data = .,
    basisOfRecord = "basisOfRecord",
    names_to_keep = c(
      # Keep all plus some at the bottom.
      "Event",
      "HUMAN_OBSERVATION",
      "HumanObservation",
      "LIVING_SPECIMEN",
      "LivingSpecimen",
      "MACHINE_OBSERVATION",
      "MachineObservation",
      "MATERIAL_SAMPLE",
      "O",
      "Occurrence",
      "MaterialSample",
      "OBSERVATION",
      "Preserved Specimen",
      "PRESERVED_SPECIMEN",
      "preservedspecimen Specimen",
      "Preservedspecimen",
      "PreservedSpecimen",
      "preservedspecimen",
      "S",
      "Specimen",
      "Taxon",
      "UNKNOWN",
      "",
      NA,
      "NA",
      "LITERATURE", 
      "None", "Pinned Specimen", "Voucher reared", "Emerged specimen"
    )) %>% 
  BeeBDC::flagAbsent(data = ., PresAbs = "occurrenceStatus") %>%
  BeeBDC::flagLicense(data = .,
                      strings_to_restrict = "all",
                      # DON'T flag if in the following dataSource(s)
                      excludeDataSource = NULL) %>%
  BeeBDC::summaryFun(
    data = .,
    # Don't filter these columns (or NULL)
    dontFilterThese = NULL,
    # Remove the filtering columns?
    removeFilterColumns = FALSE,
    # Filter to ONLY cleaned data?
    filterClean = FALSE)
```

    ## New names:
    ## • `images` -> `images...2`
    ## • `images` -> `images...203`

    ## Warning: The following named parsers don't match the column names: database_id,
    ## subspecies, verbatimIdentification, level0Gid, level0Name, level1Gid,
    ## level1Name, license, issue, type, Location, spatiallyValid, gbifID, taxonKey,
    ## coreid, recordId, verbatimScientificName, accessRights, dctermsLicense,
    ## dctermsType, dctermsAccessRights, bibliographicCitation,
    ## dctermsBibliographicCitation, flags, isDuplicateOf, hasCoordinate,
    ## hasGeospatialIssues, assertions, occurrenceYear, id, duplicateStatus,
    ## dataSource, dataBase_scientificName, .rou, .val, .equ, .zer, .cap, .cen, .sea,
    ## .otl, .gbf, .inst, .dpl, .summary, names_clean, verbatim_scientificName,
    ## .uncer_terms, .eventDate_empty, .year_outOfRange, .duplicates, .lonFlag,
    ## .latFlag, .gridSummary, .basisOfRecords_notStandard, .scientificName_empty,
    ## .coordinates_empty, .coordinates_outOfRange, coordinates_transposed,
    ## country_suggested, .countryOutlier, countryMatch, .expertOutlier,
    ## .occurrenceAbsent, .coordinates_country_inconsistent, .unLicensed,
    ## .invalidName, .sequential, idContinuity, .uncertaintyThreshold, .GBIFflags,
    ## finalLatitude, finalLongitude, Source

    ## 
    ## bdc_scientificName_empty:
    ## Flagged 0 records.
    ## One column was added to the database.
    ## 
    ## 
    ## bdc_coordinates_empty:
    ## Flagged 24 records.
    ## One column was added to the database.
    ## 
    ## 
    ## bdc_coordinates_outOfRange:
    ## Flagged 0 records.
    ## One column was added to the database.
    ## 
    ## 
    ## bdc_basisOfRecords_notStandard:
    ## Flagged 0 of the following specific nature:
    ##  integer(0) 
    ## One column was added to the database.
    ## 
    ## \.occurrenceAbsent:
    ##  Flagged 0 absent records:
    ##  One column was added to the database.
    ## 
    ## No dataSource provided. Filling this column with NAs...
    ## No license provided. Filling this column with NAs...
    ## No accessRights provided. Filling this column with NAs...
    ## \.unLicensed:
    ##  Flagged 0 records that may NOT be used.
    ##  One column was added to the database.

    ##  - We will flag all columns starting with '.'

    ##  - summaryFun:
    ## Flagged 24 
    ##   The .summary column was added to the database.

``` r
  # Space
RichmondBirdwingData <- RichmondBirdwingData %>%
  BeeBDC::jbd_coordinates_precision(data = ., lon = "decimalLongitude",
                                    lat = "decimalLatitude", ndec = 2  # number of decimals to be tested
  ) %>%
  BeeBDC::coordUncerFlagR(data = ., uncerColumn = "coordinateUncertaintyInMeters",
                          threshold = 1000) %>%
  BeeBDC::dupeSummary(
    data = .,
    path = tempdir(),
    # options are "ID","collectionInfo", or "both"
    duplicatedBy = "collectionInfo", 
    # The columns to generate completeness info from (and to sort by completness)
    completeness_cols = c("decimalLatitude",  "decimalLongitude",
                          "scientificName", "eventDate"),
    # The columns to ADDITIONALLY consider when finding duplicates in collectionInfo
    collectionCols = c("decimalLatitude", "decimalLongitude", "scientificName", "eventDate", 
                       "recordedBy"),
    # The columns to combine, one-by-one with the collectionCols
    collectInfoColumns = c("catalogNumber", "otherCatalogNumbers"),
    # Custom comparisons — as a list of columns to compare
    # RAW custom comparisons do not use the character and number thresholds
    CustomComparisonsRAW = dplyr::lst(c("catalogNumber", "institutionCode", "scientificName")),
    # Other custom comparisons use the character and number thresholds
    CustomComparisons = dplyr::lst(
                                   c("occurrenceID", "scientificName")),
    # The order in which you want to KEEP duplicated based on data source
    # try unique(check_time$dataSource)
    sourceOrder = c("CAES", "Gai", "Ecd","BMont", "BMin", "EPEL", "ASP", "KP", "EcoS", "EaCO",
                    "FSCA", "Bal", "SMC", "Lic", "Arm",
                    "USGS", "ALA", "VicWam", "GBIF","SCAN","iDigBio"),
    # Paige ordering is done using the database_id prefix, not the dataSource prefix.
    prefixOrder = c("Paige", "Dorey"),
    # Set the complexity threshold for id letter and number length
    # minimum number of characters when WITH the numberThreshold
    characterThreshold = 2,
    # minimum number of numbers when WITH the characterThreshold
    numberThreshold = 3,
    # Minimum number of numbers WITHOUT any characters
    numberOnlyThreshold = 5
  ) %>% # END dupeSummary
  dplyr::as_tibble(col_types = BeeBDC::ColTypeR()) %>% 
  BeeBDC::summaryFun(data = ., dontFilterThese = NULL, removeFilterColumns = FALSE,
                     filterClean = FALSE) 
```

    ## Loading required namespace: igraph
    ## jbd_coordinates_precision:
    ## Flagged 39 records
    ## The '.rou' column was added to the database.
    ## 
    ## \coordUncerFlagR:
    ##  Flagged 199 geographically uncertain records:
    ##  The column '.uncertaintyThreshold' was added to the database.

    ##  - Generating a basic completeness summary from the decimalLatitude, decimalLongitude, scientificName, eventDate columns.
    ## This summary is simply the sum of complete.cases in each column. It ranges from zero to the N of columns. This will be used to sort duplicate rows and select the most-complete rows.
    ##  - Updating the .summary column to sort by...
    ##  - We will NOT flag the following columns. However, they will remain in the data file.
    ## .gridSummary, .lonFlag, .latFlag, .uncer_terms, .uncertaintyThreshold, .unLicensed

    ##  - summaryFun:
    ## Flagged 39 
    ##   The .summary column was added to the database.
    ##  - Working on CustomComparisonsRAW duplicates...
    ## 
    ## Completed iteration 1 of 1:

    ##  - Identified 0 duplicate records and kept 0 unique records using the column(s): 
    ## catalogNumber, institutionCode, scientificName

    ##  - Working on CustomComparisons duplicates...
    ## 
    ## Completed iteration 1 of 1:

    ##  - Identified 0 duplicate records and kept 0 unique records using the column(s): 
    ## occurrenceID, scientificName

    ##  - Working on collectionInfo duplicates...
    ## 
    ## Completed iteration 1 of 2:

    ##  - Identified 0 duplicate records and kept 0 unique records using the columns: 
    ## decimalLatitude, decimalLongitude, scientificName, eventDate, recordedBy, and catalogNumber

    ## 
    ## Completed iteration 2 of 2:

    ##  - Identified 0 duplicate records and kept 0 unique records using the columns: 
    ## decimalLatitude, decimalLongitude, scientificName, eventDate, recordedBy, and otherCatalogNumbers
    ##  - Clustering duplicate pairs...
    ## Duplicate pairs clustered. There are 0 duplicates across 0 kept duplicates.
    ##  - Ordering prefixs...
    ##  - Ordering data by 1. dataSource, 2. completeness and 3. .summary column...
    ##  - Find and FIRST duplicate to keep and assign other associated duplicates to that one (i.e., across multiple tests a 'kept duplicate', could otherwise be removed)...
    ##  - Duplicates have been saved in the file and location: /var/folders/5x/jm9bgqkj1g1f_vxsmfh8n_t40000gp/T//Rtmp9fki6uduplicateRun_collectionInfo_2025-02-25.csv
    ##  - Across the entire dataset, there are now 0 duplicates from a total of 1,187 occurrences.

    ##  - Completed in 0.33 secs

    ##  - We will flag all columns starting with '.'

    ##  - summaryFun:
    ## Flagged 227 
    ##   The .summary column was added to the database.

``` r
table(RichmondBirdwingData$scientificName)
```

    ## 
    ## Ornithoptera richmondia 
    ##                    1187

Output the interactive map using a modified functino from BeeBDC

``` r
RichmondBirdwingData %>% 
  interactiveMapR(outPath = getwd(),
                  speciesList = "ALL")
```

    ## Loading required namespace: leaflet

    ## The column .expertOutlier was not found. One will be created with all values = TRUE.

``` r
  # Make a map where the QLD points are all red
RichmondBirdwingData %>%
  dplyr::mutate(.summary = dplyr::if_else(stateProvince == "Queensland", FALSE, TRUE)) %>% 
  BeeBDC::interactiveMapR(outPath = getwd(),
                          speciesList = "ALL")
```

    ## The column .expertOutlier was not found. One will be created with all values = TRUE.
