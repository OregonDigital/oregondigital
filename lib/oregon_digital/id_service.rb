# -*- coding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module OregonDigital
  class IdService
    def self.namespace
      APP_CONFIG.id_namespace
    end
    def self.noid_template
      '.reeddeeddk'
    end
    @minter = ::Noid::Minter.new(template: noid_template)
    @pid = $$
    @semaphore = Mutex.new

    def self.valid?(identifier)
      # remove the fedora namespace since it's not part of the noid
      noid = identifier.split(':').last
      @minter.valid? noid
    end
    def self.namespaceize(pid)
      "#{namespace}:#{pid}"
    end
    def self.noidify(identifier)
      identifier.split(':').last
    end
    def self.create(forcedName)
      raise "#{forcedName} is taken" if ActiveFedora::Base.exists?(forcedName)
      namespaceize(forcedName)
    end
    def self.mint
      while true
        pid = next_id
        return pid unless ActiveFedora::Base.exists?(pid)
      end
    end

    protected

    def self.next_id
      # Seed with process id and time in milliseconds to avoid
      # fork-based collisions and pid-based collisions.  Even if
      # server time gets messed up and pid is repeatable over reboots,
      # the odds of a collision with the exact time and process are
      # very low.
      pid = ''
      File.open(APP_CONFIG.minter_statefile, File::RDWR|File::CREAT, 0644) do |f|
        f.flock(File::LOCK_EX)
        yaml = YAML::load(f.read)
        yaml = {template: noid_template} unless yaml
        minter = ::Noid::Minter.new(yaml)
        pid = namespaceize(minter.mint)
        f.rewind
        yaml = YAML::dump(minter.dump)
        f.write yaml
        f.flush
        f.truncate(f.pos)
      end
      return pid
    end
  end
end
