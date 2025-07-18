


# This function was written by James B Dorey on the 17th of July 2025 in order to 
# iteratively download larger amounts of genbank data

#' Download larger amounts of genbank data into R
#' 
#' This function works the same as `rentrez::entrez_search()` and `ape::read.GenBank()` together 
#' to download data from Genbank. However, it overcomes issues of download limits by iteratively
#' downloading data and adding sequences and associated metadata together.
#'
#' @param db character, name of the database to search for.
#' @param term character, the search term. The syntax used in making these searches is described in the Details of this help message, the package vignette and reference given below.
#' @param retmax numeric. The maximum number of sequences to return and download in a single search.
#' @param config vector configuration options passed to httr::GET
#' @param retmode character, one of json (default) or xml. This will make no difference in most cases.
#' @param use_history logical. If TRUE return a web_history object for use in later calls to the NCBI
#' @param seq.names the names to give to each sequence; by default the accession numbers are used. CURRENTLY NOT IN USE
#' @param species.names a logical indicating whether to attribute the species names to the returned object.
#' @param as.character a logical controlling whether to return the sequences as an object of class "DNAbin" (the default).
#' @param chunk.size the number of sequences downloaded together (see details).
#' @param quiet a logical value indicating whether to show the progress of the downloads. If TRUE, will also print the (full) name of the FASTA file containing the downloaded sequences.
#' @param type a character specifying to download "DNA" (nucleotide) or "AA" (amino acid) sequences.
#'
#' @return A list of DNA sequences made of vectors of class "DNAbin", or of single characters (if as.character = TRUE) with two attributes (species and description).
#' @export
#' 
#' @importFrom dplyr %>%
#' 
#'
#' @examples
#' 
#' TEST <- DoreyGenbank(db = "nucleotide",
#' term = "(cytb[Gene Name]) AND (Apis[Organism])",
#' retmax = 500)
#' 
#' 
#' 

DoreyGenbank <- function(
    # rentrez::entrez_search terms  
  db = "nucleotide",
  term = "(cytb[Gene Name]) AND (Apis[Organism])",
  retmax = 500,
  config = NULL,
  retmode = "xml",
  use_history = FALSE,
    # ape::read.GenBank terms
  seq.names = NULL,
  species.names = TRUE,
  as.character = FALSE, 
  chunk.size = 400, 
  quiet = TRUE,
  type = "DNA"
  ){

myCheekySearch <- rentrez::entrez_search(db = db,
                                         term = term,
                                         # With this new search term, I can see 171 sequences, which is enough for me to
                                         # download, I think! So, I'll set this in retmax
                                         retmax = retmax)

# Inspect the object and answer the question below
myCheekySearch

# What we actually need are the accession numbers form the myCheekySearch object. Let's turn this
# vector into a list of vectors, each 200 long. I'm going to write it in the tidyverse because
# it's easy for me, but it might not be the most concise way to do this.
myCheekySearch_list <- myCheekySearch$ids %>% 
  dplyr::tibble(accessionIDs = .) %>%
  # Group by the row number and step size (200 IDs at once)
  dplyr::group_by(group = ceiling(dplyr::row_number()/200)) %>%
  # Split the dataset up into a list by group
  dplyr::group_split(.keep = TRUE)

# You can check out any element of the list... let's look at the 2nd
myCheekySearch_list[[2]]

if(is.null(seq.names)){
# Now we can apply the function across a list using lapply
GenBank_list <- myCheekySearch_list %>%
  # FIrst, let's pass our list into lapply to extract (pull out) on the accessionIDs
  lapply(
    # Remember, when you use the pipe, %>%, you can call the data being passed in with "."
    X = .,
    FUN = dplyr::pull,
    accessionIDs) %>%
  lapply(
    # The data to feed into the function
    X = .,
    FUN = ape::read.GenBank)
}

if(!is.null(seq.names)){
  GenBank_list <- seq.names
}

# This is called a "for loop" It is an EXTREMELY useful tool where you cant count from 1 to
# i iterations (in our case 1 to (i-1)). Don't worry too much about understanding it, but they
# are extremely useful tools and can be quit equick to build for simple problems like below
for(i in 1:(length(GenBank_list)-1)){
  if(i == 1){
    GenBank_loop <- append(GenBank_list[[i]], GenBank_list[[i+1]])
    # Make the attribute list for the first pair of DNAbin objects
    attributesList <- list(
      names = c(attributes(GenBank_list[[i]])$names, attributes(GenBank_list[[i+1]])$names),
      class = attributes(GenBank_list[[i]])$class,
      description = c(attributes(GenBank_list[[i]])$description,
                      attributes(GenBank_list[[i+1]])$description), 
      species = c(attributes(GenBank_list[[i]])$species,
                  attributes(GenBank_list[[i+1]])$species)
    )
  }else{
    GenBank_loop <- append(GenBank_loop, GenBank_list[[i+1]])
    # Make the attribute list for the first pair of DNAbin objects
    attributesList <- list(
      names = c(attributesList$names, attributes(GenBank_list[[i+1]])$names),
      class = attributesList$class,
      description = c(attributesList$description,
                      attributes(GenBank_list[[i+1]])$description), 
      species = c(attributesList$species,
                  attributes(GenBank_list[[i+1]])$species)
    )
  }
}
# We can then call this object whatever we want in R 
combinedGenBank <- GenBank_loop

# let's now add the attributes to this new object
attributes(combinedGenBank) <- attributesList

  # Return the output
return(combinedGenBank)


} # END FUNCTION
