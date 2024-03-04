#!/usr/bin/env bash

set -e

# FILE_FILTER is a regex to match files against. For example, to validate only .c and .h files
# set it to:
#     ".*\.(c|h)$"
# By default we match everything
if [ -z $FILE_FILTER ]; then
  export FILE_FILTER=".*"
fi

tw_lines=""  # Lines containing trailing whitespaces.

# TODO (harupy): Check only changed files.
for file in $(git ls-files | sed -e 's/^/.\//')
do
  if [[ "$file" =~ $FILE_FILTER ]]; then
    lines=$(egrep -rnIH " +$" $file | cut -f-2 -d ":")
    if [ ! -z "$lines" ]; then
      tw_lines+=$([[ -z "$tw_lines" ]] && echo "$lines" || echo $'\n'"$lines")
    fi
  fi
done

exit_code=0

# If tw_lines is not empty, change the exit code to 1 to fail the CI.
if [ ! -z "$tw_lines" ]; then
  echo -e "\n***** Lines containing trailing whitespace *****\n"
  echo -e "${tw_lines[@]}"
  echo -e "\nFailed.\n"
  exit_code=1
fi

exit $exit_code
