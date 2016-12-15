#!/bin/bash

module load parallel

c_S1_R1=c_s1r1Fastq
c_S1_R2=c_s1r2Fastq
c_S2_R1=c_s2r1Fastq
c_S2_R2=c_s2r2Fastq


WORKING_PATH=working_dir
BWA_DB=bwa_db_value
BOWTIE2_DB=bowtie2_db_value
S_DB=seq_db
ref=/panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa

bwacommand1="/home/msistaff/lamx0031/my_software/BWA/bwa-0.7.15/bwa mem -M -t 24 $BWA_DB $c_S1_R1 $c_S1_R2 | samtools view -q 10 -bS - > c_bwa_s1.bam"
bwacommand2="/home/msistaff/lamx0031/my_software/BWA/bwa-0.7.15/bwa mem -M -t 24 $BWA_DB $c_S2_R1 $c_S2_R2 | samtools view -q 10 -bS - > c_bwa_s2.bam"


echo ${bwacommand1} > $WORKING_PATH/aligncommands
echo ${bwacommand2} >>$WORKING_PATH/aligncommands

btcommand1="bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $c_S1_R1 -2 $c_S1_R2 | samtools view -q 10 -bS - > c_bowtie2_s1.bam"
btcommand2="bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $c_S2_R1 -2 $c_S2_R2 | samtools view -q 10 -bS - > c_bowtie2_s2.bam"
echo ${btcommand1} >> $WORKING_PATH/aligncommands
echo ${btcommand2} >> $WORKING_PATH/aligncommands
cat ${WORKING_PATH}/aligncommands | parallel -j +0 $1



mergecommand1="samtools merge c_bwa.bam c_bwa_s1.bam c_bwa_s2.bam"
mergecommand2="samtools merge c_bowtie2.bam c_bowtie2_s1.bam c_bowtie2_s2.bam"
echo ${mergecommand1} > $WORKING_PATH/mergecommands
echo ${mergecommand2} >> $WORKING_PATH/mergecommands
cat ${WORKING_PATH}/mergecommands | parallel -j +0 $1


java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=c_bwa.bam OUTPUT=c_bwa.fixed.bam
pica1="java -Xmx4g -jar  $CLASSPATH/picard.jar MarkDuplicates REMOVE_DUPLICATES=true ASSUME_SORTED=true METRICS_FILE=c_bwa_duplicate_stats.txt INPUT=c_bwa.fixed.bam OUTPUT=c_bwa.fixed_nodup.bam"
pica2="java -Xmx4g -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=c_bowtie2.bam OUTPUT=c_bowtie2.fixed.bam"
echo ${pica1} > $WORKING_PATH/cpicardcommands
echo ${pica2} >> $WORKING_PATH/cpicardcommands
cat $WORKING_PATH/cpicardcommands | parallel -j +0 $1



indexcomm1="samtools index c_bwa.fixed.bam"
indexcomm2="samtools index c_bwa.fixed_nodup.bam"
indexcomm3="samtools index c_bowtie2.fixed.bam"

echo ${indexcomm1} > $WORKING_PATH/indexcommands
echo ${indexcomm2} >> $WORKING_PATH/indexcommands
echo ${indexcomm3} >> $WORKING_PATH/indexcommands
cat ${WORKING_PATH}/indexcommands | parallel -j +0 $1

samtools view -H c_bwa.fixed.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f1 |  xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d10000000 -f $ref  -r \"{}\" c_bwa.fixed.bam | cut -f 1,2,4 > cnv_control_name_bwa_pileup.\"{}\""
samtools view -H c_bwa.fixed_nodup.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f1 |  xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d10000000 -f $ref  -r \"{}\" c_bwa.fixed_nodup.bam | cut -f 1,2,4 > cnv_control_name_bwa_pileup_no_dup.\"{}\" "
samtools view -H c_bowtie2.fixed.bam | grep "\@SQ" | sed 's/^.*SN://g' | cut -f1 |  xargs -I {} -n 1 -P 24 sh -c "samtools mpileup -BQ0 -d10000000 -f $ref  -r \"{}\" c_bowtie2.fixed.bam | cut -f 1,2,4 > cnv_control_name_bowtie_pileup.\"{}\""

