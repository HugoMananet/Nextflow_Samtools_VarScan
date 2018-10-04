#!/usr/bin/env nextflow

Reffile = Channel.fromPath( "${params.ref}" )
Indexfile = Channel.fromPath( "${params.index}" )
Dictfile = Channel.fromPath( "${params.dict}" )

params.bam = "${params.initfiles}"
Bamfile = Channel.fromPath(params.bam)

process samtools_mpileup{

publishDir "${params.resdir}/", mode: 'copy'


	input:
	file (bam) from Bamfile
	file (ref) from Reffile
	file (index) from Indexfile
	file (dictionary) from Dictfile

	output:
	file ("${bam}.mpileup") into pileup


	"""
	samtools mpileup \
		-B \
		-Q 0 \
		-d 50000 \
		-L 50000 \
		-s \
		-f ${ref} \
		${bam} \
		> ${bam}.mpileup
	"""

}


process varscan_mpileup2cns{


publishDir "${params.resdir}/", mode: 'copy'

	input:
		file (pileupfile) from pileup


	output:
		file ("${pileupfile}.vcf.varscan") into output_vcf_varscan



	"""
		java -Xmx2g -jar /opt/varscan_2.3.6/VarScan.jar mpileup2cns \
		${pileupfile} \
		--min-coverage 0 \
		--min-reads2 1 \
		--min-var-freq 0.001 \
		--min-avg-qual 0   \
		--output-vcf 1 \
		--variants \
		--strand-filter 0 \
		> "${pileupfile}.vcf.varscan"
	"""

}
