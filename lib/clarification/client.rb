module Clarification
  class Client

    attr_reader :active_models, :search, :train, :predict

    def initialize
      raise "No Configuration Found." if Clarification.configuration.nil?
      @active_models = convert_config_models_to_model_hash(Clarification.configuration.default_public_models)
      @search = Search.new
      @train = Train.new
      @predict = Predict.new(@active_models)
    end

    # A convenience method to quickly set public models as the active models of a client.
    # 
    # @param model_name_array [Array] an array of public model names. eg. [:food, :general]
    # @return [Predict] the newly initialized Predict object.
    # @example
    #   client.set_active_models_by_public_key([:food, :general])
    def set_active_models_by_public_key(model_name_array)
      if model_name_array.class != Array
        raise "Clarification expects an array of model keys."
      end
      
      name_check = model_name_array - Clarification::PUBLIC_MODELS.keys
      unless name_check.empty?
        raise "#{name_check} models are not recognized.  Check Clarification::PUBLIC_MODELS"
      end

      @active_models = convert_config_models_to_model_hash(model_name_array)
      @predict = Predict.new(@active_models)
    end

    # Set the models that the client will process against.
    # 
    # @param model_hash [Hash] A hash containing the name of the model as the key and the id as the value.
    # @return [Array] active_models
    def set_active_models_from_hash(model_hash)
      models = []
      model_hash.each do |key, value|
        models << Model.new(name: key, id: value)
      end
      @active_models = models
      @predict = Predict.new(@active_models)
    end

    def set_active_models(models)
      @active_models = models
      @predict = Predict.new(@active_models)
    end

    private
    def convert_config_models_to_model_hash(model_names)
      model_names.each.with_object([]) do |key, model_array|
        model_array << Model.new(name: key, id: Clarification::PUBLIC_MODELS[key])
      end
    end 
    
  end
end
