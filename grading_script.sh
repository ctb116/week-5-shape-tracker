#! /bin/bash

check_commit_count() {
  printf "### Total Commits: "
  git rev-list --count HEAD | tail -1
  printf "\n"
}

check_commit_ts_diff() {
  printf "### Time between each commit: \n"
  printf "Commit --> Previous Commit \n"
  printf "date hour:minute:second --> date hour:minute:second  min:sec=  minutes:seconds \n\n"
  printf "(ignore the first timestamp)"

  for ix in `git rev-list HEAD`; do 
    thists=`git log $ix -n 1 --format=%ct`; 
    prevts=`git log $ix~1 -n 1 --format=%ct 2>/dev/null`; 
    if [ ! -z "$prevts" ] ; then
      thisd=`date -d @$thists +'%d'`
      prevd=`date -d @$prevts +'%d'`
      if (("$thisd" > "$prevd")) ; then
        echo "DIFFERENT DAY"
      else
        delta=$(( $thists - $prevts )); 
        echo `date -d @$thists +'%Y-%m-%d %H:%M:%S'` "-->"  \
            `date -d @$prevts +'%Y-%m-%d %H:%M:%S'` " min:sec= " \
            `date -d @$delta +'%M:%S'`;
      fi;
    fi; 
  done
  printf "\n"
}

check_commit_history() {
  printf "### Commit History:\n"
  git log HEAD |grep --line-buffered "Date"
}

check_main_exists() {
  val=$(git branch)
  if [ "$val" == "master" ] ; then
    print "Your default branch should be called main. Instead found master."
  else
    check_commit_count
    check_commit_ts_diff
    check_commit_history
  fi;
}

readme_exists() {
  if [ -f README.md ]; then
    printf " - ✅ Readme present! \n"
    README=./README.md
    HeaderList=("Technologies Used" "Description" "Setup/Installation Requirements" "Known Bugs" "License")
    not_in_readme=""
    for header in "${HeaderList[@]}"
    do
      if ! grep -q "$header" "$README"
      then
        not_in_readme+="$header  "
      fi
    done
      if [ "$not_in_readme" ]; then
        printf " - ❌ These sections are missing from your README (This is an exact match check): $not_in_readme"
      else
        printf " - ✅ README has all required sections based on header title. Please make sure that each section has information and you have removed all placeholder information. (make sure you have a link to your GitHub Pages)"
      fi
  else
    printf " - ❌ No README.md file in the root directory found!"
  fi
  printf "\n"
}

get_eslint_errors() {
  lint=$(npx eslint ./src/js/triangle.js)

  if [ "$lint" == "" ] ; then
    printf " - ✅ No eslint errors or warnings found."
  else
  printf " - ❌ eslint errors and/or warnings found. Please fix these:\n"
  printf "$lint"
  fi;
}

# run_htmlhint() {
#   printf "### HTML File Check \n"

#   printf "**Description:** htmlhint checks all html files in your project and outputs any errors below. \n"
#   printf "Each error is printed on a new line. \n"
#   printf "Each error directs you to the file and line in your html file the problem was found. \n\n"
#   printf "You may need to turn off word wrap (alt-z or View -> Word Wrap) for better readability. \n"

#   printf "#### HTML Errors: \n"
#   npx htmlhint "**/*.html" -f compact
#   printf "If empty then no errors found. \n"
#   printf "**Be sure to resolve all warnings in your terminal as well.** \n"
#   printf "These warnings are likely HTML formatting issues such as missing or misplaced tags, or improper indentation. \n"
#   printf "Nothing in terminal means no warnings. \n\n"

# }

  REVIEWOUTPUT=./review.md
  if [ -f "$REVIEWOUTPUT" ]; then
  rm review.md
  fi

  date=$(date +'%m/%d/%Y')
  time=$(date +'%r')

  printf "$date \n" >> "$REVIEWOUTPUT"
  printf "$time \n\n" >>  "$REVIEWOUTPUT"

  printf "## Intermediate JavaScript - Test-Driven Development and Environments with JavaScript \n\n" >> "$REVIEWOUTPUT"

  printf "❌: an X means a possible Resubmission Requirement if not addressed.\n" >> "$REVIEWOUTPUT"
  printf "✅: a checkmark means you are doing great and on the right track!\n" >> "$REVIEWOUTPUT"
  
  printf "### Objectives Check \n" >> "$REVIEWOUTPUT"
  readme_exists >> "$REVIEWOUTPUT"
  get_eslint_errors >> "$REVIEWOUTPUT"

  printf "\n" >> "$REVIEWOUTPUT"
  # run_htmlhint >> "$REVIEWOUTPUT"
  printf "\n" >> "$REVIEWOUTPUT"
   printf "\n" >> "$REVIEWOUTPUT"

  check_main_exists >> "$REVIEWOUTPUT"
  printf "\n" >> "$REVIEWOUTPUT"
