#coding:utf-8
require_relative 'xmlparser'
require 'test/unit'

class Test_Parser < Test::Unit::TestCase   
   def setup
      @teste = Parser.new("/home/oswaldo/Materiais/Projeto_Extracao_de_Metadados/Meta_Extractor/extractor/Template","template.xml")
   end

   def test_verify_metadata_page_finding
      assert_equal @teste.find_OnePage_metadata_page, 3
   end

   def test_verify_various_pages_metadata_page_finding
      assert_equal @teste.find_VariousPages_metadata_page, ([1, 10])
   end      
   
   def test_verify_authors_metadata_finding
      assert_equal @teste.find_authors, ([1, "\n"])
   end
        
   def test_verify_institution_metadata_finding
      assert_equal @teste.find_institution, (["Universidade", "Instituto"])
   end     
   
   def test_verify_abstract_metadata_finding
      assert_equal @teste.find_abstract, ([1, "RESUMO\n", "\n"])
   end
           
   #def test_verify_grade_metadata_finding
    #  assert_equal @teste.find_grade, (["Mestre"])
   #end  
   
   def test_verify_campus_metadata_finding
      assert_equal @teste.find_campus, (["Campus","CAMPUS"])
   end     
   
   def test_verify_title_metadata_finding
      assert_equal @teste.find_title, ("\n")
   end
end   
