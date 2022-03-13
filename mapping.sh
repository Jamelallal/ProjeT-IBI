#!/bin/bash


#*********************************************************************
# Bienvenue dans le deuxième programme !
# Les paramètre que nous allons ici utiliser sont les suivants :
# -> $1 qui est le dossier complet ou sont stockés les fichiers
# -> $2 fichier tsv avec les colonnes 
# -> le chemin du genome de reference 
# -> 

#*********************************************************************

emplacement="$1"
ftsv="$2"                 
genome="$3"


first=$'\t' read -r -a array <<< "$ftsv" #on separe le tableau de :de la tabulation et  \, 

if [ "${array[2]}" != "fastq_ftp" ] && [ "${array[2]}" != "" ] #vide et ligne 1
then
    first=$';' read -r -a nb_read <<< "${array[2]}" #separation avec ;
    if [ "${#nb_read[@]}" == 1 ]
    then
     filename=$(basename "${nb_read[0]}")
     bwa mem -R '@RG\tID:${array[0]}\tPL:ILLUMINA\tPI:0\tSM:${array[0]}\tLB:1' "$genome" "$dir"/"$filename"  > "$genome"/"${array[0]}".sam
    
    if [ "${#nb_read[@]}" == 10 ]  
    then
      bwa mem -R '@RG\tID:${array[0]}\tPL:ILLUMINA\tPI:0\tSM:${array[0]}\tLB:1' "$genome" "$emplacement"/"$filename0" "$emplacement"/"$filename1"  > "$emplacement"/"${array[0]}".sam
      samtools view -bt "$genome" "$emplacement"/"${array[0]}".sam > "$emplacement"/"${array[0]}".bam
      samtools sort -o "$emplacement"/"${array[0]}"_sorted.bam > "$emplacement"/"${array[0]}".bam
      bedtools genomecov -ibam "$emplacement"/"${array[0]}"_sorted.bam  -bga > "$emplacement"/"${array[0]}"_cov
      gatk MarkDuplicatesSpark -I "$emplacement"/"${array[0]}"_sorted.bam -O "$emplacement"/"${array[0]}"_gatk.bam -OBI  
      gatk --java-options "-Xmx4g" HaplotypeCaller  -R "$genome" -I "$emplacement"/"${array[0]}"_gatk.bam -O "$emplacement"/"${array[0]}".g.vcf.gz -ERC GVCF
   
    fi
fi
