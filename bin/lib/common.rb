# require 'xml/libxml'

module Repository
	SUPPORTED_MIME_TYPES = {
		"application/pdf": {name: "PDF", expression: /\.pdf/i},
		"text/html": {name: "HTML", expression: /\.html?/i},
		"application/vnd.openxmlformats-officedocument.wordprocessingml.document":
			{name: "Word", expression: /\.docx?/i},
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
			{name: "Excel", expression: /\.xlsx?/i},
		"application/hl7-cds-knowledge-artifact-1.3+xml": {name: 'HL7 KNART v1.3', expression: /KRprt.*\.xml/i},
		"application/docbook": {name: 'DocBook', expression: /(HIMKWP|KVRpt|CSD).*\.xml/i},
		'application/hl7-cds-knowledge-artifact-composite+xml': {name: 'Composite Artifact', expression: /CRCK_.*\.xml/i},
		'image/svg+xml': {name: "SVG Image", expression: /\.svg/i}
	  }
	
	KNART_MIME_TYPES = [
		"application/hl7-cds-knowledge-artifact-1.3+xml"
	  ]

	COMPOSITE_MIME_TYPES = [
		'application/hl7-cds-knowledge-artifact-composite+xml'
	  ]
		
	# Forces keys to strings.
	def rekey(hash)
		hash.collect{|k,v| [k.to_s, v]}.to_h
	end

	def audit_content_directory(root, manifest)
		good = []
		bad = []
		manifest['groups'].each do |group|
			group['items'].each do |item|
				if item['path']
					path = "#{root}/#{item['path']}"
					if File.exist? path
						good << item
					else
						bad << item
					end
				end
				begin
					if item['url']
						response = HTTParty.head(item['url'])
						if(response.code >= 400)
							bad << item
						else
							good << item
						end
					end
				rescue SocketError => e
					# Probably a bad DNS or protocol name.
					bad << item
				end
			end
		end
		return [good, bad]

	end

	def render_partial(name, stuff)
		template = File.join(File.dirname(File.expand_path(__FILE__)), name)
		Slim::Template.new(template).render(self, stuff)
	end
	
end

# USAGE: Hash.from_xml(YOUR_XML_STRING)require 'rubygems'
require 'nokogiri'
# modified from http://stackoverflow.com/questions/1230741/convert-a-nokogiri-document-to-a-ruby-hash/1231297#1231297

class Hash
  class << self
    def from_xml(xml_io)
      begin
        result = Nokogiri::XML(xml_io)
        return { result.root.name.to_sym => xml_node_to_hash(result.root)}
      rescue Exception => e
        # raise your custom exception here
      end
    end

    def xml_node_to_hash(node)
      # If we are at the root of the document, start the hash 
      if node.element?
        result_hash = {}
        if node.attributes != {}
          attributes = {}
          node.attributes.keys.each do |key|
            attributes[node.attributes[key].name.to_sym] = node.attributes[key].value
          end
        end
        if node.children.size > 0
          node.children.each do |child|
            result = xml_node_to_hash(child)

            if child.name == "text"
              unless child.next_sibling || child.previous_sibling
                return result unless attributes
                result_hash[child.name.to_sym] = result
              end
            elsif result_hash[child.name.to_sym]

              if result_hash[child.name.to_sym].is_a?(Object::Array)
                 result_hash[child.name.to_sym] << result
              else
                 result_hash[child.name.to_sym] = [result_hash[child.name.to_sym]] << result
              end
            else
              result_hash[child.name.to_sym] = result
            end
          end
          if attributes
             #add code to remove non-data attributes e.g. xml schema, namespace here
             #if there is a collision then node content supersets attributes
             result_hash = attributes.merge(result_hash)
          end
          return result_hash
        else
          return attributes
        end
      else
        return node.content.to_s
      end
    end
  end
end