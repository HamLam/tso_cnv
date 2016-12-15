CREATE INDEX `cnv_control_name_pileup_nd` ON `cnv_control_name_bwa_pileup_no_dup`(chr,pos);
CREATE INDEX `cnv_control_name_bwa_pileup_i1` ON `cnv_control_name_bwa_pileup`(chr,pos);
CREATE INDEX `cnv_control_name_bowtie_pileup_i1` ON `cnv_control_name_bowtie_pileup`(chr,pos);

DROP TABLE IF EXISTS `cnv_control_name_exon_pileup`;
CREATE TABLE `cnv_control_name_exon_pileup` AS
SELECT DISTINCT A.*, coverage FROM
tso_exon_contig_pileup A
JOIN
`cnv_control_name_bwa_pileup_no_dup` B
USING(chr,pos);
CREATE INDEX `cnv_control_name_exon_pileup_1` ON `cnv_control_name_exon_pileup`(exon_contig_id);
CREATE INDEX `cnv_control_name_exon_pileup_2` ON `cnv_control_name_exon_pileup`(chr,pos);

DROP TABLE IF EXISTS `cnv_control_name_exon_bowtie`;
CREATE TABLE `cnv_control_name_exon_bowtie` AS
SELECT DISTINCT A.*, coverage FROM
tso_exon_contig_pileup A
JOIN
`cnv_control_name_bowtie_pileup` B
USING(chr,pos);
CREATE INDEX `cnv_control_name_exon_bowtie_1` ON `cnv_control_name_exon_bowtie`(exon_contig_id);
CREATE INDEX `cnv_control_name_exon_bowtie_2` ON `cnv_control_name_exon_bowtie`(chr,pos);

DROP TABLE IF EXISTS `cnv_control_name_exon_bwa_bowtie_ratio`;
CREATE TABLE `cnv_control_name_exon_bwa_bowtie_ratio` AS
SELECT DISTINCT A.chr, A.pos, (A.coverage/B.coverage) AS bowtie_bwa_ratio
FROM
`cnv_control_name_exon_bowtie` A
JOIN
`cnv_control_name_bwa_pileup` B
ON(A.chr = B.chr AND A.pos = B.pos);
CREATE INDEX `cnv_control_name_exon_bwa_bowtie_ratio_1` ON `cnv_control_name_exon_bwa_bowtie_ratio`(chr,pos);
