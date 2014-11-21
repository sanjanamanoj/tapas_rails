class Community < CerberusCore::BaseModels::Community
  include Nid
  include OGReference

  has_collection_types ["Collection"]
  has_community_types  ["Community"]
  has_core_file_types  ["CoreFile"]

  parent_community_relationship :community 

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  has_attributes :project_members, datastream: "properties", multiple: true
end
