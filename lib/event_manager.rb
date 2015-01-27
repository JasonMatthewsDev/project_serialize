require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_num)
  phone_num.to_s.scan(/\d+/).join

  phone_num = phone_num[1..-1] if phone_num.length == 11 and phone_num[0] == '1'
  unless phone_num.length == 10
    phone_num == "0000000000"
  end

  phone_num[0..2] + '-' + phone_num[3..5] + '-' + phone_num[6..9]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."
contents = CSV.open 'full_event_attendees.csv', headers: true, header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

hours = Hash.new(0)
weekday = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  regdate = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')
  hours[regdate.hour] += 1
  weekday[regdate.strftime('%A')] += 1

  #legislators = legislators_by_zipcode(zipcode)
  #form_letter = erb_template.result(binding)
  #save_thank_you_letters(id,form_letter)
end

p hours.sort_by { |k, v| v }.reverse.first[0]
p weekday.sort_by { |k, v| v }.reverse.first[0]
