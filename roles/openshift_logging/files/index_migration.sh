#! bin/bash

# for each index in _cat/indices
# skip indices that begin with . - .kibana, .operations, etc.
# get a list of unique project.uuid
# daterx - the date regex that matches the .%Y.%m.%d at the end of the indices
# we are interested in - the awk will strip that part off
function get_list_of_proj_uuid_indices() {
    curl -s --cacert $CA --key $KEY --cert $CERT https://$es_host:$es_port/_cat/indices | \
        awk -v daterx='[.]20[0-9]{2}[.][0-1]?[0-9][.][0-9]{1,2}$' \
            '$3 !~ "^[.]" && $3 !~ "^project." && $3 ~ daterx {print gensub(daterx, "", "", $3)}' | \
        sort -u
}

if [[ -z "$(oc get pods -l component=es -o jsonpath='{.items[?(@.status.phase == "Running")].metadata.name}')" ]]; then
  echo "No Elasticsearch pods found running.  Cannot update common data model."
  echo "Scale up ES prior to running with MODE=migrate"
  exit 1
fi

count=$(get_list_of_proj_uuid_indices | wc -l)
if [ $count -eq 0 ] ; then
    echo No matching indexes found - skipping update_for_common_data_model
    exit 0
fi
echo Creating aliases for $count index patterns . . .
# for each index in _cat/indices
# skip indices that begin with . - .kibana, .operations, etc.
# get a list of unique project.uuid
# daterx - the date regex that matches the .%Y.%m.%d at the end of the indices
# we are interested in - the awk will strip that part off
{
  echo '{"actions":['
  get_list_of_proj_uuid_indices | \
    while IFS=. read proj uuid ; do
      # e.g. make project.test.uuid.* and alias of test.uuid.* so we can search for
      # /project.test.uuid.*/_search and get both the test.uuid.* and
      # the project.test.uuid.* indices
      echo "{\"add\":{\"index\":\"$proj.$uuid.*\",\"alias\":\"${PROJ_PREFIX}$proj.$uuid.*\"}}"
    done
  echo ']}'
} | curl -s --cacert $CA --key $KEY --cert $CERT -XPOST -d @- "https://$es_host:$es_port/_aliases"
