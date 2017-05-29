require 'mail'
require 'json'

def inline_body_with_attachments(html, attachments)
    attachments.each do |attachment|
        if (html =~ /#{attachment.filename}/)
            html = html.sub(attachment.filename, "cid:#{attachment.cid}")
        end
    end
    return html
end

keys = File.read('keys.json')
data_keys = JSON.parse(keys)

options = { :address              => data_keys['server'],
            :port                 => data_keys['port'],
            :domain               => data_keys['domain'],
            :user_name            => data_keys['username'],
            :password             => data_keys['password'],
            :authentication       => :login,
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

mail = Mail.new
mail.charset = 'UTF-8'

mail.from    = data_keys['username']
mail.to      = ARGV[1]
mail.subject = ARGV[2]

other_part = Mail::Part.new do
  content_type 'multipart/related;'
end

# Load the attachments
list = Dir.entries(ARGV[0] + "/img")

list.each { |x| other_part.add_file(x) }

inline_html = inline_body_with_attachments(File.read(ARGV[0] + "/index.html"), other_part.attachments)

html_part = Mail::Part.new do
    content_type 'text/html; charset=UTF-8'
    body         inline_html
end

other_part.add_part(html_part)
mail.add_part(other_part)

mail.deliver!
