#!/bin/sh

for table in artists file_dirs albums songs genres tags audio_files audio_files_tags image_files lyrics list_heads list_nodes; do
    echo "cp /srv/dev/apps/player/app/controllers/${table}_controller.rb /srv/dev/apps/playit/app/controllers"
    echo "cp -r /srv/dev/apps/player/app/views/${table} /srv/dev/apps/playit/app/views/"
done
