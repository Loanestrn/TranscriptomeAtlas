#snakemake pour le traitement des lectures
#Creer un dossier genome ou il y a genome.fa et annitation.gtf
#Creer un dossier rawReads ou il y a sra_frr.fastq



import glob

SRA, FRR = glob_wildcards('rawReads/{sra}_{frr}.fastq')

rule all:
    input:
        expand('rawQC/{sra}_{frr}_fastqc.{extension}', sra=SRA, frr=FRR, extension=["zip", "html"]),
        expand('trimmedReads/{sra}_1P.fastq', sra=SRA),
        expand('trimmedReads/{sra}_2P.fastq', sra=SRA),
        expand('starAligned/{sra}Aligned.sortedByCoord.out.bam', sra=SRA),
        expand('starAligned/{sra}Log.final.out', sra=SRA),
        expand("counts/{sra}.counts.txt", sra=SRA)

rule rawFastqc:
    input:
        rawreads='rawReads/{sra}_{frr}.fastq'
    output:
        zip='rawQC/{sra}_{frr}_fastqc.zip',
        html='rawQC/{sra}_{frr}_fastqc.html'
    threads: 1
    params:
        path='rawQC/'
    shell:
        """
        mkdir -p {params.path}
        fastqc {input.rawreads} --threads {threads} -o {params.path}
        """

rule trimmomatic:
    input:
        read1 = 'rawReads/{sra}_1.fastq',
        read2 = 'rawReads/{sra}_2.fastq'
    output:
        forwardPaired = 'trimmedReads/{sra}_1P.fastq',
        forwardUnpaired = 'trimmedReads/{sra}_1U.fastq',
        reversePaired = 'trimmedReads/{sra}_2P.fastq',
        reverseUnpaired = 'trimmedReads/{sra}_2U.fastq'
    threads: 4
    params:
        adapter = '/home/sturny/.conda/envs/rnaseq-pipeline/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa',
        trimmomatic_bin = '/home/sturny/.conda/envs/rnaseq-pipeline/bin/trimmomatic'
    shell:
        """
        mkdir -p trimmedReads
        {params.trimmomatic_bin} PE -threads {threads} -phred33 \
            {input.read1} {input.read2} \
            {output.forwardPaired} {output.forwardUnpaired} \
            {output.reversePaired} {output.reverseUnpaired} \
            ILLUMINACLIP:{params.adapter}:2:30:10:2:keepBothReads \
            LEADING:3 TRAILING:3 MINLEN:3
        """


rule star_index:
    input:
        genome="genome/genome.fa",
        gtf="genome/annotation.gtf"
    output:
        touch("starIndex/.done")
    params:
        outdir="starIndex"
    threads: 4
    shell:
        """
        mkdir -p {params.outdir}
        STAR --runThreadN {threads} --runMode genomeGenerate \
            --genomeDir {params.outdir} \
            --genomeFastaFiles {input.genome} \
            --sjdbGTFfile {input.gtf} \
            --sjdbOverhang 33
        touch {output}
        """

rule star:
    input:
        index = "starIndex/.done",
        read1="trimmedReads/{sra}_1P.fastq",
        read2="trimmedReads/{sra}_2P.fastq"
    output:
        bam="starAligned/{sra}Aligned.sortedByCoord.out.bam",
        log="starAligned/{sra}Log.final.out"
    threads: 4
    params:
        prefix="starAligned/{sra}",
        outdir="starAligned"
    log:
        "logs/star_{sra}.log"
    shell:
        """
        mkdir -p {params.outdir}
        STAR --runThreadN {threads} --genomeDir starIndex \
            --readFilesIn {input.read1} {input.read2} \
            --outFilterIntronMotifs RemoveNoncanonical \
            --outFileNamePrefix {params.prefix} \
            --outSAMtype BAM SortedByCoordinate \
            --limitBAMsortRAM 5000000000 \
            --outReadsUnmapped fastx \
            > {log} 2>&1
        """

rule featurecounts:
    input:
        bam = "starAligned/{sra}Aligned.sortedByCoord.out.bam",
        gtf = "genome/annotation.gtf"
    output:
        "counts/{sra}.counts.txt"
    log:
        "logs/featurecounts_{sra}.log"
    threads: 4
    shell:
        """
        mkdir -p counts logs
        featureCounts \
            -T {threads} \
            -F GTF \
            -t exon \
            -p \
            -a {input.gtf} \
            -o {output} \
            {input.bam} \
            > {log} 2>&1
        """

