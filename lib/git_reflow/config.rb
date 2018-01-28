module GitReflow
  module Config
    extend self

    CONFIG_FILE_PATH = "#{ENV['HOME']}/.gitconfig.reflow".freeze

    def get(key, reload: false, all: false, local: false)
      cached_key_value = instance_variable_get(:"@#{key.tr('.-', '_')}")
      reload = true if "#{cached_key_value}".strip.length <= 0
      if reload == false and cached_key_value = instance_variable_get(:"@#{key.tr('.-', '_')}")
        cached_key_value
      else
        local = local ? '--local ' : ''
        if all
          new_value = GitReflow.run "git config #{local}--get-all #{key}", capture: true, verbose: false
        else
          new_value = GitReflow.run "git config #{local}--get #{key}", capture: true, verbose: false
        end
        instance_variable_set(:"@#{key.tr('.-', '_')}", "#{new_value}".strip)
      end
    end

    def set(key, value, local: false)
      value = "#{value}".strip
      if local
        GitReflow.run "git config --replace-all #{key} \"#{value}\"", capture: true, verbose: false
      else
        GitReflow.run "git config -f #{CONFIG_FILE_PATH} --replace-all #{key} \"#{value}\"", capture: true, verbose: false
      end
    end

    def unset(key, value: nil, local: false)
      value = (value.nil?) ? "" : "\"#{value}\""
      if local
        GitReflow.run "git config --unset-all #{key} #{value}", capture: true, verbose: false
      else
        GitReflow.run "git config -f #{CONFIG_FILE_PATH} --unset-all #{key} #{value}", capture: true, verbose: false
      end
    end

    def add(key, value, local: false, global: false)
      if global
        GitReflow.run "git config --global --add #{key} \"#{value}\"", capture: true, verbose: false
      elsif local
        GitReflow.run "git config --add #{key} \"#{value}\"", capture: true, verbose: false
      else
        GitReflow.run "git config -f #{CONFIG_FILE_PATH} --add #{key} \"#{value}\"", capture: true, verbose: false
      end
    end
  end
end
