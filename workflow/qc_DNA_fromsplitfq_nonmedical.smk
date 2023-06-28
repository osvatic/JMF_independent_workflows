#This script will take interleave paired-end DNA libraries from .bam files to interleaved .fastq.gz files

#grab names for samples from data directory
FILES = glob_wildcards('data/DNA/{name}.1.fastq.gz')
NAMES = FILES.name


#Request all necessary outputs. For this workflow these are a interleave .fastq.gz and corresponding fastqc files 
rule all:
	input:
		expand("data/interleave_DNA/{sample}.interleave.fastq.gz", sample=NAMES),
		expand("intermediates/prefilter_qc/{sample}.1_fastqc.html", sample=NAMES),
		expand("intermediates/prefilter_qc/{sample}.2_fastqc.html", sample=NAMES),
		expand("intermediates/postfilter_qc/{sample}_R1.phiXclean_fastqc.html", sample=NAMES),
		expand("intermediates/postfilter_qc/{sample}_R2.phiXclean_fastqc.html", sample=NAMES)


#Fastqc for each fq in intermediates
rule fastqc_prefilter:
        input:
                "data/DNA/{sample}.1.fastq.gz",
		"data/DNA/{sample}.2.fastq.gz"
        output:
                "intermediates/prefilter_qc/{sample}.1_fastqc.html",
		"intermediates/prefilter_qc/{sample}.2_fastqc.html"
        conda: "envs/fastqc.yaml"
	threads: 16
	resources: mem_mb=10000, time="1-00:00:00"
        shell:
                """
                if [ ! -d "intermediates/prefilter_qc" ]; then mkdir intermediates/prefilter_qc; fi
                fastqc -t {threads} -o intermediates/prefilter_qc {input}
                """


#bbduk will trimadapters from reads
#we are keeping reads seperate until the end for some processing reasons (fastqc, mostly)
rule bbduk_trimadapters:
	input:
		"data/DNA/{sample}.1.fastq.gz",
		"data/DNA/{sample}.2.fastq.gz"
	output:
		"intermediates/{sample}_R1.adapterclean.fastq.gz",
		"intermediates/{sample}_R2.adapterclean.fastq.gz"
	threads: 16
	conda:
		"envs/bbmap.yaml"
	resources: mem_mb=10000, time="1-00:00:00"
	shell:
		"""
                bbduk.sh threads={threads} -Xmx10g in1={input[0]} in2={input[1]} out1={output[0]} out2={output[1]} ref=adapters ktrim=r k=21 mink=11 hdist=2 tpe tbo 
		"""


#bbduk will remove phiX contamination
rule bbduk_removephiX:
	input:
		"intermediates/{sample}_R1.adapterclean.fastq.gz",
                "intermediates/{sample}_R2.adapterclean.fastq.gz"
	output:
                "intermediates/{sample}_R1.phiXclean.fastq.gz",
                "intermediates/{sample}_R2.phiXclean.fastq.gz"
	threads: 16
	conda:
		"envs/bbmap.yaml"
	resources: mem_mb=10000, time="1-00:00:00"
	shell: 
                """
                bbduk.sh threads={threads} -Xmx10g in1={input[0]} in2={input[1]} out1={output[0]} out2={output[1]} ref=phix ktrim=r k=21 mink=11 hdist=2 minlen=50 qtrim=r trimq=15
		"""

#fastqc after all the filtering
rule fastqc_postfilter:
	input:
		"intermediates/{sample}_R1.phiXclean.fastq.gz",
		"intermediates/{sample}_R2.phiXclean.fastq.gz"
	output:
		"intermediates/postfilter_qc/{sample}_R1.phiXclean_fastqc.html",
		"intermediates/postfilter_qc/{sample}_R2.phiXclean_fastqc.html"
	threads: 16
	conda:
		"envs/fastqc.yaml"
	resources: mem_mb=10000, time="1-00:00:00"
	shell:
		"""
		if [ ! -d "intermediates/postfilter_qc" ]; then mkdir intermediates/postfilter_qc; fi
		fastqc -t {threads} -o intermediates/postfilter_qc {input}
		"""


#bbmap's reformat.sh will merge the paired end reads into a single interleaved file for ease of processing
rule fastq_merge:
	input:
		"intermediates/{sample}_R1.phiXclean.fastq.gz",
		"intermediates/{sample}_R2.phiXclean.fastq.gz"
	output:
		"data/interleave_DNA/{sample}.interleave.fastq.gz"
	threads: 16
	conda:
		"envs/bbmap.yaml"
	resources: mem_mb=10000, time="1-00:00:00"
	shell:
		"""	
		if [ ! -d "data/interleave_DNA" ]; then mkdir data/interleave_DNA; fi
		reformat.sh threads={threads} in1={input[0]} in2={input[1]} out={output}
		"""