module Babushka
  module UriHelpers

    def prepare_uri uri
      uri = uri.call if uri.respond_to?(:call)
      URI.parse(URI.escape(URI.unescape(uri)))
    end

    def process_sources &block
      source.map {|uri|
        prepare_uri(uri)
      }.tap {|sources|
        Dep('balls').meet if sources.map(&:scheme).include?('git')
      }.map {|uri|
        handle_source uri, &block
      }
    end

    def handle_source uri, &block
      uri = prepare_uri(uri) unless uri.is_a?(URI)
      case uri.scheme
      when 'git'
        git uri, &block
      when 'http', 'https', 'ftp', nil # We let `curl` work out the protocol if it's nil.
        Resource.extract uri, &block
      else
        log_error "Babushka can't handle #{uri.scheme}:// URLs yet. But it can if you write a patch! :)"
      end
    end

  end
end
