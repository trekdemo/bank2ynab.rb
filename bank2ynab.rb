#!/usr/bin/env ruby

# Small script which converts exported bank account history to YNAB compatible
# csv format.
#
# Sample usage:
#   The following will create a new file called `ynab_compatible.csv` with the
#   converted account history from `exported.csv`
#
#   $ cat exported.csv | ./bank2ynab.rb > ynab_compatible.csv budapestbank
#
#
# Supported banks:
#   * Budapest Bank
#

require 'csv'
require 'bigdecimal'

class BankCsvRow < BasicObject
  attr_reader :row

  def initialize(csv_row)
    @row = csv_row
  end

  def self.method_missing(m, *args, &blk)
    define_method(m, &blk)
  end
end

class BudapestBank
  def self.convert(io)
    new(io)
  end

  def initialize(io)
    @csv_content = io.read.force_encoding("ISO-8859-1").encode("UTF-8")
  end

  def to_ynab_csv
    puts 'Date,Payee,Category,Memo,Outflow,Inflow'
    CSV.parse(@csv_content, headers: true) do |row|
      print CsvRow.new(row).to_ynab_row
    end
  end

  class CsvRow < BankCsvRow
    date         { ::Date.parse(row['Értéknap']).strftime('%d/%m/%Y') }
    category     { row['Tranzakció'].to_s.strip }
    withdraw?    { amount < 0 }
    credit_debit { row['Credit/Debit'] == 'D' }
    currency     { row['Deviza'] }
    amount       { ::BigDecimal.new(row['Összeg']) }
    refno        { row['Referenciaszám']}
    memo1        { row['Közlemény 1'].to_s.strip }
    memo2        { row['Közlemény 2'].to_s.strip }
    memo3        { row['Közlemény 3'].to_s.strip }
    memo23       { [memo2, memo3].join(' ') }
    outflow      { amount.abs.to_s('F') if withdraw? }
    inflow       { amount.to_s('F') unless withdraw? }

    def to_ynab_row
      ::CSV.generate { |io| io << [date, memo1, category, memo23, outflow, inflow] }
    end
  end
end

if __FILE__ == $0
  case ARGV[0]
  when 'budapestbank', 'bb', nil
    BudapestBank.convert($stdin).to_ynab_csv
  else
    puts "Don't know about that format!"
  end
end
