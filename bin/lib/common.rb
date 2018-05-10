# require 'xml/libxml'

module Repository
	SUPPORTED_MIME_TYPES = {
		"application/pdf": {name: "PDF", expression: /\.pdf$/i},
		"text/html": {name: "HTML", expression: /\.html?$/i},
		"application/vnd.openxmlformats-officedocument.wordprocessingml.document":
			{name: "Word", expression: /\.docx?$/i},
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
			{name: "Excel", expression: /\.xlsx?$/i},
		"application/hl7-cds-knowledge-artifact-1.3+xml": {name: 'HL7 KNART v1.3', expression: /KRprt(?!_CRCK).*\.xml$/i},
		"application/docbook": {name: 'DocBook', expression: /(HIMKWP|KVRpt|CSD).*\.xml$/i},
		'application/hl7-cds-knowledge-artifact-composite+xml': {name: 'Composite Artifact', expression: /CRCK_.*\.xml$/i},
		'image/svg+xml': {name: "SVG Image", expression: /\.svg$/i}
	  }
	
	KNART_MIME_TYPES = [
		"application/hl7-cds-knowledge-artifact-1.3+xml"
	  ]

	COMPOSITE_MIME_TYPES = [
		'application/hl7-cds-knowledge-artifact-composite+xml'
	  ]


DIGRAPH_TEMPLATE = <<TEMPLATE
digraph {
	<% artifacts.each do |a| %>
	artifact_<%= a[:hash] %>[label="<%= a[:name] %>", shape=rounded, style=filled, fillcolor=lightblue]<% end %>

	<% events.each do |k, v| %>
	event_<%= v %>[label="<%= k %>", style=filled, fillcolor=yellow]<% end %>
	
	<% artifacts.each do |a| %><% a[:emits].each do |e| %>
	artifact_<%= a[:hash] %> -> event_<%= events[e[:name]] %>[fontsize=8, label="emits\n<%= e[:conditions] %>"]<% end %><% end %>
	<% artifacts.each do |a| %><% a[:triggers].each do |t| %>
	event_<%= events[t] %> -> artifact_<%= a[:hash] %>[label="triggers"]<% end %><% end %>
}
TEMPLATE

def generate_dot(doc)
	artifacts = []
	events = {}
	doc.xpath('//xmlns:containedArtifacts/xmlns:artifact').each do |a|
		name = a.xpath('./xmlns:name/@value').to_s
		triggers = []
		emits = []
		tmp = {
			name: name,
			hash: Digest::SHA1.hexdigest(name),
			triggers: triggers,
			emits: emits
		}
		artifacts << tmp

		# Search for triggers
		# puts a
		a.xpath('.//xmlns:triggers/xmlns:trigger/@onEventName').each do |t|
			value = t.to_s
			triggers << value
			events[value] = Digest::SHA1.hexdigest(value)
		end

		# Emmitted events within embedded KNARTs.
		a.xpath('./xmlns:knowledgeDocument//xmlns:simpleAction[@xsi:type="FireEventAction"]').each do |action|
			conditions = action.xpath('./xmlns:conditions').to_s.gsub('"', '\"')
			# puts conditions
			action.xpath('.//elm:element[@name="EventName"]/elm:value/@value').each do |n|
				value = n.to_s
				emits << {
					name: value,
					conditions: conditions
				}
				events[value] = Digest::SHA1.hexdigest(value)
			end
		end

		# Emmitted events for referencesd KNARTs.
		a.xpath('./xmlns:onCompletion//xmlns:eventName/@name').each do |n|
			value = n.to_s
			emits << {
				name: value,
				conditions: '(always)'
			}
			events[value] = Digest::SHA1.hexdigest(value)
		end
		

	end
	# puts artifacts
	# puts events
	renderer = ERB.new(DIGRAPH_TEMPLATE)
	renderer.result(binding)
end

	# Forces keys to strings.
	def rekey(hash)
		hash.collect{|k,v| [k.to_s, v]}.to_h
	end

	def mimeTypeForFile(path)
		mimeType = nil
		SUPPORTED_MIME_TYPES.each do |k,v|
			if v[:expression].match?(path)
				mimeType = k
				break
			end
		end
		# puts mimeType || path
		mimeType
	end

	def content_directory_to_item_tree(root)
		content = []
		list = Dir["#{root}/**/**"]
		list.each do |n|
			# puts n
			if(File.file?(n))
				# ext = File.extname(n).downcase[1..-1]
				mimeType = mimeTypeForFile(n)
				name = n.split('/')[1] #.split['.'][0]
				name = name.split('_').collect(&:capitalize).join(' ')
				tags = n.split('/').select{|d| d.length <= 4}
				if mimeType # it's a supported piece of content
					item = rekey({
						'name': name,
						'path': n,
						'mimeType': mimeType,
						'tags': tags
					})
					# Any directory name of 4 characters or less will be treated as a tag automatically
					content << item
				end
			end
		end
		content
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
