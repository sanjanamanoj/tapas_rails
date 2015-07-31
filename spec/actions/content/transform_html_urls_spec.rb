require 'spec_helper' 

describe TransformHTMLUrls do 
  include FileHelpers

  describe ".transform" do 
    after(:all) { ActiveFedora::Base.delete_all } 

    before(:all) do 
      @core_file = FactoryGirl.create :core_file 
      @community = FactoryGirl.create :community 
      @collection = FactoryGirl.create :collection 

      @core_file.collections << @collection 
      @collection.community = @community 

      # Create page images 
      @pimg1, @pimg2 = FactoryGirl.create_list(:image_master_file, 2) 
      @pimg1.page_image_for << @core_file
      @pimg1.add_file('picture', 'content', 'image_one.jpg')
      @pimg2.page_image_for << @core_file 
      @pimg2.add_file('picture', 'content', 'image_two.jpg') 
      
      @html = Nokogiri::HTML(File.read(fixture_file 'teibp_simple.html'))

      # Create a single Ography object and attach it to the 
      # core_file's collection
      @og_core = FactoryGirl.create :core_file 
      @biblio = FactoryGirl.create :tei_file 
      @biblio.add_file('<xml>a</xml>', 'content', 'bibliography.xml')
      @biblio.canonize
      @biblio.core_file = @og_core
      @og_core.collections << @collection
      @og_core.bibliography_for << @collection
      
      @core_file.save!
      @community.save!
      @collection.save!
      @pimg1.save!
      @pimg2.save!
      @og_core.save!
      @biblio.save!

      @html = TransformHTMLUrls.transform(@core_file, @html)
    end

    it 'uses the repository link for the bibliography' do
      expected_url = SupportFileMap.new(nil).download_url @biblio 
      element = @html.xpath("//*[text()='bibliography']")
      expect(element.count).to eq 1 
      element = element.first
      expect(element['href']).to eq expected_url
    end

    it 'uses the repository link for image one' do 
      expected_url = SupportFileMap.new(nil).download_url @pimg1
      element = @html.xpath("//*[@originally='image_one.jpg']")
      expect(element.count).to eq 1 
      element = element.first
      expect(element['src']).to eq expected_url
    end

    it "doesn't change the absolute url for image two" do 
      expected_url = 'http://www.cdn.biz/image_two.jpg'
      element = @html.xpath("//*[@originally='image_two.jpg']")
      expect(element.count).to eq 1 
      element = element.first 
      expect(element['src']).to eq expected_url
    end
  end
end
