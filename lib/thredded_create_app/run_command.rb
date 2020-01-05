# frozen_string_literal: true

module ThreddedCreateApp
  module RunCommand
    def run(*args, log: true, run_method: :system)
      if log
        log_command args.length == 1 ? args[0] : Shellwords.shelljoin(args)
      end
      exit 1 unless send(run_method, *args)
    end
  end
end
