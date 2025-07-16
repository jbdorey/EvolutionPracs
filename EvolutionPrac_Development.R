# Development
# Notes to fix:
  # Checklist - include data sources in dataset
  # Taxonomy check for no-species occurrences and for subgenus in species... have a general peak!
  # Harmoniser, consider adding protection to avoid matching genus or subgenus-level taxa to valid names
  # This will help show tidyverse warnings more than once every 8 hours...
options(lifecycle_verbosity = "warning")
.libPaths("/Users/jamesdorey/Library/R/x86_64/4.4")

#### 0.0 Working directory ####
# Choose the path to the root folder in which all other folders can be found (or made by dirMaker)
develDir <- "/Users/jamesdorey/Desktop/Uni/Packages/BeeBDC_development"

# Set the working directory
setwd(develDir)

##### 0.1 Packages ####
install.packages("devtools")
install.packages("usethis")
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("ComplexHeatmap")
install.packages("galah")
install.packages("datapasta")
install.packages("testthat")
install.packages("formatR")
install.packages("terra")
library(devtools)
library(usethis)
library(datapasta)
library(testthat)
library(formatR)
library(terra)
library(ComplexHeatmap)

# Install dev code
#devtools::install_github(repo = "ropensci/rnaturalearthdata")



#### 1.0 one-time set up ####
# Most of this is not necessary
# Create a Github Personal Access Token to interact wit hmy GitHub
    # usethis::create_github_token()
    # usethis::git_vaccinate()

# Once per package 
  # initialise a Git
?use_git()
  # connect a local repo with Git
?use_github()
  # Sets up continuous integration (CI) for an R package that is developed on GitHub using GitHub Actions. CI can be used to trigger various operations for each push or pull request, such as:
use_github_actions()


#### 2.0 Create package ####
  ##### 2.1 Descriptions ####
# Write DESCRIPTION file inst
packageDir <- "/Users/jamesdorey/Desktop/Uni/Packages/BeeBDC"
packageVersion <- "1.3.0"
here::here("BeeBDC_development/BeeBDC_Development.R")
setwd(packageDir)
usethis::create_package(path = packageDir,
                        roxygen = TRUE,
                        rstudio = FALSE,
                        check_name = TRUE,
                        open = FALSE,
                        fields = list(
                          Title = "Occurrence Data Cleaning",
                          Version = packageVersion,
                          `Authors@R` = c(person(given = "James B.",
                                               family = "Dorey",
                                               role = c("aut", "cre", "cph"),
                                               email = "jbdorey@me.com",
                                               comment = c(ORCID = "0000-0003-2721-3842")),
                                          person(given = "Robert L.",
                                                 family = "O'Reilly",
                                                 role = c("aut"),
                                                 email = "robert.oreilly@flinders.edu.au",
                                                 comment = c(ORCID = "0000-0001-5291-7396")),
                                          person(given = "Silas",
                                                 family = "Bossert",
                                                 role = c("aut"),
                                                 email = "silas.bossert@wsu.edu",
                                                 comment = c(ORCID = "0000-0002-3620-5468")),
                                          person(given = "Erica E.",
                                                 family = "Fischer",
                                                 role = c("aut"),
                                                 email = "fischeer@mail.gvsu.edu",
                                                 comment = c(ORCID = "0000-0002-8202-158X")
                                                 )),
                          Description = 
                          "Flags and checks occurrence data that are in Darwin Core format.
                          The package includes generic functions and data as well as some that are
                          specific to bees. This package is meant to build upon and be complimentary
                          to other excellent occurrence cleaning packages, including 'bdc' and
                          'CoordinateCleaner'.
                          This package uses datasets from several sources and particularly from the
                          Discover Life Website, created by Ascher and Pickering (2020).
                          For further information, please see the original publication and package website.
                          Publication - Dorey et al. (2023) <doi:10.1101/2023.06.30.547152> and
                          package website -
                          Dorey et al. (2023) <https://github.com/jbdorey/BeeBDC>.",
                          Language = "en-gb",
                          Encoding = "UTF-8",
                          "Config/testthat/edition" = 3,
                          BugReports = "https://github.com/jbdorey/BeeBDC/issues",
                          URL = "https://jbdorey.github.io/BeeBDC/ https://github.com/jbdorey/BeeBDC",
                          LazyData = TRUE,
                          LazyDataCompression = "xz",
                          RoxygenNote = "7.2.1",
                          Depends = "R (>= 4.1.0)",
                            # Removed to articles to save space of built package
                          #VignetteBuilder = "knitr"
                          License = "GPL (>= 3)"
                        ))
  # Add required packages
requiredPackages <- sort(c(
    # File packages
  "here", "openxlsx",'readr',
    # Tidyverse packages
  'stringr', 'tidyselect', 
  "dplyr","forcats","lubridate",
    # Other
  "mgsub", "igraph",
    # GIS packages
  'CoordinateCleaner', 'rnaturalearth', 'sf',
    # Graphical packages
  "ggspatial","paletteer", "ggplot2",  "circlize", "cowplot"
                           ))
