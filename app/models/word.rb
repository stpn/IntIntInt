class Word < ActiveRecord::Base
  include ParsingHelpers

  #Populating the word from sentiment file (tab delimited):
  # Thanks to Tilo from StackOverflow

  def self.populate_from_sentiments(filename)
    csv_data = Word.create_csv_data_array(filename)
    csv_data.each do |cd|
      w = Word.create!
      w.content = cd[:word]
      w.rating = cd[:number]
      w.save!
    end
  end

  def self.process(csv_array)  # makes arrays of hashes out of CSV's arrays of arrays
    result = []
    return result if csv_array.nil? || csv_array.empty?
    headerA = csv_array.shift
    headerA.map!{|x| x.downcase.to_sym }
    csv_array.each do |row|
      result << Hash[ headerA.zip(row) ]
    end
    return result
  end

  def self.create_csv_data_array(filename)
    result = Word.process( CSV.read(filename , { :col_sep => "\t"}) )
    return result
  end





end
