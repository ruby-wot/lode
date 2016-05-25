#!/usr/bin/env ruby

require 'config_collector'

module Tessellator; end

class Tessellator::Fetcher < Struct.new(:version, :user_agent, :http_redirect_limit, :pages_path)
  VERSION = "9001"

  def initialize(*args, **keyword_args, &block)
    def super_initialize(*args, **keyword_args, &block)
      self.class.superclass.instance_method(:initialize).bind(self).call(*args, **keyword_args, &block)
    end

    # TODO: Possibly make this more automagical?
    def with_argument_list(version, user_agent, http_redirect_limit, pages_path)
      super_initialize(version, user_agent, http_redirect_limit, pages_path)
    end

    def with_optional_kwargs(version: nil, user_agent: nil, http_redirect_limit: nil, pages_path: nil)
      super_initialize(version, user_agent, http_redirect_limit, pages_path)
    end

    def with_required_kwargs(version:, user_agent:, http_redirect_limit:, pages_path:)
      super_initialize(version, user_agent, http_redirect_limit, pages_path)
    end
     
    def with_block(&block)
      super_initialize(*ConfigCollector.call(:version, :user_agent, :http_redirect_limit, :pages_path, &block))
    end

    added_methods =
      [:with_argument_list, :with_optional_kwargs, :with_required_kwargs, :with_block].reduce({}) do |hash, method_name|
        hash[method_name] = method(method_name).parameters

        hash
      end

    def reject_arguments_of_type!(added_methods, type)
      added_methods.reject! {|name, parameters| parameters.map(&:first).include?(type)}
    end

    # If no block is passed, methods that accept blocks are not valid.
    reject_arguments_of_type!(added_methods, :block) if block.nil?

    if keyword_args.empty?
      reject_arguments_of_type!(added_methods, :keyreq)
    else
      # Yay, we have keyword args! Do further checking on them!
    end

    p added_methods

    p method(:with_required_kwargs).parameters
    p method(:with_block).parameters

    #with_block(*args, **keyword_args, &block)
  end
end
 
fetcher = Tessellator::Fetcher.new('1.0', 'Tessellator::Fetcher/1.0', 10, '/path/to/internal/pages') #=> #initialize.with_values
p fetcher

exit

Tessellator::Fetcher.new do |fetcher| #=> #initialize.with_block
  fetcher.version = Tessellator::Fetcher::VERSION
  fetcher.user_agent = "TessellatorFetcher/v#{fetcher.version}"
  fetcher.http_redirect_limit = 10
  fetcher.pages_path = '/path/to/internal/pages'
end
