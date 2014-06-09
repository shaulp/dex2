class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  def clean_params(params_model ,actual_params)
    tmp_params = actual_params.select {|k| params_model.has_key? k}
    tmp_params.each_pair do |k,v|
      if params_model[k].is_a? Hash
        if v.is_a? Hash
          clean_params params_model[k], v            
        else
          tmp_params.delete k
        end
      end
    end
    tmp_params
  end

  def respond_ok(type, object, options=nil)
    respond_to do |format|
      format.html { render object}
      format.json { render json: json_ok_response(type, object, options) }
    end
  end

  def respond_err(type, object, msg)
    respond_to do |format|
      format.html { render object}
      format.json { render json: json_error_response(type, msg) }
    end
  end

  def json_error_response(object_type ,messages)
    {"status" => "error", object_type.to_s => messages}.to_json
  end
  def json_ok_response(object_type, object, options=nil)
    {"status" => "ok", object_type.to_s => object}.to_json(options)
  end

end
