#!/usr/bin/python
#-*- coding: utf-8 -*-
#===============================================================================
#
#         FILE: test.py
#
#        USAGE: ./test.py  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Rendong Yang (cauyrd@gmail.com), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: Wed Apr 30 13:27:17 CDT 2014
#     REVISION: ---
#===============================================================================
import sys
import os
header = "##fileformat=VCFv4.1\n##reference=/panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample"
ifp = open(sys.argv[1])
ofp = open('temp.vcf.bed','w')
for line in ifp:
	items = line.rstrip().split()
	if items[-1] != 'gain' and items[-1] != 'hom' and items[-1] != 'het':
		continue
	chr = items[4].split('_')[0]
	start = items[4].split('_')[1]
	end = items[4].split('_')[2]
	name = chr+'_'+start+'_'+items[-1]
	print >> ofp, chr+'\t'+start+'\t'+end+'\t'+name
ifp.close()
ofp.close()
os.system('fastaFromBed -fi /panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa -bed temp.vcf.bed -name -tab -fo temp.seq.txt')
print header
ifp = open('temp.seq.txt')
for line in ifp:
	items = line.rstrip().split()
	chr,start,name = items[0].split('_')
	if name == 'gain':
		ref = items[1]
		alt = items[1]*2
		gt = 'GT\t0/1'
	elif name == 'het':
		ref = '.'
		alt = items[1]
		gt = 'GT\t0/1'
	elif name == 'hom':
		ref = '.'
		alt = items[1]
		gt = 'GT\t1/1'
	else:
		print 'type error: not gain or hom or het!'
		sys.exit(1)
	print chr+'\t'+start+'\t.\t'+ref.upper()+'\t'+alt.upper()+'\t'+'\t'.join(['.']*3)+'\t'+gt
os.remove('temp.seq.txt')
os.remove('temp.vcf.bed')



