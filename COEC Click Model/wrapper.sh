  bzcat server.log.*  B/server.* | grep ', shirts,' | grep ' SEARCH_IMP' | awk -F"," '{print $6","$8","$7}' | sed -e 's/, /,/g' > tmp &&  bzcat server.log.*  B/server.* | grep ' SEARCH_CLICK,' | awk -F"," '{print $6","$7","$8}' | sed -e 's/, /,/g' | grep '^ shirts,'  > tmp1

/* spark job */

cat redsaree_imp/part* | sed -e 's/( //g' | sed -e 's/)//g' > imp

rm -rf redsaree_imp


