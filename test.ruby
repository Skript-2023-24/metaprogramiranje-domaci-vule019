
require "google_drive"

session = GoogleDrive::Session.from_config("config.json")
ws = session.spreadsheet_by_key("1lZu2tdy3z5AYNP20CmfhozZDscac4Pt-2zHk1sShMEQ").worksheets[0]

#p ws[2, 1]  #==> "hoge"


require "google_drive"
session = GoogleDrive::Session.from_config("config.json")
ws = session.spreadsheet_by_key("1lZu2tdy3z5AYNP20CmfhozZDscac4Pt-2zHk1sShMEQ").worksheets[0]
 

GoogleDrive::Worksheet.class_eval do
  include Enumerable


   def each
     self.rows.each do |row|           #each ce mi izvrsavati blok komandi koji mu dam, tj on krene da radi vidi yield i ode da vidi sta treba da se  uradi konkretno 
      row.each do |cell|
        yield cell unless cell.empty?            
      end
    end
  end
end


GoogleDrive::Worksheet.class_eval do

 
  def method_missing(method_name, *args, &block)
    column_name = method_name.to_s.downcase
    self[column_name] if self.rows[0].include?(column_name)
  end

  
  alias_method :original_uglaste, :[]

  def [](*args)
    if args.length == 1
      headers=self.rows[0]
      col_name = args[0]
      if headers.include?(col_name)
           Column.new(self, col_name)
             # return self.rows.map{|row| unless row[headers.index(col_name)]}.compact
       else
         nil
      end
      else
      self.original_uglaste(*args)
    end
  end
  
  class Column
    def initialize(worksheet, col_name)
      @worksheet = worksheet
      @col_name = col_name
    end
    
    def sum
      headers = @worksheet.rows[0]
      if headers.include?(@col_name)
        col_index = headers.index(@col_name)
        values = @worksheet.rows[1..-1].map { |row| row[col_index] }
        values.compact.map(&:to_i).sum    #svaku vrednost provuce kroz to_i
        else
        puts "Column #{@col_name} not found."
      end
    end

    def avg
      headers = @worksheet.rows[0]
      if headers.include?(@col_name)
        col_index = headers.index(@col_name)
        values = @worksheet.rows[1..-1].map { |row| row[col_index] }     #values je array napravljen od kolone
        numeric_values = values.compact.map(&:to_i)       
        suma = numeric_values.sum
        count = numeric_values.length
  
         suma / count
      end
  
    end
   

    def [](row_index)
      headers = @worksheet.rows[0]
      if headers.include?(@col_name)
        col_index = headers.index(@col_name)
        # p @worksheet.rows[row_index][col_index]
        @worksheet.rows[row_index][col_index]
        else
        puts "Column #{@col_name} not found."
      end
    end

    def []=(index, value)
      # Assign a value to the cell
      headers = @worksheet.rows[0]
      if headers.include?(@col_name)
        row_index = index
        column_index = headers.index(@col_name)
        @worksheet[row_index + 2, column_index + 1] = value
        @worksheet.save
       else
        raise "Column '#{@col_name}' not found."
      end
    end
  end
  
end
 

def add_method(c, m, &b)
  c.class_eval {
    define_method(m, &b)
  }
end


add_method(GoogleDrive::Worksheet, :matrix){
matrix = []
self.rows.each do |row|
    myrow = []
    row.each do |cell|
        myrow << cell 
    end
    matrix << myrow
end
 matrix
 }
add_method(GoogleDrive::Worksheet, :at_index) {|index| return self.rows[index] }     #ovo nam skuplja ceo jedan niz/red 


 
# to string klase uraditi
ws.each do |cell| p cell end

p ws.at_index(5)

p ws.matrix

p ws["kolonab"][3] = "karburator"
  # Save the changes to Google Sheets
p ws["kolonaa"][5]
p ws.kolonaa.sum
p ws.kolonaa.avg

 