lapply(requiredPackages,  usethis::use_package, type = "Imports")

  # Add suggested packages
suggestedPackages <- sort(c("rlang", "xml2",  "rvest", 
                            "janitor", "rnaturalearthdata", 
                            "terra", "R.utils", 
                            "testthat", "emld", "purrr", "tidyr", "galah",
                            "classInt", "htmlwidgets",  "leaflet", "plotly", 
                            "bdc",
                            "ComplexHeatmap", 
                            "taxadb",
                            # "BiocManager",
                            "hexbin",
                            # For species richness 
                            "SpadeR", "iNEXT",
                            # "DT",
                            # Might be easy to remove
                            "countrycode", "httr", 
                            # For use with vignette
                            "tibble",
                            "BiocManager", "magrittr"
                              # Vignette packages
                            #"utils", "knitr", "renv", "devtools", 
                            #"htmltools", "prettydoc", "rgnparser", "rmarkdown",
                            #"rmdformats", "pkgdown", "formatR", "kableExtra"
                            ))
lapply(suggestedPackages,  usethis::use_package, type = "Suggests")


  # Add non-Cran packages
#usethis::use_dev_package("galah", type = "Imports", remote = "AtlasOfLivingAustralia/galah")



# In order to initialise a package citation file: (Don't re-run!)
#usethis::use_citation()

# Order and format
usethis::use_tidy_description()

  ##### 2.2 Load ####
  # Load all of the functions
devtools::load_all()

  ##### 2.3 Document ####
#roxygen2::roxygenise()
devtools::document()

citation("BeeBDC")
print(citation("BeeBDC"), bibtex=TRUE)


  ##### 2.4 Test package ####
# Set up tests
    #   usethis::use_testthat(3)
    #   devtools::test(pkg = packageDir) 
    #   usethis::use_test("countryOutlieRs")

  ##### 2.5 Check package ####
  # Choose CRAN mirror
# options(repos = c(CRAN = "https://cloud.r-project.org"))
    # Check locally
devtools::check(pkg = packageDir,
                manual = TRUE,
                remote = TRUE,
                incoming = TRUE)

  # Check with suggested packages not installed
devtools::check(manual = TRUE,
                remote = TRUE,
                incoming = TRUE,
                env_vars = c("_R_CHECK_DEPENDS_ONLY_" = "true"))
#      # you can check examples only:
  #  devtools::run_examples()
  #      # or tests only:
  #  devtools::test()

  



  # Check as CRAN
rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))

  # Check spelling
# usethis::use_spell_check()

  # Check reverse dependencies
devtools::revdep()
revdepcheck::revdep_check(num_workers = 4)


  ##### 2.6 News and comments ####
  # Generate news file
# usethis::use_news_md(open = rlang::is_interactive())

  #### 3.0 GitHub actions ####
  # generate CRAN comments file — communicate steps taken
usethis::use_cran_comments()

usethis::use_release_issue()

  ##### 3.1 GitHub actions workflow ####
usethis::use_github_action("check-standard")
usethis::use_github_action("test-coverage")
usethis::use_github_action("pkgdown")

  #### 4.0 Further CRAN tests ####
  ##### 4.1 Coverage ####
devtools::test_coverage()

  ##### 4.2 Package weights ####
pak::pkg_deps_tree("BeeBDC")



#### 5.0 Website initialisation ####
  ##### 5.1 One-time Git setup ####
# Use this to implement the files needed to build a website on GitHub
usethis::use_git(message = "Initial commit")
usethis::use_github(private = FALSE)
usethis::use_github_action("pkgdown")
usethis::use_pkgdown_github_pages()

  ##### 5.2 Start and update webpage ####
  # Load all of the vignettes
devtools::load_all()
  # Document everything
devtools::document()
  # Start using pkgdown — RUN THIS ONLY ONCE
    # usethis::use_pkgdown()
  # Build the site — updates from pkgdown
    # ISNTALL the below if there's a purrr error
    # install.packages("ragg")
# locally building site
pkgdown::build_site(packageDir)



  ##### 5.3 Vignettes ####
  # To intialise a vignette:
    # usethis::use_vignette("my-vignette")

  # KNIT the vignette in the file to make its outputs



  # Useful site to read - https://github.com/ThinkR-open/prepare-for-cran

  # To build the package in terminal, navigate to its location and type:
    # "R CMD build BeeBDC" to make the .tar file for CRAN submission
      # cd /Users/jamesdorey/Desktop/Uni/Packages
      # R CMD build BeeBDC
      # R CMD check BeeBDC_1.3.0.tar.gz
      # R CMD check --as-cran BeeBDC_1.3.0.tar.gz

# Can submit to CRAN using the below:
usethis::use_version('minor') 
devtools::spell_check()
devtools::check_rhub()
devtools::check_mac_release()
devtools::check_win_devel()
devtools::release()


  
