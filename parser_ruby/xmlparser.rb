#coding: utf-8
require "rexml/document"
include REXML

class Parser
   attr_accessor :tree

   def initialize(template_path, sysargv)
      file = File.open("#{template_path}/#{sysargv}")
      @tree = REXML::Document.new file
      
   end
   
   def find_OnePage_metadata_page
      @page = (tree.root.elements['OnePage'].attributes['type']).to_i
      return @page

   end

   def find_VariousPages_metadata_page
      pages = tree.root.elements['VariousPages']
      page_start_number = (pages.attributes['startpage']).to_i
      page_end_number = (pages.attributes['endpage']).to_i
      @pages = [page_start_number, page_end_number]
      return @pages
   end

   def find_authors
      line = tree.root.elements['OnePage/metadata1/position'].text.to_i
      ending = (tree.root.elements['OnePage/metadata1/suffix']).text.gsub("\\n","\n") #fazer decode \n
      @metauthor = [line, ending]
      return @metauthor
   end

   def find_institution
      institution = (tree.root.elements['OnePage/metadata2/prefix']).text
      @metinstitution = institution.encode("iso8859-1").split(",")
      return @metinstitution
   end

   def find_campus
      campus = tree.root.elements['OnePage/metadata3/prefix'].text
      @metcampus = campus.encode("iso8859-1").split(",")
      return @metcampus    
   end

   def find_graduation
      graduation = (tree.root.elements['OnePage/metadata4/graduation']).text
      @metgraduation = graduation.split(",")
      return @metgraduation
   end

   def find_specialization
      specialization = (tree.root.elements['OnePage/metadata4/spec']).text
      @metspecialization = specialization.split(",")
      return @metspecialization
   end

   def find_masterdegree
      masterdegree = (tree.root.elements['OnePage/metadata4/master_degree']).text
      @metmasterdegree = masterdegree
      return @metmasterdegree
   end

   def find_doctoral
      doctoral = (tree.root.elements['OnePage/metadata4/doctoral']).text
      @metdoctoral = doctoral.split(',')
      return @metdoctoral
   end   
   
   def find_postdoctoral
      postdoctoral = (tree.root.elements['OnePage/metadata4/postdoctoral']).text
      @metpostdoctoral = postdoctoral.split(',')
      return @metpostdoctoral
   end


   def find_title
      prefix = tree.root.elements['OnePage/metadata5/prefix'].text.gsub("\\n","\n")
      @mettitle = prefix
      return @mettitle      
   end

   def find_abstract
      line = tree.root.elements["VariousPages/metadata1/position"].text.to_i
      word = tree.root.elements["VariousPages/metadata1/prefix"].text.gsub("\\n","\n")
      ending = tree.root.elements["VariousPages/metadata1/suffix"].text.gsub("\\n","\n")
      @metabstract = [line, word, ending]
      return @metabstract
      
   end   
end

#teste = Parser.new("/home/oswaldoubuntu/Materiais/Projeto_Extracao_de_Metadados/Meta_Extractor/extractor/Template","template.xml")


