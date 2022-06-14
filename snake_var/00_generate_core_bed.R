## .................................................................................
## Purpose:
##
## Author: Nick Brazeau
##
## Date: 13 June, 2022
##
## Notes:
## .................................................................................
library(tidyverse)
remotes::install_github("IDEELResearch/vcfRmanip")
library(vcfRmanip)

#............................................................
# GFF to bed
#...........................................................
gff <- vcfRmanip::GFF2VariantAnnotation_Short("refgenomes/salmonella_proper.gff")
gff_cg <- gff %>%
  dplyr::filter(grepl("STM", GeneID))

gff_cg %>%
  dplyr::select(c("seqname", "start", "end")) %>%
  dplyr::mutate(start = start - 1,
                end = end - 1) %>%
  readr::write_tsv(., file = "refgenomes/salmonella_proper.bed", col_names = F)

