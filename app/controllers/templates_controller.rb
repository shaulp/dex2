class TemplatesController < ApplicationController
  ParamsTemplate = {
    "add_property" => {
      "template" => {"id" => "", "name" => ""},
      "property" => {"name" => "", "type" => "", "validation" => ""}
    },
    "delete_property" => {
      "template" => {"id" => "", "name" => ""},
      "property" => {"name" => "", "conf_key" => ""}
    },
    "update_property" => {
      "template" => {"id" => "", "name" => ""},
      "property" => {"name" => "", "type" => "", "validation" => ""}
    },
    "update" => {}
  }

  before_action :set_template, only: [:show, :edit, :update, :destroy, :add_property, :update_property, :delete_property]
  before_action :property_actions, only: [:add_property, :update_property, :delete_property]

  # GET /templates
  # GET /templates.json
  def index
    if params[:name] || params[:id]
      set_template # responds an error if template not found
      respond_ok "template", @template
    else
      @templates = Template.all
      if @templates.any?
        respond_ok "template", @templates.map {|t| t.name}
      else
        respond_err "template", @templates, "i18> No template found"
      end
    end
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
    respond_ok "template", @templates
  end

=begin
  # GET /templates/new
  def new
  end

  # GET /templates/1/edit
  def edit
  end
=end

  # POST /templates
  # POST /templates.json
  def create
    @template = Template.new(template_params)
    if @template.save
      respond_ok "template", @template
    else
      respond_err "template", @template, @template.errors
    end
  end

  # PATCH/PUT /templates/1
  # PATCH/PUT /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    logger.info ">>>> preparing to destroy #{@template.name}"
    if @template.destroy
      logger.info ">>>>>> done."
      respond_ok "template", @template
    else
      logger.info ">>>>>> problems..."
      respond_err "template", @template, @template.errors
    end
  end

  def add_property
  end
  def update_property
  end
  def delete_property
  end
  
  private
    def set_template
      if params[:id]
        tid = Integer(params[:id]) rescue nil
        if tid
          @template = Template.where(id:tid)[0] rescue nil
        else
          @template = Template.where(name:params[:id])[0] rescue nil
        end
      elsif params[:name]
        @template = Template.where(name:params[:name])[0] rescue nil
      end
          
      if @template
        logger.info ">>>>> Fetched template #{@template.name}"
      else
        respond_err "template", @templates, "i18> Cannot find template identiier in #{params} or template not found"
      end
    end

    def action_params
      clean_params ParamsTemplate[action_name], params
    end

    def property_actions
      @template.errors.clear
      @template.send action_name, action_params["property"]
      if @template.errors.empty?
        if @template.save
          respond_ok "template", @template
          return
        end
      end
      respond_err "template", @template, @template.errors.messages
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:name)
    end
end
