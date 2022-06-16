#! /bin/bash

ROOT=/proj/ideel/meshnick/users/NickB/Projects/jiffy_salmonella/snake_varfilt
WD=/pine/scr/n/f/nfb/Projects/jiffy_salmonella/snake_varfilt
WAIT=30 # number of seconds to wait for files to appear, absorbing some file system latency

snakemake \
	--snakefile $ROOT/run_hf.snake \
	--configfile $ROOT/config_hf.yaml \
	--printshellcmds \
	--directory $WD \
	--rerun-incomplete \
	--keep-going \
	--latency-wait $WAIT \
	--dryrun -p
