#! /bin/bash

ROOT=/proj/ideel/meshnick/users/NickB/Projects/jiffy_salmonella/snakescrape/snakescrape_ENA # root directory for project (non-scratch)
WD=/pine/scr/n/f/nfb/Projects/jiffy_salmonella/public_seqs/ # working directory for alignments (scratch)
NODES=128 # don't overwhelm server
WAIT=30 # number of seconds to wait for files to appear, absorbing some file system latency

snakemake \
	--snakefile $ROOT/scrape_ena_v2.snake \
	--configfile config.yaml \
	--printshellcmds \
	--directory $WD \
	--cluster $ROOT/launch.py \
	-j $NODES \
	--rerun-incomplete \
	--keep-going \
	--latency-wait $WAIT \
#	--dryrun -p
