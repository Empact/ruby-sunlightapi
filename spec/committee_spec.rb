require File.dirname(__FILE__) + '/spec_helper'

describe Sunlight::Committee do

  before(:each) do

    Sunlight::Base.api_key = 'the_api_key'
    @jan = Sunlight::Legislator.new({"firstname" => "Jan", "district" => "Senior Seat", "title" => "Sen"})  
    @bob = Sunlight::Legislator.new({"firstname" => "Bob", "district" => "Junior Seat", "title" => "Sen"})
    @tom = Sunlight::Legislator.new({"firstname" => "Tom", "district" => "4", "title" => "Rep"})

    @example_legislators = {:senior_senator => @jan, :junior_senator => @bob}    
    @example_committee = {"chamber" => "Joint", "id" => "JSPR", "name" => "Joint Committee on Printing", 
                          "members" => [{"legislator" => {"state" => "GA"}}],
                          "subcommittees" => [{"committee" => {"chamber" => "Joint", "id" => "JSPR", "name" => "Subcommittee on Ink"}}]}

  end

  describe "#initialize" do

    it "should create an object from a JSON parser-generated hash" do
      comm = Sunlight::Committee.new(@example_committee)
      comm.should be_an_instance_of(Sunlight::Committee)
      comm.name.should eql("Joint Committee on Printing")
    end

  end
  
  describe "#load_members" do
    
    it "should populate members with an array" do      
      @committee = {"chamber" => "Joint", "id" => "JSPR", "name" => "Joint Committee on Printing", 
                            "subcommittees" => [{"committee" => {"chamber" => "Joint", "id" => "JSPR", "name" => "Subcommittee on Ink"}}]}
      
      mock_committee = mock(Sunlight::Committee)
      mock_committee.should_receive(:members).and_return([])
      Sunlight::Committee.should_receive(:get).and_return(mock_committee)

      comm = Sunlight::Committee.new(@committee)
      comm.members.should be_nil
      comm.load_members
      comm.members.should be_an_instance_of(Array)      
    end
    
  end
  
  describe "#get" do
    
    it "should return a Committee with subarrays for subcommittees and members" do
      Sunlight::Committee.should_receive(:get_json_data).and_return({"response"=>{"committee" => @example_committee}})
      
      comm = Sunlight::Committee.get('JSPR')
      comm.name.should eql("Joint Committee on Printing")
      comm.subcommittees.should be_an_instance_of(Array)
      comm.members.should be_an_instance_of(Array)
    end
    
    it "should return nil when passed in a bad id" do
      Sunlight::Committee.should_receive(:get_json_data).and_return(nil)
      
      comm = Sunlight::Committee.get('gobbledygook')
      comm.should be(nil)
    end

    it "should return nil when passed in nil" do
      Sunlight::Committee.should_receive(:get_json_data).and_return(nil)
      
      comm = Sunlight::Committee.get(nil)
      comm.should be(nil)
    end
    
  end
  
  describe "#all_for_chamber" do
    
    it "should return an array of Committees with subarrays for subcommittees" do
      Sunlight::Committee.should_receive(:get_json_data).and_return({"response" => {"committees" => 
                                                                                   [{"committee" => @example_committee}]}})
                                                                                   
      comms = Sunlight::Committee.all_for_chamber("Joint")
      comms.should be_an_instance_of(Array)
      comms[0].should be_an_instance_of(Sunlight::Committee)
    end
    
    it "should return nil when passed in junk" do
      Sunlight::Committee.should_receive(:get_json_data).and_return(nil)
      
      comms = Sunlight::Committee.all_for_chamber("Pahrump")
      comms.should be(nil)
    end
    
  end
  
  describe "#all_for_legislator" do
    before do
      @example_committee = {"chamber" => "Joint", "id" => "JSPR", "name" => "Joint Committee on Printing", 
                                                                                  "members" => [{"legislator" => {"state" => "GA"}}],
                                                                                  "subcommittees" => [{"committee" => {"chamber" => "Joint", "id" => "JSPR", "name" => "Subcommittee on Ink"}}]}
      @legislator = Sunlight::Legislator.new({"webform"=>"https://forms.house.gov/wyr/welcome.shtml", "title"=>"Rep", "nickname"=>"", "eventful_id"=>"P0-001-000016482-0", "district"=>"4", "congresspedia_url"=>"http://www.sourcewatch.org/index.php?title=Carolyn_McCarthy", "fec_id"=>"H6NY04112", "middlename"=>"", "gender"=>"F", "congress_office"=>"106 Cannon House Office Building", "lastname"=>"McCarthy", "crp_id"=>"N00001148", "bioguide_id"=>"M000309", "name_suffix"=>"", "phone"=>"202-225-5516", "firstname"=>"Carolyn", "govtrack_id"=>"400257", "fax"=>"202-225-5758", "website"=>"http://carolynmccarthy.house.gov/", "votesmart_id"=>"693", "sunlight_old_id"=>"fakeopenID252", "party"=>"D", "email"=>"", "state"=>"NY"})
    end

    it "should return an array of Committees with subarrays for subcommittees" do
      Sunlight::Base.should_receive(:get_json_data).and_return({
        "response" => {"committees" => [
          {"committee" => @example_committee}
        ]}
      })

      comms = Sunlight::Committee.all_for_legislator(@legislator)
      comms.should be_an_instance_of(Array)
      comms[0].should be_an_instance_of(Sunlight::Committee)
    end

    it "should return nil if no committees are found" do
      Sunlight::Base.should_receive(:get_json_data).and_return(nil)

      comms = Sunlight::Committee.all_for_legislator(@legislator)
      comms.should be_nil
    end
  end
end