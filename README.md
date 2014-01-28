# bank2ynab.rb

Small script which converts exported bank account history files to YNAB
compatible csv format.

### Sample usage:
The following command will convert the contents of `exported.csv` and save them
into `ynab_compatible.csv`. After it you can import the new file.

    $ cat exported.csv | ./bank2ynab.rb budapestbank > ynab_compatible.csv


### Supported banks:
* Budapest Bank
