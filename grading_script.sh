#! /bin/bash

check_commit_count() {
  printf "### Total Commits: "
  git rev-list --count HEAD | tail -1
  printf "\n"
}

check_commit_ts_diff() {
  printf "### Time between each commit: \n"
  printf "Previous Commit --> Commit \n"

  for ix in `git rev-list HEAD`; do 
    thists=`git log $ix -n 1 --format=%ct`; 
    prevts=`git log $ix~1 -n 1 --format=%ct 2>/dev/null`; 
    if [ ! -z "$prevts" ] ; then
      thisd=`date -d @$thists +'%d'`
      prevd=`date -d @$prevts +'%d'`
      if (("$thisd" != "$prevd")) ; then
        echo `date -d @$prevts` "--> No more commits rest of day"
      else 
        # delta=$(( $thists - $prevts ));
        date1=$(date -d @$prevts +'%s')
        date2=$(date -d @$thists +'%s')
        DIFF=$(($date2-$date1))
        echo `date -d @$prevts` "-->"  \
             `date -d @$thists` " diff= " \
             "$(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds";
      fi;
    fi; 
  done
  printf "\n"
}

# date1=$(date +"%s")
# date2=$(date +"%s")
# DIFF=$(($date2-$date1))
# echo "Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"

# Wed 13 Apr 2022 05:41:01 PM PDT --> Wed 13 Apr 2022 06:00:24 PM PDT  min:sec=  16:19:23
# Wed 13 Apr 2022 01:26:53 PM PDT --> Wed 13 Apr 2022 05:41:01 PM PDT  min:sec=  20:14:08
# Wed 13 Apr 2022 12:50:53 PM PDT --> Wed 13 Apr 2022 01:26:53 PM PDT  min:sec=  16:36:00
# Wed 13 Apr 2022 11:20:16 AM PDT --> Wed 13 Apr 2022 12:50:53 PM PDT  min:sec=  17:30:37
# DIFFERENT DAY
# Wed 04 Aug 2021 05:06:19 PM PDT --> Wed 13 Apr 2022 11:20:16 AM PDT  min:sec=  11:13:57
# DIFFERENT DAY
# Mon 12 Jul 2021 11:32:17 AM PDT --> Wed 04 Aug 2021 05:06:19 PM PDT  min:sec=  21:34:02
# Mon 12 Jul 2021 11:32:06 AM PDT --> Mon 12 Jul 2021 11:32:17 AM PDT  min:sec=  16:00:11
# DIFFERENT DAY
# Wed 22 Jul 2020 04:33:39 PM PDT --> Mon 12 Jul 2021 11:32:06 AM PDT  min:sec=  10:58:27
# Wed 22 Jul 2020 02:58:20 PM PDT --> Wed 22 Jul 2020 04:33:39 PM PDT  min:sec=  17:35:19
# Wed 22 Jul 2020 02:09:07 PM PDT --> Wed 22 Jul 2020 02:58:20 PM PDT  min:sec=  16:49:13

check_commit_history() {
  printf "### Commit History:\n"
  git log -s --oneline
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
    printf " - ✅ No eslint errors or warnings found. \n"
  else
  printf " - ❌ eslint errors and/or warnings found. Please fix these:\n"
  printf "$lint"
  fi;
}

run_jest() {
  printf " - ▢ Check test coverage. Percent Lines should be 100. No lines should be uncovered. \n"
  npx jest --coverage
}

check_gitignore() {
    if [ -f .gitignore ]; then
    printf " - ✅ .gitignore present! \n"
    gitignore=./.gitignore
    itemList=("node_modules/" "dist/" "coverage/")
    not_in_gitignore=""
    for item in "${itemList[@]}"
    do
      if ! grep -q "$item" "$gitignore"
      then
        not_in_gitignore+="$item  \n"
      fi
    done
      if [ "$not_in_gitignore" ]; then
        printf " - ❌ These items are missing from .gitignore: $not_in_gitignore \n"
      else
        printf " - ✅ .gitinore has all appropriate files and directories \n"
      fi
  else
    printf " - ❌ No .gitignore file in the root directory found! \n"
  fi
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

  printf "### Objectives Check \n" >> "$REVIEWOUTPUT"
  printf "This is a list of items the grading script is checking for you. \n" >> "$REVIEWOUTPUT"
  printf "❌: an X means the grading script found an issue that should be addressed. \n" >> "$REVIEWOUTPUT"
  printf "✅: a checkmark the grading script has found no issue. \n\n" >> "$REVIEWOUTPUT" 
  readme_exists >> "$REVIEWOUTPUT"
  get_eslint_errors >> "$REVIEWOUTPUT"
  check_gitignore >> "$REVIEWOUTPUT"
  printf "\n\n" >>  "$REVIEWOUTPUT"

  printf "### Checklist to Review \n" >> "$REVIEWOUTPUT"
  printf "This is a list of things that the grading script can't check for you. Please review this list before turning in your project. \n" >> "$REVIEWOUTPUT"
  run_jest >> "$REVIEWOUTPUT"

  printf "\n" >> "$REVIEWOUTPUT"
  # run_htmlhint >> "$REVIEWOUTPUT"
  printf "\n" >> "$REVIEWOUTPUT"
   printf "\n" >> "$REVIEWOUTPUT"

  check_main_exists >> "$REVIEWOUTPUT"
  printf "\n" >> "$REVIEWOUTPUT"
