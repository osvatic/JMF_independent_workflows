#This rule will assemble all interleaved fastqs using SPAdes METAGENOME mode

rule SPAdes_assembly:
	input:
		"data/interleave/{sample}.interleave.fastq.gz"
	output:
		"results/{sample}_spades/scaffolds_1000bp.fa"
	threads: 48
	conda:
		"envs/spades.yaml"
	resources: mem_mb=750000, time="4-00:00:00", partition="himem"
	shell:
		"""
		spades.py -t {threads} -m 750 -k 21,31,41,51,61,71,81,91,101,111,121 --meta --pe-12 1 {input} -o results/{wildcards.sample}_spades
		reformat.sh in=results/{wildcards.sample}_spades/scaffolds.fasta out={output} minlength=1000
		"""

