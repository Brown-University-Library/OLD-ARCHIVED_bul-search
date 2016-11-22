Python program to normalize call numbers from a MySQL database
and store the results back in the database.

The original code was taken from Ted's program to normalize one call
number at a time and was updated to process batches of call numbers
(from a MySQL database) and save back the normalized numbers.

## Set up the environment
```
cd misc
virtualenv callnumber_norm
cd callnumber_norm
source bib/activate
pip install pymsql
```

## To run this program
```
cd misc/callnumber_norm
source bib/activate
DB_HOST=h DB_NAME=n DB_USR=u DB_PASS=p python callnumbers.py
```
