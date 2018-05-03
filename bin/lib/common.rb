module Repository
	SUPPORTED_MIME_TYPES = {
		"application/pdf": {name: "PDF", extensions: ['pdf']},
		"application/msword": {name: "Word", extensions: ['doc','docx']},
		"text/html": {name: "HTML", extensions: ['html','htm']},
		"application/vnd.openxmlformats-officedocument.wordprocessingml.document":
			{name: "Word", extensions: ['doc','docx']},
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
			{name: "Excel", extensions: ['xls','xlsx']},
		"application/hl7-cds-knowledge-artifact-1.3+xml": {name: 'HL7 KNART v1.3', extensions: ['xml','knart'], 'knart': true}
	  }
	
	KNART_MIME_TYPES = [
		"application/hl7-cds-knowledge-artifact-1.3+xml"
	  ]
	
	# def audit_content_directory(root, manifest)
	# 	good = []
	# 	bad = []
	# 	manifest['groups'].each do |group|
	# 		group['items'].each do |item|
	# 			if item['path']
	# 				path = "#{root}/#{item['path']}"
	# 				if File.exist? path
	# 					good << item
	# 				else
	# 					bad << item
	# 				end
	# 			end
	# 			begin
	# 				if item['url']
	# 					response = HTTParty.head(item['url'])
	# 					if(response.code >= 400)
	# 						bad << item
	# 					else
	# 						good << item
	# 					end
	# 				end
	# 			rescue SocketError => e
	# 				# Probably a bad DNS or protocol name.
	# 				bad << item
	# 			end
	# 		end
	# 	end
	# 	return [good, bad]
	# end

	
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

end