# Rakefile to build a project using HUDSON

require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/clean'

PROJ_NAME = "ruby-pdns"
PROJ_FILES = ["pkg/doc", "sbin", "lib", "#{PROJ_NAME}.spec", "etc", "records", "README"]
PROJ_DOC_TITLE = "PDNS - Ruby PDNS Pipe Backend Framework"
PROJ_VERSION = "0.4"
PROJ_RELEASE = "1"
PROJ_RPM_NAMES = [PROJ_NAME]

ENV["RPM_VERSION"] ? CURRENT_VERSION = ENV["RPM_VERSION"] : CURRENT_VERSION = PROJ_VERSION
ENV["BUILD_NUMBER"] ? CURRENT_RELEASE = ENV["BUILD_NUMBER"] : CURRENT_RELEASE = PROJ_RELEASE

CLEAN.include("pkg")

def announce(msg='')
  STDERR.puts "================"
  STDERR.puts msg
  STDERR.puts "================"
end

def init
    FileUtils.mkdir("pkg") unless File.exist?("pkg")
end

desc "Build documentation, tar balls and rpms"
task :default => [:clean, :doc, :archive, :rpm] do
end

# taks for building docs
rd = Rake::RDocTask.new(:doc) { |rdoc|
    announce "Building documentation for #{CURRENT_VERSION}"

    rdoc.rdoc_dir = 'pkg/doc'
    rdoc.template = 'html'
    rdoc.title    = "#{PROJ_DOC_TITLE} version #{CURRENT_VERSION}"
    rdoc.options << '--line-numbers' << '--inline-source' << '--main=Pdns'
}

desc "Create a tarball for this release"
task :archive => [:clean, :doc] do
    announce "Creating #{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.tgz"

    FileUtils.mkdir_p("pkg/#{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}")
    sh %{cp -R #{PROJ_FILES.join(' ')} pkg/#{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}}
    sh %{cd pkg && /bin/tar --exclude .svn -cvzf #{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.tgz #{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}}
end

desc "Creates a RPM"
task :rpm => [:archive] do
    announce("Building RPM for #{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}")

    sourcedir = `/bin/rpm --eval '%_sourcedir'`.chomp
    specsdir = `/bin/rpm --eval '%_specdir'`.chomp
    srpmsdir = `/bin/rpm --eval '%_srcrpmdir'`.chomp
    rpmdir = `/bin/rpm --eval '%_rpmdir'`.chomp
    lsbdistrel = `/usr/bin/lsb_release -r -s|/bin/cut -d . -f1`.chomp
    lsbdistro = `/usr/bin/lsb_release -i -s`.chomp

    case lsbdistro
        when 'CentOS'
            rpmdist = "el#{lsbdistrel}"
        else
            rpmdist = ""
    end

    sh %{cp pkg/#{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.tgz #{sourcedir}}
    sh %{cp #{PROJ_NAME}.spec #{specsdir}}

    sh %{cd #{specsdir} && rpmbuild -D 'version #{CURRENT_VERSION}' -D 'rpm_release #{CURRENT_RELEASE}' -D 'dist .#{rpmdist}' -ba #{PROJ_NAME}.spec}

    sh %{cp #{srpmsdir}/#{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.#{rpmdist}.src.rpm pkg/}

    sh %{cp #{rpmdir}/*/#{PROJ_NAME}*-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.#{rpmdist}.*.rpm pkg/}
end

spec = Gem::Specification.new do |s| 
    s.name = PROJ_NAME
    s.version = "#{CURRENT_VERSION}.#{CURRENT_RELEASE}"
    s.author = "R.I.Pienaar"
    s.email = "rip@devco.net"
    s.homepage = "http://code.google.com/p/ruby-pdns/"
    s.platform = Gem::Platform::RUBY
    s.summary = "Ruby framework for developing PowerDNS backends"
    s.files = FileList["{sbin,lib}/**/*"].to_a
    s.require_path = "lib"
    s.bindir = "sbin"
    s.executables = ["pdns-pipe-runner.rb", "pdns-pipe-tester.rb"]
    s.has_rdoc = true
    s.extra_rdoc_files = ["README"]
end
                             
Rake::GemPackageTask.new(spec) do |pkg| 
    pkg.need_tar = true 
end 

# vi:tabstop=4:expandtab:ai
