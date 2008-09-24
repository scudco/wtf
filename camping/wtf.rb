#!/usr/bin/env ruby

require 'camping'
  
Camping.goes :Wtf

module Wtf::Models
  class Definition < Base;end

  class CreateTheBasics < V 1.0
    def self.up
      create_table :wtf_definitions, :force => true do |t|
        t.column :id,         :integer, :null => false
        t.column :acronym,    :string,  :limit => 255
        t.column :description,:text
      end
    end
    def self.down
      drop_table :wtf_definitions
    end
  end
end

module Wtf::Controllers
  class Index < R '/'
    def get
      render :index
    end
  end
  
  class All < R '/all'
    def get
      @definitions = Definition.find(:all)
      render :all
    end
  end
  
  class Wtf < R '/wtf/is/(\w+)', '/wtf/is'
    def get acronym
      @definition = Definition.find_by_acronym(acronym.upcase)
      @definition ? render(:view) : redirect(Add,acronym.upcase)
    end
    def post
      redirect Wtf, input.definition_acronym
    end
  end
  
  class Add < R '/add/(\w+)', '/edit/(\w+)', '/add'
    def get acronym
      if definition = Definition.find_by_acronym(acronym.upcase)
        @description = definition.description
      end
      @acronym = acronym.upcase
      render :add
    end
    def post
      if definition = Definition.find_by_acronym(input.definition_acronym.upcase)
        definition.description = input.definition_description
        definition.save!
      else
        definition = Definition.create :acronym => input.definition_acronym.upcase,
                                     :description => input.definition_description
      end
      redirect Wtf, definition.acronym.upcase
    end
  end
  
  class Style < R '/styles.css'
    def get
      @headers["Content-Type"] = "text/css; charset=utf-8"
      @body = %{
        body {
          font-family: sans-serif;
          background-color: #999;
          text-align: center;
        }
        
        a:link,a:visited,a:active {color: #DDD;}
        a:hover {background-color: #366;color: #FFF;}
        
        div.content {
          padding: 10px;
          margin-left: auto;
          margin-right: auto;
          width: 50em;
        }
        p.definition {
          margin: 1em 0 1em 0;
        }
        span.acronym {
          font-size: 3em;
          font-weight: bold;
        }
        span.description {
          font-size: 3em;
          font-weight: bold;
        }
        .text {
          text-align: center; 
          font-size: 2em;
          width: 23.5em;
          font-weight: bold;
          margin: .2em 0 .2em 0;
        }
        input.submit {
          text-align: center;
          font-size: 2em;
          width: 23.5em;
        }
        h3.input_header {
          background-color: #366;
          color: #CCC;
          font-size: 2em;
          margin: 0.1em;
        }
        div.footer {
          font-size: .7em;
        }
      }
    end
    end
end
module Wtf::Views
  def layout
    html do
      head do
        title 'Gap WTF'
          link :rel => 'stylesheet', :type => 'text/css', 
               :href => '/styles.css', :media => 'screen'
      end
      body do
        div.content do      
          a(:href => R(Index)) { "Home" }
          self << yield
          div.footer do
            "Indexing #{a Wtf::Models::Definition.count, :href => R(All)} definitions"
          end
        end
      end
    end
  end
    
  def index
    _form(:action => R(Wtf))
  end
  
  def all
    separator = %{hr :style => "background-color: gray; height: 5px; border: 0"}
    @definitions.each do |definition|
      _definition(definition)
      eval(separator) if @definitions.size > 1
    end
  end
  
  def view
    _definition(@definition)
    _form(:action => R(Wtf))
  end
  
  def add
    _add_form(:action => R(Add))
  end
  
  #partials
  def _definition(definition)
    p.definition do
      span.acronym "#{definition.acronym}"
      a(:href => "/edit/#{definition.acronym}") { span " means " }
      span.description "#{definition.description}"
    end
  end
  def _add_form(opts)
    form({:method => 'post'}.merge(opts)) do
      h3.input_header { label "Tell me WTF #{@acronym} means", :for => 'definition_acronym' } 
      input :name => 'definition_acronym', :type => 'hidden', 
            :value => "#{@acronym || "ACRONYM"}"; br
      
      textarea :name => 'definition_description',:rows => 10,:cols => 50, :class => 'text' do
        @description
      end;br
      
      input :type => 'submit', :class => 'submit', :value => 'Add Definition'
    end
  end
  
  def _form(opts)
    form({:method => 'post'}.merge(opts)) do
      h3.input_header {label 'WTF does', :for => 'definition_acronym'}
      input :name => 'definition_acronym', :class => 'text',:type => 'text', 
            :value => 'WTF';br

      input :type => 'submit',:class => 'submit',:value => 'mean?'; br
    end
  end
end
 
def Wtf.create
  Wtf::Models.create_schema :assume => (Wtf::Models::Definition.table_exists? ? 1.0 : 0.0)
end