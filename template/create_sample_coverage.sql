DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov` AS
SELECT DISTINCT A.*, avg_window_coverage 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene` A
JOIN
`tso_exon_60bp_segments_main_data_sample_name` B
ON(A.window_id = B.window_id); 
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref1_med` ON `cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov`(window_id);

DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov` AS
SELECT DISTINCT A.*, avg_window_coverage 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene` A
JOIN
`tso_exon_60bp_segments_main_data_sample_name` B
ON(A.window_id = B.window_id); 
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref2_med` ON `cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov`(window_id);

DROP TABLE IF EXISTS `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov`;
CREATE TABLE `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov` AS
SELECT DISTINCT A.*, avg_window_coverage 
FROM
`cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene` A
JOIN
`tso_exon_60bp_segments_main_data_sample_name` B
ON(A.window_id = B.window_id); 
CREATE INDEX `cnv_sample_name_over_control_name_60bp_exon_ref3_med` ON `cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov`(window_id);
