#!/bin/bash

# Store list of current download errors
mkdir -p data/downloads/
wget "https://gist.githubusercontent.com/codeforIATIbot/f117c9be138aa94c9762d57affc51a64/raw/errors" -O data/downloads/errors

# Get CKAN (IATI Registry) data
rm -rf data/ckan_publishers/
python fetch_data.py

# Generate a csv file with the number of download errors logged since 2013
cd data/downloads
echo "cloning download errors"
if [ ! -d ./f117c9be138aa94c9762d57affc51a64 ]; then
    git clone https://gist.github.com/f117c9be138aa94c9762d57affc51a64.git
fi
cd ./f117c9be138aa94c9762d57affc51a64
echo "cloned download errors - checking out commits"
git checkout master > /dev/null
git pull > /dev/null
for commit in `git log --format=format:%H`; do
    git checkout $commit
    date=`git log -1 --format="%ai"`
    count=`cat errors | grep -v '^\.$' | wc -l`
    echo $date,$count
done > ../history.csv
echo "cloned and checked out download errors"
cd ../../../

rm -rf data/IATI-Codelists-1 data/IATI-Codelists-2 data/IATI-Codelists-NonEmbedded
echo "cloning IATI-Codelists-NonEmbedded"
git clone --branch master https://github.com/codeforIATI/IATI-Codelists-NonEmbedded.git data/IATI-Codelists-NonEmbedded

echo "cloning Codelists-1"
git clone --branch version-1.05 https://github.com/IATI/IATI-Codelists.git data/IATI-Codelists-1
mkdir data/IATI-Codelists-1/combined-xml
cp data/IATI-Codelists-1/xml/* data/IATI-Codelists-1/combined-xml
cp data/IATI-Codelists-NonEmbedded/xml/* data/IATI-Codelists-1/combined-xml
python mappings_to_json.py data/IATI-Codelists-1/mapping.xml > data/IATI-Codelists-1/mapping.json

echo "cloning Codelists-2"
git clone --branch version-2.03 https://github.com/andylolz/IATI-Codelists.git data/IATI-Codelists-2
mkdir data/IATI-Codelists-2/combined-xml
cp data/IATI-Codelists-2/xml/* data/IATI-Codelists-2/combined-xml
cp data/IATI-Codelists-NonEmbedded/xml/* data/IATI-Codelists-2/combined-xml
python mappings_to_json.py data/IATI-Codelists-2/mapping.xml > data/IATI-Codelists-2/mapping.json

echo "completed fetching data"
