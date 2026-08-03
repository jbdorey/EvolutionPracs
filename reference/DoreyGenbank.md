# Download larger amounts of genbank data into R

This function works the same as
[`rentrez::entrez_search()`](https://docs.ropensci.org/rentrez/reference/entrez_search.html)
and
[`ape::read.GenBank()`](https://rdrr.io/pkg/ape/man/read.GenBank.html)
together to download data from Genbank. However, it overcomes issues of
download limits by iteratively downloading data and adding sequences and
associated metadata together.

## Usage

``` r
DoreyGenbank(
  db = "nucleotide",
  term = "(cytb[Gene Name]) AND (Apis[Organism])",
  retmax = 500,
  config = NULL,
  retmode = "xml",
  use_history = FALSE,
  seq.names = NULL,
  species.names = TRUE,
  as.character = FALSE,
  chunk.size = 400,
  quiet = TRUE,
  type = "DNA"
)
```

## Arguments

- db:

  character, name of the database to search for.

- term:

  character, the search term. The syntax used in making these searches
  is described in the Details of this help message, the package vignette
  and reference given below.

- retmax:

  numeric. The maximum number of sequences to return and download in a
  single search.

- config:

  vector configuration options passed to httr::GET

- retmode:

  character, one of json (default) or xml. This will make no difference
  in most cases.

- use_history:

  logical. If TRUE return a web_history object for use in later calls to
  the NCBI

- seq.names:

  the names to give to each sequence; by default the accession numbers
  are used. CURRENTLY NOT IN USE

- species.names:

  a logical indicating whether to attribute the species names to the
  returned object.

- as.character:

  a logical controlling whether to return the sequences as an object of
  class "DNAbin" (the default).

- chunk.size:

  the number of sequences downloaded together (see details).

- quiet:

  a logical value indicating whether to show the progress of the
  downloads. If TRUE, will also print the (full) name of the FASTA file
  containing the downloaded sequences.

- type:

  a character specifying to download "DNA" (nucleotide) or "AA" (amino
  acid) sequences.

## Value

A list of DNA sequences made of vectors of class "DNAbin", or of single
characters (if as.character = TRUE) with two attributes (species and
description).

## Examples

``` r

TEST <- DoreyGenbank(db = "nucleotide",
term = "(cytb[Gene Name]) AND (Apis[Organism])",
retmax = 500)


```
