require 'csv'

class ColorMatcher
  def initialize
    @rgbcolors=[]
    CSV.foreach("./colors/colorlist.csv", headers: true, col_sep: "\t") do |row|
      name = row["Name"].to_s
      rgb  = [row["Red"].to_i, row["Green"].to_i, row["Blue"].to_i]
      @rgbcolors.push([name, rgb])
    end
    @rgbcolors
  end

  def match(array)
    @rgbcolors.each do |name, values|
      if values == array
        return name
      end
    end
  end

end
