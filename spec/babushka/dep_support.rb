def setup_yield_counts
  @yield_counts = Hash.new {|hsh,k| hsh[k] = Hash.new {|hsh,k| 0 } }

  @yield_counts_none = {}
  @yield_counts_met_run = {:setup => 1, :met? => 1}
  @yield_counts_meet_run = {:setup => 1, :met? => 2, :prepare => 1, :before => 1, :meet => 1, :after => 1}
  @yield_counts_dep_failed = {:setup => 1}
  @yield_counts_failed_meet_run = {:setup => 1, :met? => 2, :prepare => 1, :before => 1, :meet => 1, :after => 1}
  @yield_counts_early_exit_meet_run = {:setup => 1, :met? => 1, :prepare => 1, :before => 1, :meet => 1}
  @yield_counts_already_met = {:setup => 1, :met? => 1}
  @yield_counts_failed_at_before = {:setup => 1, :met? => 2, :prepare => 1, :before => 1}
end

def make_counter_dep opts = {}
  incrementers = DepContext.accepted_blocks.inject({}) {|lambdas,key|
    lambdas[key] = L{ @yield_counts[opts[:name]][key] += 1 }
    lambdas
  }
  dep opts[:name] do
    requires opts[:requires]
    requires_when_unmet opts[:requires_when_unmet]
    DepContext.accepted_blocks.each {|dep_method|
      send dep_method do
        incrementers[dep_method].call
        (opts[dep_method] || default_block_for(dep_method)).call
      end
    }
  end
end

def make_order_dep dep_name, opts = {}
  list = []

  [opts[:requires], opts[:requires_when_unmet]].each {|requirement|
    dep requirement do
      met? { list << "#{name} / met?" }
    end if requirement
  }

  dep dep_name do
    requires opts[:requires]
    requires_when_unmet opts[:requires_when_unmet]
    DepContext.accepted_blocks.each {|dep_method|
      send dep_method do
        list << "#{name} / #{dep_method}"
        (opts[dep_method] || default_block_for(dep_method)).call
      end
    }
  end

  list
end
