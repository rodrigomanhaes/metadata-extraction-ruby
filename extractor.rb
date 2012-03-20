#coding: utf-8
#Gem utilizada: unicode
require 'unicode'
load 'constants.rb' #parsing constants and stop words from constants.rb
require_relative 'parser_ruby/xmlparser'
require_relative 'divider_ruby/divider'

class Extractor
   def initialize      
      @xmlobject = Parser.new("#{Dir.pwd}/Template","template.xml")
      @pages = @xmlobject.find_VariousPages_metadata_page
      @page = @xmlobject.find_OnePage_metadata_page
      @divider = Divider.new
      @name = ARGV[0]
   end

   def open_document
      @document = File.open("#{Dir.pwd}/#{@name}.txt")
   end

   def convert_document(page1, page2)
      system("pdftotext -f #{page1} -l #{page2} #{@name}.pdf #{@name}.txt")
      open_document
   end

   def pdf_page_numbers
      system("pdfinfo #{@name}.pdf | grep Pages")
   end
   
   #auxiliar method
   def list_upcase(array)
      (0..array.length - 1).each do |index|
         array[index] = Unicode.upcase array[index]       
      end
      return array
   end
   
   def extract_authors
      authors = []
      convert_document(@page, @page+1)
      document_lines = @document.readlines
      metadata = @xmlobject.find_authors
      num_line = metadata[0]
      ending = metadata[1]
      (0..document_lines.length - 1).each do |index|
         document_lines[index].strip!
         if document_lines[index].empty?
            @last_author_line = index+1 
            break
         else
            authors << document_lines[index]
         end
      end
      return authors * "\n"
   end

   def extract_title
      metadata = @xmlobject.find_title
      title = " "
      convert_document(@page, @page)
      document_lines = @document.readlines
      title_starting_index = @last_author_line
      while document_lines[title_starting_index] != "\n"
         title += document_lines[title_starting_index]
         title_starting_index += 1
      end
      return title
   end

   def extract_summary
      summary = []
      start_index = 1
      metadata = @xmlobject.find_abstract
      word = metadata[1] #RESUMO\n
      ending = "\n"
      for loop in (@pages[0]..@pages[1]) do
         convert_document(loop, loop+1)
         document_lines = @document.readlines      
         if document_lines[0] == word
            
            if document_lines[start_index] == ending
               start_index += 1            
            end
   
            while document_lines[start_index] != ending do
               summary << document_lines[start_index]
               start_index += 1   
            end
         end

         if not summary.empty?
            break
         end
      end
      #concatenate and remove \\n      
      summary = (summary * '').gsub('\\n',' ')
      return summary   
   end

   def extract_institution
      result = ''
      metadata = @xmlobject.find_institution
      convert_document(@page, @page)
      document_lines = list_upcase(@document.readlines)
      for loop in (0..metadata.length - 1) do
         for index in (0..document_lines.length - 1) do           
            if document_lines[index].include? (metadata[loop]) and result == ''            
               result = (document_lines[index] + document_lines[index+1] + document_lines[index+2])
            elsif result != ''
               break
            end                     
         end
      end
      #Catch the line that includes metadata[loop], and the next 2 lines.           
      result = (result.gsub(",",'').split - STOP_WORDS) - EXTRA_STOP_WORDS 
      return result
   end

   def search_institution_file
      institution_data = ''
      institution = extract_institution
      inst_list = list_upcase(File.open("#{Dir.pwd}/Instituto").readlines)
      biggest_length = 0
      #Run into institution list spliting till catch only the institution name.
      #The loop compares and returns the biggest length using &. The biggest length on
      #the extracted "tags" (institution) & institution name, must be our guy. 
      (0..inst_list.length - 1).each do |index|         
         splited_list = inst_list[index].split(",")
         institution_name = (splited_list[2][25,splited_list[2].length].split(' ')) - EXTRA_STOP_WORDS
         equal_name = (institution & institution_name).length
         if equal_name > biggest_length
            biggest_length = equal_name
            institution_data = inst_list[index]
         end                      
      end
      return institution_data
   end

   def extract_campus
      document_result = ''
      metadata = @xmlobject.find_campus
      convert_document(@page, @page)
      document_lines = list_upcase(@document.readlines)
      (0..metadata.length - 1).each do |template_index|          
         (0..document_lines.length - 1).each do |line_index|
            if document_lines[line_index].include? (metadata[template_index])
               document_result = (document_lines[line_index] + document_lines[line_index+1])  
               break
            end
         end
      end
      document_result = document_result.gsub(",",'').split - STOP_WORDS
      return document_result  
   end


   def search_campi_file
      campus_data = 'Campus '
      campus = extract_campus
      campus_list = list_upcase(File.open("#{Dir.pwd}/Campus").readlines) 
      #Run into institution list, upcasing and spliting till catch only the institution name.
      #It returns what's equal on metadata extraction (institution) and (inst_list),
      #finding the right line on "Instituto" archive. 
      (0..campus_list.length - 1).each do |index|
         splited_list = campus_list[index].split(",")
         campus_name = splited_list[1].split(' ') - STOP_WORDS       
         equal_name = campus_name & campus
         if equal_name == campus_name
            campus_data += equal_name*' '
            break         
         end   
      end
      if campus_data != 'Campus '
         return campus_data
      else
         return "Campus não encontrado."
      end   
   end

   def extract_grade
      graduation_level = ''
      spec_level = ''
      masterdegree_level = ''
      doctoral_level = ''      
      postdoctoral_level = ''
      big_string = ' '     
      #Extracting metadata      
      graduation_metadata = @xmlobject.find_graduation
      spec_metadata = @xmlobject.find_specialization
      masterdegree_metadata = @xmlobject.find_masterdegree # >>> JUST ONE METADATA STRING (MESTRADO)
      doctoral_metadata = @xmlobject.find_doctoral
      postdoctoral_metadata = @xmlobject.find_postdoctoral       
      
      convert_document(@page, @page)
      document_lines = list_upcase(@document.readlines)

      document_lines.each do |line|
         big_string += line.gsub("\n",' ')        
      end   
              
      
      graduation_metadata.each do |graduation|
         if big_string.include? graduation
            graduation_level = GRADUATION
         end
      end

      spec_metadata.each do |spec|
         if big_string.include? spec
            spec_level = SPECIALIZATION 
         end
      end

      if big_string.include? masterdegree_metadata
         masterdegree_level = MASTERDEGREE 
      end   
         
      doctoral_metadata.each do |doctoral|
         if big_string.include? doctoral
            doctoral_level = DOCTORAL
         end
      end
   
      postdoctoral_metadata.each do |postdoctoral|
         if big_string.include? postdoctoral
            postdoctoral_level = POSTDOCTORAL
         end
      end         

  
            
      if postdoctoral_level != '' 
         return postdoctoral_level
      elsif doctoral_level != ''
         return doctoral_level 
      elsif masterdegree_level != ''
         return masterdegree_level      
      elsif spec_level != ''
         return spec_level
      elsif graduation_level != ''
         return graduation_level
      end
      
   end

   

teste = Extractor.new
puts ("RESUMO: #{teste.extract_summary}")
puts
puts ("Autores: #{teste.extract_authors}")
puts
puts ("Grau: #{teste.extract_grade}")
#puts ("Metadados de INSTITUTO: #{teste.extract_institution}")
puts
puts ("Instituto: #{teste.search_institution_file}")
#p ("Metadados de CAMPUS: #{teste.extract_campus}")
puts ("Campus: #{teste.search_campi_file}")
puts
puts ("Título: #{teste.extract_title}")
puts
teste.pdf_page_numbers
#puts teste.extract_campus
end

