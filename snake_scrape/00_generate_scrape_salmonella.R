## .................................................................................
## Purpose:
##
## Author: Nick Brazeau
##
## Date: 12 June, 2022
##
## Notes: https://ftp.ncbi.nlm.nih.gov/pathogen/Results/Salmonella/
## .................................................................................

library(tidyverse)

#............................................................
# metadata scrape
#...........................................................
#......................
# 2022 samples
#......................
pathos <- readr::read_tsv("mtdt/PDG000000002.2452.metadata.tsv")
recent_salm <- pathos %>%
  dplyr::mutate(collection_date = lubridate::ymd(collection_date),
                isolation_source = tolower(isolation_source)) %>%
  dplyr::filter(collection_date >= lubridate::ymd("2022-01-01") &
                  collection_date < lubridate::ymd("2022-05-12"), # date ENA updated to as of 6/14
                collected_by == "FDA")
#......................
# peanut butter samples
#......................
pb <- pathos %>%
  dplyr::mutate(collection_date = lubridate::ymd(collection_date)) %>%
  dplyr::mutate(isolation_source = tolower(isolation_source))
pb <- pb[ grepl("peanut", tolower(pb$isolation_source)) |
            grepl("SRR975406", pb$Run), ] # manually add suspected culprit: SRR975406
pb <- pb %>%
  dplyr::filter(collected_by == "FDA")

#......................
# out
#......................
out <- dplyr::bind_rows(recent_salm, pb) %>%
  dplyr::filter(Run != "NULL")

#............................................................
# edit accessions for SRA
#...........................................................
ena_table <- out %>%
  dplyr::select(c("Run")) %>%
  dplyr::rename(acc = Run)
#TODO this should be tidy not base R
# part 1
ena_table$p1 <- sapply(out$Run, function(x){
  paste(stringr::str_split(x, "", simplify = T)[1:6], collapse = "")})

# this craziness for part 2
ena_table$p2 <- sapply(out$Run, function(x){
  ifelse(length(stringr::str_split(x, "", simplify = T)) == 11,
         paste0("0", paste(stringr::str_split(x, "", simplify = T)[10:11], collapse = "")),
         paste0("00", paste(stringr::str_split(x, "", simplify = T)[10], collapse = "")))})

# now bring together
ena_table$base <- NA
ena_table$R1 <- NA
ena_table$R2 <- NA
for (i in 1:nrow(ena_table)) {
  # base
  ena_table$base[i] <-   paste(c(
    "ftp.sra.ebi.ac.uk/vol1/fastq/",
    ena_table$p1[i], "/",
    ena_table$p2[i], "/",
    ena_table$acc[i], "/",
    ena_table$acc[i]
  ), collapse = "")
  #R1
  ena_table$R1[i] <- paste(c(
    ena_table$base[i], "_1.fastq.gz"
  ), collapse = "")
  #R2
  ena_table$R2[i] <- paste(c(
    ena_table$base[i], "_2.fastq.gz"
  ), collapse = "")
}


#......................
# make accession list for snakemake
#......................
ena_table %>%
  dplyr::select(c("acc", "R1", "R2")) %>%
  readr::write_tsv(x = .,
                   "snake_scrape/ENA_master_acc_download_map.tab.txt")

#............................................................
# run map
#...........................................................
runmap <- out %>%
  dplyr::select(c("biosample_acc", "Run")) %>%
  dplyr::mutate(space = ".")


#......................
# intersect w/ available sequences
#......................
available <- readr::read_tsv("mtdt/ena_available.tab.txt", col_names = F)
colnames(available) <- "Run"
runmap <- dplyr::inner_join(runmap, available, by = "Run")
# out
runmap %>%
  readr::write_tsv(x = .,
                   "snake_align/salmonella_run_map.tab.txt", col_names = F)

# mtdt
mtdt <- dplyr::left_join(runmap, out, by = c("Run", "biosample_acc"))
mtdt %>%
  readr::write_tsv(., "mtdt/mtdt_salm_download.tsv")



# symlink architecture
runmap %>%
  dplyr::mutate(r1 = paste0("/pine/scr/n/f/nfb/Projects/jiffy_salmonella/public_seqs/raw", "/",
                            Run, "_1.fastq.gz"),
                r2 = paste0("/pine/scr/n/f/nfb/Projects/jiffy_salmonella/public_seqs/raw", "/",
                            Run, "_2.fastq.gz")) %>%
  dplyr::select(c("biosample_acc", "r1", "r2")) %>%
  tidyr::pivot_longer(cols = c("r1","r2"), values_to = "reads") %>%
  dplyr::mutate(
    end = stringr::str_split_fixed(reads, "/", n =11)[,11],
    end = paste0(biosample_acc, "/", end)
  ) %>%
  dplyr::select(-c("name")) %>%
  readr::write_tsv(., "snake_align/symlink_architecture.tab.txt")


