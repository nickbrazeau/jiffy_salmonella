## .................................................................................
## Purpose:
##
## Author: Nick Brazeau
##
## Date: 14 June, 2022
##
## Notes: going to use all bams and gvcfs - no qc here
## .................................................................................

library(tidyverse)

#............................................................
# make lists
#...........................................................
mtdt <- readr::read_tsv("mtdt/mtdt_salm_download.tsv", col_names = T)
#......................
# bamlist
#......................
bamlist <- mtdt %>%
  dplyr::select(biosample_acc) %>%
  dplyr::mutate(
    out = paste0("/pine/scr/n/f/nfb/Projects/jiffy_salmonella/snake_align/aln/merged/",
                 biosample_acc,
                 ".bam")
  )
bamlist %>%
  dplyr::select("out") %>%
  readr::write_tsv(., "lists/all_bams.list", col_names = F)

#......................
# gvcfs
#......................
gvcflist <- mtdt %>%
  dplyr::select(biosample_acc) %>%
  dplyr::mutate(
    out = paste0("/pine/scr/n/f/nfb/Projects/jiffy_salmonella/vcfs_gatk_joint_raw/chunks/all/",
                 biosample_acc,
                 "g.vcf.gz")
  )
gvcflist %>%
  dplyr::select("out") %>%
  readr::write_tsv(., "lists/passed_smpls.gvcfs.list", col_names = F)
