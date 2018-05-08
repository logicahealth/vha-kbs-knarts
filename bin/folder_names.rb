#!/usr/bin/env ruby
require 'csv'

def normalize_name(n)
	n.strip.downcase.gsub(/\s+/, '_').gsub(/&/,'and').gsub(/[^\w]/, '').gsub(/_clinical_content_white_paper/, '')
end

names = []
CSV.read('folder_names.csv', headers: :first_row, return_headers: false).each do |r|
	if r[0].nil? || r[0].empty?
		names.push "#{normalize_name(r[1])}"
	else
		r[0].split(",").each do |code|
			names.push "#{normalize_name(r[1])}/#{code.downcase}"
		end
	end
end

names.each do |n| puts n end
