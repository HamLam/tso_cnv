#!/bin/bash

module load parallel

s_S1_R1=s_s1r1Fastq
s_S1_R2=s_s1r2Fastq
s_S2_R1=s_s2r1Fastq
s_S2_R2=s_s2r2Fastq


WORKING_PATH=working_dir
BWA_DB=bwa_db_value
BOWTIE2_DB=bowtie2_db_value
S_DB=seq_db
ref=/panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa

bwacommand1="/home/msistaff/lamx0031/my_software/BWA/bwa-0.7.15/bwa mem -M -t 24 $BWA_DB $s_S1_R1 $s_S1_R2 | samtools view -q 10 -bS - > s_bwa_s1.bam"
bwacommand2="/home/msistaff/lamx0031/my_software/BWA/bwa-0.7.15/bwa mem -M -t 24 $BWA_DB $s_S2_R1 $s_S2_R2 | samtools view -q 10 -bS - > s_bwa_s2.bam"

echo ${bwacommand1} > $WORKING_PATH/saligncommands
echo ${bwacommand2} >>$WORKING_PATH/saligncommands

btcommand1="bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $s_S1_R1 -2 $s_S1_R2 | samtools view -q 10 -bS - > s_bowtie2_s1.bam"
btcommand2="bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $s_S2_R1 -2 $s_S2_R2 | samtools view -q 10 -bS - > s_bowtie2_s2.bam"
echo ${btcommand1} >> $WORKING_PATH/saligncommands
echo ${btcommand2} >> $WORKING_PATH/saligncommands
cat ${WORKING_PATH}/saligncommands | parallel -j +0 $1


mergecommand1="samtools merge s_bwa.bam s_bwa_s1.bam s_bwa_s2.bam"
mergecommand2="samtools merge s_bowtie2.bam s_bowtie2_s1.bam s_bowtie2_s2.bam"
echo ${mergecommand1} > $WORKING_PATH/smergecommands
echo ${mergecommand2} >> $WORKING_PATH/smergecommands
cat ${WORKING_PATH}/smergecommands | parallel -j +0 $1


java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=s_bwa.bam OUTPUT=s_bwa.fixed.bam
pica1="java -Xmx4g -jar  $CLASSPATH/picard.jar MarkDuplicates REMOVE_DUPLICATES=true ASSUME_SORTED=true METRICS_FILE=s_bwa_duplicate_stats.txt INPUT=s_bwa.fixed.bam OUTPUT=s_bwa.fixed_nodup.bam"
pica2="java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=s_bowtie2.bam OUTPUT=s_bowtie2.fixed.bam"
echo ${pica1} > $WORKING_PATH/spicadcommands
echo ${pica2} >> $WORKING_PATH/spicadcommands

cat ${WORKING_PATH}/spicadcommands | parallel -j +0 $1

indexcomm1="samtools index s_bwa.fixed.bam"
indexcomm2="samtools index s_bwa.fixed_nodup.bam"
indexcomm3="samtools index s_bowtie2.fixed.bam"

echo ${indexcomm1} > $WORKING_PATH/sindexcommands
echo ${indexcomm2} >> $WORKING_PATH/sindexcommands
echo ${indexcomm3} >> $WORKING_PATH/sindexcommands
cat ${WORKING_PATH}/sindexcommands | parallel -j +0 $1

samtools view -H s_bwa.fixed.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f1 |  xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d10000000 -f $ref  -r \"{}\" s_bwa.fixed.bam | cut -f 1,2,4 > cnv_sample_name_bwa_pileup.\"{}\" "
samtools view -H s_bwa.fixed_nodup.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f1 |  xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d10000000 -f $ref  -r \"{}\" s_bwa.fixed_nodup.bam | cut -f 1,2,4 > cnv_sample_name_bwa_pileup_no_dup.\"{}\" "
samtools view -H s_bowtie2.fixed.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f1 |  xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d10000000 -f $ref  -r \"{}\" s_bowtie2.fixed.bam |cut -f 1,2,4 > cnv_sample_name_bowtie_pileup.\"{}\" "
