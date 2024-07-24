

infile <- commandArgs(trailingOnly = TRUE)
print(infile)

rfile <- stringr::str_replace(infile, '.qmd', '.R')

knitr::purl(input = infile, output = rfile)