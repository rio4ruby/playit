#!/bin/sh

# for table in artists file_dirs albums songs genres tags audio_files audio_files_tags image_files lyrics list_heads list_nodes; do
for table in artists file_dirs albums songs genres tags audio_files audio_files_tags image_files lyrics; do
    echo $table
    pg_dump -h db.kitatdot.net -U play player_development -t $table -a > data/$table.sql
    psql -h db.kitatdot.net -U play playit_development < data/$table.sql
done
