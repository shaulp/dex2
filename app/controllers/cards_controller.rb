require 'lookups'
class CardsController < ApplicationController
	ParamsTemplate = {
  	"set" => {
	    "card" => {"id" => ""},
	    "property" => {"name" => "", "value" => ""}},
  	"index" => {"title" => ""},
  	"QueryParams" => {"properties" => ""},
  	"create" =>  {"template" => "", "title" => "", "properties" => ""},
    "delete" => {"id" => ""},
    "update" => {"id" => "", "title" => ""},
    "query" => {"properties" => {}}
	}

  before_action :set_card, only: [:show, :edit, :update, :destroy, :set, :get]
  before_action :set_template, only:[:create, :index]
  before_action :set_actual_params, only:[:index, :create, :set, :query]

  def home
    respond_to do |format|
      format.html { render "home"}
      format.json { render json: json_err_response("cards", "i18> Use html call for home") }
    end
  end

  def index
    begin
      @cards = Lookups.cards_with_properties(@actual_params)

      if @cards.empty?
        respond_err "card", Card.new, "i18> No cards found"
      else
        respond_ok "card", @cards
      end
    rescue Exception => e
      respond_err "card", Card.new, e.message
    end
  end

  def create
    @card = Card.new(@actual_params)
    @card.template = @template
    if @card.save
      respond_ok "card", @card
    else
      respond_err "card", @card, @card.errors
    end
  end

  def destroy
    if @card.destroy
      respond_ok "card", @card
    else
      respond_err "card", @card, @card.errors
    end
  end

  def update
    if @card.update(@actual_params)
      respond_ok "card", @card
    else
      respond_err "card", @card, @card.errors
    end
  end

  def set
    @card.set @actual_params["property"]["name"], @actual_params["property"]["value"]
    if @card.errors.empty? && @card.save
      respond_ok "card", @card
    else
      respond_err "card", @card, @card.errors
    end
  end

  def query
    begin
      @cards = Lookups.cards_with_properties(@actual_params["properties"])
      if @cards.empty?
        respond_err "card", Card.new, "i18> No cards found"
      else
        respond_ok "card", @cards
      end
    rescue Exception => e
      respond_err "card", Card.new, e.message
    end
  end

	private
    def set_actual_params
      @actual_params = clean_params(ParamsTemplate[action_name], params)
    end

    def set_template
      @template = Template.where(name:params[:template_name])[0] rescue nil
      unless @template
      #  params[:template] = @template
      #else
        respond_err "card", Card.new, "i18> Template '#{params[:template_name]}' not found."
      end
    end

    def set_card
      @card = Card.where(id:params[:id])[0] rescue nil
      respond_err "card", Card.new, "i18> Card '#{params[:id]}' not found." unless @card
    end
end
