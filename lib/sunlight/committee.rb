module Sunlight

  class Committee < Base

    attr_accessor :name, :id, :chamber, :subcommittees, :members

    def initialize(params)
      params.each do |key, value|    

        case key

        when 'subcommittees'
          self.subcommittees = value.map do |subcommittee|
            Sunlight::Committee.new(subcommittee["committee"])
          end
          
        when 'members'
          self.members = value.map do |legislator|
            Sunlight::Legislator.new(legislator["legislator"])
          end
    
        else
          instance_variable_set("@#{key}", value) if Committee.instance_methods.include? key
        end
      end
    end
    
    def load_members
      self.members = Sunlight::Committee.get(self.id).members
    end
    
    # 
    # Usage:
    #   Sunlight::Committee.get("JSPR")     # returns a Committee
    #
    def self.get(id)

      url = construct_url("committees.get", {:id => id})
      
      if (result = get_json_data(url))
        committee = Committee.new(result["response"]["committee"])
      end

    end
    
    #
    # Usage:
    #   Sunlight::Committee.all_for_chamber("Senate") # or "House" or "Joint"
    #
    # Returns:
    #
    # An array of Committees in that chamber of Congress
    #
    def self.all_for_chamber(chamber)
      
      url = construct_url("committees.getList", {:chamber=> chamber})
      
      if (result = get_json_data(url))
        result["response"]["committees"].map do |committee|
          Committee.new(committee["committee"])
        end
      end
    end

    #
    # Usage:
    #   Sunlight::Committee.all_for_legislator(Sunlight::Legislator.find(...))
    #
    # Returns:
    #
    # An array of Committees for that legislator
    #
    def self.all_for_legislator(legislator)
      url = Sunlight::Base.construct_url("committees.allForLegislator", {:bioguide_id => legislator.bioguide_id})

      if result = Sunlight::Base.get_json_data(url)
        result["response"]["committees"].map do |committee|
          Sunlight::Committee.new(committee["committee"])
        end
      end
    end

  end # class Committee
  
end # module Sunlight