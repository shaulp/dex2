require 'lookups'
class CardsController < ApplicationController
	ParamsTemplate = {
  	"SetPropertyParams" => {
	    "card" => {"id" => ""},
	    "property" => {"name" => "", "value" => ""}},
  	"index" => {"title" => ""},
  	"QueryParams" => {"properties" => ""},
  	"create" =>  {"template" => "", "title" => "", "properties" => ""}
	}

  before_action :set_card, only: [:show, :edit, :update, :destroy, :set, :get]
  before_action :set_template, only:[:create, :index]

  def index
    begin
      @cards = Lookups.cards_with_properties(action_params)

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
    @card = Card.new(action_params)
    if @card.save
      respond_ok "card", @card
    else
      respond_err "card", @card, @card.errors
    end
  end

	private
    def action_params
      clean_params ParamsTemplate[action_name], params
    end

    def set_template
      template = Template.where(name:params[:template_name])
      if template
        params[:template] = template
      else
        respond_err "card", Card.new, "i18> Template '#{params[:template_name]}' not found."
      end
    end

end
