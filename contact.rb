require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'datamapper'
require 'erb'
require 'haml'

# Map to a sqlite3 database named 'contact.db' in the current directory
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/contact.db")

# Define a Contact class make it data-aware
class Contact
    include DataMapper::Resource
    property :id, Serial
    property :firstname, String
    property :lastname, String
    property :email, String
end

# Automatically create the contact table
Contact.auto_migrate! unless Contact.storage_exists?

get '/' do
  erb :index
end

get '/contacts' do
  contacts = Contact.all(:order => [ :lastname, :firstname ])
  erb :list, :locals => {:contacts => contacts}
end

get '/contacts/init' do
  Contact.all.destroy
  Contact.create(:firstname => "bilbo", :lastname => "baggins", :email => "bilbo@gmail.com")
  Contact.create(:firstname => "frodo", :lastname => "baggins", :email => "underhill@mac.com")
  Contact.create(:firstname => "fred",  :lastname => "savage",  :email => "fred@comcast.net")
  Contact.create(:firstname => "steve", :lastname => "mcqueen", :email => "bullet@att.net")
  redirect to('/contacts')
end

get '/contact/:id' do
  id = params[:id]
  if (id == "new")
    c = Contact.create(:firstname => "first", :lastname => "last", :email => "mail")
    id = c.id
    redirect to('/contact/edit/' + id.to_s)
  end  
  c = Contact.get(id)
  erb :one, :locals => {:c => c}
end

get '/contact/del/:id' do
  c = Contact.get(params[:id])
  erb :delete, :locals => {:c => c}
end

get '/contact/edit/:id' do
  id = params[:id]
  c = Contact.get(id)
  erb :edit, :locals => {:c => c}
end

delete '/contact/:id' do
  id = params[:id]
  c = Contact.get(id)
  c.destroy if (c)
  redirect to('/contacts')
end

post '/contact' do
  id = params[:id]
  c = Contact.get(id)
  c.update(:lastname => params[:lastname], :firstname => params[:firstname],:email => params[:email])
  redirect to('/contacts')
end
