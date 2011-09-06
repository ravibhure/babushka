module Babushka
  module DSL
    # Use +spec+ to look up a dep. Because +spec+ might include a source
    # prefix, the dep this method returns could be from any of the currently
    # known sources.
    # If no dep matching +spec+ is found, nil is returned.
    def Dep spec, opts = {}
      Base.sources.dep_for(spec, opts) || raise(Babushka::DepNotFound, "Can't find a dep called '#{spec}'.")
    end

    # Define and return a dep named +name+, and whose implementation is found
    # in +block+. This is the usual top-level entry point of the babushka
    # DSL (along with +meta+); templated or not, this is how deps are
    # defined.
    def dep name, opts = {}, &block
      Base.sources.current_load_source.deps.add name, opts, block
    end

    # Define and return a meta dep named +name+, and whose implementation is
    # found in +block+. This method, along with +dep, together are the
    # top level of babushka's DSL.
    def meta name, opts = {}, &block
      Base.sources.current_load_source.templates.add name, opts, block
    end
  end
end
