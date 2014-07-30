require 'lookups'
class CardsController < ApplicationController
	ParamsTemplate = {
  	"set" => {
	    "card" => {"id" => ""},
	    "property" => {"name" => "", "value" => ""}},
  	"index" => {"title" => ""},
  	"create" =>  {"template" => "", "title" => "", "properties" => {}},
    "delete" => {"id" => ""},
    "update" => {"id" => "", "title" => ""},
    "query" => {"title" => "", "properties" => {}}
	}

#   "QueryParams" => {"properties" => ""},
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
    @card = Card.new(title:@actual_params['title'])
    @card.template = @template
    @card.set_properties @actual_params['properties'] if @actual_params['properties']
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
      cards = Lookups.cards_with_properties(template_by_name, @actual_params)
      if cards.empty?
        respond_err "card", Card.new, "i18> No cards found"
      else
        logger.info ">>>>> responding with #{cards.count} cards"
        respond_ok "cards", cards.as_json
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
    @template = template_by_name
    unless @template
      respond_err "card", Card.new, "i18> Template '#{params[:template_name]}' not found."
    end
  end

  def set_card
    @card = Card.where(id:params[:id])[0] rescue nil
    respond_err "card", Card.new, "i18> Card '#{params[:id]}' not found." unless @card
  end

  def template_by_name
    Template.where(name:params[:template_name])[0] rescue nil
  end
end
