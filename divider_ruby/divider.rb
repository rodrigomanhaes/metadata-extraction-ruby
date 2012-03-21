
class Divider
   def divide_data(type_file)
      campus_file = File.new("#{Dir.pwd}/#{type_file}" ,"w")
        
      File.foreach("#{Dir.pwd}/data") do |line|
         if line.include?(type_file)
            campus_file.write(line)
         end
      end
   end
end

separate = Divider.new
#separate.divide_data("Instituto")
#separate.divide_data("Campus")
